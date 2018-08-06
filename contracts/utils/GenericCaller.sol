pragma solidity ^0.4.22;

import "../IDaoBase.sol";

import "../governance/Voting.sol";
import "../governance/Proposals.sol";

import "../utils/ConversionLib.sol";

import "zeppelin-solidity/contracts/ownership/Ownable.sol";


/**
 * @title GenericCaller
 * @dev This is a wrapper that help us to do action that CAN require votings
 * WARNING: should be permitted to add new proposal by the current DaoBase!!!
*/
contract GenericCaller is DaoClient, Ownable {
	struct VotingParams {
		Voting.VotingType votingType;
		bytes32 param1;
		bytes32 param2;
		bytes32 param3;
		bytes32 param4;
		bytes32 param5;
	}

	mapping (bytes32=>VotingParams) votingParams;

	event GenericCaller_DoActionDirectly(bytes32 _permissionId, address _target, address _origin, string _methodSig);
	event GenericCaller_CreateNewProposal(bytes32 _permissionId, address _target, address _origin, string _methodSig);
	event ContractCreated(address newAddress);

/////
	constructor(IDaoBase _dao)public
		// DaoClient (for example) helps us to handle DaoBase upgrades
		// and will automatically update the 'dao' to the new instance
		DaoClient(_dao)
	{
		emit ContractCreated(this);
	}

	// _actionId is something like "issueTokens"
	// _methodSig some kind of "issueTokens(bytes32[])"
	function doAction(bytes32 _permissionId, address _target, address _origin, string _methodSig, bytes32[] _params) internal returns(address proposalOut) {
		if(dao.isCanDoAction(msg.sender, _permissionId)) {
			emit GenericCaller_DoActionDirectly(_permissionId, _target, _origin, _methodSig);

			// 1 - call immediately
			if(!address(_target).call(
				bytes4(keccak256(_methodSig)),
				uint256(32),						 // pointer to the length of the array
				uint256(_params.length),		 // length of the array
				_params)){
				revert();
			}

			return 0x0;
		}else {
			// 2 - create a proposal + voting first  
			emit GenericCaller_CreateNewProposal(_permissionId, _target, _origin, _methodSig);

			// _origin is the initial msg.sender (just like tx.origin) 
			GenericProposal prop = new GenericProposal(_target, _origin, _methodSig, _params);

			IVoting voting = createVoting(_permissionId, prop, _origin);
			prop.setVoting(voting);

			// WARNING: should be permitted to add new proposal by the current contract address!!!
			// check your permissions or see examples (tests) how to do that correctly
			dao.addNewProposal(prop);
			return prop;
		}
	}

	// address _origin, uint _minutesToVote,
	// uint _quorumPercent, uint _consensusPercent, VotingType _votingType,
	// string _groupName, address _tokenAddress
	function setVotingParams(bytes32 _permissionIdHash, uint _votingType, 
		bytes32 _param1, bytes32 _param2, 
		bytes32 _param3, bytes32 _param4, bytes32 _param5) public onlyOwner {
		VotingParams memory params;
		params.votingType = Voting.VotingType(_votingType);
		params.param1 = _param1;
		params.param2 = _param2;
		params.param3 = _param3;
		params.param4 = _param4;
		params.param5 = _param5;

		votingParams[_permissionIdHash] = params;
	}

	function createVoting(bytes32 _permissionIdHash, IProposal _proposal, address _origin)public returns(IVoting) {
		VotingParams memory vp = votingParams[_permissionIdHash];

		IVoting V = new Voting(
			dao, 
			_proposal, 
			_origin, 
			vp.votingType,
			uint(vp.param1), 
			ConversionLib.bytes32ToString(vp.param2),
			uint(vp.param3), 
			uint(vp.param4),
			address(vp.param5)
		);

		return V;
	}
}

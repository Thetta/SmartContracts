pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

import "../IDaoBase.sol";
import "../governance/IVoting.sol";

/**
 * @title GenericProposal 
 * @dev This is the implementation of IProposal interface. Each Proposal should have voting attached. 
 * This is an auto proposal that is used by GenericCaller to call actions on a _target 
 * Used by GenericCaller, DaoBaseAuto, MoneyflowAuto, etc
*/
contract GenericProposal is IProposal, Ownable {
	IVoting voting;

	address target;
	string methodSig;
	bytes32[] params;

	constructor(address _target, address _origin, string _methodSig, bytes32[] _params) public {
		target = _target;
		params = _params;
		methodSig = _methodSig;
		if(_origin==0x0) {
			revert();
		}
	}

	event GenericProposal_Action(IVoting _voting, address _target, string _methodSig, bytes32[] _params);

// IVoting implementation
	function action() public {
		emit GenericProposal_Action(voting, target, methodSig, params);

		// in some cases voting is still not set
		if(0x0!=address(voting)) {
			require(msg.sender==address(voting));
		}

		// cool! voting is over and the majority said YES -> so let's go!
		// as long as we call this method from WITHIN the vote contract 
		// isCanDoAction() should return yes if voting finished with Yes result
		if(!address(target).call(
			bytes4(keccak256(methodSig)),
			uint256(32),				// pointer to the length of the array
			uint256(params.length), // length of the array
			params)
		){
			// revert();
		}
	}

	function setVoting(IVoting _voting) public onlyOwner {
		voting = _voting;
	}

	function getVoting() public view returns(IVoting) {
		return voting;
	}

	function getMethodSig() public view returns(string) {
		return methodSig;
	}

	function getParams() public view returns(bytes32[]) {
		return params;
	}
}
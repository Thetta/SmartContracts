pragma solidity ^0.4.22;

import "./IDaoBase.sol";
import "./DaoBase.sol";
import "./ImpersonationCaller.sol";
import "./utils/UtilsLib.sol";

// TODO: convert to library?


/**
 * @title DaoBaseImpersonated 
 * @dev This contract is a helper that will call the action is not allowed directly (by the current user) on behalf of the other user.
 * It is calling it really without any 'delegatecall' so msg.sender will be DaoBaseImpersonated, not the original user!
 * 
 * WARNING: As long as this contract is just an ordinary DaoBase client -> you should provide permissions to it 
 * just like to any other account/contract. So you should give 'manageGroups', 'issueTokens', etc to the DaoBaseImpersonated! 
 * Please see 'tests' folder for example.
*/
contract DaoBaseImpersonated is ImpersonationCaller {
	constructor(IDaoBase _dao)public 
		ImpersonationCaller(_dao)
	{
	}

	function issueTokensImp(bytes32 _hash, bytes _sig, address _token, address _to, uint _amount) public {
		bytes32[] memory params = new bytes32[](3);
		params[0] = bytes32(_token);
		params[1] = bytes32(_to);
		params[2] = bytes32(_amount);

		doActionOnBehalfOf(
			_hash, 
			_sig, 
			DaoBase(dao).ISSUE_TOKENS(), 
			"issueTokensGeneric(bytes32[])", 
			params
		);
	}

	function upgradeDaoContractImp(bytes32 _hash, bytes _sig, address _newMc) public {
		bytes32[] memory params = new bytes32[](1);
		params[0] = bytes32(_newMc);

		doActionOnBehalfOf(
			_hash, 
			_sig, 
			DaoBase(dao).UPGRADE_DAO_CONTRACT(), 
			"upgradeDaoContractGeneric(bytes32[])", 
			params
		);
	}

	function addGroupMemberImp(bytes32 _hash, bytes _sig, string _group, address _a) public {
		bytes32[] memory params = new bytes32[](2);
		params[0] = UtilsLib.stringToBytes32(_group);
		params[1] = bytes32(_a);

		doActionOnBehalfOf(
			_hash, 
			_sig, 
			DaoBase(dao).MANAGE_GROUPS(), 
			"addGroupMemberGeneric(bytes32[])", 
			params
		);
	}

	function removeGroupMemberImp(bytes32 _hash, bytes _sig, string _groupName, address _a) public {
		bytes32[] memory params = new bytes32[](2);
		params[0] = UtilsLib.stringToBytes32(_groupName);
		params[1] = bytes32(_a);

		doActionOnBehalfOf(
			_hash, 
			_sig, 
			DaoBase(dao).REMOVE_GROUP_MEMBER(), 
			"removeGroupMemberGeneric(bytes32[])", 
			params
		);
	}

	function allowActionByShareholderImp(bytes32 _hash, bytes _sig, bytes32 _what, address _tokenAddress) public {
		bytes32[] memory params = new bytes32[](2);
		params[0] = _what;
		params[1] = bytes32(_tokenAddress);

		doActionOnBehalfOf(
			_hash, 
			_sig, 
			DaoBase(dao).ALLOW_ACTION_BY_SHAREHOLDER(), 
			"allowActionByShareholderGeneric(bytes32[])", 
			params
		);
	}

	function allowActionByVotingImp(bytes32 _hash, bytes _sig, bytes32 _what, address _tokenAddress) public {
		bytes32[] memory params = new bytes32[](2);
		params[0] = _what;
		params[1] = bytes32(_tokenAddress);

		doActionOnBehalfOf(
			_hash, 
			_sig, 
			DaoBase(dao).ALLOW_ACTION_BY_VOTING(), 
			"allowActionByVotingGeneric(bytes32[])", 
			params
		);
	}

	function allowActionByAddressImp(bytes32 _hash, bytes _sig, bytes32 _what, address _a) public {
		bytes32[] memory params = new bytes32[](2);
		params[0] = _what;
		params[1] = bytes32(_a);

		doActionOnBehalfOf(
			_hash, 
			_sig, 
			DaoBase(dao).ALLOW_ACTION_BY_ADDRESS(), 
			"allowActionByAddressGeneric(bytes32[])", 
			params
		);
	}

	function allowActionByAnyMemberOfGroupImp(bytes32 _hash, bytes _sig, bytes32 _what, string _groupName) public {
		bytes32[] memory params = new bytes32[](2);
		params[0] = _what;
		params[1] = UtilsLib.stringToBytes32(_groupName);

		doActionOnBehalfOf(
			_hash, 
			_sig, 
			DaoBase(dao).ALLOW_ACTION_BY_ANY_MEMBER_OF_GROUP(), 
			"allowActionByAnyMemberOfGroupGeneric(bytes32[])", 
			params
		);
	}
}



pragma solidity ^0.4.22;

import "./utils/UtilsLib.sol";

import "./DaoBase.sol";

/**
 * @title DaoBaseWithUnpackers
 * @dev Use this contract instead of DaoBase if you need DaoBaseAuto.
 * It features method unpackers that will convert bytes32[] params to the method params.
 *
 * When DaoBaseAuto will creates voting/proposal -> it packs params into the bytes32[] 
 * After voting is finished -> target method is called and params should be unpacked
*/
contract DaoBaseWithUnpackers is DaoBase {
	constructor(DaoStorage _daoStorage) public DaoBase(_daoStorage){
	}

	function upgradeDaoContractGeneric(bytes32[] _params) external {
		IDaoBase _b = IDaoBase(address(_params[0]));
		upgradeDaoContract(_b);
	}

	function addGroupMemberGeneric(bytes32[] _params) external {
		string memory _groupName = UtilsLib.bytes32ToString(_params[0]);
		address a = address(_params[1]);
		addGroupMember(_groupName, a);
	}

	function issueTokensGeneric(bytes32[] _params) external {
		address _tokenAddress = address(_params[0]);
		address _to = address(_params[1]);
		uint _amount = uint(_params[2]);
		issueTokens(_tokenAddress, _to, _amount);
	}

	function removeGroupMemberGeneric(bytes32[] _params) external {
		string memory _groupName = UtilsLib.bytes32ToString(_params[0]);
		address _a = address(_params[1]);
		removeGroupMember(_groupName, _a);
	}

	function allowActionByShareholderGeneric(bytes32[] _params) external {
		bytes32 _what = bytes32(_params[0]);
		address _a = address(_params[1]);
		allowActionByShareholder(_what, _a);
	}

	function allowActionByVotingGeneric(bytes32[] _params) external {
		bytes32 _what = bytes32(_params[0]);
		address _tokenAddress = address(_params[1]);
		allowActionByVoting(_what, _tokenAddress);
	}

	function allowActionByAddressGeneric(bytes32[] _params) external {
		bytes32 _what = bytes32(_params[0]);
		address _a = address(_params[1]);
		allowActionByAddress(_what, _a);
	}
 
	function allowActionByAnyMemberOfGroupGeneric(bytes32[] _params) external {
		bytes32 _what = bytes32(_params[0]);
		string memory _groupName = UtilsLib.bytes32ToString(_params[1]);
		allowActionByAnyMemberOfGroup(_what, _groupName);
	}
}

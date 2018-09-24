pragma solidity ^0.4.22;

import "./IMoneyflow.sol";

import "./ether/WeiExpense.sol";
import "./ether/WeiAbsoluteExpense.sol";

import "../utils/GenericCaller.sol";


/**
 * @title MoneyflowAuto 
 * @dev This contract is a helper that will create new Proposal (i.e. voting) if the action is not allowed directly.
 * This is completely optional.
 *
 * WARNING: As long as this contract is just an ordinary DaoBase client -> you should provide permissions to it 
 * just like to any other account/contract. So you should give 'withdrawDonations', 'setRootWeiReceiver', etc to the MoneyflowAuto! 
 * Please see 'tests' folder for example.
*/
contract MoneyflowAuto is GenericCaller {
	IMoneyflow mf;

	//bytes32 constant public WITHDRAW_DONATIONS = keccak256("withdrawDonations");
	bytes32 constant public WITHDRAW_DONATIONS = 0xfc685f51f68cb86aa29db19c2a8f4e85183375ba55b5e56fb2e89adc5f5e4285;
	//bytes32 constant public SET_ROOT_WEI_RECEIVER = keccak256("setRootWeiReceiver");
	bytes32 constant public SET_ROOT_WEI_RECEIVER = 0xcb02529cf7b85f6f804884cd47d35cf58a3ffbee0b87a019fe725b688923c627;

	constructor(IDaoBase _daoBase, IMoneyflow _mf) public 
		GenericCaller(_daoBase)
	{
		mf = _mf;
	}

	/*
	// TODO:
	// this is moved to Scheme!
	function addNewTaskAuto(WeiAbsoluteExpense _wt) public returns(address voteOut){
		bytes32[] memory params = new bytes32[](1);
		params[0] = bytes32(address(_wt));

		return doAction("addNewTask", mf, msg.sender,"addNewTaskGeneric(bytes32[])",params);
	}
   */

	function setRootWeiReceiverAuto(WeiAbsoluteExpense _wt) public returns(address voteOut) {
		bytes32[] memory params = new bytes32[](1);
		params[0] = bytes32(address(_wt));

		return doAction(
			SET_ROOT_WEI_RECEIVER, 
			mf, 
			msg.sender,
			"setRootWeiReceiverGeneric(bytes32[])",
			params
		);
	}

	function withdrawDonationsToAuto(address _wt) public returns(address voteOut) {
		bytes32[] memory params = new bytes32[](1);
		params[0] = bytes32(_wt);

		return doAction(
			WITHDRAW_DONATIONS, 
			mf, 
			msg.sender,
			"withdrawDonationsToGeneric(bytes32[])",
			params
		);
	}
}

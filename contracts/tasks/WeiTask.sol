pragma solidity ^0.4.23;

import "./WeiGenericTask.sol";


/**
 * @title WeiTask 
 * @dev Can be prepaid or postpaid. 
*/
contract WeiTask is WeiGenericTask {

	bytes32 constant public START_TASK = keccak256("startTask");

	constructor(IDaoBase _daoBase, string _caption, string _desc, bool _isPostpaid, bool _isDonation, uint _neededWei, uint64 _deadlineTime, uint64 _timeToCancell) public 
		WeiGenericTask(_daoBase, _caption, _desc, _isPostpaid, _isDonation, _neededWei, _deadlineTime, _timeToCancell) 
	{
	}

	// callable by any Employee of the current DaoBase or Owner
	// employee should call this function when for starting the task
	/**
	* @notice This function should be called only by account with START_TASK permissions
	* @param _employee employee of this task
	* @dev starts task 
	*/
	function startTask(address _employee) public isCanDo(START_TASK) {
		require(getCurrentState() == State.Init || getCurrentState() == State.PrePaid);

		if(getCurrentState() == State.Init) {
			// can start only if postpaid task 
			require(isPostpaid);
		}
		
		startTime = block.timestamp;
		employee = _employee;
		state = State.InProgress;
		emit WeiGenericTaskStateChanged(state);
	}
}
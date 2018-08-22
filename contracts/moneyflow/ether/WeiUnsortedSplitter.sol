pragma solidity ^0.4.23;

import "./SplitterBase.sol";


/**
 * @title WeiUnsortedSplitter 
 * @dev Will split money (order does not matter!). 
*/
contract WeiUnsortedSplitter is SplitterBase, IWeiReceiver {
	event ConsoleUint(string a, uint b);

	constructor(string _name) SplitterBase(_name) public {
	}

	// IWeiReceiver:
	// calculate only absolute outputs, but do not take into account the Percents
	function getMinWeiNeeded()public view returns(uint) {
		if(!isOpen()) {
			return 0;
		}

		uint absSum = 0;
		uint percentsMul100ReverseSum = 10000;

		for(uint i=0; i<childrenCount; ++i) {
			if(0!=IWeiReceiver(children[i]).getPercentsMul100()) {
				percentsMul100ReverseSum -= IWeiReceiver(children[i]).getPercentsMul100();
			}else {
				absSum += IWeiReceiver(children[i]).getMinWeiNeeded();
			}
		}

		if(percentsMul100ReverseSum==0) {
			return 0;
		}else {
			return 10000*absSum/percentsMul100ReverseSum;
		}		
	}

	function getTotalWeiNeeded(uint _inputWei)public view returns(uint) {
		if(!isOpen()) {
			return 0;
		}

		uint total = 0;
		for(uint i=0; i<childrenCount; ++i) {
			IWeiReceiver c = IWeiReceiver(children[i]);
			uint needed = c.getTotalWeiNeeded(_inputWei);
			total = total + needed;
		}
		return total;
	}

	function getPercentsMul100()public view returns(uint) {
		uint total = 0;
		for(uint i=0; i<childrenCount; ++i) {
			IWeiReceiver c = IWeiReceiver(children[i]);
			total = total + c.getPercentsMul100();
		}

		// truncate, no more than 100% allowed!
		if(total>10000) {
			return 10000;
		}
		return total;
	}

	function isNeedsMoney()public view returns(bool) {
		if(!isOpen()) {
			return false;
		}

		for(uint i=0; i<childrenCount; ++i) {
			IWeiReceiver c = IWeiReceiver(children[i]);
			// if at least 1 child needs money -> return true
			if(c.isNeedsMoney()) {
				return true;
			}
		}
		return false;
	}

	// WeiSplitter allows to receive money from ANY address
	// WeiSplitter should not hold any funds. Instead - it should split immediately
	// If WeiSplitter receives less or more money than needed -> exception 
	function processFunds(uint _currentFlow) public payable {
		require(isOpen());
		emit SplitterBaseProcessFunds(msg.sender, msg.value, _currentFlow);
		uint amount = msg.value;

		// TODO: can remove this line?
		// transfer below will throw if not enough money?
		require(amount>=getTotalWeiNeeded(_currentFlow));

		// DO NOT SEND LESS!
		// DO NOT SEND MORE!
		for(uint i=0; i<childrenCount; ++i) {
			IWeiReceiver c = IWeiReceiver(children[i]);
			uint needed = c.getTotalWeiNeeded(_currentFlow);

			// send money. can throw!
			// we sent needed money but specifying TOTAL amount of flow
			// this help relative Splitters to calculate how to split money
			if(needed>0) {
				c.processFunds.value(needed)(_currentFlow);
			}		
		}	

		if(this.balance>0) {
			revert();
		}	
	}

	function() public {
	}
}
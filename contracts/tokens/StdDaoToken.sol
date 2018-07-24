pragma solidity ^0.4.22;

import "zeppelin-solidity/contracts/token/ERC20/PausableToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";

import "./CopyOnWriteToken.sol";
import "./ITokenVotingSupport.sol";
import "../DaoBase.sol";

/**
 * @title StdDaoToken 
 * @dev Currently DaoBase works only with StdDaoToken. It does not support working with 
 * plain ERC20 tokens because we need some extra features like mint(), burn() and transferOwnership()
 *
 * EVERY token that is used on Thetta should support these operations:
 * ERC20:
 *		balanceOf() 
 *		transfer() 
 *
 * Non ERC20:
 *		transferOwnership()
 *		mintFor()
 *		burnFor()
 *    startNewVoting()
 *    finishVoting()
 *    getBalanceAtVoting() 
*/
contract StdDaoToken is DetailedERC20, PausableToken, CopyOnWriteToken, DaoBase, ITokenVotingSupport {
	uint256 public cap;
	bool isBurnable;
	bool isPausable;

	address[] public holders;
	mapping (address => bool) isHolder;
	mapping (uint => address) votingCreated;

	bytes32 public TOKEN_StartNewVoting = keccak256(abi.encodePacked("TOKEN_StartNewVoting"));

	modifier isBurnable_() { 
		require (isBurnable); 
		_; 
	}

	modifier isPausable_() { 
		require (isPausable);
		_; 
	}

	event VotingStarted(address indexed _address, uint _votingID);
	event VotingFinished(address indexed _address, uint _votingID);
	
	constructor(string _name, string _symbol, uint8 _decimals, bool _isBurnable, bool _isPausable, uint256 _cap) public
		DetailedERC20(_name, _symbol, _decimals)
	{
		require(_cap > 0);
		cap = _cap;
		isBurnable = _isBurnable;
		isPausable = _isPausable;

		holders.push(this);
	}

// ITokenVotingSupport implementation
	// TODO: VULNERABILITY! no onlyOwner!
	function startNewVoting(address _voting) public whenNotPaused isCanDo(TOKEN_StartNewVoting) returns(uint) {
		uint idOut = super.startNewEvent();
		votingCreated[idOut] = _voting;
		emit VotingStarted(msg.sender, idOut);
		return idOut;
	}

	// TODO: VULNERABILITY! no onlyOwner!
	function finishVoting(uint _votingID) whenNotPaused public {
		require (msg.sender == votingCreated[_votingID]);
		
		super.finishEvent(_votingID);
		emit VotingFinished(msg.sender, _votingID);
	}

	function getBalanceAtVoting(uint _votingID, address _owner) public view returns (uint256) {
		return super.getBalanceAtEventStart(_votingID, _owner);
	}

// 
	function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
		if(!isHolder[_to]){
			holders.push(_to);
			isHolder[_to] = true;
		}
		return super.transfer(_to, _value);
	}

	function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
		if(!isHolder[_to]){
			holders.push(_to);
			isHolder[_to] = true;
		}
		return super.transferFrom(_from, _to, _value);
	}

	function getVotingTotalForQuadraticVoting() public view returns(uint){
		uint votersTotal = 0;
		for(uint k=0; k<holders.length; k++){
			votersTotal += sqrt(this.balanceOf(holders[k]));
		}
		return votersTotal;
	}
	
// MintableToken override
	// @dev do not call this method. Instead use mintFor()
	function mint(address _to, uint256 _amount) canMint onlyOwner public returns(bool){
		revert();
	}

	function mintFor(address _to, uint256 _amount) canMint onlyOwner public returns(bool){
		require(totalSupply_.add(_amount) <= cap);

		if(!isHolder[_to]){
			holders.push(_to);
			isHolder[_to] = true;
		}
		return super.mint(_to, _amount);
	}

// BurnableToken override
	// @dev do not call this method. Instead use burnFor()
   function burn(uint256 _value) public {
		revert();
   }

	function burnFor(address _who, uint256 _value) isBurnable_ onlyOwner public{
		super._burn(_who, _value);
	}

	// this is an override of PausableToken method
	function pause() isPausable_ onlyOwner public{
		super.pause();
	}

	// this is an override of PausableToken method
	function unpause() isPausable_ onlyOwner  public{
		super.unpause();
	}

	function sqrt(uint x) internal pure returns (uint y) {
		uint z = (x + 1) / 2;
		y = x;
		while (z < y) {
			y = z;
			z = (x / z + z) / 2;
		}
	}
}

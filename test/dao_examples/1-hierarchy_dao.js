var DaoBaseWithUnpackers = artifacts.require("./DaoBaseWithUnpackers");
var StdDaoToken = artifacts.require("./StdDaoToken");
var DaoStorage = artifacts.require("./DaoStorage");
var DaoBaseWithUnpackers = artifacts.require("./DaoBaseWithUnpackers");

var IDaoBase = artifacts.require("./IDaoBase");
var AacFactory = artifacts.require("./AacFactory");
var AutoDaoBaseActionCaller = artifacts.require("./AutoDaoBaseActionCaller");

// DAO factories
var HierarchyDaoFactory = artifacts.require("./HierarchyDaoFactory"); 

var CheckExceptions = require('../utils/checkexceptions');

function KECCAK256 (x){
	return web3.sha3(x);
}

global.contract('HierarchyDaoFactory', (accounts) => {
	let token;
	let store;
	let daoBase;

	const creator = accounts[0];

	const boss = accounts[1];
	const employee1 = accounts[2];
	const employee2 = accounts[3];
	const employee3 = accounts[4];
	const employee4 = accounts[5];

	const manager1 = accounts[6];
	const manager2 = accounts[7];

	global.beforeEach(async() => {

	});

	/*
	global.it('should create Boss -> Managers -> Employees hierarchy',async() => {
		let token = await StdDaoToken.new("StdToken","STDT",18,{from: creator});
		//await token.mint(creator, 1000);
		let store = await DaoStorage.new(token.address,{gas: 10000000, from: creator});
		let daoBase = await DaoBaseWithUnpackers.new(store.address,{gas: 10000000, from: creator});
		let aacInstance = await AutoDaoBaseActionCaller.new(daoBase.address, {from: creator});

		{
			// add creator as first employee	
			await store.allowActionByAddress(KECCAK256("manageGroups"),creator);

			// do not forget to transfer ownership
			await token.transferOwnership(daoBase.address);
			await store.transferOwnership(daoBase.address);

			await daoBase.addGroup("Employees");
			await daoBase.addGroup("Managers");

			// 1 - grant all permissions to the boss (i.e. "the monarch")
			await daoBase.addGroupMember("Managers", boss);
			await daoBase.addGroupMember("Employees", boss);
			await daoBase.allowActionByAddress("modifyMoneyscheme",boss);
			await daoBase.allowActionByAddress("issueTokens", boss);
			await daoBase.allowActionByAddress("upgradeDaoContract", boss);
			await daoBase.allowActionByAddress("withdrawDonations", boss);
			await daoBase.allowActionByAddress("flushReserveFundTo", boss);
			await daoBase.allowActionByAddress("flushDividendsFundTo", boss);

			// 2 - set Managers group permissions
			await daoBase.allowActionByAnyMemberOfGroup("addNewProposal","Managers");
			await daoBase.allowActionByAnyMemberOfGroup("addNewTask","Managers");
			await daoBase.allowActionByAnyMemberOfGroup("startTask","Managers");
			await daoBase.allowActionByAnyMemberOfGroup("startBounty","Managers");

			// 3 - set Employees group permissions 
			await daoBase.allowActionByAnyMemberOfGroup("startTask","Employees");
			await daoBase.allowActionByAnyMemberOfGroup("startBounty","Employees");

			// 4 - the rest is by voting only (requires addNewProposal permission)
			// so accessable by Managers only even with voting
			await daoBase.allowActionByVoting("manageGroups", token.address);
			await daoBase.allowActionByVoting("modifyMoneyscheme", token.address);

			// 5 - set the auto caller
			const VOTING_TYPE_1P1V = 1;
			//const VOTING_TYPE_SIMPLE_TOKEN = 2;
			await aacInstance.setVotingParams("manageGroups", VOTING_TYPE_1P1V, (24 * 60), KECCAK256("Managers"), 0);
			await aacInstance.setVotingParams("modifyMoneyscheme", VOTING_TYPE_1P1V, (24 * 60), KECCAK256("Managers"), 0);

			await daoBase.allowActionByAddress("addNewProposal", aacInstance.address);
			await daoBase.allowActionByAddress("manageGroups", aacInstance.address);
			await daoBase.allowActionByAddress("modifyMoneyscheme", aacInstance.address);
		}

		// Now populate groups
		await daoBase.addGroupMember("Managers", manager1);
		await daoBase.addGroupMember("Managers", manager2);

		await daoBase.addGroupMember("Employees", employee1);
		await daoBase.addGroupMember("Employees", employee2);
		await daoBase.addGroupMember("Employees", employee3);
		await daoBase.addGroupMember("Employees", employee4);
	});
	*/

	global.it('should create Boss -> Managers -> Employees hierarchy',async() => {
		let hdf = await HierarchyDaoFactory.new({gas: 10000000, from: creator});

		let mgrs = [manager1, manager2];
		let empls = [employee1, employee2];
		await hdf.createDao(boss, mgrs, empls, {from: creator});
		
		const daoAddress = await hdf.daoBase();
		const daoBase = await IDaoBase.at(daoAddress);

		let af = await AacFactory.new({gas: 10000000, from: creator});
		await af.setupAac(daoBase.address, {from: creator});

		const aacAddress = await af.aac();
		const aac = await AutoDaoBaseActionCaller.at(aacAddress);

		/*
		let aacInstance = await AutoDaoBaseActionCaller.new(daoBase.address, {from: creator});

		// set the auto caller
		const VOTING_TYPE_1P1V = 1;
		await aacInstance.setVotingParams("manageGroups", VOTING_TYPE_1P1V, (24 * 60), KECCAK256("Managers"), 0);
		await aacInstance.setVotingParams("modifyMoneyscheme", VOTING_TYPE_1P1V, (24 * 60), KECCAK256("Managers"), 0);

		await daoBase.allowActionByAddress("addNewProposal", aacInstance.address);
		await daoBase.allowActionByAddress("manageGroups", aacInstance.address);
		await daoBase.allowActionByAddress("modifyMoneyscheme", aacInstance.address);
		*/
	});
});


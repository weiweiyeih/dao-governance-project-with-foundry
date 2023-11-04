// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployDaoBox} from "../script/DeployDaoBox.s.sol";
import {GovernanceToken} from "../src/GovernanceToken.sol";
import {TimeLock} from "../src/governance_standard/TimeLock.sol";
import {GovernorContract} from "../src/governance_standard/GovernorContract.sol";
import {Box} from "../src/Box.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DaoBoxTest is Test {
    DeployDaoBox public deployer;
    GovernanceToken public governanceToken;
    TimeLock public timeLock;
    GovernorContract public governorContract;
    Box public box;

    address[] public targets;
    uint256[] public values;
    bytes[] public calldatas;

    address public PLAYER = makeAddr("PLAYER");

    function setUp() external {
        deployer = new DeployDaoBox();
        (governanceToken, timeLock, governorContract, box) = deployer.run();

        // self-delegating
        // https://docs.openzeppelin.com/contracts/5.x/governance#cast_a_vote
        vm.prank(msg.sender);
        governanceToken.delegate(msg.sender);
    }

    function testCantUpdateBoxWithoutGovernance(uint256 newValue) public {
        vm.prank(PLAYER);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, PLAYER));
        box.store(newValue);
    }

    function testGovernanceUpdatesBo() public {
        uint256 newValue = 77;
        bytes memory calldataOfStore77 = abi.encodeWithSignature("store(uint256)", newValue);
        // 0x6057361d000000000000000000000000000000000000000000000000000000000000004d;

        targets.push(address(box));
        values.push(0);
        calldatas.push(calldataOfStore77);
        string memory description = "store 77";

        // 1. Propose
        uint256 proposalId = governorContract.propose(targets, values, calldatas, description);

        // the Proposal State is an enum data type, defined in the IGovernor contract.
        // 0:Pending, 1:Active, 2:Canceled, 3:Defeated, 4:Succeeded, 5:Queued, 6:Expired, 7:Executed
        uint256 stateBeforeVotingDelay = uint256(governorContract.state(proposalId));
        console.log("stateBeforeVotingDelay: ", stateBeforeVotingDelay);
        assertEq(stateBeforeVotingDelay, 0);

        uint256 votingDelay = governorContract.votingDelay();
        vm.roll(block.number + uint32(votingDelay) + 1);

        uint256 stateAfterVotingDelay = uint256(governorContract.state(proposalId));
        console.log("stateAfterVotingDelay: ", stateAfterVotingDelay);
        assertEq(stateAfterVotingDelay, 1);

        // 2. Vote
        // 0 = Against, 1 = For, 2 = Abstain for this example
        uint8 support = 1;
        string memory reason = "I like 77.";

        vm.prank(msg.sender); // delegatee
        governorContract.castVoteWithReason(proposalId, support, reason);

        uint256 stateBeforeVotingPeriod = uint256(governorContract.state(proposalId));
        console.log("stateBeforeVotingPeriod: ", stateBeforeVotingPeriod);

        uint256 votingPeriod = governorContract.votingPeriod();
        vm.roll(block.number + uint48(votingPeriod) + 1);

        uint256 stateAfterVotingPeriod = uint256(governorContract.state(proposalId));
        console.log("stateAfterVotingPeriod: ", stateAfterVotingPeriod);

        // 3. Queue
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governorContract.queue(targets, values, calldatas, descriptionHash);

        uint256 stateAfterQueued = uint256(governorContract.state(proposalId));
        console.log("stateAfterQueued: ", stateAfterQueued);

        uint256 minDelay = timeLock.getMinDelay();
        vm.warp(block.timestamp + minDelay + 1);

        // 4. Execute
        governorContract.execute(targets, values, calldatas, descriptionHash);
        uint256 stateAfterExecute = uint256(governorContract.state(proposalId));
        console.log("stateAfterExecute: ", stateAfterExecute);

        assert(box.retrieve() == newValue);
    }
}

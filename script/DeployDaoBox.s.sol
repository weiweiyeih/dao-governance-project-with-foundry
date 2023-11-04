// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 1. Deploy GovernanceToken.sol
// 2. Deploy TimeLock.sol
// 3. Deploy GovernorContract.sol
// 4. Set up GovernorContract
// 5. Deploy Box.sol aka. the contract we want to governor over,
//    and transferOwnership() to TimeLock.sol

import {Script} from "forge-std/Script.sol";
import {GovernanceToken} from "../src/GovernanceToken.sol";
import {TimeLock} from "../src/governance_standard/TimeLock.sol";
import {GovernorContract} from "../src/governance_standard/GovernorContract.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {Box} from "../src/Box.sol";

contract DeployDaoBox is Script {
    GovernanceToken public governanceToken;
    TimeLock public timeLock;
    GovernorContract public governorContract;
    Box public box;

    uint256 public constant MIN_DELAY = 3600; // 3600 seconds == 1 hr
    uint32 public constant VOTING_PERIOD = 5; // 5 blocks
    uint48 public constant VOTING_DELAY = 1; // 1 blocks
    uint256 public constant QUORUM_PERCENTAGE = 4; // 4% of voters need to vote
    address public constant ADDRESS_ZERO = address(0); // give the admin role to nobody == everybody
    address[] public ADDRESSES_ZERO;

    function run() external returns (GovernanceToken, TimeLock, GovernorContract, Box) {
        vm.startBroadcast();
        // 1. Deploy
        governanceToken = new GovernanceToken();
        timeLock = new TimeLock(MIN_DELAY, ADDRESSES_ZERO, ADDRESSES_ZERO);
        governorContract =
        new GovernorContract(IVotes(address(governanceToken)), TimelockController(timeLock), VOTING_DELAY,  VOTING_PERIOD, QUORUM_PERCENTAGE);

        // 2. Set up the roles
        bytes32 proposerRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();
        bytes32 adminRole = timeLock.DEFAULT_ADMIN_ROLE();

        timeLock.grantRole(proposerRole, address(governorContract)); // proposer == GovernorContract
        timeLock.grantRole(executorRole, ADDRESS_ZERO); // everyone can execute
        timeLock.revokeRole(adminRole, msg.sender); // no one owns TimeLock.sol

        // 3. TransferOwnerShip
        box = new Box();
        box.transferOwnership(address(timeLock));

        vm.stopBroadcast();

        return (governanceToken, timeLock, governorContract, box);
    }
}

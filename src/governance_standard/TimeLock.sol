// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract TimeLock is TimelockController {
    /**
     *
     * @param minDelay how long you have to wait before executing
     * @param proposers the list of addresses that can propose (in our case, evevryone can)
     * @param executors who can execute when a proposal passes (in our case, again, everyone)
     */
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors)
        TimelockController(minDelay, proposers, executors, msg.sender)
    {}
}

# DAO Governance Project with Foundry

This GitHub repository contains smart contracts written in Solidity with [Foundry](https://getfoundry.sh/) for a decentralized governance system. The repository includes the following contracts, which extend the [OpenZeppelin contracts 5.x](https://docs.openzeppelin.com/contracts/5.x/governance):

- **GovernanceToken.sol**: This contract represents an ERC20 token with additional features for voting and permit. It allows token holders to participate in governance processes.

- **Box.sol**: This contract allows the owner to store and retrieve a single unsigned integer value.

- **GovernorContract.sol**: This contract is basically configured with the [Openzeppelin Wizard](https://docs.openzeppelin.com/contracts/5.x/wizard). It provides a comprehensive governance solution, including voting, vote counting, vote quorum, timelock control, and proposal management functionalities.

- **TimeLock.sol**: This contract allows for the execution of proposals with a minimum delay and provides control over who can propose and execute proposals.

## Table of Content

- [DAO Governance Project with Foundry](#dao-governance-project-with-foundry)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
- [Usage](#usage)
  - [Test](#test)
  - [Deploy](#deploy)
- [License](#license)
- [Acknowledgments](#acknowledgments)

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [foundry](https://getfoundry.sh/)

## Quickstart

```bash
git clone https://github.com/weiweiyeih/dao-governance-project-with-foundry.git
forge install
forge build
```

# Usage

## Test

```
forge test -vv
```

## Deploy

This will default to your local Anvil node. You need to have it running in another terminal in order for it to deploy.

```
forge script script/DeployDaoBox.s.sol:DeployDaoBox --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast
```

# License

This project is licensed under the MIT License.

# Acknowledgments

- https://github.com/PatrickAlphaC/dao-template/tree/main

- https://github.com/ThomasHeim11/Foundry-DAO-Governance/tree/main

- https://docs.openzeppelin.com/contracts/5.x/governance

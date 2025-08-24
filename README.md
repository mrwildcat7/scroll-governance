# Scroll Governance Token Example

This project demonstrates a basic governance token and voting system using [Foundry](https://book.getfoundry.sh/) and OpenZeppelin's ERC20 implementation.

## Features

- **SimpleVotingToken**: An ERC20 token with built-in proposal and voting logic.
- **Proposal System**: Token holders can create proposals and vote for or against them.
- **Token Locking**: After voting, tokens are locked until the proposal's deadline, preventing transfers and double voting.

## Getting Started

### 1. Install Dependencies

Install OpenZeppelin contracts at a specific version:

```sh
forge install OpenZeppelin/openzeppelin-contracts@v4.9.0
```

### 2. Build & Test

Build the contracts:

```sh
forge build
```

Run all tests:

```sh
forge test
```

Run a specific test:

```sh
forge test --match-test <testName>
```

### 3. Deploy

#### Prepare a Keystore

Import your private key into a keystore for secure management.  
**Your address must have funds on Scroll Sepolia testnet.**

```sh
cast wallet import Deployer --interactive
```

Follow the prompts to enter your private key and set a password.  
Your address will be displayed after successful import.

#### Deploy the Governance Token Contract

Use Foundry's script to deploy:

```sh
forge script script/DeployGovernance.s.sol \
  --rpc-url https://scroll-sepolia.drpc.org \
  --broadcast \
  --account Deployer \
  --sender <your_address>
```

### 4. Interact with the Contract

#### Create a Proposal

```sh
cast send <contract_address> "propose(string,uint256)" "Your proposal text" <deadline_timestamp> --account Deployer --rpc-url https://scroll-sepolia.drpc.org
```

#### Cast a Vote

```sh
cast send <contract_address> "castVote(uint256,bool)" <proposal_id> true --account Deployer --rpc-url https://scroll-sepolia.drpc.org
```

### 5. Verify the Contract

Verify your contract on ScrollScan (Blockscout):

```sh
forge verify-contract <contract_address> src/GovernanceMRW.sol:SimpleVotingToken \
  --compiler-version v0.8.30+commit.73712a01 \
  --chain 534351 \
  --etherscan-api-key <API-KEY>
```

Replace `<contract_address>`, `<your_address>`, `<API-KEY>`, and other placeholders as needed.

## Contract Overview

### SimpleVotingToken

- Inherits from OpenZeppelin's ERC20.
- On deployment, mints all tokens to the deployer (can be set to any address using `vm.prank` in tests).
- Proposals are created with a name and deadline.
- Voting is restricted to one vote per address per proposal, and only within the proposal's deadline.
- After voting, tokens are locked (cannot be transferred) until the proposal's deadline.

#### Key Functions

- `propose(string name, uint deadline)`: Create a new proposal.
- `castVote(uint proposalId, bool voteFor)`: Vote for or against a proposal. Locks tokens until deadline.

#### Key State Variables

- `mapping(address => uint) blocked`: Tracks when an address's tokens are locked after voting.
- `mapping(uint => Proposal) proposals`: Stores proposals.

## Example Tests

See `test/GovernanceMRW.t.sol` for:

- Minting and supply checks
- Voting and proposal creation
- Reverts when voting twice or after deadline
- Reverts when transferring tokens after voting

## References

- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)

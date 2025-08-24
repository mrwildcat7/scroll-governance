// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

//import {ERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/ERC20.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract SimpleVotingToken is ERC20 {
    event ProposalCreated(uint proposalId, string name, uint deadline);
    event VoteCast(address voter, uint proposalId, bool voteFor, uint weight);

    struct Proposal {
        string name;
        uint deadline;
        uint forVotes;
        uint againstVotes;
    }

    mapping (uint proposalId => Proposal) public proposals;
    uint public proposalCount;
    mapping (address account => uint deadline) public blocked;

    constructor() ERC20("MrWildcatToken", "MRW") {
        _mint(msg.sender, 21_000_000 ether);
    }

    function propose(string memory name, uint deadline) public {
        proposalCount += 1;
        proposals[proposalCount] = Proposal(name, deadline, 0, 0);
        emit ProposalCreated(proposalCount, name, deadline);
    }

    function castVote(uint proposalId, bool voteFor) public {
        require(blocked[msg.sender] < block.timestamp, "Can't vote twice");
        require(proposals[proposalId].deadline >= block.timestamp, "Voting period is over");
        blocked[msg.sender] = proposals[proposalId].deadline;
        if(voteFor)
        {
            proposals[proposalId].forVotes += balanceOf(msg.sender);
        } else {
            proposals[proposalId].againstVotes += balanceOf(msg.sender);
        }
        emit VoteCast(msg.sender, proposalId, voteFor, balanceOf(msg.sender));
    }

    function _beforeTokenTransfer(address from, address to, uint amount)
        internal virtual override
    {
        require(blocked[from] < block.timestamp, "Tokens are blocked");
        super._beforeTokenTransfer(from, to, amount);
    }
}
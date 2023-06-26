// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract VerifyBytes {
    function verify(
        bytes memory message,
        bytes memory signature,
        address messageSigner
    ) external pure returns (bool) {
        bytes32 messageHash = keccak256(message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, signature) == messageSigner;
    }

    function getEthSignedMessageHash(bytes32 messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    messageHash
                )
            );
    }

    function recover(bytes32 ethSignedMessageHash, bytes memory signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = _split(signature);
        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory signature)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(signature.length == 65, "Invalid signature length");
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }
}

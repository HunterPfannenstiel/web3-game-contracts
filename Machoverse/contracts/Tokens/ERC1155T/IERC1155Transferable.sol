// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IERC1155Transferable is IERC1155 {
    /**
     * @dev Grants or revokes permission to transfer 'amount' of 'tokenId' according to 'canTransfer'
     *
     * Requirements:
     *
     * - msg.sender must own 'tokenId' or be approved
     */
    function setTransferable(
        address user,
        uint256 tokenId,
        uint256 amount,
        bool canTransfer
    ) external;

    /**
     * @dev Returns true if 'amount' of 'tokenId' can be transfered
     *
     * See {setTransferable}
     */
    function isTransferable(
        address user,
        uint256 tokenId,
        uint256 amount
    ) external view returns (bool);

    /**
     * @dev Allows users to revoke the transferable status of their token if it was set by a contract that is no longer approved
     */
    function revokeTransferable(uint256 tokenId, address revokedContract)
        external;

    /**
     * @dev Allows for contracts to be whitelisted so they can change the transferable status of tokens
     */
    function setContractApproval(address contractAddress, bool approve)
        external;
}

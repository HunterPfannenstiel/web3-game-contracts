// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721Transferable is IERC721 {
    /**
     * @dev Grants or revokes permission to transfer 'tokenId' according to 'canTransfer'
     *
     * Requirements:
     *
     * - msg.sender must be approved
     */
    function setTransferable(uint256 tokenId, bool canTransfer) external;

    /**
     * @dev Returns true if 'tokenId' can be transfered
     *
     * See {setTransferable}
     */
    function isTransferable(uint256 tokenId) external view returns (bool);

    /**
     * @dev Allows users to revoke the transferable status of their token if it was set by a contract that is no longer approved
     */
    function revokeTransferable(uint256 tokenId) external;

    /**
     * @dev Allows for contracts to be whitelisted so they can change the transferable status of tokens
     */
    function setContractApproval(address contractAddress, bool approve)
        external;
}

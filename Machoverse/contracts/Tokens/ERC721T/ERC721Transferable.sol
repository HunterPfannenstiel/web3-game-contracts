// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC721Transferable.sol";

/**
  * @dev Extension of {ERC721} that allows tokens to be classified as 'transferable' or 'non-transferable'

  * @notice Many contracts implement a 'staking' functionality for ERC tokens. When a token is staked, it is often the case that it should not be transferable.
  * The typical solution to this has been to transfer that token to a 'staking' contract so the user is not able to transfer it. This puts the token
  * at risk if the contract gets compromised in any way. To fix this, we can classify tokens as either 'transferable' or 'non-transferable' to prevent
  * token transfers, as well as provide a way for other contracts to tell if a specific token will be able to be transfered or not. 
 */
contract ERC721Transferable is Ownable, ERC721, IERC721Transferable {
    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {}

    /// @notice Used to check if a token is transferable
    mapping(uint256 => bool) internal _isTransferable;

    /// @notice Used to track which contracts have been approved to change the transferable status of tokens, maps: contract address to bool
    mapping(address => bool) internal _isApprovedContract;

    /// @notice Used to determine which contract changed the transferable status of a token, maps: tokenId to contract that changed the transferable status
    mapping(uint256 => address) internal _transferableOwner;

    /** @dev Changes the transferable status of 'tokenId'
     * @param tokenId The tokenId that needs it's transferable status updated
     * @param canTransfer Determines whether or not 'tokenId' is transferable
     */
    function setTransferable(uint256 tokenId, bool canTransfer)
        public
        virtual
        override
    {
        require(
            _isApprovedContract[msg.sender],
            "ERC721Transferable: You do not have permission to set transferable status"
        );

        if (canTransfer) {
            require(
                _transferableOwner[tokenId] == msg.sender,
                "ERC721Transferable: Cannot change the transferable status of a token set by another contract"
            );
            delete _transferableOwner[tokenId];
        } else {
            require(
                _isTransferable[tokenId],
                "ERC721Transferable: Token is already non-transferable"
            );
            _transferableOwner[tokenId] = msg.sender;
        }
        _isTransferable[tokenId] = canTransfer;
    }

    /** @dev Determines if a tokenId is transferable
     * @param tokenId The tokenId to check the status of
     */
    function isTransferable(uint256 tokenId)
        public
        view
        override
        returns (bool)
    {
        return _isTransferable[tokenId];
    }

    /** @dev Allows users to reclaim the transferable status on their tokens if it was set by a contract that is no longer approved
     * @param tokenId The tokenId to reclaim transferable status for
     */
    function revokeTransferable(uint256 tokenId) public virtual override {
        require(
            !_isTransferable[tokenId],
            "ERC721Transferable: Token is already transferable"
        );
        require(
            !_isApprovedContract[_transferableOwner[tokenId]],
            "ERC721Transferable: Cannot revoke transferable status from a contract that is approved"
        );
        _isTransferable[tokenId] = true;
        delete _transferableOwner[tokenId];
    }

    /** @dev Allows for contracts to be whitelisted so they can change the transferable status of tokens
     * @param contractAddress The contract address to change the approval status for
     * @param approve The approval status for the contract address (true means the contract is approved to set token transferable status)
     */
    function setContractApproval(address contractAddress, bool approve)
        external
        virtual
        override
        onlyOwner
    {
        require(
            _isApprovedContract[contractAddress] != approve,
            "ERC721Transferable: Contract is already set to desired approval status."
        );
        _isApprovedContract[contractAddress] = approve;
    }

    /** @dev Ensures that a token is transferable before being transfered
     * @param from Address of the owner of the token
     * @param to Address of the recipient
     * @param tokenId The tokenId to be transfered
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override {
        if (from != address(0)) {
            require(
                _isTransferable[tokenId],
                "ERC721Transferable: Token cannot be transferred"
            );
        }
        if (from == address(0)) {
            _isTransferable[tokenId] = true;
        }
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}

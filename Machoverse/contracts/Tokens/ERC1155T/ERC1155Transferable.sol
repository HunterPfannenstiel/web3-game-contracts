// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC1155Transferable.sol";

/**
  * @dev Extension of {ERC1155} that allows tokens to be classified as 'transferable' or 'non-transferable'

  * @notice Many contracts implement a 'staking' functionality for ERC tokens. When a token is staked, it is often the case that it should not be transferable.
  * The typical solution to this has been to transfer that token to a 'staking' contract so the user is not able to transfer it. This puts the tokens
  * at risk if the contract gets compromised in any way. To fix this, we can classify tokens as either 'transferable' or 'non-transferable' to prevent
  * token transfers, as well as provide a way for other contracts to tell if a specific token will be able to be transfered or not. 
 */
contract ERC1155Transferable is Ownable, ERC1155, IERC1155Transferable {
    constructor(string memory uri_) ERC1155(uri_) {}

    /// @notice Used to check a user's tokenId to see how much of it is not allowed to be transfered, maps: user address to tokenId to non-transferable amount
    mapping(address => mapping(uint256 => uint256)) internal _notTransferable;

    /// @notice Used to track which contracts have been approved to change the transferable status of tokens, maps: contract address to bool
    mapping(address => bool) internal _isApprovedContract;

    /// @notice Used to track which contracts have changed the transferable status a user's tokens, maps: contract address to user address to tokenId to amount
    mapping(address => mapping(address => mapping(uint256 => uint256))) _transferableOwner;

    /**
     * @dev Changes the transferable status of 'tokenId' by 'amount'.
     * @notice Ensures that the user's does not have more 'non-transferable' tokens than their actual balance
     * @param user The address of the user to update the transferable tokens for
     * @param tokenId The tokenId that needs it's transferable status updated
     * @param amount The amount of 'tokenId' that needs to be updated
     * @param canTransfer Determines whether the tokens are going to be non-transferable or transferable
     */
    function setTransferable(
        address user,
        uint256 tokenId,
        uint256 amount,
        bool canTransfer
    ) external virtual override {
        require(
            _isApprovedContract[msg.sender],
            "ERC1155Transferable: Not approved to set transfer status."
        );
        if (canTransfer) {
            require(
                _transferableOwner[msg.sender][user][tokenId] >= amount,
                "ERC1155Transferable: Non-transferable amount too small compared to given amount."
            );

            _notTransferable[user][tokenId] -= amount;
            _transferableOwner[msg.sender][user][tokenId] -= amount;
        } else {
            require(
                balanceOf(user, tokenId) - _notTransferable[user][tokenId] >=
                    amount,
                "ERC1155Transferable: Cannot make non-transferable amount greater than amount of tokens owned."
            );
            _notTransferable[user][tokenId] += amount;
            _transferableOwner[msg.sender][user][tokenId] += amount;
        }
    }

    /** @dev Determines if 'amount' of 'tokenId' is able to be transfered or not
        @param tokenId the tokenId to check the status of
        @param amount the amount that wants to be transfered
        @param user the address of the user that wants to transfer
        @return bool whether or not 'amount' of 'tokenId' can be transfered from 'user'
     */
    function isTransferable(
        address user,
        uint256 tokenId,
        uint256 amount
    ) public view virtual override returns (bool) {
        return
            (balanceOf(user, tokenId) - _notTransferable[user][tokenId]) >=
            amount;
    }

    /** @dev Allows users to reclaim the transferable status on their tokens if it was set by a contract that is no longer approved
     * @param tokenId The tokenId to reclaim transferable status for
     * @param revokedContract The address of a contract that is no longer approved
     */
    function revokeTransferable(uint256 tokenId, address revokedContract)
        external
        virtual
        override
    {
        require(
            !_isApprovedContract[revokedContract],
            "ERC1155Transferable: Cannot revoke transferable status from a contract that is approved."
        );
        uint256 amount = _transferableOwner[revokedContract][msg.sender][
            tokenId
        ];
        require(
            amount > 0,
            "ERC1155Transferable: There are no tokens to revoke."
        );
        _notTransferable[msg.sender][tokenId] -= amount;
        _transferableOwner[revokedContract][msg.sender][tokenId] -= amount;
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
            "ERC1155Transferable: Contract is already set to desired approval status."
        );
        _isApprovedContract[contractAddress] = approve;
    }

    /** @dev Ensures all of the tokens that are wanting to be transfered are allowed to be transfered
     * @param from The user that is transfering tokens
     * @param to The recipient of the tokens
     * @param ids The array of all tokenIds to be transfered
     * @param amounts The array of corresponding amounts to be transfered
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        if (from != address(0)) {
            for (uint256 i = 0; i < ids.length; ) {
                require(
                    isTransferable(from, ids[i], amounts[i]),
                    "ERC1155Transferable: At least one tokenId was not allowed to transfer with the specified amount."
                );

                unchecked {
                    i += 1;
                }
            }
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}

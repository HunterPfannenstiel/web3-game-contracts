// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Tokens/ERC1155T/ERC1155Transferable.sol";
import "./VerifyBytes.sol";

contract Machoverse is ERC1155Transferable {
    constructor(address _messageSigner, address _verificationAddress)
        ERC1155Transferable("")
    {
        messageSigner = _messageSigner;
        verificationContract = VerifyBytes(_verificationAddress);
    }

    address public messageSigner;

    VerifyBytes public verificationContract;

    mapping(address => mapping(uint256 => bool)) private _accountNonces;

    mapping(uint256 => string) private _tokenURI;

    event MintClaimed(address account, uint256 nonce);

    event GameMint(address account, uint256[] ids, uint256[] amounts);

    function mintTokens(bytes memory message, bytes memory signature) external {
        require(
            verificationContract.verify(message, signature, messageSigner),
            "MachoVerse: Invalid minting message!"
        );
        (
            address minter,
            uint256 validTill,
            uint256 nonce,
            uint256[] memory ids,
            uint256[] memory amounts
        ) = decodeClaimInfo(message);
        require(msg.sender == minter, "MachoVerse: This is not your mint.");
        require(
            !_accountNonces[msg.sender][nonce],
            "MachoVerse: This mint has already been claimed."
        );
        require(
            block.timestamp < validTill,
            "MachoVerse: This mint has expired, please create another mint."
        );
        _accountNonces[msg.sender][nonce] = true;
        _mintBatch(msg.sender, ids, amounts, "");
        emit MintClaimed(msg.sender, nonce);
    }

    function decodeClaimInfo(bytes memory message)
        internal
        pure
        returns (
            address,
            uint256,
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {
        return
            abi.decode(
                message,
                (address, uint256, uint256, uint256[], uint256[])
            );
    }

    function mintToGame(uint256[] memory ids, uint256[] memory amounts)
        external
    {
        _burnBatch(msg.sender, ids, amounts);
        emit GameMint(msg.sender, ids, amounts);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return _tokenURI[tokenId];
    }

    function changeMessageSigner(address newSigner) external onlyOwner {
        messageSigner = newSigner;
    }

    function updateTokenURI(uint256 tokenId, string memory _uri)
        external
        onlyOwner
    {
        _tokenURI[tokenId] = _uri;
    }
}

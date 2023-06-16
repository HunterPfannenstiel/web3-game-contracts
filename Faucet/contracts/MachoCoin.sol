// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MachoCoin is ERC1155, Ownable {
    mapping(uint256 => string) private _tokenURI;
    mapping(uint256 => bool) private _tokenCreated;
    address private _faucetContract;

    constructor() ERC1155("") {}

    function updateFaucetAddress(address faucetAddress) public onlyOwner {
        _faucetContract = faucetAddress;
    }

    function createToken(string memory tokenURI, uint256 tokenId)
        public
        onlyOwner
    {
        require(
            !_tokenCreated[tokenId],
            "MachoCoin: Token already exists. To update the URI, call updateURI."
        );
        _tokenCreated[tokenId] = true;
        _tokenURI[tokenId] = tokenURI;
    }

    function updateURI(string memory newURI, uint256 tokenId) public onlyOwner {
        require(
            _tokenCreated[tokenId],
            "MachoCoin: Token does not exist. To create a new token, call createToken."
        );
        _tokenURI[tokenId] = newURI;
    }

    function mint(uint256 tokenId) public {
        require(
            msg.sender == _faucetContract,
            "MachoCoin: Please mint through the faucet"
        );
        require(_tokenCreated[tokenId], "MachoCoin: Token does not exist.");
        _mint(tx.origin, tokenId, 1000, "");
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return _tokenURI[tokenId];
    }
}

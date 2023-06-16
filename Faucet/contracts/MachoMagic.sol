// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MachoMagic is ERC20, Ownable {
    address private _faucetContract;

    constructor() ERC20("Macho Magic", "MM") {}

    function updateFaucetAddress(address faucetAddress) public onlyOwner {
        _faucetContract = faucetAddress;
    }

    function mint() public {
        require(
            msg.sender == _faucetContract,
            "MachoMagic: Please mint through the faucet"
        );
        _mint(tx.origin, 1000 ether); //Mint 1000 tokens
    }
}

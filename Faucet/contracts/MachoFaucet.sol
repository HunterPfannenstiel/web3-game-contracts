// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "./MachoUSD.sol";
import "./MachoMagic.sol";
import "./MachoCoin.sol";

contract MachoFaucet {
    MachoUSD machoUSD;
    MachoMagic machoMagic;
    MachoCoin machoCoin;

    constructor(
        address _machoUSD,
        address _machoMagic,
        address _machoCoin
    ) {
        machoUSD = MachoUSD(_machoUSD);
        machoMagic = MachoMagic(_machoMagic);
        machoCoin = MachoCoin(_machoCoin);
    }

    function mintMachoUSD() public {
        machoUSD.mint();
    }

    function mintMachoMagic() public {
        machoMagic.mint();
    }

    function mintMachoCoin(uint256 tokenId) public {
        machoCoin.mint(tokenId);
    }
}

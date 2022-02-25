// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestCoin is ERC20 {

    constructor(address _mintAddress) ERC20("Synapse", "SYN") {
        _mint(_mintAddress, 100000);
    }
}
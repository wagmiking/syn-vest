//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "./Vest.sol";

contract VestFactory {
    address private owner;
    /*
    One beneficiary can have multiple vesting contracts - we maintain a mapping of beneficiary -> all vesting contracts in `vestingContracts`
    */
    mapping(address => Vest[]) public vestingContracts;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can perform this action");
        _;
    }

    //call this function to deploy a new vesting contract
    function createVestingContract(
        address _owner,
        address _beneficiary,
        uint256 _vestDuration,
        uint256 _cliffPeriod,
        bool _revocable
    ) public onlyOwner {
        Vest vestingContract = new Vest(
            _owner,
            _beneficiary,
            _vestDuration,
            _cliffPeriod,
            _revocable
        );
        vestingContracts[_beneficiary].push(vestingContract);
    }
}

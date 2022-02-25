//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "./Vest.sol";

contract VestFactory {
    address private owner;

    // One beneficiary can have multiple vesting contracts
    // keep track via a mapping of beneficiary -> all vesting contracts in `vestingContracts`
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
        address _tokenToDistribute,
        uint256 _vestDuration,
        uint256 _cliffPeriod,
        uint256 _numTokensToDistribute,
        bool _revocable
    ) public onlyOwner {
        Vest vestingContract = new Vest(
            _owner,
            _beneficiary,
            _tokenToDistribute,
            _vestDuration,
            _cliffPeriod,
            _numTokensToDistribute,
            _revocable
        );
        vestingContracts[_beneficiary].push(vestingContract);
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Vest.sol";

contract VestFactory {
    address private owner;
<<<<<<< HEAD
    Vest[] public vestingContracts;
=======

    // One beneficiary can have multiple vesting contracts
    // keep track via a mapping of beneficiary -> all vesting contracts in `vestingContracts`
    mapping(address => Vest[]) public vestingContracts;
>>>>>>> 0aa2c1f (Initial commit)

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
<<<<<<< HEAD
        uint256 _tokenAmount,
        uint256 _timePeriodToVest,
=======
        address _tokenToDistribute,
>>>>>>> 0aa2c1f (Initial commit)
        uint256 _vestDuration,
        uint256 _cliffPeriod,
        uint256 _numTokensToDistribute,
        bool _revocable
    ) public onlyOwner {
        Vest vestingContract = new Vest(
            _owner,
            _beneficiary,
<<<<<<< HEAD
            _tokenAmount,
            _timePeriodToVest,
=======
            _tokenToDistribute,
>>>>>>> 0aa2c1f (Initial commit)
            _vestDuration,
            _cliffPeriod,
            _numTokensToDistribute,
            _revocable
        );
        vestingContracts.push(vestingContract);
    }
}

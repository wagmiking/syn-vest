//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// The vesting schedule is time-based (i.e. using block timestamps as opposed to e.g. block numbers), and is
// therefore sensitive to timestamp manipulation (which is something miners can do, to a certain degree). Therefore,
// it is recommended to avoid using short time durations (less than a minute). Typical vesting schemes, with a
// cliff period of a year and a duration of four years, are safe to use.

contract Vest {
    //address who created the vesting contract (i.e. SYN multisig)
    address private owner;

    //address who's receiving the vested tokens
    address public beneficiary;

<<<<<<< HEAD
    uint256 public tokenAmount; // total token amounts in 10**18 decimals
    uint256 public timePeriodToVest; // duration in unix time seconds
    uint256 public cliffPeriod; // time in unix time seconds
=======
    // this is the address of the ERC-20 token you'd like to distribute to the beneficiary of the vesting contract
    address public tokenToDistribute;

    //this is the length of the vesting contract in seconds (i.e. 1 month is 2419200 seconds)
>>>>>>> 0aa2c1f (Initial commit)
    uint256 public vestDuration;

    //period beneficiary must wait until vesting begins
    uint256 public cliffPeriod; // time in unix time seconds

    //total number of tokens to emit to the beneficiary over the entire vest duration
    uint256 public numTokensToDistribute;

    //TODO: do you want Vest frequency? (i.e. pay out per day / week / month rather than seconds)

    //block timestamp of when the contract is deployed
    uint256 public start;

    //number of tokens that have been vested thus far
    uint256 public releasedTokens;

    // whether the vesting contract is cancellable after it has been deployed or not
    bool public revocable;

    //whether the vesting contract has received the initial token supply to disburse
    bool public active;

    //a mapping to keep track of how many tokens have already  been released to a given address
    mapping (address => uint256) public released;


    //this event is emitted when tokens are vested
    event Released(uint256 amount, address beneficiary);

    //this event is emmitted when a vesting contract is seeded with tokens to vest
    event Activated(uint256 amount, address beneficiary);

    //this event is emitted when a vesting contract is revoked
    event TokenVestingRevoked(address contractAddress);

    //this creates the tokenVest contract, and ensures:
    // whether the cliff period is bad
    // whether the duration is bad

    constructor(
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
    ) {
        owner = _owner;
        beneficiary = _beneficiary;
        tokenAmount = _tokenAmount;
        timePeriodToVest = _timePeriodToVest;
        vestDuration = _vestDuration;
        cliffPeriod = _cliffPeriod;
        require(_beneficiary != address(0), "Call cannot come from 0 address.");

        require(
            cliffPeriod < vestDuration,
            "Cliff period must not be longer than vesting contract duration."
        );
        require(duration > 0, "TokenVesting: duration is <= 0");
        numTokensToDistribute = _numTokensToDistribute;
        tokenToDistribute = _tokenToDistribute;
        revocable = _revocable;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can perform this action");
        _;
    }

<<<<<<< HEAD
    function releaseToken(address _token) public onlyOwner {
        require(IERC20(_token).balanceOf(this) > 0, "no more tokens available");
        
        uint256 amountToRelease = releaseableAmount(_token);
        releasedTokens += amountToRelease; // change state before transfer to prevent reentrancy

        (bool success, ) = IERC20(_token).safeTransfer(beneficiary, amountToRelease);
        require(success);

        Released(amountToRelease);
=======
    //this modifier checks if a vesting contract  has been seeded with an initial token deposit
    modifier onlyActive() {
        require(
            active == true,
            "only an active, seeded contract can perform this action"
        );
        _;
    }

    // call this function to begin a vest - vesting contracts are inactive until they have tokens to release
    function depositInitialTokens(uint256 _amount) public onlyOwner {
        bool success = IERC20(tokenToDistribute).transfer(
            address(this),
            _amount
        );
        require(success);

        active = true;
        start = block.timestamp;
        cliffPeriod = start.add(cliffPeriod);
>>>>>>> 0aa2c1f (Initial commit)
    }

    // call this function to stop vesting tokens for a given vesting contract
    // only callable by the contract owner (i.e. the SYN multisig who delegate-called the factory)
    // emits a TokenVestingRevoked event identifying  which contract was revoked
    function revoke() public onlyOwner {
        require(revocable);

<<<<<<< HEAD
        uint256 balance = IERC20(_token).balanceOf(this);
        uint256 unreleased = releaseableAmount(_token);
        uint256 refund = balance - unreleased;

        (bool success, ) = IERC20(_token).safeTransfer(owner, refund);
=======
        uint256 balance = IERC20(tokenToDistribute).balanceOf(address(this));
        uint256 unreleased = releaseableAmount(tokenToDistribute);
        uint256 refund = balance - unreleased;

        bool success = IERC20(tokenToDistribute).transfer(owner, refund);
>>>>>>> 0aa2c1f (Initial commit)
        require(success);
        emit TokenVestingRevoked(address(this));
    }

    //TODO: still fixing functionality  of releaseToken

    function releaseToken() public onlyOwner onlyActive {
        require(
            IERC20(tokenToDistribute).balanceOf(address(this)) > 0,
            "no more tokens available to vest"
        );

        uint256 amountToRelease = releaseableAmount(tokenToDistribute);
        releasedTokens += amountToRelease; // change state before transfer to prevent reentrancy

        bool success = IERC20(tokenToDistribute).transfer(
            beneficiary,
            amountToRelease
        );
        require(success);

        emit Released(amountToRelease, beneficiary);
    }


    function vestedAmount(ERC20Basic token) public returns (uint256) {
        uint256 currentBalance = tokenToDistribute.balanceOf(this);
        uint256 totalBalance = currentBalance.add(released[token]);

        if (now < cliff) {
        return 0;
        } else if (now >= start.add(duration) || revoked[token]) {
        return totalBalance;
        } else {
        return totalBalance.mul(now.sub(start)).div(duration);
        }
    }







    ///////////////
    /// Helpers ///
    ///////////////

<<<<<<< HEAD
    function releaseableAmount(address _token) public returns (uint256) {
        return vestedAmount(_token) - releasedTokens;
=======
    //returns the amount of tokens that are still up for vesting
    function vestableAmount(address _token) public view returns (uint256) {
        return tokensToDistribute - vestedAmount(_token);
    }

    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     * @param _token ERC20 token which is being vested
     */
    function releasableAmount(address _token) public view returns (uint256) {
        return vestedAmount(_token).sub(_released[address(token)]);
>>>>>>> 0aa2c1f (Initial commit)
    }

    function vestedAmount(address _token) public returns (uint256) {
        uint256 currentBalance = IERC20(_token).balanceOf(this);
        uint256 totalBalance = currentBalance + releasedTokens;

        // can't vest anything if it is before the cliff
        if (block.timestamp < cliffPeriod) {
<<<<<<< HEAD
            return 0; // can't vest anything if it is before the cliff
        } else if (block.timestamp >= start + vestDuration ) { // if it is fully past the vesting period and nothing has been vested yet, then vest it all
            return totalBalance;
        } else {
            return totalBalance * ((block.timestamp - start) / vestDuration); // otherwise, vest it linearlly
=======
            return 0;
        }
        //vest linearly
        else {
            return
                totalBalance.mul(block.timestamp.sub(start)).div(vestDuration);
>>>>>>> 0aa2c1f (Initial commit)
        }
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

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

    //this is the length of the vesting contract in seconds (i.e. 1 month is 2419200 seconds)
    uint256 public vestDuration;

    //period beneficiary must wait until vesting begins, default cliffPeriod is 0
    uint256 public cliffPeriod; // time in unix time seconds

    //block timestamp of when the contract is deployed
    uint256 public start;

    //number of tokens that have been released thus far
    uint256 public releasedTokens;

    // whether the vesting contract is cancellable after it has been deployed or not
    bool public revocable;

    //whether the vesting contract has received the initial token supply to disburse
    bool public active;

    //a mapping to keep track of how many tokens have already  been released to a given address
    mapping(address => uint256) public released;

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
        uint256 _vestDuration,
        uint256 _cliffPeriod,
        bool _revocable
    ) {
        owner = _owner;
        beneficiary = _beneficiary;
        vestDuration = _vestDuration;
        cliffPeriod = _cliffPeriod;
        require(_beneficiary != address(0), "Call cannot come from 0 address.");

        require(
            cliffPeriod < vestDuration,
            "Cliff period must not be longer than vesting contract duration."
        );

        require(vestDuration > 0, "TokenVesting: duration is <= 0");
        revocable = _revocable;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can perform this action");
        _;
    }

    //this modifier checks if a vesting contract  has been seeded with an initial token deposit
    modifier onlyActive() {
        require(
            active == true,
            "only an active, seeded contract can perform this action"
        );
        _;
    }

    /**
     * @dev call this function to begin a vest - vesting contracts are inactive until they have tokens to release
     * @param _token address of initial tokenToDistribute that you want to seed the vest contract with
     * @param _amount of initial tokenToDistribute that you want to seed the vest contract with
     */
    function depositInitialTokens(address _token, uint256 _amount)
        public
        onlyOwner
    {
        bool success = IERC20(_token).transfer(address(this), _amount);
        require(success);
        active = true;
        start = block.timestamp;
        cliffPeriod = start + cliffPeriod;
    }

    //TODO: revoke() currently  pays out to the owner. You may want to pay out to the beneficiary.
    /**
     * @dev call this function to stop vesting tokens for a given vesting contract
     * only callable by the contract owner (i.e. the SYN multisig who delegate-called the factory)
     * emits a TokenVestingRevoked event identifying  which contract was revoked
     */
    function revoke(address _tokenToDistribute) public onlyOwner {
        require(revocable);

        uint256 balance = IERC20(_tokenToDistribute).balanceOf(address(this));
        uint256 unreleased = releaseableAmount(_tokenToDistribute);
        uint256 refund = balance - unreleased;

        bool success = IERC20(_tokenToDistribute).transfer(owner, refund);
        require(success);
        emit TokenVestingRevoked(address(this));
    }

    /**
     * @notice Transfers vested tokens to beneficiary.
     */
    function releaseToken(address _tokenToDistribute)
        public
        onlyOwner
        onlyActive
    {
        require(
            IERC20(_tokenToDistribute).balanceOf(address(this)) > 0,
            "no more tokens available to vest"
        );

        uint256 unreleased = releaseableAmount(_tokenToDistribute);

        require(unreleased > 0);

        releasedTokens += unreleased;

        bool success = IERC20(_tokenToDistribute).transfer(
            beneficiary,
            unreleased
        );
        require(success);

        emit Released(unreleased, beneficiary);
    }

    ///////////////
    /// Helpers ///
    ///////////////

    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     */
    function releaseableAmount(address _token) public view returns (uint256) {
        return vestedAmount(_token) - releasedTokens;
    }

    /**
     * @dev Calculates the amount that has already vested for the beneficiary.
     */
    function vestedAmount(address _token) public view returns (uint256) {
        uint256 currentBalance = IERC20(_token).balanceOf(address(this));
        uint256 totalBalance = currentBalance + releasedTokens;

        if (block.timestamp < cliffPeriod) {
            return 0;
        } else {
            return (totalBalance * (block.timestamp - start)) / (vestDuration);
        }
    }

    fallback() external payable {}

}

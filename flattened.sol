// SPDX-License-Identifier: MIT
pragma solidity =0.8.20 ^0.8.20;

// SparkUp/node_modules/@openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// SparkUp/node_modules/@openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SparkUp/src/SparkUp.sol

/// @title SparkUp - A decentralized crowdfunding platform for ideas
/// @author Original contract author
/// @notice This contract allows users to create and fund innovative ideas
/// @dev All function calls are currently implemented without side effects

contract SparkUp is Ownable {

    constructor() Ownable(msg.sender)
    {
        address owner = msg.sender;
    }
    struct Idea {
        string title;
        string description;
        address payable owner;
        uint256 fundGoal;
        uint256 deadline;
        uint256 amountCollected;
        bool completed;
    }

    mapping(uint => mapping(address => uint)) public contributions;
    mapping (uint => Idea) ideas;
    uint public totalIdeas = 0;
    bool isActive = true;
    uint256 public FeePercentage = 5;

    modifier onlyActive() {
        require(isActive, "Crowdfunding is paused");
        _;
    }
    function toggleActive() public onlyOwner {
        isActive =  !isActive;
    }

    event IdeaCreated(uint id , address owner , string title , string description );
    event IdeaFunded(uint id , address funder , uint256 amount);
    event withdrawFunds(uint id , address owner , uint256 amount);
    event refunded(uint id, address backer, uint256 amount);

    /// @notice Creates a new idea for crowdfunding
    /// @param title The title of the idea
    /// @param description A description of the idea
    /// @param goal The funding goal for the idea
    /// @param deadline The deadline for the idea
    /// @dev Emits an IdeaCreated event

    function createIdea (string memory title, string memory description , uint256 goal , uint256 deadline) public onlyActive {
        totalIdeas ++;
        Idea storage i = ideas[totalIdeas];
        i.title = title;
        i.description = description;
        i.owner = payable(msg.sender);
        i.fundGoal = goal;
        i.deadline = deadline;
        i.amountCollected = 0;
        i.completed = false;
        emit IdeaCreated(totalIdeas, msg.sender, title, description);
    }
    ///@notice Returns the details of an idea
    ///@param ideaId The ID of the idea to retrieve
    ///@return A tuple containing the title, description, owner, funding goal, deadline, amount collected, and completion status
    function getIdea(uint256 ideaId) public view returns (
        string memory,
        string memory,
        address,
        uint256,
        uint256,
        uint256,
        bool
    ) {
        Idea storage i = ideas[ideaId];
        return (i.title, i.description, i.owner, i.fundGoal, i.deadline, i.amountCollected, i.completed);
    }
    
    /// @notice Funds an idea for crowdfunding
    /// @param id The ID of the idea to fund
    /// @dev Emits an IdeaFunded event

    function fundIdea (uint id) public payable {
        Idea storage i = ideas[id];
        require(i.completed == false, "Idea is already completed");
        require(i.deadline > block.timestamp, "Idea deadline has passed");
        require(msg.value > 0, "Amount must be greater than 0");
        uint256 remaining = i.fundGoal - i.amountCollected;
        require(msg.value <= remaining, "Amount exceeds remaining funding goal");
        i.amountCollected += msg.value;
        contributions[id][msg.sender] += msg.value;
        emit IdeaFunded(id, msg.sender, msg.value);
    }

    /// @notice Withdraws funds from an idea
    /// @param id The ID of the idea to withdraw funds from
    /// @dev Emits a withdrawFunds event

    function withdraw (uint id) public {
        Idea storage i = ideas[id];
        require(!i.completed, "Idea is already completed");
        require(i.amountCollected > 0, "Idea has not been funded yet");
        require(msg.sender == i.owner, "Only the owner can withdraw funds");

        uint256 fee = (i.amountCollected * FeePercentage) /100;
        uint256 amount = i.amountCollected - fee;

        i.amountCollected = 0;
        i.completed = true;

        (bool sent, ) = i.owner.call{value: amount}("");
        require(sent, "Failed to send funds");
        emit withdrawFunds(id , msg.sender,amount);
    }

    ///@notice Completes an idea
    ///@param id The ID of the idea to complete

    function completeIdea(uint id) public {
    require(msg.sender == ideas[id].owner, "Only owner can complete");
    ideas[id].completed = true;
    }

    ///@notice Withdraws fees from an idea
    ///@param id The ID of the idea to withdraw fees from
    ///@dev Emits a withdrawFunds event
    function withdrawFees(uint id) public onlyOwner
    {
        Idea storage i = ideas[id];
        require(i.completed , "Idea must be completed to withdraw fees");

        uint256 feesAmount = (i.fundGoal * FeePercentage) /100;
        require(address(this).balance >= feesAmount, "Fees are not enough to withdraw");

        (bool sent, ) = msg.sender.call{value: feesAmount}("");
        require(sent, "Failed to send fees");
        emit withdrawFunds(id , msg.sender, feesAmount);
    }

    /// @notice Refunds a backer's contribution to an idea
    /// @param id The ID of the idea to refund the backer from
    /// @param backer The address of the backer to refund
    /// @dev Emits a refunded event

    function refund (uint id , address backer) public {
        Idea storage i = ideas[id];
        require(i.completed == false, "Idea is already completed");
        require(i.deadline > block.timestamp, "Idea deadline has passed");
        require(i.amountCollected > 0, "Idea has not been funded yet");
        require(contributions[id][backer] > 0, "Backer has not contributed to the idea");
        uint refundAmount = contributions[id][backer];
        contributions[id][backer] = 0;
        i.amountCollected -= refundAmount;
        emit refunded(id, backer, refundAmount);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
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
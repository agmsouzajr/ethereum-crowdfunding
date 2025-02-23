// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Crowdfunding {
    struct Campaign {
        address payable creator;
        uint256 goal;
        uint256 deadline;
        uint256 fundsRaised;
        bool claimed;
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;
    uint256 public campaignCount;

    event CampaignCreated(uint256 campaignId, address creator, uint256 goal, uint256 deadline);
    event ContributionMade(uint256 campaignId, address contributor, uint256 amount);
    event FundsClaimed(uint256 campaignId, address creator, uint256 amount);
    event RefundClaimed(uint256 campaignId, address contributor, uint256 amount);

    function createCampaign(uint256 _goal, uint256 _duration) external {
        require(_goal > 0, "Goal must be greater than 0");
        require(_duration > 0, "Duration must be greater than 0");

        uint256 campaignId = campaignCount++;
        campaigns[campaignId] = Campaign(payable(msg.sender), _goal, block.timestamp + _duration, 0, false);

        emit CampaignCreated(campaignId, msg.sender, _goal, block.timestamp + _duration);
    }

    function contribute(uint256 _campaignId) external payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(msg.value > 0, "Contribution must be greater than 0");

        campaign.fundsRaised += msg.value;
        contributions[_campaignId][msg.sender] += msg.value;

        emit ContributionMade(_campaignId, msg.sender, msg.value);
    }

    function claimFunds(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.sender == campaign.creator, "Only creator can claim funds");
        require(block.timestamp >= campaign.deadline, "Campaign is still active");
        require(campaign.fundsRaised >= campaign.goal, "Funding goal not reached");
        require(!campaign.claimed, "Funds already claimed");

        campaign.claimed = true;
        payable(campaign.creator).transfer(campaign.fundsRaised);

        emit FundsClaimed(_campaignId, campaign.creator, campaign.fundsRaised);
    }

    function refund(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign is still active");
        require(campaign.fundsRaised < campaign.goal, "Goal was reached, no refunds");

        uint256 amount = contributions[_campaignId][msg.sender];
        require(amount > 0, "No funds to refund");

        contributions[_campaignId][msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit RefundClaimed(_campaignId, msg.sender, amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@thirdweb-dev/contracts/extension/ContractMetadata.sol";


contract CrowdFunding is ContractMetadata {

    address public deployer;

    struct Campaign {
        address owner;
        string title;
        string description;
        uint target;
        uint deadline;
        uint amountCollected;
        string image;
        address[] donators;
        uint[] donations;
    }

    mapping(uint => Campaign) public campaigns;

    uint public campaignCount = 0;

    constructor() {
        deployer = msg.sender;
    }

    function _canSetContractURI() internal view virtual override returns (bool){
        return msg.sender == deployer;
    }

    function createCampaign(address _owner, 
        string memory _title, 
        string memory _description, 
        uint _target, 
        uint _deadline, 
        string memory _image) public returns (uint) {
            Campaign storage campaign = campaigns[campaignCount];

            require(campaign.deadline < block.timestamp, "The deadline should be a date in the future.");

            campaign.owner = _owner;
            campaign.title = _title;
            campaign.description = _description;
            campaign.target = _target;
            campaign.deadline = _deadline;
            campaign.image = _image;
            campaign.amountCollected = 0;

            campaignCount++;

            return campaignCount -1;
        }

    function donate(uint _id) public payable {
        Campaign storage campaign = campaigns[_id];

        require(campaign.deadline > block.timestamp, "The deadline has passed.");
        require(msg.value > 0, "You need to send some Ether.");

        campaign.donators.push(msg.sender);
        campaign.donations.push(msg.value);

        (bool sent,) = payable(campaign.owner).call{value: msg.value}("");
        if(sent) {
            campaign.amountCollected += msg.value;
        }
    }

    function getDonators(uint _id) view public returns(address[] memory, uint[] memory){
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory _campaigns = new Campaign[](campaignCount);

        for(uint i = 0; i < campaignCount; i++) {
            Campaign storage item = campaigns[i];
            _campaigns[i] = item;
        }

        return _campaigns;
    }
}
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Crowdfunding", function () {
    let crowdfunding, owner, addr1, addr2;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        const Crowdfunding = await ethers.getContractFactory("Crowdfunding");
        crowdfunding = await Crowdfunding.deploy();
        await crowdfunding.waitForDeployment();
    });

    it("Should create a new campaign", async function () {
        await crowdfunding.createCampaign(ethers.parseEther("1"), 1000);
        const campaign = await crowdfunding.campaigns(0);
        expect(campaign.goal).to.equal(ethers.parseEther("1"));
    });

    it("Should allow contributions", async function () {
        await crowdfunding.createCampaign(ethers.parseEther("1"), 1000);
        await crowdfunding.connect(addr1).contribute(0, { value: ethers.parseEther("0.5") });
        const campaign = await crowdfunding.campaigns(0);
        expect(campaign.fundsRaised).to.equal(ethers.parseEther("0.5"));
    });
});
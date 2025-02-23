const { ethers } = require("hardhat");

async function main() {
    // Get the contract factory
    const Crowdfunding = await ethers.getContractFactory("Crowdfunding");

    // Deploy the contract
    const crowdfunding = await Crowdfunding.deploy();

    // Wait for deployment to complete
    await crowdfunding.waitForDeployment();

    // Log the deployed contract address
    console.log(`Crowdfunding contract deployed at: ${await crowdfunding.getAddress()}`);
}

// Handle errors properly
main().catch((error) => {
    console.error(error);
    process.exit(1);
});
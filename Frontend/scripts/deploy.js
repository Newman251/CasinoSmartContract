//  How To Deploy Our Contract to the Blockchain?

const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log( "Deploying contracts with the account:", deployer.address);
  
  
  const Casino = await hre.ethers.getContractFactory("Casino");
  const casino = await Casino.deploy();
  
  await casino.deployed();

  console.log("Contract deployed to:", casino.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
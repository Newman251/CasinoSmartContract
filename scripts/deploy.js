
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );
  
  
  const Casino = await hre.ethers.getContractFactory("Casino");
  const casino = await Casino.deploy();
  
  await casino.deployed();

  console.log("Token deployed to:", casino.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
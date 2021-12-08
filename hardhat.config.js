require("@nomiclabs/hardhat-waffle");


task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});


module.exports = {
  solidity: "0.8.3",
  paths:{
    artifacts:'./src/artifacts',//derleyince bütün kod bu adrese gidecek ve biz react ile kullanabiliriz.
  },
  networks:{
    hardhat:{ //setting hardhat &local network
      chainId:1337//specific to the way that hardhat works
    },
    ropsten:{
      url:"https://ropsten.infura.io/v3/99d3ebabdc964c2092a1c318b126e245",
      accounts:['ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80']
    }
  }
};

/*When we compile our project using hardhat
it's going to take our smart contracts and create some
machine readable code called abis and additional artifacts as well
that we're going to be needing and we want those artifacts to go
in our src directory so we can import those from our react app*/
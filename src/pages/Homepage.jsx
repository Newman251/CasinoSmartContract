import React from 'react';
import '../App.css';
import { Layout, Typography, Space,Avatar } from 'antd';
import icon from  "../images/img1.png";
import { Switch, Route, Link } from 'react-router-dom';
import Casino from '../artifacts/contracts/Casino.sol/Casino.json';
import {useState} from 'react';
import {ethers} from 'ethers';

const casinoAddress= "0x5FbDB2315678afecb367f032d93F642f64180aa3"


function Homepage () {
    const [userAccount, setUserAccount] = useState()
  const [amount, setAmount] = useState()
  const [balance, setBalance] = useState("Users Balance")
  //const [casinoBalance, setCasinoBalance] = useState("Casino's Tokens")



  async function requestAccount() {
    await window.ethereum.request({ method: 'eth_requestAccounts' });
  }
      async function getBalance() {
        if (typeof window.ethereum !== 'undefined') {
          const [account] = await window.ethereum.request({ method: 'eth_requestAccounts' })
          const provider = new ethers.providers.Web3Provider(window.ethereum);
          const contract = new ethers.Contract(casinoAddress, Casino.abi, provider)
          const balance = await contract.balanceOf(account);
          setBalance(balance.toString());
          console.log("Balance: ", balance.toString());
        }
      }
      

      async function sendCoins() {
        if (typeof window.ethereum !== 'undefined') {
          await requestAccount()
          const provider = new ethers.providers.Web3Provider(window.ethereum);
          const signer = provider.getSigner();
          const contract = new ethers.Contract(casinoAddress, Casino.abi, signer);
          const transaction = await contract.transfer(userAccount, amount);
          await transaction.wait();
          console.log(`${amount} Coins successfully sent to ${userAccount}`);
        }
      }

  return (
        <div >
           
       <Typography.Title level={9} style={{ flex:1,color: 'darkblue', textAlign: 'center' ,fontSize:34}}>------Start To The Game------
       <br /><br />
       
          
       <button onClick={getBalance}>Get My Balance</button>
       <h1>{balance}</h1>
       <br>
     
       </br>
        <button onClick={sendCoins}>Send Coins</button>
        <br></br>
        <input onChange={e => setUserAccount(e.target.value)} placeholder="Account ID" />
        <br/>
        <input onChange={e => setAmount(e.target.value)} placeholder="Amount" />
        <br></br>
        <br></br>
        <br></br>
        <br></br>
        <br></br>
        <br></br>


</Typography.Title> 
        </div>
    );
}

export default Homepage;
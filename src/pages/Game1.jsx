// Casino Contract deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
import React, { Component } from "react";
import {
  Popup,
  Button,
  Header,
  Image,
  Modal,
  Grid,
  Form,
  Input,
  Message
} from "semantic-ui-react";
import {useState} from 'react';
import {ethers} from 'ethers';
import logo from '../images/diceroll.png'; 
import '../App.css';

//import Casino from '../artifacts/contracts/Casino.sol/Casino.json';


//the adress of the Casino contract
const casinoAdress="0x5FbDB2315678afecb367f032d93F642f64180aa3";


function Game1() {

  
  

  /*
  async function fetchDiceValue(){
    /*we're looking for metamask extension to be connected
  if metamask is installed on that user's browser then window.ethereum 
  will be injected to the window object
    *//*
    if (typeof window.ethereum !=='undefined'){ //if metamask exists
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    /*once we have a provider we can create an instance of the contract
    we pass abi from the compiled contract that we imported on the top*/
 /* const casino =new ethers.Contract(casinoAdress,Casino.abi,provider)
  try{
    const data= await casino.rollDice() // reading from the blockchain
    console.log("data:",data)
  } catch(err){
    console.log("Error: ",err)
  } 
  }
  }
  */
  
  return (
    <div className="game1">
      <br />

      <Grid centered columns={3}>
        <Grid.Column>
       
          
        <img src={logo} className="imagerollDice" />
        <br /> <br /> 
          
   <Input
                    label="Guess number"
                  //  labelPosition="right"
                    placeholder="1-6"
                   // value={this.state.number}
                  //   onChange={event =>
                  //     this.setState({ number: event.target.value })
                  //   }
                  />
                       <Input
                    label="Enter the Amount"
                  //  labelPosition="right"
                    placeholder="$"
                   // value={this.state.number}
                  //   onChange={event =>
                  //     this.setState({ number: event.target.value })
                  //   }
                  />
             
  
           
               
              <br/>
         
        
        </Grid.Column>
      </Grid>
    </div>
  );
  }





export default Game1;

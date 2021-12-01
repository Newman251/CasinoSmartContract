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

import logo from '../images/diceroll.png'; // Tell webpack this JS file uses this image
import '../App.css';


//import web3 from "../ethereum/web3";
//import dice from "../ethereum/_dice";
//import { Link, Router } from "../routes";

class Game1 extends Component {
 
   
      

//   state = { open: false,
//             value: "",
//             errorMessage: "",
//             loading: false,
//             number: ""
// };

//   show = size => () => this.setState({ size, open: true });
//   close = () => this.setState({ open: false });

  

//   onClick = async event => {

//       event.preventDefault();
//       this.setState({ loading: true})
    
   
    
//     this.setState({ errorMessage: "", loading: true });
  

//     const total = this.state.value * 100000000000000000;
   
//     const num = this.state.number;


//     try {
//       const accounts = await web3.eth.getAccounts();
//         await dice.methods.rollDice(num).send({
//           from: accounts[0],
//           value: total,
//           gasLimit: 500000
//         });
//       }
      
    
//     catch (err) {
//       this.setState({ errorMessage: err.message.split("\n")[0] });
//     }
   
//     this.setState({ loading: false, open: false})
//     Router.pushRoute(`/dice`);
//     this.render();
//     this.close();

//   };

  render() {
   // const { open, size } = this.state;


   function sayHello() {
    alert('You clicked me!');
  }
  
    return (
      <div className="game1">
        <br />

        <Grid centered columns={3}>
          <Grid.Column>
         
            
          <img src={logo} className="imagerollDice" />
           
            
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
                <button onClick={sayHello}>PLAY</button>
             
                  {/* <Button.Group color="grey">
                  <Button onClick={event => this.setState({ value: 0.01 })}>
                  {"0.01 ETH"}
                </Button>
                <Button onClick={event => this.setState({ value: 0.1 })}>
                  {"0.1 ETH"}
                </Button>
                <Button onClick={event => this.setState({ value: 0.25 })}>
                  {"0.25 ETH"}
                </Button>
                <Button onClick={event => this.setState({ value: 0.5 })}>
                  {"0.5 ETH"}
                </Button>
                <Button onClick={event => this.setState({ value: 1 })}>
                  {"1 ETH"}
                
                  </Button>
                  </Button.Group> */}
                  
            
                <br/>
           
          
          </Grid.Column>
        </Grid>
      </div>
    );
  }
}

export default Game1;

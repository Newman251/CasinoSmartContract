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

import logo2 from '../images/blackjack.png';
import '../App.css';




class Game2 extends Component {
 
 
  render() {
   


   function sayHello() {
    alert('You clicked me!');
  }
  
    return (
      <div className="game1">
        <br />

        <Grid centered columns={3}>
          <Grid.Column>
         
            
          <img src={logo2} className="imagerollDice" />
           
            
    
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
             
                 
 
            
                <br/>
           
          
          </Grid.Column>
        </Grid>
      </div>
    );
  }
}

export default Game2;

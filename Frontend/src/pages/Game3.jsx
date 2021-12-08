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

import logo from '../images/roulette.jpg'; 
import '../App.css';



class Game3 extends Component {
 
   
 

  render() {



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
                    
                     // placeholder="1-6"
                     // value={this.state.number}
                    //   onChange={event =>
                    //     this.setState({ number: event.target.value })
                    //   }
                    />
                    <Input
                      label="Guess Color"
                    
                     // placeholder="1-6"
                     // value={this.state.number}
                    //   onChange={event =>
                    //     this.setState({ number: event.target.value })
                    //   }
                    />
                         <Input
                      label="Enter the Amount"
                  
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

export default Game3;

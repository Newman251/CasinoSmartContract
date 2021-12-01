import React from 'react';
import '../App.css';
import { Layout, Typography, Space,Avatar } from 'antd';
import icon from  "../images/img1.png";
import { Switch, Route, Link } from 'react-router-dom';


const Homepage= ()=> {
    return (
        <div>
           <div className="logo-container">


               <Avatar src={icon} className="logo" size="large"/>
           </div>
       <Typography.Title level={5} style={{ color: 'darkblue', textAlign: 'center' ,fontSize:34}}>------Start to the Game------
       <br /><br />
          <Link to="/">
            BUY COINS
          </Link> <br />
</Typography.Title> 
        </div>
    );
}

export default Homepage;
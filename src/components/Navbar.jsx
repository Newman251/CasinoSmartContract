import React from 'react';
import {Button,Menu,Typography,Avatar} from "antd";
import {Link} from "react-router-dom";
import {HomeOutlined,MoneyCollectOutlined,BulbOutlined,FundOutlined,MenuOutlined} from "@ant-design/icons";
import icon from  "../images/img1.png";
   
const Navbar= ()=> {
    return (
        <div className="nav-container">
        <div className="logo-container">
     
        <Typography.Title level={2} className="logo">
   <Link to="/">Welcome to the Casino!</Link>
        </Typography.Title>
      {/*  <Avatar src={icon} className="logo"/>*/}
       
        </div>
        <Menu theme="dark">
            <Menu.Item icon={<HomeOutlined/>}>
                <Link to="/">Home</Link>
            </Menu.Item>

            <Menu.Item icon={<MoneyCollectOutlined/>}>
                <Link to="/game1">RollDice</Link>
            </Menu.Item>
            <Menu.Item icon={<BulbOutlined/>}>
                <Link to="/game2">Blackjack</Link>
            </Menu.Item>
            <Menu.Item icon={<FundOutlined/>}>
                <Link to="/game3">Roulette</Link>
            </Menu.Item>


        </Menu>
            
        </div>
    );
}

export default Navbar;
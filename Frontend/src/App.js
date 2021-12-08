import React from 'react';
import { Switch, Route, Link } from 'react-router-dom';
import { Layout, Typography, Space,Avatar } from 'antd';
import {Navbar} from "./components";
import {Homepage,Game1,Game2,Game3} from './pages';
import './App.css';
import icon from  "./images/img1.png";

const App = () => (
  <div className="app">
    <div className="navbar">
      <Navbar />
    </div>
    <div className="main">
    
      <Layout>
        <div className="routes">
          <Switch>
            <Route exact path="/">
              <Homepage />
            </Route>
            <Route exact path="/game1">
              <Game1 />
            </Route>{/*}
            <Route exact path="/game2">
              <Game2 />
            </Route>
            <Route exact path="/game3">
              <Game3 />
</Route>*/}
          
          </Switch>
        </div>
      </Layout>

   {/*}   <div className="footer">
  
        <Space>
          <Link to="/">Home</Link>
          <Link to="/game1">Game1</Link>
          <Link to="/game2">Game2</Link>
       </Space> 
</div>*/}
    </div>
  </div>
);

export default App;
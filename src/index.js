import React from 'react';
import { hashHistory, Router, Route } from 'react-router'
import ReactDOM from 'react-dom';
import GetForm from './GetForm';
import CheckAdmin from './CheckAdmin';

import './index.css';

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/edit/" component={() => (<GetForm formtype="EDIT"   />)} />
    <Route path="/admin" component={() => (<GetForm formtype="IS"   />)} />
    <Route path="/"      component={CheckAdmin} />
  </Router>,
  document.getElementById('root') 
);

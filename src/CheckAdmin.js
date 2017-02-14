import React from 'react';
//import { hashHistory } from 'react-router'
import axios from 'axios'; //ajax library
import LibPath from './LibPath';
import Supv from './Supv';
import Admin from './Admin';

class CheckAdmin extends React.Component {
//checks if logged in user is SUPV, ADMIN, or neither
  constructor(props) { 
    super(props);
    this.state = {
      userType: null,
      loading: true,
      error: null
    };
  }

  componentDidMount() { 
    axios.get(LibPath + 'DBGet.cfm', {
      params: {
        Proc: "IsAdminOrSupv",
        cachebuster: Math.random()
      }
    })
    .then(res => {
      const userType = res.data[0]; 
      
      this.setState({
        userType,
        loading: false,
        error: null
      });
    })
    .catch(err => {
      this.setState({
        loading: false,
        error: err
      });
    }); 
  }
  
  renderLoading() {
    return <div>Loading...</div>;
  }

  renderNextStep() {
    if(this.state.userType==="ADMIN"){
        return <Admin />
    }else if(this.state.userType==="SUPV"){
      return <Supv />
    }else{
      return <div>Sorry, you are not authorized.</div>
    }
  }
  
  renderError() { 
    return (
      <div>
        Uh oh: {this.state.error.message}
      </div>
    );
  }
  
  render()  {
    return (
      <div className="outerdiv">
          {this.state.loading ?
          this.renderLoading()
          : this.renderNextStep()}
      </div>
    );
  }
}


export default CheckAdmin;
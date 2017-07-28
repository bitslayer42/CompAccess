import React from 'react';
//import { Redirect } from 'react-router-dom'
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';
import Supv from './Supv';
import Admin from './Admin';
import { HomePath } from './LibPath';

export default class CheckAdmin extends React.Component {
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
	const self = this;
    axios.get(LibPath + 'DBGet.cfm', {
      params: {
        Proc: "IsAdminOrSupv",
        cachebuster: Math.random()
      }
    })
    .then(res => {
	  const reqidFromQueryString = window.location.search.substring(7); //this gets reqid from query string in url: /index.cfm?reqid=131
	  //const match =  self.props.match;
      const userType = res.data[0]; 
      if(reqidFromQueryString && userType==="ADMIN"){  //was match.reqid
        //To call from email when user might not be logged in, hash (#) not passed to server, use query (?)
        // call: https://ccp1.msj.org/login/login/CompAccess/index.cfm?reqid=33
		//{`${HomePath}ADMIN/0/${match.reqid}`}
		
		
        self.props.history.push(`${HomePath}ADMIN/0/${reqidFromQueryString}`);
		
      }else{
        this.setState({
          userType,
          loading: false,
          error: null
        });
      }
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

  renderNextStep=()=>{ 
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
      <div>
          {this.state.loading ?
          this.renderLoading()
          : this.renderNextStep()}
      </div>
    );
  }
}


import React from 'react';
import { hashHistory } from 'react-router'
import axios from 'axios'; //ajax library
import LibPath from './LibPath';
import GetForm from './GetForm';

class CheckAdmin extends React.Component {
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
      
      // Update state to trigger a re-render.
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
      hashHistory.push('/admin');
    }else if(this.state.userType==="SUPV"){
      return <GetForm formtype="SUPV"/>
    }else{
      return <div>You must be a supervisor or in the IS department to use the Computer Access Form.</div>
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
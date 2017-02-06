import React from 'react';
//import { hashHistory } from 'react-router'
import axios from 'axios'; //ajax library
import LibPath from './LibPath';
import GetForm from './GetForm';
import Admin from './Admin';

class CheckAdmin extends React.Component {
//checks if logged in user is SUPV, ADMIN, or neither
  constructor(props) { 
    super(props);
    let view = "SUPV", formID = null,reqID = null;
    if(props.params){
      if(props.params.view){view = props.params.view}
      if(props.params.formID){formID = props.params.formID}
      if(props.params.reqID){reqID = props.params.reqID}
    }
    this.state = {
      reqview: view, //Can be "SUPV", "IS", or "EDIT"      
      formID: formID,
      reqID: reqID,
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
      if(this.state.reqview==="ADMIN"){
        return <Admin/>
      }else{
        return <GetForm view={this.state.reqview} formID={this.state.formID} reqID={this.state.reqID}/>
      }
    }else if(this.state.reqview==="SUPV" && this.state.userType==="SUPV"){
      return <GetForm view="SUPV" formID={this.state.formID}/>
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
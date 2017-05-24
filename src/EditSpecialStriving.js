import React from 'react';
//import { BrowserRouter } from 'react-router-dom'
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';
//import './css/special.css';

export default class Special extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      SpecialID: this.props.SpecialID,
	  SpecialData: null,
      loading: true,
      error: null,
    };
  } 
  componentDidMount() { 
		axios.get(LibPath + 'SpecialJSON.cfm', {
		  params: {
			SpecialID: this.props.SpecialID,
			cachebuster: Math.random()
		  }
		})
		.then(res => {
		  const SpecialData = res.data; 
		  //debugger;
		  this.setState({
			SpecialData,
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
    const data = this.state.SpecialData;
	const action = (data.special.Action==="HIDERESPONSE" ? "Hidden Fields"  : 
					data.special.Action==="SENDEMAIL"    ? "Special Emails" : "");	
    return (    
    <div>
		<h3><i>Special Action:</i> {action}</h3>
		<h1>{data.special.Description}</h1>
		<div class="flx">
			<div>
				flexdiv1
			</div>
			<div>
				flexdiv2
			</div>
		</div>
    </div>
    )
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

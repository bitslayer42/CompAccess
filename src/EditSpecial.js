import React from 'react';
import { Link } from 'react-router-dom';
import { HomePath } from './LibPath';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';
import './css/special.css';
import AddCriteria from './AddCriteria';
import AddHiddenFields from './AddHiddenFields';
import AddSpecialEmail from './AddSpecialEmail';
import AddSpecialEmailFields from './AddSpecialEmailFields';  
import DeleteCriteria from './DeleteCriteria';
import DeleteHiddenFields from './DeleteHiddenFields';
import DeleteEmail from './DeleteEmail';
import DeleteEmailFields from './DeleteEmailFields'; 

export default class Special extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      SpecialID: props.match.params.SpecialID,
	  SpecialData : null,
      loading: true,
      error: null,
    };
  } 
  componentDidMount() { 
	this.getSpecial();
  }
  getSpecial=()=>{
		axios.get(LibPath + 'SpecialJSON.cfm', {
		  params: {
			SpecialID: this.props.match.params.SpecialID,
			cachebuster: Math.random()
		  }
		})
		.then(res => {
		  const SpecialData = res.data; 
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
  
  handleRedraw=()=>{
	  //redraw
	  this.getSpecial();
  }
  
  renderNextStep() { //debugger;
	const self=this;
    const data = this.state.SpecialData;
	const action = (data.special.Action==="HIDERESPONSE" ? "Hidden Fields"  : 
					data.special.Action==="SENDEMAIL"    ? "Special Emails" : "");	
	
		
 	const listCriteria = data.criteria.map(function(criteria,ix){
	  return (
		<div key={ix}>
			<div className="criteria">
				<span
				dangerouslySetInnerHTML={{__html: criteria.HumanCriteria}} />
				<DeleteCriteria ID={criteria.ID} handleRedraw={self.handleRedraw} />
			</div>
			<div>
				<div>
					and
				</div>
			</div>			
		</div>
	  )
	});		
	const listHiddenFields = data.hide.map(function(hide,ix){
	  return (
		<div key={ix} style={{marginBottom:"5px"}}>
			<div className="criteria">
				{hide.Descrip}
				<DeleteHiddenFields ID={hide.ID} handleRedraw={self.handleRedraw} />
			</div>			
		</div>
	  )
	});
	const listEmails = data.email.map(function(email,ix){
	  return (
		<div key={ix} style={{marginBottom:"5px"}}>
			<div className="criteria">
				{email.Email}
				<DeleteEmail ID={email.ID} handleRedraw={self.handleRedraw} />
			</div>			
		</div>
	  )
	});
	const listEmailFields = data.emailfields.map(function(emailfields,ix){
	  return (
		<div key={ix} style={{marginBottom:"5px"}}>
			<div className="criteria">
				{emailfields.Descrip}
				<DeleteEmailFields ID={emailfields.ID} handleRedraw={self.handleRedraw} />
			</div>			
		</div>
	  ) 
	});
 

 return (    
    <div>
		<h3><i>{action}: </i> {data.special.Description}</h3>
		<div className="sectionclass"  style={{textAlign:"center"}}>
			<h3>CRITERIA</h3>
			{listCriteria}
			<AddCriteria SpecialID={this.state.SpecialID} fieldList={data.fieldlist} handleRedraw={this.handleRedraw} />
		</div>
		{action==="Hidden Fields" &&
		<div className="sectionclass"  style={{textAlign:"center"}}>
			<h3>If Criteria is True Hide These Fields</h3>
			{listHiddenFields}
			<AddHiddenFields SpecialID={this.state.SpecialID} fieldList={data.fieldlist} handleRedraw={this.handleRedraw} />
		</div>
		}
		{action==="Special Emails" &&
		<div className="sectionclass"  style={{textAlign:"center"}}>
			<h3>Send Special Emails To:</h3>
			{listEmails}
			<AddSpecialEmail SpecialID={this.state.SpecialID} handleRedraw={this.handleRedraw} />

			<h3>Fields to Display in Special Email</h3>
			{listEmailFields}
			<AddSpecialEmailFields SpecialID={this.state.SpecialID} fieldList={data.fieldlist} handleRedraw={this.handleRedraw} />
		</div>
		}
	</div>
    )
  }

  renderLoading() {return <div>Loading...</div>;}
  renderError() { return (<div>Uh oh: {this.state.error.message}</div>);}
  
  render()  {
    return (
      <div className="outerdiv">
        <Link to={HomePath}>&larr; Return to Admin menu</Link>
        <div className="formclass">
          <h1> Computer Access Forms </h1>
          <div className="sectionclass" >
			  {this.state.loading ?
			  this.renderLoading()
			  : this.renderNextStep()}
          </div>
        </div>
      </div>
    );
  }
}


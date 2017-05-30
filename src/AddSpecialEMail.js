import React from 'react';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';
import './css/special.css';
import addbutton from './images/plus.png';

export default class AddHiddenFields extends React.Component {
	constructor(props) { 
		super(props); 
		this.state = {
			SpecialID: props.SpecialID,
			value: '',
		};
		this.handleSubmit = this.handleSubmit.bind(this);		
	} 

	handleChange=(event)=>{
		this.setState({   
		  value: event.target.value
		});
	} 	
	handleSubmit=(event)=>{
		axios.get(LibPath + 'Special.cfm', {
		  params: {
			Proc: "AddSpecialEmail",
			SpecialID:     this.state.SpecialID,
			Email:   this.state.value,
			cachebuster: Math.random()
		  }
		})
		.then(res => { 
		  this.setState({value: ''});
		  this.props.handleRedraw();
		})
		.catch(err => {
		  console.log(err);
		});		
		
	}
	
    render()  { 
		return (
			<div className="flx">
				<form onSubmit={this.handleSubmit}>
					<input type="text" value={this.state.value} 
						onChange={this.handleChange} placeholder="Type in email address"  style={{width: "450px"}}/>
					<a onClick={this.handleSubmit}><img src={addbutton} alt="Add" title="Add"/></a>
				</form>			
			</div>	
		)
	}

}




  
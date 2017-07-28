import React from 'react';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';
import './css/special.css';

export default class AddSpecialEmailFields extends React.Component {
	constructor(props) { 
		super(props); 
		this.state = {
			fieldList: props.fieldList,
			SpecialID: props.SpecialID,
			value: 0,
		};
		this.handleSelectField = this.handleSelectField.bind(this);		
	} 
	
	handleSelectField=(event)=>{
		this.setState({value: 0});
		axios.get(LibPath + 'Special.cfm', {
		  params: {
			Proc: "AddSpecialEmailFields",
			SpecialID:     this.state.SpecialID,
			Field:   event.target.value,
			cachebuster: Math.random()
		  }
		})
		.then(res => { 
		  this.props.handleRedraw();
		})
		.catch(err => {
		  console.log(err);
		});		
	}
	
    render()  { 
		return (
			<div className="flx">
				<select onChange={this.handleSelectField} value={this.state.value}>
				  <option key={0} value="0">(Add Field)</option>
				  {this.state.fieldList.map((field) => { 
					return( 
					  <option key={field.ID} value={field.ID}>{field.Descrip}</option>
					)
				  })}
				</select>
			  </div>	
		)
	}

}




  
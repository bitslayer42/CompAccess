import React from 'react';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';
import './css/special.css';

export default class AddCriteria extends React.Component {
	constructor(props) { 
		super(props); 
		this.state = {
			fieldList: props.fieldList,
			SpecialID: props.SpecialID,
			stateToShow: "field", //can be "field" (select which field), or these 3: "option","filled in","checked","selected"
			chosenFieldID: 0,     		//will be SpecialCriteria.Field
			chosenObject: null,         //Field selected data: ID,Type,Descrip,FormName
			IsValue: '',              //will be SpecialCriteria.IsValue
			ItExists: null,
			notCkbox: false,
			HumanCriteria: null,
		};
		this.handleSelectField = this.handleSelectField.bind(this);	
		this.handleSelectOption = this.handleSelectOption.bind(this);	
	} 
	
	handleSelectField=(event)=>{ 
	  const selEl = this.state.fieldList.find(
		function(el){return el.ID.toString()===event.target.value;}
	  );
	  let nextState;
	  switch(selEl.Type){
		  case "SELECT":
		  case "RADIO":
			nextState = "option"; //these have multiple options so we need another select
			break;
		  case "INPUT":
		  case "DATE":
			nextState = "filled in"; //these can be either filled in or not
			break;
		  case "CHECKBOX":
			nextState = "checked"; //these can be checked or not
			break;
		  case "NODE":
			nextState = "selected"; //these can be selected or not
			break;
		  default:
		    nextState = "";
	  }
	  this.setState({
		  chosenFieldID: event.target.value,
		  stateToShow: nextState,
		  chosenObject: selEl
	  });
	  
	} 
	
	handleSelectOption=(optionDescrip)=>{  	
		const HumanCriteria =   '<i>'            //"<span class='criteria'>"
								+ this.state.chosenObject.Descrip 
								+ '</i>'
								+ ' is' 
								+ (this.state.notCkbox?' not ':' ')
								+ '<i>'
								+ optionDescrip
								+ '</i>';
		this.setState({
		  HumanCriteria: HumanCriteria,
		  IsValue: optionDescrip
		},this.sendAdd);
		
    }
//https://ccp1.msj.org/CompAccess/Special.cfm?Proc=AddSpecialCriteria&SpecialID=5&Field=4&IsNot=false&ItExists=0&cachebuster=0.018909803314135054	
	sendAdd=()=>{                                         console.log(this.state);
		axios.get(LibPath + 'Special.cfm', {
		  params: {
			Proc: "AddSpecialCriteria",
			SpecialID:     this.state.SpecialID,
			Field:         this.state.chosenFieldID,
			IsNot:         this.state.notCkbox,
			ItExists:      this.state.ItExists,
			IsValue:       this.state.IsValue,
			HumanCriteria: this.state.HumanCriteria,
			cachebuster: Math.random()
		  }
		})
		.then(res => { 
		  this.setState({
			stateToShow: "field",
			chosenFieldID: 0,     		
			chosenObject: null,         
			IsValue: '',              
			ItExists: null,
			notCkbox: false,
			HumanCriteria: null,			  
		  });
		  this.props.handleRedraw();
		})
		.catch(err => {
		  console.log(err);
		});		
	}
	
	toggleNotCkboxChange=()=>{
	  this.setState({
		  notCkbox: !this.state.notCkbox
	  });
	}
	
	handleRadioClick=(event)=>{                          
		const HumanCriteria =   '<i>'
								+ this.state.chosenObject.Descrip 
								+ '</i>'
								+ ' is' 
								+ (event.currentTarget.value==="0"?' not ':' ')
								+ this.state.stateToShow;		
		this.setState({
			HumanCriteria: HumanCriteria,
			ItExists: event.currentTarget.value
		},this.sendAdd);
			
	}
										
    render()  { 
		return (
			this.state.stateToShow === "field"
			? <div className="flx">
				<select onChange={this.handleSelectField} value={this.state.value}>
				  <option key={0} value="0">(Choose Field)</option>
				  {this.state.fieldList.map((field) => { 
					return( 
					  <option key={field.ID} value={field.ID}>{field.Descrip}</option>
					)
				  })}
				</select>
			  </div>	
			: this.state.stateToShow === "option"
			? <div className="flx">
				<div>
				{this.state.chosenObject.Descrip}
				</div>
				<div>
					is
				</div>
				<div>
					<input type="checkbox" checked={this.state.notCkbox} onChange={this.toggleNotCkboxChange} value="IsNot" />not
				</div>
				<div>
					<GetOptions FieldID={this.state.chosenFieldID} handleSelectOption={this.handleSelectOption}/>
				</div>
			  </div>
			: <div className="flx"> {/*stateToShow is filled or checked*/}
				<div>
				{this.state.chosenObject.Descrip}
				</div>
				<div>
					<input type="radio" name="rad" onChange={this.handleRadioClick} value="1" />is
					<input type="radio" name="rad" onChange={this.handleRadioClick} value="0" />is not
				</div>
				<div>
					{this.state.stateToShow}
				</div>
			  </div>


		)
	}

}

class GetOptions extends React.Component {
	constructor(props) { 
		super(props);
		this.state = {
			FieldID: this.props.FieldID,
			OptionData: null,		
			loading: true,
			error: null,
		};
	}
  
	componentDidMount() { 
		axios.get(LibPath + 'Special.cfm', {
		  params: {
			Proc: "GetOptions",
			FormID: this.props.FieldID,
			cachebuster: Math.random()
		  }
		})
		.then(res => { 
		  const OptionData = res.data; 
		  this.setState({
			OptionData,
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

	handleSelectOption=(event)=>{
	  this.props.handleSelectOption(event.target.value);
	}
	
	renderLoading() {return <div>Loading...</div>;}
	renderError() { return (<div>Uh oh: {this.state.error.message}</div>);}
  
	renderNextStep() {  
		return (
			<div>
				<select onChange={this.handleSelectOption} value={this.state.value}>
				  <option key={0} value="0">(Choose One)</option>
				  {this.state.OptionData.map((opt) => { 
					return( 
					  <option key={opt.ID} value={opt.Descrip}>{opt.Descrip}</option>
					)
				  })}
				</select>
			</div>
		)
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



  
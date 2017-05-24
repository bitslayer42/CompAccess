import React from 'react';
import axios from 'axios'; //ajax library
import { LibPath, HomePath } from './LibPath';
import { Link } from 'react-router-dom'
import Autosuggest from 'react-autosuggest'; //https://github.com/moroshko/react-autosuggest
import './css/StaffList.css';

export default class StaffList extends React.Component {
  constructor() {
    super();

    this.state = {
      value: '',
      suggestions: []
    };  
    this.getSuggestionValue = this.getSuggestionValue.bind(this);
    this.onSuggestionSelected = this.onSuggestionSelected.bind(this);
  }

  onChange = (event, { newValue, method }) => { 
    this.setState({
      value: newValue
    });
  };
  
  onSuggestionsFetchRequested = ({ value }) => {
    this.getSuggestions(value);
  };

  onSuggestionsClearRequested = () => {
    this.setState({
      suggestions: []
    });
  };

  //Employee is selected, go to ShowAdministrator
  onSuggestionSelected=(event, { suggestion, suggestionValue, suggestionIndex, sectionIndex, method })=>{
	this.props.history.push(`${HomePath}useradmin/${suggestion.BadgeNum}`);
    //this.props.handleAdminID(suggestion);
  }
 
  ///////////////////////////////////////////////////////////////////////
  getSuggestions(value) {  
    const self=this;
    const inputLength = value.length;
    if(inputLength === 0){
      return []; 
    }else{
      axios.get(LibPath + 'Administrator.cfm', {
        params: {
          Proc: "GetStaffList",
          SearchString: value,
          cachebuster: Math.random()
        }
      })
      .then(res => {
        const userData = res.data; 
          self.setState({
            suggestions: userData
          });
      })
      .catch(err => {
        console.log(err);
      }); 
    }
  }

  getSuggestionValue(suggestion) { //when selected
    return suggestion.Name;
  }

  renderSuggestion(suggestion) { //in drop down
    return (
      <span>{suggestion.Name}</span>
    );
  }
  ///////////////////////////////////////////////////////////////////////
  
  render() {
    const { value, suggestions } = this.state;
    const inputProps = {
      placeholder: "Find Staff by Last Name",
      value,
      onChange: this.onChange,
      autoFocus: "autoFocus"
    };

    return (
      <div className="outerdiv">
        <Link to={HomePath}>&larr; Return to Admin menu</Link>
        <div className="formclass">
          <h1> Computer Access Forms </h1>
          <div className="sectionclass" >	
			  <div className="outerdiv">
				<h3> Add New Administrator </h3>
				  <Autosuggest 
					suggestions={suggestions}
					onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
					onSuggestionsClearRequested={this.onSuggestionsClearRequested}
					onSuggestionSelected={this.onSuggestionSelected}
					getSuggestionValue={this.getSuggestionValue}
					renderSuggestion={this.renderSuggestion}
					inputProps={inputProps} />
			  </div>
          </div>
        </div>
      </div>
    );
  }
}

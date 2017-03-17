import React from 'react';

export default class MySelect extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      value: 'select'
    };
  } 
  
  change=(event)=>{
    this.setState({value: event.target.value});
  }
  
  render()  {
    return (
      <div>
         <select id="lang" onChange={this.change} value={this.state.value}>
            <option value="select">Select</option>
            <option value="Java">Java</option>
            <option value="C++">C++</option>
         </select>
         <p></p>
         <p>{this.state.value}</p>
      </div>
    )
  }
} 

class NameForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {value: ''};

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    this.setState({value: event.target.value});
  }

  handleSubmit(event) {
    alert('A name was submitted: ' + this.state.value);
    event.preventDefault();
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          Name:
          <input type="text" value={this.state.value} onChange={this.handleChange} />
        </label>
        <input type="submit" value="Submit" />
      </form>
    );
  }
 


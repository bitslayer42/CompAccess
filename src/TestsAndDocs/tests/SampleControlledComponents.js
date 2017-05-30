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
///////////////////TextBox////////////////////////////////////////////////////////////
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
 
///////////////////////////////////////////////////////////////////////////////
class Checkbox extends Component {
  state = {
    isChecked: false,
  }

  toggleCheckboxChange = () => {
    const { handleCheckboxChange, label } = this.props;

    this.setState(({ isChecked }) => (
      {
        isChecked: !isChecked,
      }
    ));

    handleCheckboxChange(label);
  }

  render() {
    const { label } = this.props;
    const { isChecked } = this.state;

    return (
      <div className="checkbox">
        <label>
          <input
            type="checkbox"
            value={label}
            checked={isChecked}
            onChange={this.toggleCheckboxChange}
          />

          {label}
        </label>
      </div>
    );
  }
}

Checkbox.propTypes = {
  label: PropTypes.string.isRequired,
  handleCheckboxChange: PropTypes.func.isRequired,
};

//export default Checkbox;
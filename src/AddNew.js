import React from 'react';
import addbutton from './images/plus.png';

export default class AddNew2 extends React.Component {
  constructor(props) { //debugger;
    super(props);
    this.state = {
      showPrompt: false
    };
  }
  
  addForm=()=>{
    this.setState({ 
      showPrompt: true
    });
  }
  
  submitForm=()=>{
    console.log("moo?");
  }
  
  render()  {
    return (
  <AddNew buttonText="New Form" addForm={() => this.addForm()} submitForm={() => this.submitForm()} showPrompt={this.state.showPrompt}/>
    )
  }
}  


class AddNew extends React.Component {
  constructor(props) { 
    super(props);

    this.state = {
      buttonText: props.buttonText
    };
  }

  handleChange = (e) => {
    this.setState({ 
      inputText: e.target.value
    });
  }
  render()  {
    return (
      <div className="addnew">
        {this.props.showPrompt && <div><input type="text" onChange={this.handleChange} />
        <a onClick={() => this.props.submitForm()}><img src={addbutton} alt="Add"/></a></div>}
         <a className="editclass" onClick={() => this.props.addForm()}>Add Form</a>
     </div>
    )
  }
};



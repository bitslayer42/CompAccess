import React from 'react';
import addbutton from './images/plus.png';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';

//USAGE:   // <AddNew typeToAdd="FORM" procToCall="AddChild" code="" parNodeID={this.state.adminData.root} handleAddedObj={this.handleAddedObj} />

export default class AddNew extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      showPrompt: false,
      promptBoxText: ''
    };
  }  
  addForm=()=>{
    this.setState({ 
      showPrompt: true
    });
  }
  handleChange=(event)=>{
    this.setState({promptBoxText: event.target.value});
  }  
  handleSubmit=(event)=>{
    event && event.preventDefault();    

    axios.get(LibPath + 'DBUpdate.cfm', {
      params: {
        Proc: this.props.procToCall,
        FormID: this.props.parNodeID,
        Type: this.props.typeToAdd,
        Code: this.props.code,
        Descrip: this.state.promptBoxText,
        cachebuster: Math.random()
      }
    })
    .then(res => {   //returns new node: "FormID","Type","Code","Descrip","ParentID"
      const newNode = res.data; 
       newNode.ItemValue = null;
       //newNode.children = []; 
      this.props.handleAddedObj(newNode);
    })
    .catch(err => {
      this.setState({
        loading: false,
        error: err
      });
    });
    this.setState({ 
      showPrompt: false,
      promptBoxText: ''
    });
  }  

  render()  {
    let convertUnpubLabel = this.props.typeToAdd==="UNPUB"?"FORM":this.props.typeToAdd;
    let typeToAddLabel = convertUnpubLabel.replace(/(.)(.*)/g, function(match, p1, p2){return p1+p2.toLowerCase()});
    let placehold = typeToAddLabel + " Name";
    let clickName = "Add " + typeToAddLabel;
    return (
      <div className="addnew">
        {
          this.state.showPrompt && 

              <form id="AddNewForm" onSubmit={this.handleSubmit}>
                <input type="text" autoFocus value={this.state.promptBoxText} onChange={this.handleChange} placeholder={placehold} />
                <a onClick={() => this.handleSubmit()}><img src={addbutton} alt="Add"/></a>
              </form>

        }
        {
          !this.state.showPrompt && <div><a className="editclass" onClick={() => this.addForm()}>{clickName}</a></div>
        }
        
     </div>
    )
  }
};

// class AddNewTest extends React.Component {
  
  // handleAddedObj=(obj)=>{
    // //console.log(obj);
  // }
  
  // render()  {
    // return (
  // <AddNew typeToAdd="FORM" procToCall="AddChild" code="" parNodeID="14" handleAddedObj={this.handleAddedObj}/>
    // )
  // }
// } 
 
//
//

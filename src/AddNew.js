import React from 'react';
import addbutton from './images/plus.png';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';

//USAGE:   // <AddNew typeToAdd="FORM" procToCall="AddChild" code="" parNode={this.state.adminData.root} getAddedObj={this.getAddedObj} />

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
        ID: this.props.parNode,
        Type: this.props.typeToAdd,
        Code: this.props.code,
        Descrip: this.state.promptBoxText,
        cachebuster: Math.random()
      }
    })
    .then(res => { 
      const newNode = res.data; 
       newNode.ItemValue = null;
       newNode.children = []; 
      this.props.getAddedObj(newNode);
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
    let convertUnpub = this.props.typeToAdd==="UNPUB"?"FORM":this.props.typeToAdd;
    let typeToAdd = convertUnpub.replace(/(.)(.*)/g, function(match, p1, p2){return p1+p2.toLowerCase()});
    let placehold = typeToAdd + " Name";
    let clickName = "Add " + typeToAdd;
    return (
      <div className="addnew">
        {
          this.state.showPrompt && 
            <div>
              <form id="AddNewForm" onSubmit={this.handleSubmit}>
                <input type="text" autoFocus value={this.state.promptBoxText} onChange={this.handleChange} placeholder={placehold} />
                <a onClick={() => this.handleSubmit()}><img src={addbutton} alt="Add"/></a>
              </form>
            </div>
        }
        {
          !this.state.showPrompt && <div><a className="editclass" onClick={() => this.addForm()}>{clickName}</a></div>
        }
        
     </div>
    )
  }
};

// class AddNewTest extends React.Component {
  
  // getAddedObj=(obj)=>{
    // console.log(obj);
  // }
  
  // render()  {
    // return (
  // <AddNew typeToAdd="FORM" procToCall="AddChild" code="" parNode="14" getAddedObj={this.getAddedObj}/>
    // )
  // }
// } 
 


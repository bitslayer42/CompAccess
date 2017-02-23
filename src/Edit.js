import React from 'react';
import AddNew from './AddNew';

export default class Edit extends React.Component {  
  constructor(props) {
    super(props);
    this.handleAddedObj = this.handleAddedObj.bind(this);
  }

  handleAddedObj=(obj)=>{ //debugger;
    console.log(obj);
    this.props.editCB(this.props.curr.nodeid,obj);
  }
  
  render() { 
    if(this.props.view !== "EDIT"){
      return null
    }else{
    return ( 
        <div className="editclass">
          {this.props.type==="FORM"
          && <AddNew typeToAdd="SECTION" procToCall="AddChild" code="" parNodeID={this.props.curr.FormID} handleAddedObj={this.handleAddedObj} />}          
          {this.props.type==="SECTION"
          && <AddNew typeToAdd=">>" procToCall="AddChild" code="" parNodeID={this.props.curr.FormID} handleAddedObj={this.handleAddedObj} />}   
          {this.props.type==="SECTIONAFTER"
          && <AddNew typeToAdd="SECTION" procToCall="InsNode" code="" parNodeID={this.props.curr.FormID} handleAddedObj={this.handleAddedObj} />}   
        </div>
      )
    }
  }
}

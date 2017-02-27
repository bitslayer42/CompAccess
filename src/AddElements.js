import React from 'react';
import AddNew from './AddNew';

export default class Edit extends React.Component {  
  constructor(props) {
    super(props);
    this.handleRedraw = this.handleRedraw.bind(this);
  }

  handleRedraw=()=>{ 
    this.props.handleRedraw();
  }
  
  render() { 
    if(this.props.view !== "EDIT"){
      return null
    }else{
    return ( 
        <div className="editclass" >
          {
            this.props.type==="FORM" ? (
              <AddNew typeToAdd="SECTION" procToCall="AddChild" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="SECTION" ? (
              <AddNew typeToAdd=">>" procToCall="AddChild" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="SECTIONAFTER" ? (
              <AddNew typeToAdd="SECTION" procToCall="InsNode" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="TEXTAFTER" ? (
              <AddNew typeToAdd=">>" procToCall="InsNode" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="NODE" ? (
              <span>
                <AddNew typeToAdd="REQUEST" procToCall="AddChild" code="REQUEST" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
                <AddNew typeToAdd="RESPONSE" procToCall="AddChild" code="RESPONSE" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
              </span>
            )
            : this.props.type==="NODEAFTER" ? (
              <AddNew typeToAdd=">>" procToCall="InsNode" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
           : this.props.type==="INPUTAFTER" ? (
              <AddNew typeToAdd=">>" procToCall="InsNode" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : <AddNew typeToAdd="TODO" procToCall="AddChild" code="" parNodeID="0" handleRedraw={this.handleRedraw} />

          }   
          
        </div>
      )
    }
  }
}
          // {this.props.type==="NODE"
          // && (

            // <AddNew typeToAdd="REQUEST" procToCall="InsNode" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            // <AddNew typeToAdd="RESPONSE" procToCall="InsNode" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />

          // )
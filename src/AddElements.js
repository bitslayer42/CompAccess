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
              <AddNew typeToAdd="SECTION" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="SECTION" ? (
              <AddNew typeToAdd=">>>" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="SECTIONAFTER" ? (
              <AddNew typeToAdd="SECTION" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="AFTER" ? (
              <AddNew typeToAdd=">>>" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="REQUEST" || this.props.type==="RESPONSE" ? (
              <AddNew typeToAdd=">>" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="RADIO" ? (
              <AddNew typeToAdd="OPTION" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : <AddNew typeToAdd="TODO" procToCall="AddChild" parNodeID="0" handleRedraw={this.handleRedraw} />

          }   
          
        </div>
      )
    }
  }
}
          // {this.props.type==="NODE"
          // && (

            // <AddNew typeToAdd="REQUEST" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            // <AddNew typeToAdd="RESPONSE" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />

          // )
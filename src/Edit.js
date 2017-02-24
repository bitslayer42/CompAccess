import React from 'react';
import AddNew from './AddNew';
import DeleteNode from './DeleteNode';

export default class Edit extends React.Component {  
  constructor(props) {
    super(props);
    this.handleAddedObj = this.handleAddedObj.bind(this);
  }

  handleAddedObj=(obj)=>{ //debugger;
    this.props.handleEdit();
  }

  handleDelete=(obj)=>{ //debugger;
    this.props.handleEdit();
  }
  
  render() { 
    if(this.props.view !== "EDIT"){
      return null
    }else{
    return ( 
        <div className="editclass" >
          {this.props.type==="FORM"
          && <AddNew typeToAdd="SECTION" procToCall="AddChild" code="" parNodeID={this.props.curr.FormID} handleAddedObj={this.handleAddedObj} />} 
          
          {this.props.type==="SECTION"
          && (
            <div>
            <DeleteNode DelID={this.props.curr.FormID} handleDelete={this.handleDelete} index={0}/>
            <AddNew typeToAdd="INPUT" procToCall="AddChild" code="" parNodeID={this.props.curr.FormID} handleAddedObj={this.handleAddedObj} />   
            <AddNew typeToAdd="RADIO" procToCall="AddChild" code="" parNodeID={this.props.curr.FormID} handleAddedObj={this.handleAddedObj} />   
            </div>
          )

          }
          {this.props.type==="SECTIONAFTER"
          && <AddNew typeToAdd="SECTION" procToCall="InsNode" code="" parNodeID={this.props.curr.FormID} handleAddedObj={this.handleAddedObj} />}   
        </div>
      )
    }
  }
}

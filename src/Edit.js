import React from 'react';
import AddNew from './AddNew';
import DeleteNode from './DeleteNode';

export default class Edit extends React.Component {  
  constructor(props) {
    super(props);
    this.handleAddedObj = this.handleAddedObj.bind(this);
  }

  handleAddedObj=(obj)=>{ //debugger;
    //console.log(obj);
    this.props.editCB(this.props.curr.nodeid,false,obj);
  }

  handleDelete=(obj)=>{ //debugger;
    //console.log("handleDelete",obj);
    this.props.editCB(this.props.curr.nodeid,true,null);
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

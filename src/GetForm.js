import React from 'react';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';
import Element from './Element';

export default class GetForm extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      view: props.params.view, //Can be "SUPV", "ADMIN", or "EDIT"
      formID: props.params.formID,
      reqID: props.params.reqID,
      nodes: [], //the tree 'flat'
      header: {},
      loading: true,
      error: null,
    };
    this.handleRedraw = this.handleRedraw.bind(this);
    this.getFromServer = this.getFromServer.bind(this);
  }
 
  componentDidMount() {
    this.getFromServer();
  }
  
  getFromServer(){
    axios.get(LibPath + 'FormJSON.cfm', {
      params: {
        FormID: this.state.formID,
        reqID: this.state.reqID,
        cachebuster: Math.random()
      }
    })
    .then(res => {
      const nodes = res.data.body; 
      const header = {};
      header.RequestID = res.data.RequestID;
      header.SupvName = res.data.SupvName;
      header.EnteredDate = res.data.EnteredDate;
      
      this.setState({
        nodes,
        header,
        loading: false,
        error: null
      });
    })
    .catch(err => { 
      this.setState({
        loading: false,
        error: err
      });
    }); 
  }

  handleRedraw() { //(renamed from EditCB) 
  // CallBack after adding or deleting node. Element is already deleted in db, 
  // now repull tree. 
    this.getFromServer();
  } 
  
  renderLoading() {
    return <div>Loading...</div>;
  }

  renderError() { 
    return (
      <div>
        Uh oh: {this.state.error.message}
      </div>
    );
  }
  
  makeTree() {     //debugger;
    let nodes = JSON.parse(JSON.stringify(this.state.nodes));
    let rootID = nodes[0].FormID;
    var map = {}, node, atree = [];
    for (var i = 0; i < nodes.length; i += 1) {
        node = nodes[i];
        node.nodeid = i;
        node.children = [];
        map[node.FormID] = i; // use map to look-up the parents:stackoverflow.com/questions/18017869/
        if (node.FormID !== rootID) {
            nodes[map[node.ParentID]].children.push(node);
        } else {
            atree.push(node); // first
        }
    }
                                                                          //console.log("statenodes",this.state.nodes); //console.log("localnodes",nodes);//console.log("atree",atree);
    return (
      <Element tree={atree} view={this.state.view} header={this.state.header} handleRedraw={this.handleRedraw}/>
    )
    
  }
  
  render()  {
    return (
      <div className="outerdiv">
          {this.state.loading ?
          this.renderLoading()
          : this.makeTree()}
      </div>
    );
  }
}


//export default GetForm;
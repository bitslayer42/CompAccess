import React from 'react';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';
import Element from './Element';

class GetForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      nodes: [],
      loading: true,
      error: null
    };
  }

  componentDidMount() {
      axios.get(LibPath + 'FormJSON.cfm', {
        params: {
          FORMCODE: 'CCPIT'
        }
      })
      .then(res => {
        const nodes = res.data; 
        
        // Update state to trigger a re-render.
        this.setState({
          nodes,
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

  handleClick(i) {
    i?console.log(i):console.log("clique");
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
  
  makeTree() { 
    let nodes = this.state.nodes;
    let rootID = nodes[0].ID;
    var map = {}, node, atree = [];
    for (var i = 0; i < nodes.length; i += 1) {
        node = nodes[i];
        node.children = [];
        map[node.ID] = i; // use map to look-up the parents:stackoverflow.com/questions/18017869/
        if (node.ID !== rootID) {
            nodes[map[node.ParentID]].children.push(node);
        } else {
            atree.push(node);
        }
    }
    //console.log(atree);
    return (
      <Element tree={atree} submitForm={(i) => this.handleClick(i)}/>
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


export default GetForm;
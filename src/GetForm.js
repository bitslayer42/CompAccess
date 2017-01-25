import React from 'react';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';

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
        console.log(res);

        const nodes = res.data; 

        // Update state to trigger a re-render.
        // Clear any errors, and turn off the loading indiciator.
        this.setState({
          nodes,
          loading: false,
          error: null
        });
      })
      .catch(err => {
        // Something went wrong. Save the error in state and re-render.
        this.setState({
          loading: false,
          error: err
        });
      }); 
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

  drawdots(n) {
    var dots = "";
    for(var i=1;i<n;i++){
      dots = dots.concat(" * ");
    }
    return dots; 
  }
  
  renderform() {
    if(this.state.error) {
      return this.renderError();
    }
    return (
      <div>
        {this.state.nodes.map(post =>
          (
        
            <div key={post.ID}>{this.drawdots(post.depth)}{post.Descrip}</div>

          )
        )}
      </div>
    );
  }

  render() {
    return (
      <div className="outerdiv">
        <h1>ITForm</h1>
        {this.state.loading ?
          this.renderLoading()
          : this.renderform()}
      </div>
    );
  }
}
export default GetForm;
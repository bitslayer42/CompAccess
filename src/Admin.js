import React from 'react';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';
import { Link } from 'react-router'

export default class Admin extends React.Component {
//Lists Forms
  constructor(props) { 
    super(props);

    this.state = {
      FormList: null,
      loading: true,
      error: null
    };
  }

  componentDidMount() { 
    axios.get(LibPath + 'DBGet.cfm', {
      params: {
        Proc: "ListForms",
        cachebuster: Math.random()
      }
    })
    .then(res => {
      const FormList = res.data; 
      
      // Update state to trigger a re-render.
      this.setState({
        FormList,
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
  
  renderLoading() {
    return <div>Loading...</div>;
  }

  renderNextStep() {
    var listItems = this.state.FormList.map(function(form){
      return <li key={form.ID}><Link to={`/supv/${form.ID}`}>{form.Descrip}</Link></li>;
    });
    return (
      <div>
        <h3> Form List </h3>
        <ul>
          {listItems}
        </ul>
        <div>
        <Link to={`/admin`}>Admin</Link>
        </div>
      </div>
    )
  }
  
  renderError() { 
    return (
      <div>
        Uh oh: {this.state.error.message}
      </div>
    );
  }
  
  render()  {
    return (
      <div className="outerdiv">
          {this.state.loading ?
          this.renderLoading()
          : this.renderNextStep()}
      </div>
    );
  }
}


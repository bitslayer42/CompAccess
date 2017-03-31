import React from 'react';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';
import { Link } from 'react-router'
import { browserHistory } from 'react-router';
import { HomePath } from './LibPath';

export default class Supv extends React.Component {
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
    if(this.state.FormList.length===1){
      browserHistory.replace(`/SUPV/${this.state.FormList[0].FormID}`);
    }else{
      var listItems = this.state.FormList.map(function(form){
        return (
          <li key={form.FormID}>
              <Link to={`${HomePath}SUPV/${form.FormID}`}>{form.Descrip}</Link><br/>
          </li> 
        )
      });
      return (
        <div className="formclass">
          <h1> Computer Access Forms </h1>
          <div className="sectionclass" >
          <h3> Form List </h3>
          <ul>
            {listItems}
          </ul>
          </div>
        </div>
      )
    }
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



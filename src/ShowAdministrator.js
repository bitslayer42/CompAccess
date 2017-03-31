import React from 'react';
//import { browserHistory } from 'react-router'
import axios from 'axios'; //ajax library
import LibPath from './LibPath';

export default class ShowAdministrator extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      userData: null,
      loading: true,
      error: null
    };
  } 
  componentDidMount() { 
    axios.get(LibPath + 'Administrator.cfm', {
      params: {
        Proc: "GetAdmin",
        AdminID: this.props.AdminRecord.AdminID,
        Name: this.props.AdminRecord.Name,
        EmailAddress: this.props.AdminRecord.EmailAddress,
        cachebuster: Math.random()
      }
    })
    .then(res => {
      const userData = res.data; 
      
      this.setState({
        userData,
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
    let userData = this.state.userData;
    
    //group by FormName
    let groupedList = userData.Subscrips.reduce((acc, item)=>{  
      var key = item.FormName;
      acc[key] = acc[key] || [];
      acc[key].push(item);
      return acc;
    }, {});

    let FormNames = Object.keys(groupedList);
    let listScrips = FormNames.map((Form,ix)=>{
      return (
        <div key={ix}>
          <div>{Form}</div>
          <table style={{margin:"0 auto"}}>
            <tbody>
            {groupedList[Form].map((Node,ix)=>{
              return(
              <AdminNodeCheckbox key={ix} node={Node} AdminID={userData.AdminID} />
             )
            })
            }
            </tbody>
          </table> 
        </div>
      )
    });

    return (    
    <div>
      <label>Name:</label>{userData.Name}<br/>
      <label>ID:</label>{userData.AdminID}<br/>
      <label>Email:</label>{userData.EmailAddress}<br/>
      <div>
        <h3 style={{margin:"0 auto"}}> Subscribe to emails for these systems</h3>
        <div>An email will be sent to you when a supervisor requests access to any checked system.</div>
        <div style={{margin:"0 auto"}}>
          {listScrips}
        </div>
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
      <div>
          {this.state.loading ?
          this.renderLoading()
          : this.renderNextStep()}
      </div>
    );
  }
}

class AdminNodeCheckbox extends React.Component {
 constructor(props) { 
    super(props);
    this.state = {
      value: this.props.node.Subscribed==="1"
    };
    this.onChange = this.onChange.bind(this);
  }
  
  onChange=()=>{ 
    let newval = !this.state.value;  
    this.setState({value: !this.state.value});    
    axios.get(LibPath + 'Administrator.cfm', {
      params: {
        Proc: "ToggleEmail",
        AdminID: this.props.AdminID,
        NodeID: this.props.node.ID,
        cachebuster: Math.random()
      }
    })
    .then(() => {  
      this.setState({
        value: newval
      });
    })
    .catch(err => {
      console.log(err);
    });
  }  

  render()  {   
      return (
        <tr className="reqsrow"  onClick={this.onChange}>
          <td>
            <input type="checkbox" checked={this.state.value} onChange={this.onChange} />
            {this.props.node.Descrip}
          </td>
        </tr>
      )
  }
};


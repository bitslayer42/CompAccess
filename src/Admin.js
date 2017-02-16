import React from 'react';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';
import AddNew from './AddNew';
import { Link } from 'react-router';
import { hashHistory } from 'react-router';

export default class Admin extends React.Component {

  constructor(props) { 
    super(props);

    this.state = {
      adminData: null,
      loading: true,
      error: null
    };
    this.getAddedForm = this.getAddedForm.bind(this);
  }

  componentDidMount() { 
    axios.get(LibPath + 'AdminJSON.cfm')
    .then(res => {
      const adminData = res.data; 
      
      this.setState({
        adminData,
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
  
  unpackXML(xmlStr) { //The request has some of the key detail fields duplicated in the Requests.headerXML field, here we turn xml into a table row.
    let text = "<xml>" + xmlStr + "</xml>";

    let parser = new DOMParser();
    let xmlDoc = parser.parseFromString(text,"text/xml");
    let returnArr = [];
    let values = xmlDoc.getElementsByTagName("ItemValue");
    for (let i = 0; i < values.length; i++) {
        values[i].childNodes[0] && returnArr.push(<td key={i}>{values[i].childNodes[0].nodeValue}</td>);
    }
    return returnArr;
  }
  
  handleFormRowClick(id){
    hashHistory.push(`/ADMIN/0/${id}`);
  }
  
  getAddedForm(obj){
    let newForm = {
      "Descrip":obj.Descrip,
      "ID":obj.FormID
    }
    let newAdminData = {
      "admins": this.state.adminData.admins,
      "forms": this.state.adminData.forms.concat(newForm),
      "requests": this.state.adminData.requests,
      "root": this.state.adminData.root
    }
    this.setState({
      adminData: newAdminData
    });    
    console.log(this.state.adminData);
  }
  
  handleNewAdminClick(){
    console.log("handleNewAdminClick");
  }
  
  renderNextStep() {                                                          console.log(this.state.adminData);
    var self = this; //so nested funcs can see the parent object
    let listRequests = <tr><td>No unresolved requests.</td></tr>
    if(this.state.adminData.requests[0]) { 
      listRequests = this.state.adminData.requests.map(function(req){
        return (
          <tr key={req.RequestID}  className="reqsrow" onClick={() => self.handleFormRowClick(req.RequestID)}>
            
            {self.unpackXML(req.headerXML)}
          </tr>
        )
      });
    }
    let listFormsEDIT = this.state.adminData.forms.map(function(form){
      return <li key={form.ID}><Link to={`/EDIT/${form.ID}`}>{form.Descrip}</Link></li>;
    });
    let listFormsSUPV = this.state.adminData.forms.map(function(form){
      return <li key={form.ID}><Link to={`/SUPV/${form.ID}`}>{form.Descrip}</Link></li>;
    });
    let listAdmins = this.state.adminData.admins.map(function(adm){
      return <li key={adm.AdminID}><Link to={`/useradmin/${adm.AdminID}`}>{adm.Name}</Link></li>;
    });
    return (
      <div className="formclass" >
        <h1>Computer Access Forms-Admin</h1>
        <div className="sectionclass" >
        <h3> Unresolved Queue </h3>
        <table>
          <tbody>
            <tr><th>Form</th><th>Name</th><th>Reason</th><th>Access Needed</th></tr>
            {listRequests}
          </tbody>
        </table>
        </div>
        
        <div className="sectionclass" >
        <h3> Search Forms </h3>
        <ul>
          <input/><button>Search</button>
        </ul>
        </div>
        
        <div className="sectionclass" >
        <h3> Edit Forms </h3>
        <ul>
          {listFormsEDIT}
        </ul>
        <ul>
          <li className="editclass">
            <AddNew typeToAdd="UNPUB" procToCall="AddChild" code="" parNode={this.state.adminData.root} getAddedObj={this.getAddedForm} />
          </li>
        </ul>
        </div>
        
        <div className="sectionclass" >
        <h3> Administrators </h3>
        <ul>
          {listAdmins}
        </ul>
        <ul>
          <li className="editclass" onClick={() => self.handleNewAdminClick()}>Add New Administrator</li>
        </ul> 
        </div>
        
        <div className="sectionclass" >        
        <h3> Enter a Request </h3>
        <ul>
          {listFormsSUPV}
        </ul>
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



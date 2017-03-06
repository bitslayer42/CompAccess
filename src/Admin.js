import React from 'react';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';
import AddElement from './AddElement';
import TogglePublish from './TogglePublish';
import DeleteElement from './DeleteElement';
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
    this.handleRedraw = this.handleRedraw.bind(this);
    this.getFromServer = this.getFromServer.bind(this);
  }

  componentDidMount() { 
    this.getFromServer();
  }
  
  getFromServer(){  
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
    let cols = xmlDoc.getElementsByTagName("Col");
    let values = xmlDoc.getElementsByTagName("ItemValue");
    for (let i = 0; i < values.length; i++) {
    values[i].childNodes[0] && returnArr.push(<td key={i}><div className="queueheaders">{cols[i].childNodes[0].nodeValue}:</div>{values[i].childNodes[0].nodeValue}</td>);  
    }
    return returnArr;
  }
  
  handleFormRowClick(ReqID){
    hashHistory.push(`/ADMIN/0/${ReqID}`); 
  }

  handleRedraw() { //(renamed from EditCB) 
  // CallBack after adding or deleting node. Element is already deleted in db, 
  // now repull tree. 
    this.getFromServer();
  } 
    
  handleNewAdminClick(){
    //console.log("handleNewAdminClick");
  }

  
  renderNextStep() {   //console.log("adminData",this.state.adminData);                                                      
    var self = this; //so nested funcs can see the parent object
    let listRequests = <tr ><td colSpan="4">No unresolved requests.</td></tr>
    if(this.state.adminData.requests[0]) { 
      listRequests = this.state.adminData.requests.map(function(req){
        return (
          <tr key={req.RequestID}  className="reqsrow" onClick={() => self.handleFormRowClick(req.RequestID)}>
            
            {self.unpackXML(req.headerXML)}
          </tr>
        )
      });
    }
    let listFormsEDIT = this.state.adminData.forms.map(function(form,ix){
      return (
        <tr key={form.FormID}>
          <td>
          <TogglePublish FormID={form.FormID} published={form.Type==="FORM" ? true : false} handleRedraw={self.handleRedraw} />
          </td><td>
          <Link to={`/EDIT/${form.FormID}`}>{form.Descrip}</Link>
          </td><td>
          <DeleteElement DelID={form.FormID} view="EDIT" handleRedraw={self.handleRedraw}  />
          </td>
        </tr>
      )
    });
    let listFormsSUPV = this.state.adminData.forms.map(function(form){
      return <li key={form.FormID}><Link to={`/SUPV/${form.FormID}`}>{form.Descrip}</Link></li>;
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
        <table>
          <tbody>
            {listFormsEDIT}
          </tbody>
        </table>
        <ul>
          <li >
            <AddElement typeToAdd="UNPUB" procToCall="AddChild" parNodeID={this.state.adminData.root} handleRedraw={self.handleRedraw} />
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



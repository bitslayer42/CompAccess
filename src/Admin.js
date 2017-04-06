import React from 'react';
import axios from 'axios'; //ajax library
import { HomePath, LibPath } from './LibPath';
import AddElement from './AddElement';
import TogglePublish from './TogglePublish'; 
import DeleteElement from './DeleteElement';
import DeleteAdmin from './DeleteAdmin';
import Search from './Search';
import { Link } from 'react-router';
import { browserHistory } from 'react-router';
import moment from 'moment'; //date library

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
  
  unpackXML(headerXML,EditedXML) { //The request has some of the key detail fields duplicated in the Requests.headerXML field, here we turn xml into a table row.
    let xmlDoc;
    let returnArr = [];
    let parser = new DOMParser();
    
    xmlDoc = parser.parseFromString(headerXML,"text/xml");
    let cols = xmlDoc.getElementsByTagName("Col");
    let values = xmlDoc.getElementsByTagName("ItemValue");
    for (let i = 0; i < values.length; i++) {
      values[i].childNodes[0] && cols[i].childNodes[0] 
      && returnArr.push(<td key={i}><div className="queueheaders">{cols[i].childNodes[0].nodeValue}:</div>{values[i].childNodes[0].nodeValue}</td>);  
    }

    xmlDoc = parser.parseFromString(EditedXML,"text/xml");
    let names = xmlDoc.getElementsByTagName("UserName");
    let dates = xmlDoc.getElementsByTagName("DateMod");
    let EditedTD = [];
    for (let i = 0; i < names.length; i++) {
      let formatdate = moment(dates[i].childNodes[0].nodeValue).format("MM/DD/YY, h:mma");
      names[i].childNodes[0] && dates[i].childNodes[0] 
      && EditedTD.push(<p key={i} style={{margin:"0",fontSize:"0.7em"}}>{names[i].childNodes[0].nodeValue}({formatdate})</p>);  
    }    
    returnArr.push(<td key="100"><div className="queueheaders">Edited By:</div>{EditedTD}</td>);
    
    return returnArr;
  }
  
  handleFormRowClick(ReqID){
    browserHistory.push(`${HomePath}ADMIN/0/${ReqID}`); 
  }

  handleRedraw() { //(renamed from EditCB) 
  // CallBack after adding or deleting node. Element is already deleted in db, 
  // now repull tree. 
    this.getFromServer();
  } 
  
  renderNextStep() {   //console.log("adminData",this.state.adminData);                                                      
    var self = this; //so nested funcs can see the parent object
    let listRequests = <tr ><td>No unresolved requests.</td></tr>
    if(this.state.adminData.requests[0]) { 
      listRequests = this.state.adminData.requests.map(function(req){
        return (
          <tr key={req.RequestID}  className="reqsrow" onClick={() => self.handleFormRowClick(req.RequestID)}>
            {self.unpackXML(req.headerXML,req.EditedXML)}
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
          <Link to={`${HomePath}PREVIEW/${form.FormID}`}>{form.Descrip}</Link>
          </td><td>
          <DeleteElement FormID={form.FormID} handleRedraw={self.handleRedraw}  />
          </td>
        </tr>
      )
    });
    let listFormsSUPV = this.state.adminData.forms.map(function(form){
      return <li key={form.FormID}><Link to={`${HomePath}SUPV/${form.FormID}`}>{form.Descrip}</Link></li>;
    });
    let listAdmins = this.state.adminData.admins.map(function(adm){
      return (
        <tr key={adm.AdminID}>
          <td>
          <Link to={`${HomePath}useradmin/${adm.AdminID}`}>{adm.Name}</Link>
          </td><td>
          <DeleteAdmin AdminID={adm.AdminID} handleRedraw={self.handleRedraw}  />
          </td>
        </tr>
      )      
    });
    return (
     <div>
      <a href="https://ccp1.msj.org/login/login/home.cfm"> &larr; Intranet Login Menu </a>
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
        <h3> Search Requests </h3>
            <Search />
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
        <h3> View Completed Form </h3>
        <ul>
          {listFormsSUPV}
        </ul>
        </div>        
        <div className="sectionclass" >
        <h3> Administrators </h3>
        <table>
          <tbody>
            {listAdmins}
          </tbody>
        </table>        

        <ul>
          <Link className="editclass"  to={`${HomePath}useradmin`}>Add New Administrator</Link>
        </ul> 
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
      <div className="adminouterdiv">
          {this.state.loading ?
          this.renderLoading()
          : this.renderNextStep()}
      </div>
    );
  }
}



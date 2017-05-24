import React from 'react';
//import { BrowserRouter } from 'react-router-dom'
import axios from 'axios'; //ajax library
import { LibPath, HomePath } from './LibPath';
import { Link } from 'react-router-dom'

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
        AdminID: this.props.match.params.AdminID,
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
    const userData = this.state.userData;
    
    //group by FormName
    const groupedList = userData.Subscrips.reduce((acc, item)=>{  
      const key = item.FormName;
      acc[key] = acc[key] || [];
      acc[key].push(item);
      return acc;
    }, {});

    const FormNames = Object.keys(groupedList);
    const listScrips = FormNames.map((Form,ix)=>{
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
      <div className="outerdiv">
        <Link to={HomePath}>&larr; Return to Admin menu</Link>
        <div className="formclass">	
			<div className="sectionclass" >	
			  <label>Name:</label>{userData.Name}<br/>
			  <label>ID:</label>{userData.AdminID}<br/>
			  <label>Email:</label>{userData.EmailAddress}<br/>
			  <div style={{margin:"0 auto",width:"700px"}}>
				<h3 style={{textAlign:"center"}}> Subscribe to emails for these systems</h3>
				<div><i>An email will be sent to you when a supervisor requests access to any checked system.</i></div>
				<div style={{textAlign:"center",fontSize:"1.6em"}}>
				  {listScrips}
				</div>
			  </div>
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
  
  onChange=()=>{ //debugger;
    const newval = !this.state.value;   
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
        <tr className="reqsrow">
          <td style={{width:"400px"}}>
            <label style={{textAlign:"left",paddingLeft:"20px",width:"100%"}}>
            <input type="checkbox"  checked={this.state.value} onChange={this.onChange} />
            {this.props.node.Descrip}
            </label>
          </td>
        </tr>
      )
  }
};


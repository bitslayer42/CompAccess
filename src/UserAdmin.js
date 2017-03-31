import React from 'react';
import StaffList from './StaffList';
import ShowAdministrator from './ShowAdministrator';
import { browserHistory, Link } from 'react-router'

export default class UserAdmin extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      AdminRecord: null
    };
    this.handleAdminID = this.handleAdminID.bind(this);
  }

  componentWillMount() {
    const AdminRecord = {};
    AdminRecord.AdminID = this.props.params.AdminID;
    AdminRecord.Name = "";
    AdminRecord.EmailAddress = "";
    this.state = {
      AdminRecord: AdminRecord
    };
  }
  
  handleAdminID(SelectedStaff){ 
    //console.log(SelectedStaff);
    const selAdmin = {};
    selAdmin.AdminID = SelectedStaff.BadgeNum;
    selAdmin.Name = SelectedStaff.Name;
    selAdmin.EmailAddress = SelectedStaff.EmailAddress;
      this.setState({
        AdminRecord: selAdmin
      });   
    browserHistory.replace(`/useradmin/${SelectedStaff.BadgeNum}`);      
  }

  render()  { 
    return (
      <div>
        <Link to={'/'}>&larr; Return to Admin menu</Link>
        <div className="formclass">
          <h1> Computer Access Forms </h1>
          <div className="sectionclass" >
            {this.props.params.AdminID===undefined 
            ? <StaffList handleAdminID={this.handleAdminID} /> //
            : <ShowAdministrator AdminRecord={this.state.AdminRecord} />
            }
          </div>
        </div>
      </div>      
    );
  }
}

import React from 'react';
import axios from 'axios'; //ajax library
import { LibPath, HomePath } from './LibPath';
import { Redirect } from 'react-router-dom'
import moment from 'moment'; //date library

export default class Search extends React.Component {

  constructor(props) { 
    super(props);

    this.state = {
      searchString: "",
	  clickedQue: null,
      returnData: null
    };
    this.getFromServer = this.getFromServer.bind(this);
    this.handleOnChange = this.handleOnChange.bind(this);
    
  }


  getFromServer(searchString){  
    axios.get(LibPath + 'SearchJSON.cfm', {
      params: {
        searchString: searchString,
        cachebuster: Math.random()
      }
    })  
    .then(res => {
      const returnData = res.data; 
      
      this.setState({
        returnData
      });
    })
    .catch(err => {
      console.log("error loading search");
    });
  }
  
  
  unpackXML(headerXML,EditedXML) { //The request has some of the key detail fields duplicated in the Requests.headerXML field, here we turn xml into a table row.
    let xmlDoc;
    const returnArr = [];
    const parser = new DOMParser();
    
    xmlDoc = parser.parseFromString(headerXML,"text/xml");
    const cols = xmlDoc.getElementsByTagName("Col");
    const values = xmlDoc.getElementsByTagName("ItemValue");
    for (let i = 0; i < values.length; i++) {
      values[i].childNodes[0] && cols[i].childNodes[0] 
      && returnArr.push(<td key={i}><div className="queueheaders">{cols[i].childNodes[0].nodeValue}:</div>{values[i].childNodes[0].nodeValue}</td>);  
    }

    xmlDoc = parser.parseFromString(EditedXML,"text/xml");
    const names = xmlDoc.getElementsByTagName("UserName");
    const dates = xmlDoc.getElementsByTagName("DateMod");
    const EditedTD = [];
    for (let i = 0; i < names.length; i++) {
      const formatdate = moment(dates[i].childNodes[0].nodeValue).format("MM/DD/YY, h:mma");
      names[i].childNodes[0] && dates[i].childNodes[0] 
      && EditedTD.push(<p key={i} style={{margin:"0",fontSize:"0.7em"}}>{names[i].childNodes[0].nodeValue}({formatdate})</p>);  
    }    
    returnArr.push(<td key="100"><div className="queueheaders">Edited By:</div>{EditedTD}</td>);
    
    return returnArr;
  }

  handleOnChange(event){
    this.setState({
      searchString: event.target.value
    });
    if(event.target.value.length === 0){
      this.setState({
        returnData: null
      });
    }else{
      this.getFromServer(event.target.value);
    }
  }
  
  handleFormRowClick(ReqID){
      this.setState({
        clickedQue: ReqID
      }); 	   
  }
  
  render()  {
    const self = this; //so nested funcs can see the parent object   
	if(this.state.clickedQue){
		return(
			<Redirect push to={`${HomePath}ADMIN/0/${this.state.clickedQue}`} />
		)
	}else{      
		return (
		  <div >
			<input value={this.state.searchString} onChange={this.handleOnChange} placeholder="search" />
			<table><tbody>
			{this.state.returnData  
			 ? this.state.returnData.requests[0] 
			  ? this.state.returnData.requests.map(function(req){
				  return (
					<tr key={req.RequestID}  className="reqsrow" onClick={() => self.handleFormRowClick(req.RequestID)}>
					  {self.unpackXML(req.headerXML,req.EditedXML)}
					</tr>
				  )
				})
			  : <tr ><td>No matching records.</td></tr>
			 : null
			}
			</tbody></table>
		  </div>
		);
	}
  }
}



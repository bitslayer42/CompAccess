import React from 'react';
import { Link } from 'react-router-dom';
import { HomePath } from './LibPath';

export default class Special extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      SpecialID: this.props.SpecialID,
	  SpecialData: null
    };
  } 

  
  render()  {
    return (
      <div className="outerdiv">
        <Link to={HomePath}>&larr; Return to Admin menu</Link>
        <div className="formclass">
          <h1> Computer Access Forms </h1>
          <div className="sectionclass" >
			  Hiya!

          </div>
        </div>
      </div> 
    );
  }
}
 
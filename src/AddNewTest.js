import React from 'react';

export default class AddNew extends React.Component {
  constructor(props) { 
    super(props);

    this.state = {
      username: 'Jon'
    };
  }

  handleChange = (e) => {
    this.setState({ 
      username: e.target.value
    });
  }
  render()  {
    return (
      <div>
        Hello {this.state.username} <br />
        Change Name: <input type="text" value={this.state.username} onChange={this.handleChange} />
      </div>
    )
  }
};

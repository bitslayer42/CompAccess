  constructor(props) { 
    super(props);

    this.state = {
      adminData: null,
      loading: true,
      error: null
    };

    this.handleTogglePublish = this.handleTogglePublish.bind(this);
  }
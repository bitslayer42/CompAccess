import { browserHistory, Router, Route, IndexRoute } from 'react-router'

ReactDOM.render((
  <Router>
    <Route component={MainLayout}>
      <Route path="/" component={Home} />
      <Route component={SearchLayout}>
        <Route path="users" component={UserList} />
        <Route path="widgets" component={WidgetList} />
      </Route> 
    </Route>
  </Router>
), document.getElementById('root'));


Place inside parent components:
{this.props.children}

    return (
      <div className="search">
        <header className="search-header"></header>
        <div className="results">
          {this.props.children}
        </div>
        <div className="search-footer pagination"></div>
      </div>
    );
    
  //---------------------------------------------------------------  
<Route path="product">
  <IndexRoute component={ProductProfile} />
  <Route path="settings" component={ProductSettings} />
</Route>    

is equiv of:

<Route path="product" component={ProductProfile} />
<Route path="product/settings" component={ProductSettings} />
    
  //---------------------------------------------------------------  
adding links:
<Link to="/">Home</Link>
    
  //--------------------------------------------------------------- 
Browser history:
  
<Router history={browserHistory}>     <- requires server config
hashHistory                           <- ugly urls example.com/#/some/path?_k=ckuvup


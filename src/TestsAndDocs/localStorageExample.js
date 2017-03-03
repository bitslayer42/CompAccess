localStorage.setItem('favoriteflavor','vanilla');
var taste = localStorage.getItem('favoriteflavor');
localStorage.removeItem('favoriteflavor');

localStorage.setItem( 'car', JSON.stringify(car) );
console.log( JSON.parse( localStorage.getItem( 'car' ) ) );

if(localStorage && localStorage.getItem('thewholefrigginworld')){
  render(JSON.parse(localStorage.getItem('thewholefrigginworld')));
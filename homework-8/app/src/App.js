import './App.css';
import 'bootstrap/dist/css/bootstrap.min.css';
import { Routes, Route, Outlet, Link } from 'react-router-dom'
import { Container, Row, Col, Button } from 'react-bootstrap'
import Search from './pages/Search'
import Bookings from './pages/Bookings'

export default function App() {
  return (
    <div className='background' style={{ backgroundImage: 'url(/city.jpg)'}}>
      <Routes>
        <Route path='/search' element={<Layout />}>
          <Route index element={<Search />} />
          <Route path='bookings' element={<Bookings />} />
        </Route>
      </Routes>
    </div>
  );
}

function Layout() {
  return (
      <Container>
        <Row>
          <Col>
            <div className='nav-bar'>
              <Button className='nav-button' variant='outline-dark' size='sm' style={window.location.pathname === '/search' ? {border: '2px solid', borderRadius: '12px'} : null}><Link to='/search'>Search</Link></Button>
              <Button className='nav-button' variant='outline-dark' size='sm' style={window.location.pathname === '/bookings' ? {border: '2px solid', borderRadius: '12px'} : null}><Link to='/bookings'>My Bookings</Link></Button>
            </div>
          </Col>
        </Row>
        <Row>
          <Col>
            <Outlet />
          </Col>
        </Row>
      </Container>
  )
}
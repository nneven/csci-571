import './App.css'
import 'bootstrap/dist/css/bootstrap.min.css'
import React, { useState } from 'react'
import { Routes, Route, Outlet, Link } from 'react-router-dom'
import { Container, Row, Col, Button } from 'react-bootstrap'
import Search from './pages/Search'
import Bookings from './pages/Bookings'

export default function App() {
  const [page, setPage] = useState('search')

  function Layout() {
    return (
      <>
        <Container fluid>
          <Row>
            <Col className='nav-bar' md="auto">
              <Link to='/search'><Button className='nav-button' variant='outline-dark' size='sm' style={{border: '2px solid', borderRadius: '12px', borderColor: page !== 'search' && 'transparent'}} onClick={e => setPage('search')}>Search</Button></Link>
              <Link to='/bookings'><Button className='nav-button' variant='outline-dark' size='sm' style={{border: '2px solid', borderRadius: '12px', borderColor: page !== 'bookings' && 'transparent'}} onClick={e => setPage('bookings')}>My Bookings</Button></Link>
            </Col>
          </Row>
        </Container>
        <Container>
          <Row>
            <Col>
              <Outlet />
            </Col>
          </Row>
        </Container>
      </>
    )
  }

  return (
    <div className='background' style={{ backgroundImage: 'url(/city.jpg)'}}>
      <Routes>
        <Route path='/' element={<Layout />}>
          <Route path='search' element={<Search />} />
          <Route path='bookings' element={<Bookings />} />
        </Route>
      </Routes>
    </div>
  )
}

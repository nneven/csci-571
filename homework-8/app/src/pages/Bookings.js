import './Bookings.css'
import React, { useEffect, useState } from 'react'
import axios from 'axios'
import { Container, Row, Col, Button, Table } from 'react-bootstrap'
import { Link } from 'react-router-dom'

export default function Bookings() {
  const [bookings, setBookings] = useState([])
  const [page, setPage] = useState('bookings')

  useEffect(() => {
    axios.get('https://csci-571-363723.wl.r.appspot.com/reservations')
      .then(res => {
        setBookings(res.data)
      })
  }, [])

  function cancel(index) {
    axios.get(`https://csci-571-363723.wl.r.appspot.com/cancel?index=${index}`)
      .then(res => {
        setBookings(res.data)
      })
    alert("Reservation canceled!")
  }

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
            {!!bookings.length && <h3 className="bookings-header">List of your reservations</h3>}
            {!!bookings.length && <Table className="bookings-table text-center" striped>
              <thead>
                <tr>
                  <th>#</th>
                  <th>Business Name</th>
                  <th>Date</th>
                  <th>Time</th>
                  <th>Email</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {bookings.map((booking, index) => (
                  <tr key={index}>
                    <td>{index + 1}</td>
                    <td>{booking.business}</td>
                    <td>{booking.date}</td>
                    <td>{booking.time}</td>
                    <td>{booking.email}</td>
                    <td><img src="https://cdn-icons-png.flaticon.com/512/2891/2891491.png" alt="trash" width="16" onClick={e => cancel(index)}/></td>
                  </tr>
                ))}
              </tbody>
            </Table>}
            {!bookings.length && <h4 className="text-center no-reservations">No reservations to show</h4>}
          </Col>
        </Row>
      </Container>
    </>
  )
}
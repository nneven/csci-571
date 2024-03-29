import './Bookings.css'
import React, { useEffect, useState } from 'react'
import axios from 'axios'
import { Table } from 'react-bootstrap'

export default function Bookings() {
  const [bookings, setBookings] = useState([])

  useEffect(() => {
    axios.get('https://csci-571-363723.wl.r.appspot.com/reservations')
      .then(res => {
        setBookings(res.data)
        console.log(res.data)
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
              <td><img className="trash-icon" src="https://cdn-icons-png.flaticon.com/512/2891/2891491.png" alt="trash" width="16" onClick={e => cancel(index)}/></td>
            </tr>
          ))}
        </tbody>
      </Table>}
      {!bookings.length && <h4 className="text-center no-reservations">No reservations to show</h4>}
    </>
  )
}
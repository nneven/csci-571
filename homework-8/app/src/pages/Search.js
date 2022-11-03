import './Search.css'
import React, { useState } from 'react'
import { Row, Col, Form, Button, Table } from 'react-bootstrap'
import axios from 'axios'

export default function Search() {
  const [keyword, setKeyword] = useState('')
  const [distance, setDistance] = useState(10)
  const [category, setCategory] = useState('Default')
  const [location, setLocation] = useState('')
  const [autoDetect, setAutoDetect] = useState(false)
  const [searchResult, setSearchResult] = useState([])

  async function submit(event) {
    event.preventDefault()

    let latitude, longitude
    if (autoDetect) {
      await axios.get('https://ipinfo.io?token=41eab4d12ac318')
        .then(response => {
          const loc = response.data.loc.split(',')
          latitude = loc[0]
          longitude = loc[1]
        })
        .catch(error => {
          console.log(error)
        })
    } else {
      await axios.get('https://csci-571-363723.wl.r.appspot.com/google', {
        params: {
          url: `https://maps.googleapis.com/maps/api/geocode/json?address=${location}&key=AIzaSyDZQNW6Ut1G3ySELQPBUsI6JpdatAUyxvo`
        }
      })
        .then(response => {
          const loc = response.data.results[0].geometry.location
          latitude = String(loc.lat)
          longitude = String(loc.lng)
        })
        .catch(error => {
          console.log(error)
        })
    }

    await axios.get('https://csci-571-363723.wl.r.appspot.com/yelp', {
      params: {
        url: `https://api.yelp.com/v3/businesses/search?term=${keyword}&latitude=${latitude}&longitude=${longitude}&category=${category}&radius=${parseInt(distance * 1609.34)}&limit=10`
      }
    })
      .then(response => {
        if (!response.data.businesses) return
        else {
          const result = response.data.businesses.map(business => {
            return {
              id: business.id,
              name: business.name,
              image: business.image_url,
              rating: business.rating,
              distance: business.distance / 1609.34,
            }
          })
          setSearchResult(result)
          console.log(result)
        }
      }
    )
  }

  function clear(event) {
    setKeyword('')
    setDistance(10)
    setCategory('Default')
    setLocation('')
    setAutoDetect(false)
    setSearchResult([])
  }

  function SearchTable({ searchResult }) {
    return (
      <Table striped>
        <thead className="text-center">
          <tr>
            <th>#</th>
            <th>Image</th>
            <th>Business Name</th>
            <th>Rating</th>
            <th>Distance (miles)</th>
          </tr>
        </thead>
        <tbody className="text-center">
          {searchResult.map((business, index) => (
            <tr key={business.id}>
              <td style={{fontWeight: 600}}>{index + 1}</td>
              <td><img src={business.image} alt={business.name} height="120" width="120"/></td>
              <td>{business.name}</td>
              <td>{business.rating}</td>
              <td>{Math.round(business.distance)}</td>
            </tr>
          ))}
        </tbody>
      </Table>
    )
  }

  return (
    <>
    <Form className="search" onSubmit={submit}>
      <Form.Group className="mb-3">
        <Form.Label>Keyword<span className="star">*</span></Form.Label>
        <Form.Control type="text" value={keyword} onChange={e => setKeyword(e.target.value)} required />
      </Form.Group>
      <Row className="mb-3">
        <Form.Group as={Col}>
          <Form.Label>Distance</Form.Label>
          <Form.Control type="number" value={distance} onChange={e => setDistance(e.target.value)}/>
        </Form.Group>
        <Form.Group as={Col}>
          <Form.Label>Category<span className="star">*</span></Form.Label>
          <Form.Select value={category} onChange={e => setCategory(e.target.value)} required>
            <option value="all">Default</option>
            <option value="arts">Arts and Entertainment</option>
            <option value="health">Health and  Medical</option>
            <option value="hotelstravel">Hotels and Travel</option>
            <option value="food">Food</option>
            <option value="professional">Professional Services</option>
          </Form.Select>
        </Form.Group>
      </Row>
      <Form.Group className="mb-3">
        <Form.Label>Location<span className="star">*</span></Form.Label>
        <Form.Control type="text" value={location} onChange={e => setLocation(e.target.value)} required disabled={autoDetect}/>
      </Form.Group>
      <Form.Group className="mb-3">
        <Form.Check type="checkbox" label="Auto-detect my location" value={autoDetect} onChange={e => setAutoDetect(e.target.checked)} />
      </Form.Group>
      <Row className="mb-3 justify-content-center">
        <Col md="auto">
          <Button className="form-button" variant="danger" type="submit">Submit</Button>
        </Col>
        <Col md="auto">
          <Button className="form-button" variant="primary" type="reset" onClick={clear}>Clear</Button>
        </Col>
      </Row>
    </Form>
    {searchResult.length > 0 && <SearchTable searchResult={searchResult}/>}
    </>
  )
}
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
      await axios.get(`https://maps.googleapis.com/maps/api/geocode/json?address=${location}&key=AIzaSyDZQNW6Ut1G3ySELQPBUsI6JpdatAUyxvo`)
        .then(response => {
          console.log(response)
          const loc = response.data.results[0].geometry.location
          latitude = String(loc.lat)
          longitude = String(loc.lng)
        })
        .catch(error => {
          console.log(error)
        })
    }

    let request = `term=${keyword}&latitude=${latitude}&longitude=${longitude}&category=${category}`
    if (distance) request += `&radius=${parseInt(distance) * 1600}`
    await axios.get('https://csci-571-363723.wl.r.appspot.com/yelp', {
      params: {
        url: `https://api.yelp.com/v3/businesses/search?${request}`
      }
    })
      .then(response => {
        if (response.data.error || response.data.businesses.length === 0) return
        else {
          const result = response.data.businesses.map(business => {
            return {
              name: business.name,
              image: business.image_url,
              rating: business.rating,
              reviewCount: business.review_count,
              address: business.location.display_address.join(', '),
              phone: business.display_phone,
              categories: business.categories.map(category => category.title).join(', '),
              url: business.url
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
  }

  function SearchTable() {
    return (
      <Table striped>
        <thead>
          <tr>
            <th>#</th>
            <th>Image</th>
            <th>Business Name</th>
            <th>Rating</th>
            <th>Distance (miles)</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>1</td>
            <td>Image</td>
            <td>The Donut Man</td>
            <td>4</td>
            <td>0</td>
          </tr>
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
            <option>Default</option>
            <option>Arts and Entertainment</option>
            <option>Health and  Medical</option>
            <option>Hotels and Travel</option>
            <option>Food</option>
            <option>Professional Services</option>
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
    {searchResult.length > 0 && <SearchTable />}
    </>
  )
}
import './Search.css'
import React, { useState } from 'react'
import { Row, Col, Form, Button, Table } from 'react-bootstrap'

export default function Search() {
  const [keyword, setKeyword] = useState('')
  const [distance, setDistance] = useState(10)
  const [category, setCategory] = useState('Default')
  const [location, setLocation] = useState('')
  const [autoDetect, setAutoDetect] = useState(false)
  const [searchResult, setSearchResult] = useState([])

  function submit(event) {
    return alert(keyword + distance + category + location + autoDetect)
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
        <Form.Control type="text" value={location} onChange={e => setLocation(e.target.value)} required/>
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
import './Search.css'
import React, { useState } from 'react'
import axios from 'axios'
import { Container, Row, Col, Form, Button, Table, Tab, Tabs, Carousel } from 'react-bootstrap'
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api';

export default function Search() {
  const [keyword, setKeyword] = useState('')
  const [distance, setDistance] = useState(10)
  const [category, setCategory] = useState('Default')
  const [location, setLocation] = useState('')
  const [autoDetect, setAutoDetect] = useState(false)
  const [searchResult, setSearchResult] = useState([])
  const [business, setBusiness] = useState()
  const [reviews, setReviews] = useState()

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

  async function getBusiness(id) {
    await axios.get('https://csci-571-363723.wl.r.appspot.com/yelp', {
      params: {
        url: `https://api.yelp.com/v3/businesses/${id}`
      }
    })
      .then(response => {
        setBusiness(response.data)
      })
    
    await axios.get('https://csci-571-363723.wl.r.appspot.com/yelp', {
      params: {
        url: `https://api.yelp.com/v3/businesses/${id}/reviews`
      }
    })
      .then(response => {
        setReviews(response.data)
      })
  }

  function clear() {
    setKeyword('')
    setDistance(10)
    setCategory('Default')
    setLocation('')
    setAutoDetect(false)
    setSearchResult([])
    setBusiness()
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
              <td className="business-name-cell" onClick={e => getBusiness(business.id)}>{business.name}</td>
              <td>{business.rating}</td>
              <td>{Math.round(business.distance)}</td>
            </tr>
          ))}
        </tbody>
      </Table>
    )
  }

  function Business({ business, reviews }) {
    console.log(reviews)
    return (
      <div className="business-card">
        <h3 className="arrow" onClick={e => setBusiness(null)}>←</h3>
        <h3>{business.name}</h3>
        <Tabs
          defaultActiveKey="business"
        >
          <Tab eventKey="business" title="Business details">
            <Container className="business-details">
              <Row>
                <Col>
                  <h5>Address</h5>
                  <p>{business.location.display_address.join(', ')}</p>
                </Col>
                <Col>
                  <h5>Category</h5>
                  <p>{business.categories.map(category => category.title).join(', ')}</p>
                </Col>
              </Row>
              <Row>
                <Col>
                  <h5>Phone</h5>
                  <p>{business.display_phone}</p>
                </Col>
                <Col>
                  <h5>Price range</h5>
                  <p>{business.price}</p>
                </Col>
              </Row>
              <Row>
                <Col>
                  <h5>Status</h5>
                  <p>{business.is_closed ? 'Closed' : 'Open'}</p>
                </Col>
                <Col>
                  <h5>Visit yelp for more</h5>
                  <a href={business.url} target="_blank" rel="noreferrer">Business link</a>
                </Col>
              </Row>
              <Row>
                <Button className="reserve-button" variant="danger">Reserve Now</Button>
              </Row>
              <Row>
                <div className="share-on">
                  Share on:
                </div>
              </Row>
              <Row>
              <Carousel variant="dark">
                {business.photos.map(photo => (
                  <Carousel.Item>
                    <img
                      src={photo}
                      alt="business-photos"
                    />
                  </Carousel.Item>
                ))}
              </Carousel>
              </Row>
            </Container>
          </Tab>
          <Tab eventKey="map" title="Map location">
            <LoadScript
              googleMapsApiKey="AIzaSyDZQNW6Ut1G3ySELQPBUsI6JpdatAUyxvo"
            >
              <GoogleMap className="map"
                mapContainerStyle={{
                  width: '100%',
                  height: '640px'
                }}
                center={{
                  lat: business.coordinates.latitude,
                  lng: business.coordinates.longitude
                }}
                zoom={14}
              >
                <Marker
                  position={{
                    lat: business.coordinates.latitude,
                    lng: business.coordinates.longitude
                  }}
                />
              </GoogleMap>
            </LoadScript>
          </Tab>
          <Tab eventKey="reviews" title="Reviews">
            <Container className="reviews">
              {reviews && reviews.reviews.map((review, i) => (
                <Row style={ i % 2 === 0 ? {backgroundColor: '#F2F2F2'} : null}>
                  <Col>
                    <div className="review">
                      <div className="review-header">
                        <div className="review-user">
                          {review.user.name}
                        </div>
                        <div className="review-rating">Rating: {review.rating}/5</div>
                      </div>
                      <br/>
                      <div className="review-content">
                        {review.text}
                      </div>
                      <br/>
                      <div className="review-time">
                        {review.time_created.split(' ')[0]}
                      </div>
                      <br/>
                    </div>
                  </Col>
                </Row>
              ))}
            </Container>
          </Tab>
        </Tabs>
      </div>
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
          <Form.Check type="checkbox" label="Auto-detect my location" value={autoDetect} onChange={e => {setAutoDetect(e.target.checked); setLocation('')}} />
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
      {searchResult.length && !business && <SearchTable searchResult={searchResult}/>}
      {business && <Business business={business} reviews={reviews}/>}
      <div className="bottom"/>
    </>
  )
}
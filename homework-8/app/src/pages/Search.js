/* eslint-disable jsx-a11y/heading-has-content */
import './Search.css'
import React, { useRef, useState } from 'react'
import axios from 'axios'
import { Container, Row, Col, Form, Button, Table, Tab, Tabs, Modal, Carousel } from 'react-bootstrap'
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api'
import {AsyncTypeahead } from 'react-bootstrap-typeahead';

export default function Search() {
  const [keyword, setKeyword] = useState('')
  const [distance, setDistance] = useState(10)
  const [category, setCategory] = useState('Default')
  const [location, setLocation] = useState('')
  const [autoDetect, setAutoDetect] = useState(false)
  const [searchResult, setSearchResult] = useState([])
  const [business, setBusiness] = useState()
  const [reviews, setReviews] = useState()
  const [reservation, setReservation] = useState(false)
  const [reserved, setReserved] = useState(false)
  const [noResult, setNoResult] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [options, setOptions] = useState([])
  const ref = useRef();

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
        if (!response.data.businesses.length) setNoResult(true)
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
    let business = {}
    await axios.get('https://csci-571-363723.wl.r.appspot.com/yelp', {
      params: {
        url: `https://api.yelp.com/v3/businesses/${id}`
      }
    })
      .then(response => {
        business = response.data
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

    await axios.get('https://csci-571-363723.wl.r.appspot.com/reservations')
      .then(response => {
        const reservations = response.data
        const reserved = reservations.some(reservation => reservation.business === business.name)
        setReserved(reserved)
        console.log(business.name)
      })
    }

  function reserve(event) {
    event.preventDefault()
    axios.get('https://csci-571-363723.wl.r.appspot.com/reservation', {
      params: {
        business: business.name,
        email: event.target[0].value,
        date: event.target[1].value,
        time: event.target[2].value + ":" + event.target[3].value
      }
    })
    alert("Reservation created!")
    setReservation(false)
    setReserved(true)
  }

  function cancel(name) {
    axios.get('https://csci-571-363723.wl.r.appspot.com/reservations')
      .then(response => {
        const reservations = response.data
        const index = reservations.findIndex(reservation => reservation.business === name)
        axios.get(`https://csci-571-363723.wl.r.appspot.com/cancel?index=${index}`)
      })
    alert("Reservation canceled!")
    setReserved(false)
  }

  function clear() {
    setKeyword('')
    setDistance(10)
    setCategory('Default')
    setLocation('')
    setAutoDetect(false)
    setSearchResult([])
    setBusiness()
    setNoResult(false)
    ref.current.clear()
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
            <tr key={business.id} onClick={e => getBusiness(business.id)}>
              <td style={{fontWeight: 600}}>{index + 1}</td>
              <td><img src={business.image} alt={business.name} height="120" width="120"/></td>
              <td className="business-name-cell">{business.name}</td>
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
                {reserved && <Button className="cancel-button" variant="primary" onClick={e => cancel(business.name)}>Cancel reservation</Button>}
                {!reserved && <Button className="reserve-button" variant="danger" onClick={e => setReservation(true)}>Reserve Now</Button>}
                <Modal show={reservation} onHide={e => setReservation(false)}>
                  <Modal.Header closeButton>
                    <Modal.Title>Reservation form</Modal.Title>
                  </Modal.Header>
                  <Modal.Body>
                    <h5>{business.name}</h5>
                    <Form onSubmit={reserve}>
                      <Form.Group>
                        <Form.Label>Email address</Form.Label>
                        <Form.Control type="email" required />
                      </Form.Group>
                      <Form.Group as={Col}>
                        <Form.Label>Date</Form.Label>
                        <Form.Control type="date" required />
                      </Form.Group>
                      <Form.Label>Time</Form.Label>
                      <Row className="reservation-time">
                        <Form.Group as={Col} md="auto">
                          <Form.Select required>
                            <option>10</option>
                            <option>11</option>
                            <option>12</option>
                            <option>13</option>
                            <option>14</option>
                            <option>15</option>
                            <option>16</option>
                            <option>17</option>
                          </Form.Select>
                        </Form.Group>
                        :
                        <Form.Group as={Col} md="auto">
                          <Form.Select required>
                            <option>00</option>
                            <option>15</option>
                            <option>30</option>
                            <option>45</option>
                          </Form.Select>
                        </Form.Group>
                        <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTFVBfLTkAoPpYjW_5UkzsygMAaCzJGsrZ_pA&usqp=CAU" alt="clock"/>
                      </Row>
                      <Row className="justify-content-md-center">
                        <Col md="auto">
                          <Button className="submit-reservation" variant="danger" type="submit">Submit</Button>
                        </Col>
                      </Row>
                    </Form>
                  </Modal.Body>
                  <Modal.Footer>
                    <Button variant="dark" onClick={e => setReservation(false)}>
                      Close
                    </Button>
                  </Modal.Footer>
                </Modal>
              </Row>
              <Row>
                <div className="share-on">
                  Share on:
                  <a href={`https://twitter.com/intent/tweet?text=${encodeURI(`Check ${business.name} on Yelp. ${business.url}`)}`} target="_blank" rel="noreferrer"><img src="https://www.iconpacks.net/icons/2/free-icon-twitter-logo-2429.png" alt="twitter" /></a>
                  <a href={`https://www.facebook.com/sharer/sharer.php?u=${encodeURI(business.url)}`} target="_blank" rel="noreferrer"><img src="https://www.iconpacks.net/icons/2/free-icon-facebook-logo-2428.png" alt="facebook" /></a>
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
          {/* <Form.Control type="text" value={keyword} onChange={e => setKeyword(e.target.value)} required /> */}
          <AsyncTypeahead
            ref={ref}
            id="keyword"
            type="text"
            value={keyword}
            onChange={setKeyword}
            isLoading={isLoading}
            onSearch={(query) => {
              setKeyword(query)
              setIsLoading(true)
              axios.get('https://csci-571-363723.wl.r.appspot.com/yelp', {
                params: {
                  url: `https://api.yelp.com/v3/autocomplete?text=${query}`,
                }
              })
                .then(response => {
                  let results = []
                  for (const category of response.data.categories) {
                    results.push(category.title)
                  }
                  for (const term of response.data.terms) {
                    results.push(term.text)
                  }
                  setOptions(results)
                  setIsLoading(false)
                  console.log(results)
                })
            }}
            options={options}
            renderMenuItemChildren={(option, props) => (
              <div>
                {option}
              </div>
            )}
            inputProps={{ required: true }}
          />
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
          <Form.Check type="checkbox" label="Auto-detect my location" value={autoDetect} onClick={e => {setAutoDetect(e.target.checked); setLocation('')}} />
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
      {!!searchResult.length && !business && <SearchTable searchResult={searchResult}/>}
      {business && <Business business={business} reviews={reviews} />}
      {noResult && <h3 className="no-results">No results available</h3>}
      <div className="bottom"/>
    </>
  )
}
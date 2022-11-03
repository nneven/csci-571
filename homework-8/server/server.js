// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

'use strict';

// [START app]
const express = require('express');
const axios = require('axios')
const cors = require('cors');
const path = require('path');
const app = express();

app.use(cors());
app.use(express.static(path.join(__dirname, 'build')));

app.get('/yelp', (req, res) => {
  console.log(req.query)
  axios.get(decodeURI(req.query.url), {
    headers: {
      Authorization: 'Bearer VnkIbhsZy69FOh3SIvmLg2Ee1EntTZ7503IvzLYGE83f4vPykJ3BW883p9U3wpb6WAvULCN2MD0nql8XEhzXyNMia0RMbNMJ_FPGW0tOEdT0x0HloEa1FeuGu-M0Y3Yx'
    }
  })
  .then(response => {
    res.send(response.data)
    console.log(response.data)
  })
  .catch(error => {
    res.send(error)
    console.log(error)
  })
});

app.get('/google', (req, res) => {
  console.log(req.query)
  axios.get(decodeURI(req.query.url))
  .then(response => {
    res.send(response.data)
    console.log(response.data)
  })
  .catch(error => {
    res.send(error)
    console.log(error)
  })
});

app.get('*', async (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

// Listen to the App Engine-specified port, or 8080 otherwise
const PORT = parseInt(process.env.PORT) || 8080;
app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}...`);
});
// [END app]

module.exports = app;

from flask import Flask, send_from_directory, request
import requests

# If `entrypoint` is not defined in app.yaml, App Engine will look for an app called `app` in `main.py`.
app = Flask(__name__)

@app.route('/')
def serve_html():
    return send_from_directory('static', 'business.html')

@app.get('/yelp/<query>')
def business(query):
    headers = {'Authorization': 'Bearer VnkIbhsZy69FOh3SIvmLg2Ee1EntTZ7503IvzLYGE83f4vPykJ3BW883p9U3wpb6WAvULCN2MD0nql8XEhzXyNMia0RMbNMJ_FPGW0tOEdT0x0HloEa1FeuGu-M0Y3Yx'}
    r = requests.get('https://api.yelp.com/v3/businesses/' + query, headers=headers)
    return r.json()

@app.get('/yelp/search/<query>')
def search(query):
    headers = {'Authorization': 'Bearer VnkIbhsZy69FOh3SIvmLg2Ee1EntTZ7503IvzLYGE83f4vPykJ3BW883p9U3wpb6WAvULCN2MD0nql8XEhzXyNMia0RMbNMJ_FPGW0tOEdT0x0HloEa1FeuGu-M0Y3Yx'}
    r = requests.get('https://api.yelp.com/v3/businesses/search?' + query, headers=headers)
    return r.json()

if __name__ == '__main__':
    # This is used when running locally only. When deploying to Google App
    # Engine, a webserver process such as Gunicorn will serve the app. You
    # can configure startup instructions by adding `entrypoint` to app.yaml.
    app.run(host='127.0.0.1', port=8080, debug=True)

from flask import Flask, render_template, request, jsonify
import requests
import os
from datetime import datetime
import logging
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

logging.basicConfig(level=logging.INFO)

WEATHER_API_KEY = os.getenv('WEATHER_API_KEY')
if not WEATHER_API_KEY:
    raise RuntimeError("Missing WEATHER_API_KEY environment variable!")
WEATHER_API_URL = "https://api.openweathermap.org/data/2.5"

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/weather')
def get_weather():
    city = request.args.get('city')
    if not city:
        return jsonify({'error': 'Missing city parameter'}), 400

    try:
        # Get 5-day forecast
        forecast_response = requests.get(
            f"{WEATHER_API_URL}/forecast",
            params={
                'q': city,
                'appid': WEATHER_API_KEY,
                'units': 'metric'
            },
            timeout=5
        )
        forecast_response.raise_for_status()  # Raises an HTTPError for bad responses (4xx or 5xx)
        forecast_data = forecast_response.json()

        # The forecast response includes most of what we need for "current" weather.
        # We can extract the first item as the current weather.
        current_weather_data = forecast_data['list'][0]
        current_weather_data['name'] = forecast_data['city']['name'] # Add city name
        
        return jsonify({
            'current': current_weather_data,
            'forecast': forecast_data,
            'timestamp': datetime.now().isoformat()
        })
    except requests.exceptions.HTTPError as e:
        error_message = "City not found or invalid API key."
        if e.response.status_code != 404:
            logging.error(f"API Error: {e.response.text}")
            error_message = "Error fetching weather data from the provider."
        return jsonify({'error': error_message}), e.response.status_code
    except Exception as e:
        logging.error(f"Error fetching weather data: {str(e)}")
        return jsonify({'error': 'An internal server error occurred.'}), 500

@app.route('/health')
def health_check():
    try:
        # Test API connectivity
        requests.get(f"{WEATHER_API_URL}/weather", 
                    params={'q': 'Haifa', 'appid': WEATHER_API_KEY},
                    timeout=5)
        return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()}), 200
    except Exception as e:
        logging.error(f"Health check failed: {str(e)}")
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

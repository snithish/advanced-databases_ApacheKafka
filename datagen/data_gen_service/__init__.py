import json
from datetime import datetime, timedelta

from flask import Flask, jsonify
from requests import get


def create_app():
    app = Flask(__name__)

    @app.route('/')
    def return_chucked_json():
        stream = get('http://stream.meetup.com/2/rsvps', stream=True)
        counter = 0
        data = []
        end = datetime.now() + timedelta(seconds=2)
        for line in stream.iter_lines():
            if line:
                decoded_line = line.decode('utf-8')
                data.append(json.loads(decoded_line))
                counter += 1
            if (counter > 10) or (end < datetime.now()):
                break
        stream.close()
        return jsonify(data)

    return app

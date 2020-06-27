import warnings
import app as application

from flask import Flask
from flask_cors import CORS


def create_app(config=None, debug=False, testing=False, config_overrides=None):
    app = Flask(__name__)
    CORS(app)

    app.debug = debug
    app.testing = testing

    if config_overrides:
        app.config.update(config_overrides)

    # Configuration
    with warnings.catch_warnings(record=True):
        application.config(config)

    # Add endpoints
    from app.endpoints.statuses import blueprint as statuses_bp

    app.register_blueprint(statuses_bp)

    return app

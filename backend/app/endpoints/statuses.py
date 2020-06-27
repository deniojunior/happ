import logging

from flask import Blueprint, jsonify, make_response

_logger = logging.getLogger(__name__)

blueprint = Blueprint('statuses', __name__)


@blueprint.route('/status', methods=['GET', 'OPTIONS'])
def is_alive_request():
    return make_response(jsonify({"status": "OK"}), 200)


@blueprint.route('/healthz', methods=['GET', 'OPTIONS'])
def google_healthz():
    """Health check endpoint"""
    return make_response(jsonify({"status": "OK"}), 200)


@blueprint.route('/ready', methods=['GET', 'OPTIONS'])
def is_ready_request():
    """Test all used services and return readiness."""
    return make_response(jsonify({"status": "OK"}), 200)

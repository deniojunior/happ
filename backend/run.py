import logging
import argparse

from app import server


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--config', type=str, default="config.yaml", help='Config file')
    args = parser.parse_args()
    logging.info("Configuration file: {}".format(args.config))
    app = server.create_app(config=args.config)
    app.run(debug=True, port=8080, host='0.0.0.0', use_reloader=False)

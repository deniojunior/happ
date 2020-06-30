'use strict';

module.exports.handler = (event, context, callback) => {
  const request = event.Records[0].cf.request;
  
  // Remove context before origin connection
  request.uri = request.uri.replace(/^\/frontend/, "/index.html");
  request.uri = request.uri.replace(/^\/backend/, "");
  
  callback(null, request);
};

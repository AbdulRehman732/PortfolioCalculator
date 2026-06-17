const serverless = require("serverless-http");
const app = require("../../backend/server.js");

// Wrap the Express app for Netlify Serverless Functions
module.exports.handler = serverless(app);

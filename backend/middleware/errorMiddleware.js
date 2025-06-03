// middleware/errorMiddleware.js

function errorHandler(err, req, res, next) {
    console.error(err.stack);
  
    // Default to 500, but override for certain error types:
    let statusCode = 500;
    let message = err.message || 'Internal Server Error';
  
    // JSON parse errors
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
      statusCode = 400;
      message = 'Invalid JSON payload';
    }
    // Mongoose bad ObjectId
    else if (err.name === 'CastError' && err.kind === 'ObjectId') {
      statusCode = 400;
      message = `Invalid ID format: ${err.value}`;
    }
    // Mongoose validation errors
    else if (err.name === 'ValidationError') {
      statusCode = 400;
      // collect all error messages into one
      message = Object.values(err.errors).map(e => e.message).join(', ');
    }
    // JWT verification errors (if you end up using jsonwebtoken)
    else if (err.name === 'JsonWebTokenError') {
      statusCode = 401;
      message = 'Invalid token';
    }
    else if (err.name === 'TokenExpiredError') {
      statusCode = 401;
      message = 'Token expired';
    }
  
    res.status(statusCode).json({
      status: false,
      message
    });
  }
  
  module.exports = { errorHandler };
  

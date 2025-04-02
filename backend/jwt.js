const crypto = require('crypto');

// Generate a secure random string (256-bit key)
const jwtSecret = crypto.randomBytes(64).toString('hex');
console.log(jwtSecret);

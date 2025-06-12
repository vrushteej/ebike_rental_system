// services/qr_services.js

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const QRCode = require('qrcode');
const bikeModel = require('../models/bike_model');

// Load RSA private and public keys
const PRIVATE_KEY = fs.readFileSync(
  path.join(__dirname, '../keys/bike_qr_private.pem'),
  'utf8'
);
const PUBLIC_KEY = fs.readFileSync(
  path.join(__dirname, '../keys/bike_qr_public.pem'),
  'utf8'
);

/**
 * Generate a signed QR code image (base64) for a given bike ID.
 * @param {string} bikeId
 * @returns {Promise<string>} base64 PNG data URL
 */
async function generateBikeQR(bikeId) {
  try {
    const bike = await bikeModel.findById(bikeId).populate('station_id');
    if (!bike) throw new Error('Bike not found');

    // Prepare the payload
    const payload = {
      id: bike._id.toString(),
      status: bike.status,
      isInDock: bike.isInDock,
      battery_level: bike.battery_level,
      station: bike.station_id
        ? { id: bike.station_id._id.toString(), name: bike.station_id.name }
        : null,
      latitude: bike.latitude,
      longitude: bike.longitude,
      last_service_date: bike.last_service_date,
    };

    // Sign the payload with RSA private key
    const signer = crypto.createSign('RSA-SHA256');
    signer.update(JSON.stringify(payload));
    signer.end();
    const signature = signer.sign(PRIVATE_KEY, 'base64');

    // Build the combined QR data
    const qrData = { payload, signature };
    const qrString = JSON.stringify(qrData);

    // Generate the QR code image as base64 PNG
    const qrImage = await QRCode.toDataURL(qrString);
    return qrImage;
  } catch (err) {
    throw new Error(`QR generation failed: ${err.message}`);
  }
}

/**
 * Verify a scanned QR string (base64 JSON), checking its signature.
 * @param {string} qrString
 * @returns {Object} Decoded payload if valid
 */
function verifyBikeQR(qrString) {
  try {
    const qrData = JSON.parse(qrString);
    const { payload, signature } = qrData;
    if (!payload || !signature) throw new Error('QR missing payload or signature');

    // Verify the signature using the public key
    const verifier = crypto.createVerify('RSA-SHA256');
    verifier.update(JSON.stringify(payload));
    verifier.end();
    const isValid = verifier.verify(PUBLIC_KEY, signature, 'base64');

    if (!isValid) throw new Error('Invalid QR signature');
    return payload;
  } catch (err) {
    throw new Error(`QR verification failed: ${err.message}`);
  }
}

module.exports = {
  generateBikeQR,
  verifyBikeQR,
};

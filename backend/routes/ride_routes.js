const router = require('express').Router();
const rideController = require('../controller/ride_controller');

// Existing route
//router.post('/storeRide', rideController.createRide);

// Start a new ride (user_id, bike_id, lat, lng from frontend)
router.post('/start', rideController.startRide);

// End a ride (rideId, lat, lng, finalFare from frontend)
router.post('/end', rideController.endRide);

// Get all rides of a user
router.get('/user/:userId', rideController.getUserRides);

module.exports = router;

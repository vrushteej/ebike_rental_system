const express = require('express');
const router = express.Router();
const profileController = require('../controller/profile_controller');

// Route for creating a profile
router.post('/:userId', profileController.createProfile);

// Route for fetching profile by userId
router.get('/:userId', profileController.getProfile);

// Route for updating profile by userId
router.put('/:userId', profileController.updateProfile);

// Route for deleting profile by userId
router.delete('/:userId', profileController.deletedProfile);

module.exports = router;

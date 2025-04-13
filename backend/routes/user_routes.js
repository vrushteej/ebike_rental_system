const express = require('express');
const router = express.Router();
const userController = require('../controller/user_controller');

// User Auth & Account Routes
router.post('/register', userController.register);
router.post('/login', userController.login);
router.put('/:userId', userController.updateUserDetails);
router.get('/:userId', userController.getUserById);

// Profile Management Routes (for the same userId)
router.post('/:userId/profile', userController.createProfile);
router.delete('/:userId/profile', userController.deleteProfile); // renamed to deleteProfile for consistency

module.exports = router;

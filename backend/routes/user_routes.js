const express = require('express');
const router = express.Router();
const userController = require('../controller/user_controller');

router.post('/register', userController.register);
router.post('/login', userController.login);
router.post('/update', userController.updateUserDetails);

module.exports = router;

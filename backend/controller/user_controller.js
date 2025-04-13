const userService = require('../services/user_services');
const mongoose = require('mongoose');

// Register a new user
exports.register = async (req, res, next) => {
    try {
        const { email, phone, password } = req.body;
        const response = await userService.registerUser(email, phone, password);
        res.json({ status: true, message: response.message, user: response.user });
    } catch (error) {
        next(error);
    }
};

// Login user
exports.login = async (req, res, next) => {
    try {
        const { email, phone, password } = req.body; // Retrieve from the request body
        const response = await userService.loginUser(email, phone, password);
        res.json({ status: true, message: response.message, userId: response.userId, token: response.token });
    } catch (error) {
        next(error);
    }
};


// Update user basic info (email, phone, password)
exports.updateUserDetails = async (req, res, next) => {
    try {
        const { userId } = req.params;
        const { email, phone, password, firstName, lastName, address, dob, gender } = req.body;
        const updatedUser = await userService.updateUserDetails(
            userId, email, phone, password, firstName, lastName, address, dob, gender
        );

        res.json({ status: true, message: 'User details updated successfully', updatedUser });
    } catch (error) {
        next(error);
    }
};

// Get user by ID
exports.getUserById = async (req, res, next) => {
    try {
        const { userId } = req.params;
        const user = await userService.getUserById(userId);
        res.json({ status: true, user });
    } catch (error) {
        next(error);
    }
};

// Create profile for user
exports.createProfile = async (req, res, next) => {
    try {
        const { userId } = req.params;
        const { firstName, lastName, address, dob, gender } = req.body;
        const profileData = { firstName, lastName, address, dob, gender };
        const response = await userService.createProfile(userId, profileData);
        

        res.json({ status: true, message: response.message, profile: response.profile });
    } catch (error) {
        next(error);
    }
};

// Get user profile
exports.getProfile = async (req, res, next) => {
    try {
        const { userId } = req.params;
        const profile = await userService.getProfile(userId);
        res.json({ status: true, profile });
    } catch (error) {
        next(error);
    }
};

// Update user profile
exports.updateProfile = async (req, res, next) => {
    try {
        const { userId } = req.params;
        const { firstName, lastName, address, dob, gender } = req.body;
        const response = await userService.updateProfile(userId, firstName, lastName, address, dob, gender);
        res.json({ status: true, message: response.message, profile: response.profile });
    } catch (error) {
        next(error);
    }
};

// Delete profile
exports.deleteProfile = async (req, res, next) => {
    try {
        const { userId } = req.params;
        const response = await userService.deleteProfile(userId);
        res.status(200).json({
            status: true,
            message: 'Profile deleted successfully',
            response
        });
    } catch (error) {
        next(error);
    }
};

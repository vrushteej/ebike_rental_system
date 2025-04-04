const ProfileService = require('../services/profile_services');
const mongoose = require('mongoose');

exports.createProfile = async (req, res, next) => {
    try {
        const { userId} = req.params;
        const {firstName, lastName, address, dob, gender } = req.body;

        // Ensure userId is a valid ObjectId
        if (!mongoose.Types.ObjectId.isValid(userId)) {
            return res.status(400).json({ status: false, message: 'Invalid userId format' });
        }

        const response = await ProfileService.createProfile(userId, firstName, lastName, address, dob, gender);
        res.json({ status: true, message: response.message });
    } catch (error) {
        next(error);  // Pass the error to the error-handling middleware
    }
};

exports.getProfile = async (req, res, next) => {
    try {
        const { userId } = req.params;  // The userId will come as a route parameter

        // Ensure userId is a valid ObjectId
        if (!mongoose.Types.ObjectId.isValid(userId)) {
            return res.status(400).json({ status: false, message: 'Invalid userId format' });
        }

        const profile = await ProfileService.getProfileByUserId(userId);
        res.json({ status: true, profile });
    } catch (error) {
        next(error);  // Pass the error to the error-handling middleware
    }
};

exports.updateProfile = async (req, res, next) => {
    try {
        const { userId } = req.params;  // The userId will come as a route parameter
        const { firstName, lastName, address, dob, gender } = req.body;

        // Ensure userId is a valid ObjectId
        if (!mongoose.Types.ObjectId.isValid(userId)) {
            return res.status(400).json({ status: false, message: 'Invalid userId format' });
        }

        const response = await ProfileService.updateProfile(userId, firstName, lastName, address, dob, gender);
        res.json({ status: true, message: response.message, profile: response.profile });
    } catch (error) {
        next(error);  // Pass the error to the error-handling middleware
    }
};

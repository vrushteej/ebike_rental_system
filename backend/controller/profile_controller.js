const ProfileService = require('../services/profile_services');

exports.createProfile = async (req, res, next) => {
    try {
        const { userId, firstName, lastName, address, dob, gender } = req.body;
        const response = await ProfileService.createProfile(userId, firstName, lastName, address, dob, gender);
        res.json({ status: true, message: response.message });
    } catch (error) {
        next(error);  // Pass the error to the error-handling middleware
    }
};

exports.getProfile = async (req, res, next) => {
    try {
        const { userId } = req.params;  // The userId will come as a route parameter
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
        const response = await ProfileService.updateProfile(userId, firstName, lastName, address, dob, gender);
        res.json({ status: true, message: response.message, profile: response.profile });
    } catch (error) {
        next(error);  // Pass the error to the error-handling middleware
    }
};

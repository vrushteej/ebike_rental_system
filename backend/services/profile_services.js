const mongoose = require('mongoose');
const profileModel = require('../models/profile_model');
const userModel = require('../models/user_model');

class ProfileService {
    // Create a new profile for the user
    static async createProfile(userId, firstName, lastName, address, dob, gender) {
        try {
            // Ensure userId is a valid ObjectId
            if (!mongoose.Types.ObjectId.isValid(userId)) {
                throw new Error('Invalid userId format');
            }

            // Check if profile already exists
            const existingProfile = await profileModel.findOne({ userId });
            if (existingProfile) {
                throw new Error('Profile already exists for this user');
            }

            // Create and save profile
            const profile = new profileModel({
                userId, // No need to explicitly convert to ObjectId
                firstName,
                lastName,
                address,
                dob,
                gender
            });

            await profile.save();
            return { message: 'Profile created successfully', profile };
        } catch (error) {
            console.error('Error creating profile:', error.message);
            throw new Error(error.message);
        }
    }

    // Get profile by userId
    static async getProfileByUserId(userId) {
        try {
            if (!mongoose.Types.ObjectId.isValid(userId)) {
                throw new Error('Invalid userId format');
            }

            const profile = await profileModel.findOne({ userId }).populate('userId', 'email phone');
            if (!profile) {
                throw new Error('Profile not found');
            }

            return profile;
        } catch (error) {
            console.error('Error fetching profile:', error.message);
            throw new Error(error.message);
        }
    }

    // Update user profile
    static async updateProfile(userId, firstName, lastName, address, dob, gender) {
        try {
            if (!mongoose.Types.ObjectId.isValid(userId)) {
                throw new Error('Invalid userId format');
            }

            const profile = await profileModel.findOneAndUpdate(
                { userId },
                { firstName, lastName, address, dob, gender },
                { new: true } // Return updated profile
            );

            if (!profile) {
                throw new Error('Profile not found');
            }

            return { message: 'Profile updated successfully', profile };
        } catch (error) {
            console.error('Error updating profile:', error.message);
            throw new Error(error.message);
        }
    }

    static async deleteProfile(userId) {
        try {
            if (!mongoose.Types.ObjectId.isValid(userId)) {
                throw new Error('Invalid userId format');
            }
    
            const profile = await profileModel.findOneAndDelete({ userId });
            if (!profile) {
                throw new Error('Profile not found');
            }
    
            return { message: 'Profile deleted successfully', profile };
        } catch (error) {
            throw error;
        }
    }    
}

module.exports = ProfileService;

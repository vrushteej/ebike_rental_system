const profileModel = require('../models/profile_model');
const userModel = require('../models/user_model');

class ProfileService {
    // Create a new profile for the user
    static async createProfile(userId, firstName, lastName, address, dob, gender) {
        try {
            // Check if profile already exists for the user
            const existingProfile = await profileModel.findOne({ userId });
            if (existingProfile) {
                throw new Error('Profile already exists for this user');
            }

            // Create a new profile
            const profile = new profileModel({
                userId,
                firstName,
                lastName,
                address,
                dob,
                gender
            });
            await profile.save();
            return { message: 'Profile created successfully' };
        } catch (error) {
            throw error;
        }
    }

    // Get profile by userId
    static async getProfileByUserId(userId) {
        try {
            const profile = await profileModel.findOne({ userId }).populate('userId', 'email phone');  // Populate email and phone from the user model
            if (!profile) {
                throw new Error('Profile not found');
            }

            return profile;
        } catch (error) {
            throw error;
        }
    }

    // Update user profile
    static async updateProfile(userId, firstName, lastName, address, dob, gender) {
        try {
            const profile = await profileModel.findOneAndUpdate(
                { userId },
                { firstName, lastName, address, dob, gender },
                { new: true } // Returns the updated document
            );

            if (!profile) {
                throw new Error('Profile not found');
            }

            return { message: 'Profile updated successfully', profile };
        } catch (error) {
            throw error;
        }
    }

    // Optionally, you can add more methods to handle profile deletion, etc.
}

module.exports = ProfileService;

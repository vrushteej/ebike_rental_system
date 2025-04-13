const userModel = require('../models/user_model');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const mongoose = require('mongoose');

class UserService {
    //  Register a new user
    static async registerUser(email, phone, password) {
        try {
            const existingUser = await userModel.findOne({ $or: [{ email }, { phone }] });
            if (existingUser) throw new Error("User with this email or phone already exists.");

            const newUser = new userModel({ email, phone, password });

            await newUser.save();

            return { message: "User registered successfully", user: newUser };
        } catch (err) {
            throw err;
        }
    }

    //  Login existing user
    static async loginUser(email, phone, password) {
        try {
            // Search for the user by either email or phone
            const user = await userModel.findOne({ $or: [{ email }, { phone }] });
            if (!user) throw new Error('User not found');
    
            // Compare the password
            const isMatch = await user.comparePassword(password);
            if (!isMatch) throw new Error('Invalid credentials');
    
            // Create a JWT token with the user's _id
            const tokenData = { userId: user._id }; // Use the MongoDB ObjectId here
            const token = jwt.sign(tokenData, process.env.JWT_SECRET_KEY, { expiresIn: '1h' });
    
            return { message: 'Login successful', userId: user._id, token };
        } catch (error) {
            throw error;
        }
    }
    

    //  Update email, phone, or password
    static async updateUserDetails(userId, email, phone, password,firstName,lastName,address,dob,gender) {
        try {
            const updateData = {};

            if (email) updateData.email = email;
            if (phone) updateData.phone = phone;
            if(firstName) updateData.firstName = firstName;
            if(lastName) updateData.lastName = lastName;
            if(address) updateData.address = address;
            if(dob) updateData.dob = dob;
            if(gender) updateData.gender = gender;

            if (password) {
                const salt = await bcrypt.genSalt(10);
                updateData.password = await bcrypt.hash(password, salt);
            }

            const updatedUser = await userModel.findByIdAndUpdate(userId, updateData, { new: true });
            if (!updatedUser) throw new Error('User not found');

            return updatedUser;
        } catch (error) {
            throw error;
        }
    }

    //  Get user by ID
    static async getUserById(userId) {
        try {
            const user = await userModel.findById(userId).select('-password');
            if (!user) throw new Error('User not found');
            return user;
        } catch (error) {
            throw error;
        }
    }


    //  Create profile (only if not already existing)
    static async createProfile(userId, profileData) {
        try {
            
            const user = await userModel.findById(userId);
            if (!user) throw new Error('User not found');

            const hasProfile =
                user.firstName || user.lastName || user.address?.street || user.dob || user.gender;
            if (hasProfile) throw new Error('Profile already exists');

            Object.assign(user, profileData);
            await user.save();

            return { message: 'Profile created successfully', user };
        } catch (error) {
            throw error;
        }
    }

    //  Get user profile only
    static async getProfile(userId) {
        try {
            if (!mongoose.Types.ObjectId.isValid(userId)) throw new Error('Invalid userId format');

            const user = await userModel.findById(userId).select('-password');
            if (!user) throw new Error('User not found');

            const profile = {
                email : user.email,
                phone: user.phone,
                firstName: user.firstName,
                lastName: user.lastName,
                address: user.address,
                dob: user.dob,
                gender: user.gender
            };

            return profile;
        } catch (error) {
            throw error;
        }
    }

    //  Update profile
    static async updateProfile(userId, profileData) {
        try {

            const user = await userModel.findByIdAndUpdate(userId, profileData, { new: true }).select('-password');
            if (!user) throw new Error('User not found');

            return { message: 'Profile updated successfully', user };
        } catch (error) {
            throw error;
        }
    }
}

module.exports = UserService;

const userModel = require('../models/user_model');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

class userService {
    static async registerUser(first_name, last_name, email, phone, password) {
        try {
            // Check if user already exists
            const existingUser = await userModel.findOne({ $or: [{ email }, { phone }] });
            if (existingUser) {
                throw new Error("User with this email or phone already exists.");
            }

            // Create new user
            const newUser = new userModel({ first_name, last_name, email, phone, password: password });
            await newUser.save();

            return { message: "User registered successfully", user: newUser };
        } catch (err) {
            throw err;
        }
    }

    static async loginUser(email, phone, password) {
        try {
            // Find user by email or phone
            const user = await userModel.findOne({ $or: [{ email }, { phone }] });
            if (!user) throw new Error('User not found');

            // Validate password
            const isMatch = await bcrypt.compare(password, user.password);
            if (!isMatch) throw new Error('Invalid credentials');

            // Generate token
            const tokenData = { userId: user._id };
            const token = jwt.sign(tokenData, process.env.JWT_SECRET_KEY, { expiresIn: '1h' });

            return { message: 'Login successful', userId: user._id, token };
        } catch (error) {
            throw error;
        }
    }

    static async updateUserDetails(userId, email, phone, password) {
        try {
            const updateData = {};

            if (email) updateData.email = email;
            if (phone) updateData.phone = phone;
            if (password) {
                updateData.password = password;
            }

            const updatedUser = await userModel.findByIdAndUpdate(userId, updateData, { new: true });
            if (!updatedUser) throw new Error('User not found');

            return updatedUser;
        } catch (error) {
            throw error;
        }
    }

    static async getUserById(userId) {
        try {
            const user = await userModel.findById(userId); // This will return all fields, including the hashed password
            if (!user) throw new Error('User not found');
            return user;
        } catch (error) {
            throw error;
        }
    }
}

module.exports = userService;
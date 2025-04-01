const userModel = require('../models/user_model');
const jwt = require('jsonwebtoken')

class userService {
    static async registerUser(email, phone, password) {
        try {
            // Check if a user with the same email or phone already exists
            const existingUser = await userModel.findOne({ 
                $or: [{ email }, { phone }] 
            });
    
            if (existingUser) {
                throw new Error("User with this email or phone number already exists.");
            }
    
            // Create a new user if no duplicate is found
            const createUser = new userModel({ email, phone, password });
            return await createUser.save();
        } catch (err) {
            throw err;
        }
    }
    
    static async loginUser(email, phone, password) {
        try {
            // Check if user exists by email or phone
            const user = await userModel.findOne({ 
                $or: [{ email }, { phone }] 
            });
    
            if (!user) {
                throw new Error('User not found');
            }
    
            // Check if password matches
            const isMatch = await user.comparePassword(password);
            if (!isMatch) {
                throw new Error('Invalid credentials');
            }
    
            // Return a structured response with a message
            return { message: 'Login successful' };  // Add any additional data if needed
        } catch (error) {
            throw error;  // Rethrow the error to be caught by the controller
        }
    }
    
    
    static async generateToken(tokenData, secretKey, jwt_expire) {
        return jwt.sign(tokenData, secretKey, { expiresIn: jwt_expire });
    }
}    

module.exports = userService;
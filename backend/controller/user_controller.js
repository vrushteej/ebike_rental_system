const bcrypt = require('bcryptjs');
const userService = require('../services/user_services');
const User = require('../models/user_model');  // Ensure the path is correct

exports.register = async (req, res, next) => {
    try {
        const { first_name, last_name, email, phone, password } = req.body;

        // Check if the email already exists
        const existingUser = await User.findOne({$or: [{ email }, { phone }]});

        if (existingUser) {
            return res.status(400).json({ message: "User with this email or phone number already exists." });
        }

        // Create a new user
//        const newUser = new User({
//            first_name,
//            last_name,
//            email,
//            phone,
//            password // Will be hashed in the `pre('save')` middleware
//        });

        const response = await userService.registerUser(first_name, last_name, email, phone, password);
        res.json({ status: true, message: response.message });
    } catch (error) {
        next(error);
    }
};

exports.login = async (req, res, next) => {

    const { phoneOrEmail, password } = req.body;

        try {
            // Find user by email or phone
            const user = await User.findOne({
                $or: [{ email: phoneOrEmail }, { phone: phoneOrEmail }]
            });

            if (!user) {
                return res.status(401).json({ success: false, message: 'User not found' });
            }

            // Compare passwords
            const isMatch = await bcrypt.compare(password, user.password);
            if (!isMatch) {
                return res.status(401).json({ success: false, message: 'Invalid credentials' });
            }

            res.status(200).json({
                success: true,
                message: 'Login successful',
                userId: user.user_id
            });

        } catch (error) {
            console.error(error);
            res.status(500).json({ success: false, message: 'Server error' });
        }
    };

exports.updateUserDetails = async (req, res, next) => {
    try {
        const { userId } = req.params; // userId from URL params
        const { email, phone, password } = req.body; // email, phone, password from request body

        const updatedUser = await userService.updateUserDetails(userId, email, password);
        res.json({ status: true, message: 'User details updated successfully', updatedUser });
    } catch (error) {
        next(error);
    }
};

exports.getUserById = async (req,res,next) => {
    try {
        const { userId } = req.params;
        const user = await userService.getUserById(userId);
        res.json({ status: true, user});
    } catch (error) {
        next(error);
    }
};
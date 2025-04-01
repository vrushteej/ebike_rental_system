const userService = require('../services/user_services');

exports.register = async (req, res, next) => {
    try {
        const {email, phone, password } = req.body;
        const response = await userService.registerUser(email, phone, password);
        res.json({ status: true, message: response.message });
    } catch (error) {
        next(error);
    }
};

exports.login = async (req, res, next) => {  
    try {
        const { phone, password } = req.body;
        const response = await userService.loginUser(null, phone, password);  // You can also pass the email if needed

        // Ensure that response has a message
        if (!response || !response.message) {
            throw new Error('Login failed');
        }

        res.json({ status: true, message: response.message });
    } catch (error) {
        console.error(error);
        next(error);  // Pass error to the error handling middleware
    }
};


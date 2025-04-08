const userService = require('../services/user_services');

exports.register = async (req, res, next) => {
    try {
        const { email, phone, password } = req.body;
        const response = await userService.registerUser(email, phone, password);
        res.json({ status: true, message: response.message, user: response.user });
    } catch (error) {
        next(error);
    }
};

exports.login = async (req, res, next) => {
    try {
        const { email, phone, password } = req.body;
        const response = await userService.loginUser(email, phone, password);
        res.json({ status: true, message: response.message, userId: response.userId, token: response.token });
    } catch (error) {
        next(error);
    }
};

exports.updateUserDetails = async (req, res, next) => {
    try {
        const { userId } = req.params; 
        const {email, phone, password } = req.body;
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

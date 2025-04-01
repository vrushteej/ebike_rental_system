const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const db = require('../config/db');
const { v4: uuidv4 } = require('uuid');

const { Schema } = mongoose;

const userSchema = new Schema({
    user_id: {
        type: String,
        default: uuidv4,
        unique: true
    },
    email: {
        type: String,
        lowercase: true,
        required: true,
        unique: true
    },
    phone: {
        type: String,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    created_at: {
        type: Date,
        default: Date.now
    }
});

userSchema.pre('save', async function (next) {
    try {
        if (this.password) {
            const salt = await bcrypt.genSalt(10);
            this.password = await bcrypt.hash(this.password, salt);
        }
        next();
    } catch (error) {
        next(error);
    }
});

userSchema.methods.comparePassword = async function (userPassword) {
    try {
        return await bcrypt.compare(userPassword, this.password);
    } catch (error) {
        throw error;
    }
};

const userModel = db.model('user', userSchema);
module.exports = userModel;
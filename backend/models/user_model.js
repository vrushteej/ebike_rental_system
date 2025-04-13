const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const db = require('../config/db');

const { Schema } = mongoose;

const userSchema = new Schema({
    email: {
        type: String,
        lowercase: true,
        required: true,
        unique: true
    },
    phone: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true,
        // minlength: 6,
    },
    firstName: {
        type: String,
        required: false,
        trim: true,
        default: null
    },
    lastName: {
        type: String,
        required: false,
        trim: true,
        default: null
    },
    address: 
        {
        street: { type: String, trim: false, default: null },
        city: { type: String, trim: false, default: null },
        state: { type: String, trim: false, default: null },
        country: { type: String, trim: false, default: null },
        zipCode: { type: String, trim: false, default: null }
    },
    dob: {
        type: Date,
        required: false,
        default: null
    },
    gender: {
        type: String,
        enum: ["Male", "Female", "Other"],
        required: false,
        default: null,
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
});

// Hash password before saving
userSchema.pre('save', async function (next) {
    if (!this.isModified('password')) return next();
    try {
        const salt = await bcrypt.genSalt(10);
        this.password = await bcrypt.hash(this.password, salt);
        next();
    } catch (error) {
        next(error);
    }
});

// Compare hashed password
userSchema.methods.comparePassword = async function (userPassword) {
    return bcrypt.compare(userPassword, this.password);
};

const userModel = db.model('User', userSchema);
module.exports = userModel;

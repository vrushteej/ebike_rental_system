const mongoose = require('mongoose');
const db = require('../config/db');
const userModel = require('./user_model')
const { Schema } = mongoose;

const profileSchema = new Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,  // This will reference the userId from the user model
        ref: userModel.modelName,
    },
    firstName: {
        type: String,
        required: true,
        trim: true
    },
    lastName: {
        type: String,
        required: true,
        trim: true
    },
    address: {
        street: { type: String, trim: true },
        city: { type: String, trim: true },
        state: { type: String, trim: true },
        country: { type: String, trim: true },
        zipCode: { type: String, trim: true }
    },
    dob: {
        type: Date,
        required: true
    },
    gender: {
        type: String,
        enum: ["Male", "Female", "Other"],
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

const profileModel = db.model('profiles', profileSchema);

module.exports = profileModel;

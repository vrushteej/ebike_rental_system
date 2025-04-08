const mongoose = require("mongoose");
const db=require('../config/db');
const userModel=require('./user_model');

const { Schema }=mongoose;

const rideSchema = new Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: userModel.modelName, // Reference to User model
        
    },
    amount: {
        type: Number,
        required: true
    }
   
    
});

const Ride = db.model("Ride", rideSchema);
module.exports = Ride;

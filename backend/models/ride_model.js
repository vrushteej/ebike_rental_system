const mongoose = require("mongoose");
const db=require('../config/db');
const userModel=require('./user_model');

const { Schema } = mongoose;

const rideSchema = new Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: userModel.modelName, // Reference to User model
        
    },
    amount: {
        type: Number,
    },
    start_station: {
        station_id: String,
        name: String,
        location: {
          latitude: Number,
          longitude: Number
        }
      },
    
    end_station: {
        station_id: String,
        name: String,
        location: {
          latitude: Number,
          longitude: Number
        }
    },
    
    start_time: { 
        type: Date, 
        default: Date.now 
    },
    end_time : {
        type: Date,
        default: Date.now
    },
    duration_minutes: {
        type:Number
    },
    distance_km:{
        type: Number
    },
    status: {
        type: String,
        enum: ['ongoing', 'completed'],
        default: 'ongoing'
    }
});

const Ride = db.model("Ride", rideSchema);
module.exports = Ride;

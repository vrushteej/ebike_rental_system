const db = require("../config/db");
const mongoose = require("mongoose");
const User = require("./user_model");
const Ride = require("./ride_model"); // Import Ride Model

const { Schema } = mongoose;

const razorpaySchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: User.modelName, // References User collection
        required: true
    },
    rideId: {
        type: Schema.Types.ObjectId,
        ref: Ride.modelName, // References Ride collection
        required: true
    },
    amount: {
        type: Number,
        required: true
    },
    payment_method: {
        type: String,
        required: true
    },
    razorpay_order_id: {
        type: String,
        required: true
    },
    razorpay_payment_id: {
        type: String,
        required: false
    },
    razorpay_signature: {
        type: String,
        required: false
    },
    status: {
        type: String,
        enum: ["pending", "successful", "failed"],
        default: "pending"
    },
    timestamp: {
        type: Date,
        default: Date.now
    }
});

const Payment = db.model("Payment", razorpaySchema);
module.exports = Payment;



// const mongoose = require("mongoose");
// const db = require("../config/db");
// const userModel=require('./user_model');
// const rideModel=require('./ride_model');

// const { Schema }=mongoose;

// const razorpaySchema = new Schema({
//     userId:{
//         type:Schema.Types.ObjectId,
//         ref:userModel.modelName,
//     },
//     rideId:{
//         type:Schema.Types.ObjectId,
//         ref:rideModel.modelName,

//     },
//     amount:{
//         type:Number,
//         required:true,
        
//     },
//     payment_method:{
//         type:String,
//         required:true,
//     },

    

    
// });

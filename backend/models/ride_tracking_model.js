const mongoose = require("mongoose");
const db = require("../config/db");

const { Schema } = mongoose;

const rideTrackingSchema = new Schema({
  rideId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Ride",
    required: true,
  },
  trackingData: [
    {
      latitude: Number,
      longitude: Number,
      accuracy: Number,
      timestamp: { type: Date, default: Date.now }
    }
  ],
  createdAt: { type: Date, default: Date.now },
});

const RideTracking = db.model("RideTracking", rideTrackingSchema);
module.exports = RideTracking;

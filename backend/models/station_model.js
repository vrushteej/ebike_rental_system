const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;

const stationSchema = new Schema({
    station_name: {
        type: String,
        required: true,
        trim: true,
    },
    latitude: {
        type: Number,
        required: true
    },
    longitude: {
        type: Number,
        required: true
    },
    location: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point',
        },
        coordinates: {
            type: [Number],
            required: true,
        }
    },
    capacity: 
    {
        type: Number, 
        required: true
    },
    available_bikes: {
        type: Number,
        required: true
    },
})

stationSchema.pre('save', function (next) {
    this.location.coordinates = [this.longitude, this.latitude]; // Longitude first, then latitude
    next();
});

stationSchema.index({location: "2dsphere"});

module.exports = db.model('station',stationSchema);
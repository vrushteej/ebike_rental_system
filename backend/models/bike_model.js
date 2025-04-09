const mongoose = require('mongoose');
const db = require('../config/db');
const stationModel = require('./station_model'); // Assuming you have a station model 
const { Schema } = mongoose;

const bikeSchema = new Schema({
    status: {
        type: String,
        enum: ['locked', 'unlocked', 'maintenance'],
        default: 'locked'
    },

    isInDock: {
        type: Boolean,
        default: true
      },
    station_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: stationModel.modelName, // This should match the name in your `station_model.js`
        default: null
    },
    battery_level: {
        type: Number,
        min: 0,
        max: 100,
        required: true
    },
    last_service_date: {
        type: Date,
        default: Date.now
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
}, {
    timestamps: true
});

bikeSchema.pre('save', function (next) {
  if (!this.isInDock) {
    this.station_id = null;
  }
  next();
});

bikeSchema.pre('findOneAndUpdate', function (next) {
    const update = this.getUpdate();
    if (update.isInDock === false || update.$set?.isInDock === false) {
      this.set({ station_id: null });
    }
    next();
  });

const bikeModel = db.model('Bike', bikeSchema);
module.exports = bikeModel;




// const mongoose = require('mongoose');

// const bikeSchema = new mongoose.Schema({
//   bikeId: {
//     type: String,
//     required: true,
//     unique: true
//   },
//   qrCodeStatus: {
//     type: String,
//     enum: ['locked', 'unlocked'],
//     default: 'locked'
//   },
//   isInDock: {
//     type: Boolean,
//     default: true
//   },
//   stationId: {
//     type: String,
//     default: null
//   }
// });

// // 💡 Pre-save hook to clear stationId if bike is not docked


// // Also applies to update operations if needed


// module.exports = mongoose.model('Bike', bikeSchema);

const Ride = require('../models/ride_model');
const Station = require('../models/station_model');
const RideTracking = require('../models/ride_tracking_model');

class RideServices {
  // Start a ride
  static async startRide({ userId, bikeId, latitude, longitude }) {
    const station = await Station.findOne({
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [longitude, latitude]
          },
          $maxDistance: 100
        }
      }
    });

    if (!station) throw new Error('No nearby start station found');

    const start_station = {
      station_id: station._id.toString(),
      name: station.station_name,
      location: {
        latitude: station.latitude,
        longitude: station.longitude
      }
    };

    const ride = await Ride.create({
      userId,
      bike_id: bikeId,
      start_station,
      start_time: new Date()
    });

    return ride;
  }

  // ✅ Distance utility
  static calculateDistanceKm(lat1, lon1, lat2, lon2) {
    const toRad = (val) => (val * Math.PI) / 180;
    const R = 6371; // Radius of the Earth in km
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);

    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(toRad(lat1)) *
        Math.cos(toRad(lat2)) *
        Math.sin(dLon / 2) ** 2;

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  // End ride and store final amount and distance
  static async endRide({ rideId, latitude, longitude, amount }) {
    const station = await Station.findOne({
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [longitude, latitude]
          },
          $maxDistance: 100
        }
      }
    });

    if (!station) throw new Error('No nearby end station found');

    const ride = await Ride.findById(rideId);
    if (!ride) throw new Error('Ride not found');
    if (ride.status === 'completed') throw new Error('Ride already completed');

    const endTime = new Date();
    const duration = Math.ceil((endTime - ride.start_time) / (1000 * 60));

    const start = ride.start_station.location;
    const end = { latitude, longitude };

    const distance = this.calculateDistanceKm(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude
    );

    ride.end_station = {
      station_id: station._id.toString(),
      name: station.station_name,
      location: {
        latitude: station.latitude,
        longitude: station.longitude
      }
    };

    ride.end_time = endTime;
    ride.duration_minutes = duration;
    ride.amount = amount;
    ride.status = 'completed';
    ride.distance_km = parseFloat(distance.toFixed(2)); // ✅ Save the distance

    await ride.save();
    return ride;
  }

  static async getRide(userId) {
    return await Ride.find({ userId }).populate('userId');
  }

  static async addTrackingPoint({ rideId, latitude, longitude, accuracy }) {
  const point = {
    latitude,
    longitude,
    accuracy,
    timestamp: new Date()
  }
  const existing = await RideTracking.findOne({ rideId });

  if (existing) {
    existing.trackingData.push(point);
    await existing.save();
  } else {
    await RideTracking.create({
      rideId,
      trackingData: [point],
    });
  }

  return point;
}
  
}

module.exports = RideServices;

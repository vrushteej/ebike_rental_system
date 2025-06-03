const rideService = require('../services/ride_service');

//  Start Ride
exports.startRide = async (req, res, next) => {
  try {
    const { userId, bikeId, latitude, longitude } = req.body;

    const ride = await rideService.startRide({
      userId,
      bikeId,
      latitude,
      longitude
    });

    res.status(201).json({
      status: true,
      message: 'Ride started successfully',
      data: ride
    });
  } catch (error) {
    next(error);
  }
};

//  End Ride with distance & amount
exports.endRide = async (req, res, next) => {
    try {
      const { rideId, latitude, longitude, amount } = req.body;
  
      const ride = await rideService.endRide({
        rideId,
        latitude,
        longitude,
        amount
      });
  
      res.status(200).json({
        status: true,
        message: 'Ride ended successfully',
        data: {
          ride_id: ride._id,
          duration: `${ride.duration_minutes} mins`,
          distance: `${ride.distance_km} km`,
          amount: `₹${ride.amount}`,
          start_station: {
            station_id: ride.start_station.station_id,
            name: ride.start_station.name,
            latitude: ride.start_station.location.latitude,
            longitude: ride.start_station.location.longitude
          },
          end_station: {
            station_id: ride.end_station.station_id,
            name: ride.end_station.name,
            latitude: ride.end_station.location.latitude,
            longitude: ride.end_station.location.longitude
          },
          started_at: ride.start_time,
          ended_at: ride.end_time
        }
      });
    } catch (error) {
      next(error);
    }
  };
  

//  Get All Rides for a User
exports.getUserRides = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const rides = await rideService.getRide(userId);

    res.json({
      status: true,
      data: rides
    });
  } catch (error) {
    next(error);
  }
};

// Optional: Track via REST (for testing or fallback)
exports.trackRide = async (req, res, next) => {
  try {
    const { rideId, latitude, longitude, accuracy } = req.body;

    const result = await rideService.addTrackingPoint({ rideId, latitude, longitude, accuracy });

    res.status(200).json({
      status: true,
      message: 'Tracking point added',
      data: result
    });
  } catch (error) {
    next(error);
  }
};



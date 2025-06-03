const http = require('http');
const { Server } = require('socket.io');
const app = require('./app');
const RideTracking = require('./models/ride_tracking_model');

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('location-update', async (data) => {
    console.log('Location from user:', data);

    const { rideId, latitude, longitude, accuracy, timestamp } = data;

    try {
      await RideTracking.updateOne(
        { rideId },
        {
          $push: {
            trackingData: {
              latitude,
              longitude,
              accuracy,
              timestamp: timestamp || new Date()
            }
          }
        },
        { upsert: true }
      );

      // Broadcast updated location to clients listening for this ride
      io.emit(`ride-${rideId}-update`, {
        latitude,
        longitude,
        accuracy,
        timestamp: timestamp || new Date()
      });

    } catch (err) {
      console.error('Error saving tracking data:', err);
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

module.exports = server;

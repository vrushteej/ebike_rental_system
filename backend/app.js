const express = require('express');
// const bodyParser = require('body-parser');
const userRouter = require('./routes/user_routes');
const stationRouter = require('./routes/station_routes');
const rideRoute = require('./routes/ride_routes');
const razorpayRoute = require('./routes/razorpay_routes');
const bikeRouter = require('./routes/bike_routes');
const dotenv = require('dotenv');
const { errorHandler } = require('./middleware/errorMiddleware');

dotenv.config();

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));


app.use('/user', userRouter);
app.use('/ride',rideRoute);
app.use('/payment',razorpayRoute);
app.use('/station', stationRouter);
app.use('/bike', bikeRouter);


app.get('/', (req, res) => {
    res.send("Hello, Welcome to the E-bike Rental System!");
});

app.use(errorHandler);

module.exports = app;

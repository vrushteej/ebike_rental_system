const express = require('express');
<<<<<<< HEAD
const bodyParser = require('body-parser');
const userRouter = require('./routes/user_routes');
const profileRouter = require('./routes/profile_routes')
const rideRoute=require('./routes/ride_routes');
const razorpayRoute=require('./routes/razorpay_routes');
=======
>>>>>>> 43aa807a695c9d6ced52bd317cc0b36fa252f7b9
const dotenv = require('dotenv');

const userRouter = require('./routes/user_routes');
const profileRouter = require('./routes/profile_routes');
const stationRouter = require('./routes/station_routes');

dotenv.config();

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));


app.use('/user', userRouter);
<<<<<<< HEAD
app.use('/profile',profileRouter);
app.use('/ride',rideRoute);
app.use('/payment',razorpayRoute);
=======
app.use('/profile', profileRouter);
app.use('/station', stationRouter);

>>>>>>> 43aa807a695c9d6ced52bd317cc0b36fa252f7b9

app.get('/', (req, res) => {
    res.send("Hello, Welcome to the E-bike Rental System!");
});

module.exports = app;

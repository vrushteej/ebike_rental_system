const express = require('express');
const dotenv = require('dotenv');

const userRouter = require('./routes/user_routes');
const profileRouter = require('./routes/profile_routes');
const stationRouter = require('./routes/station_routes');

dotenv.config();

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));


app.use('/user', userRouter);
app.use('/profile', profileRouter);
app.use('/station', stationRouter);


app.get('/', (req, res) => {
    res.send("Hello, Welcome to the E-bike Rental System!");
});

module.exports = app;

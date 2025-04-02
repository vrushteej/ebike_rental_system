const express = require('express');
const bodyParser = require('body-parser');
const userRouter = require('./routes/user_routes');
const profileRouter = require('./routes/profile_routes')
const dotenv = require('dotenv');

dotenv.config();
const app = express();

app.use(bodyParser.json());
app.use('/user', userRouter);
app.use('/profile',profileRouter);

app.get('/', (req, res) => {
    res.send("Hello, Welcome to the E-bike Rental System!");
});

module.exports = app;

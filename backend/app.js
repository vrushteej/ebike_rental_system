const express = require('express')
const body_parser = require('body-parser')
const userRouter = require('./routes/user_routes')
const profileRouter = require('./routes/profile_routes');
const app = express()

app.use(body_parser.json())

app.use('/user',userRouter)
app.use('/profile',profileRouter)

module.exports = app
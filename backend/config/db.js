const mongoose = require('mongoose')

const connection = mongoose.createConnection('mongodb://localhost:27017/ToDo').on('open',()=> {
    console.log('MongoDB connected');
}).on('error', () => {
    console.log("Connection failed");
});

module.exports = connection;
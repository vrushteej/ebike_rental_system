const mongoose = require('mongoose')

const connection = mongoose.createConnection('mongodb://127.0.0.1:27017/new').on('open',()=> {
    console.log('MongoDB connected');
}).on('error', () => {
    console.log("Connection failed");
});

module.exports = connection;
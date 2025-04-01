const mongoose = require('mongoose')

const connection = mongoose.createConnection('mongodb+srv://dhruvshah22:UMjI7nZLAnDWpLr1@ccmap.314dmtr.mongodb.net/ccmap').on('open',()=> {
    console.log('MongoDB connected');
}).on('error', () => {
    console.log("Connection failed");
});

module.exports = connection;
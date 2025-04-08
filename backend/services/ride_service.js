const ride = require('../models/ride_model');

class RideServices{
    static async createRide(userId,amount){
        const createRide=new ride({
            userId,
            amount
        });
        return await createRide.save();
    }

    static async getRide(userId){
        const getRide=await ride.find({
            userId 
        });
        return getRide;
    }
}

module.exports=RideServices;


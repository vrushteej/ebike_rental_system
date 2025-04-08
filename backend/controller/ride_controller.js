const rideService=require('../services/ride_service');


exports.createRide=async (req,res,next)=>{
try {

  const {userId,amount}=req.body;
    let ride=await rideService.createRide(userId,amount);

    res.json({
        status:true,
        success:ride
    });
    
} catch (error) {
    next(error);
    
}

}


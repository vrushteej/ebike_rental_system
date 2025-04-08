const router=require('express').Router();
const rideController=require('../controller/ride_controller');

router.post('/storeRide',rideController.createRide);

module.exports=router;
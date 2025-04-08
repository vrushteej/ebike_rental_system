const express = require('express');
const router = express.Router();
const stationController = require('../controller/station_controller');

router.post('/create',stationController.createStation);
router.put('/:stationId',stationController.updateStationDetails);
router.get('/all',stationController.getAllStations);
router.get('/name',stationController.getStationName);
router.get('/coordinates',stationController.getStationByCoordinates);
router.delete('/:stationId',stationController.deletedStation);

module.exports = router;
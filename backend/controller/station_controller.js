const stationService = require('../services/station_services');
const mongoose = require('mongoose');

exports.createStation = async(req,res,next) => {
    try {
        const {station_name,latitude,longitude,capacity,available_bikes} = req.body;
        const response = await stationService.createStation(station_name,latitude,longitude,capacity,available_bikes);
        res.json({status: true, message: response.message,station: response.station});
    } catch (error) {
        next(error);
    }
}

exports.updateStationDetails = async (req,res,next) => {
    try {
        const { stationId } = req.params;
        const {station_name,capacity,available_bikes} = req.body;
        const updatedStation = await stationService.updateStationdetails(stationId,station_name,capacity,available_bikes);
        res.json({status: true, message: 'Station details updated succesfully',updatedStation});
    } catch (error) {
        next(error);
    }
}

exports.getAllStations = async (req, res) => {
    try {
        const stations = await stationService.getAllStations();
        res.status(200).json(stations);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

exports.getStationName = async (req,res,next) => {
    try {
        const { station_name } = req.body;
        const station = await stationService.getStationName(station_name);
        res.status(200).json(station);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

exports.getStationByCoordinates = async(req,res,next) => {
    try {
        const { stationId } = req.params;
        const {latitude,longitude} = req.body;
        
        const station = await stationService.getStationbyCoordinates(stationId,latitude,longitude);
        res.json({staus:true,message:'Station details',station});

    } catch (error) {
        next(error);
    }
}

exports.deletedStation = async(req,res,next) => {
    try {
        const { stationId } = req.params;
        const station = await stationService.deleteStation(stationId);
        res.json({status: true,message:'Station deleted succesfully',station});
    } catch (error) {
        next(error)
    }
}


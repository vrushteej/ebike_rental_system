const bikeService = require('../services/bike_services');
const mongoose = require('mongoose');

// exports.createBike = async (req, res, next) => {
//     try {
//         const { status, isInDock, station_id, battery_level, latitude, longitude } = req.body;

//         const bike = await bikeService.createBike(status, isInDock, station_id, battery_level, latitude, longitude);
//         res.status(201).json({ status: true, message: 'Bike created successfully', bike });
//     } catch (error) {
//         next(error);
//     }
// };

exports.createBike = async (req, res, next) => {
    try {
        // Pass the entire req.body as a single object instead of separate parameters
        const bike = await bikeService.createBike(req.body);
        res.status(201).json({ status: true, message: 'Bike created successfully', bike });
    } catch (error) {
        next(error);
    }
};

exports.getAllBikes = async (req, res, next) => {
    try {
        const bikes = await bikeService.getAllBikes();
        res.status(200).json({ status: true, bikes });
    } catch (error) {
        next(error);
    }
};

exports.getBikeById = async (req, res, next) => {
    try {
        const { bikeId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(bikeId)) {
            return res.status(400).json({ status: false, message: 'Invalid bikeId format' });
        }

        const bike = await bikeService.getBikeById(bikeId);
        res.status(200).json({ status: true, bike });
    } catch (error) {
        next(error);
    }
};

exports.updateBike = async (req, res, next) => {
    try {
        const { bikeId } = req.params;
        const { status, isInDock, station_id, battery_level, latitude, longitude } = req.body;

        // Similar issue here - you're not passing req.body to the service
        const updatedBike = await bikeService.updateBike(bikeId, req.body);
        res.status(200).json({ status: true, message: 'Bike updated successfully', bike: updatedBike });
    } catch (error) {
        next(error);
    }
};

exports.deleteBike = async (req, res, next) => {
    try {
        const { bikeId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(bikeId)) {
            return res.status(400).json({ status: false, message: 'Invalid bikeId format' });
        }

        await bikeService.deleteBike(bikeId);
        res.status(200).json({ status: true, message: 'Bike deleted successfully' });
    } catch (error) {
        next(error);
    }
};
const mongoose = require('mongoose');
const bikeService = require('../services/bike_services');
const bikeModel = require('../models/bike_model');
const { generateBikeQR, verifyBikeQR } = require('../services/qr_services');

// Create a new bike
exports.createBike = async (req, res, next) => {
    try {
        const bike = await bikeService.createBike(req.body);
        res.status(201).json({ status: true, message: 'Bike created successfully', bike });
    } catch (error) {
        next(error);
    }
};

//  Get all bikes
exports.getAllBikes = async (req, res, next) => {
    try {
        const bikes = await bikeService.getAllBikes();
        res.status(200).json({ status: true, bikes });
    } catch (error) {
        next(error);
    }
};

//  Get a specific bike by ID
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

// Update a bike
exports.updateBike = async (req, res, next) => {
    try {
        const { bikeId } = req.params;
        const updatedBike = await bikeService.updateBike(bikeId, req.body);
        res.status(200).json({ status: true, message: 'Bike updated successfully', bike: updatedBike });
    } catch (error) {
        next(error);
    }
};

//  Delete a bike
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

// Generate QR code for a bike
exports.getBikeQR = async (req, res, next) => {
    try {
        const { bikeId } = req.params;
        const qrImage = await generateBikeQR(bikeId);
        res.status(200).json({ status: true, qrcode: qrImage });
    } catch (error) {
        next(error);
    }
};

//  Verify scanned QR code
exports.verifyScannedQR = async (req, res, next) => {
    try {
        const { qrString } = req.body;

        if (!qrString) {
            return res.status(400).json({ status: false, message: 'QR string is required' });
        }

        const payload = verifyBikeQR(qrString); // returns decoded + verified payload
        const bike = await bikeModel.findById(payload.id);

        if (!bike) {
            return res.status(404).json({ status: false, message: 'Bike not found' });
        }

        res.status(200).json({ status: true, bike, message: 'QR code verified' });
    } catch (error) {
        return res.status(400).json({ status: false, message: 'Invalid or expired QR code', error: error.message });
    }
};

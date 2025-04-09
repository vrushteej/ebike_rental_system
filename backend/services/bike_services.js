const bikeModel = require('../models/bike_model');

class bikeService {
    // 1. Create a bike
    static async createBike(data) {
        try {
            const {
                status,
                isInDock,
                station_id,
                battery_level,
                latitude,
                longitude,
                last_service_date
            } = data;

            const bike = new bikeModel({
                status,
                isInDock,
                station_id: isInDock ? station_id : null,
                battery_level,
                last_service_date,
                latitude,
                longitude,
                location: {
                    type: 'Point',
                    coordinates: [longitude, latitude]
                }
            });

            await bike.save();
            return { message: "Bike created successfully", bike };
        } catch (error) {
            console.error('Error creating bikeModel:', error.message);
            throw error;
        }
    }

    // 2. Get all bikes
    static async getAllBikes() {
        try {
            const bikes = await bikeModel.find().populate('station_id');
            return bikes;
        } catch (error) {
            throw error;
        }
    }

    // 3. Get bike by ID
    static async getBikeById(bikeId) {
        try {
            const bike = await bikeModel.findById(bikeId).populate('station_id');
            if (!bike) throw new Error('Bike not found');
            return bike;
        } catch (error) {
            throw error;
        }
    }

    // 4. Update bike
    static async updateBike(bikeId, data) {
        try {
            if (data.latitude && data.longitude) {
                data.location = {
                    type: 'Point',
                    coordinates: [data.longitude, data.latitude]
                };
            }

            // If isInDock is false, unset station_id
            if (data.isInDock === false) {
                data.station_id = null;
            }

            const updatedBike = await bikeModel.findByIdAndUpdate(bikeId, data, { new: true });
            if (!updatedBike) throw new Error('Bike not found');

            return updatedBike;
        } catch (error) {
            throw error;
        }
    }

    // 5. Delete bike
    static async deleteBike(bikeId) {
        try {
            const deleted = await bikeModel.findByIdAndDelete(bikeId);
            if (!deleted) throw new Error('Bike not found');
            return { message: 'Bike deleted successfully', deleted };
        } catch (error) {
            throw error;
        }
    }
}

module.exports = bikeService;

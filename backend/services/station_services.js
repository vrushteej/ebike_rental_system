const mongoose = require('mongoose');
const stationModel = require('../models/station_model');
const { create } = require('../models/user_model');

class stationService {
    static async createStation(station_name,latitude,longitude,capacity,available_bikes) {
        try {
            const existingStation = await stationModel.findOne({station_name,latitude,longitude});
            if (existingStation) {
                throw new Error("A station already exists at this location");
            }

            const station = new stationModel({
                station_name,
                latitude,
                longitude,
                location: {
                    type: "Point",
                    coordinates: [longitude, latitude] // GeoJSON format: [lng, lat]
                },
                capacity,
                available_bikes
            });

            await station.save();
            return { message: "Station created succesfully", station};
        } catch (error) {
            throw error;
        }
    }

    static async getAllStations() {
        try {
            const stations = await stationModel.find();
            return stations;
        } catch (error) {
            throw error;
        }
    }

    static async getStationName(station_name) {
        try {
            const station = await stationModel.findOne({station_name});
            if(!station)
                throw new Error("Station does not exist with this name");
            return station;
        } catch (error) {
            throw error;
        }
    }

    static async getStationbyCoordinates(latitude,longitude) {
        try {
            const station = await stationModel.findOne({latitude,longitude});
            if(!station)
                throw new Error("Station not found at these coordinates");
            return station;
        } catch (error) {
            throw error;
        }
    }

    static async updateStationdetails(stationId,station_name,capacity,available_bikes) {
        try {
            const updateData = {};

            if(station_name) updateData.station_name = station_name;
            if(capacity) updateData.capacity = capacity;
            if(available_bikes) updateData.available_bikes = available_bikes;

            const updateStation = await stationModel.findByIdAndUpdate(stationId,updateData, { new: true });
            if(!updateStation) throw new Error('Station not found');

            return updateStation;
        } catch (error) {
            throw error;
        }
    }

    static async deleteStation(stationId) {
        try {
            const deletedStation = await stationModel.findByIdAndDelete(stationId);
            if(!deletedStation) throw new Error('Station does not exist');

            return {message: 'Station deleted succesfully',deletedStation};
        } catch (error) {
            throw error;
        }
    }
}

module.exports = stationService;

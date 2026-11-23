import mongoose, { Model, Schema } from "mongoose";

import requestLogManager from "../utils/request_log";

export interface ISimulatedLocationData {
    tripId: string;
    driverId: string;
    vehicleId: string;
    latitude: number;
    longitude: number;
    speed: number;
    heading: number;
    accuracy: number;
    createdAt?: Date;
    updatedAt?: Date;
}

interface IFindSimulatedLocationData {
    tripId: string;
}

class SimulatedLocationModel {
    private static readonly simulatedLocationModel: Model<ISimulatedLocationData> =
        mongoose.models.SimulatedLocation ||
        mongoose.model<ISimulatedLocationData>(
            "SimulatedLocation",
            new Schema<ISimulatedLocationData>(
                {
                    tripId: { type: String, required: true, unique: true, index: true },
                    driverId: { type: String, required: true, index: true },
                    vehicleId: { type: String, required: true },
                    latitude: { type: Number, required: true, min: -90, max: 90 },
                    longitude: { type: Number, required: true, min: -180, max: 180 },
                    speed: { type: Number, required: true, min: 0 },
                    heading: { type: Number, required: true, min: 0, max: 360 },
                    accuracy: { type: Number, required: true, min: 0 }
                },
                { timestamps: true }
            )
        );

    public static async updateLatestLocation(locationData: ISimulatedLocationData): Promise<ISimulatedLocationData> {
        requestLogManager.addEvent("Updating simulated location in database");

        const updatedLocation = await this.simulatedLocationModel
            .findOneAndUpdate(
                { tripId: locationData.tripId },
                { $set: locationData },
                { new: true, upsert: true, runValidators: true, setDefaultsOnInsert: true }
            )
            .lean<ISimulatedLocationData>()
            .exec();

        requestLogManager.addEvent("Simulated location updated in database");

        return updatedLocation as ISimulatedLocationData;
    }

    public static async findLocationByTripId(locationData: IFindSimulatedLocationData): Promise<ISimulatedLocationData | null> {
        requestLogManager.addEvent("Checking simulated location in database");

        const location = await this.simulatedLocationModel
            .findOne({ tripId: locationData.tripId })
            .lean<ISimulatedLocationData>()
            .exec();

        requestLogManager.addEvent(
            location ? "Simulated location found in database" : "Simulated location not found in database"
        );

        return location;
    }
}

export default SimulatedLocationModel;

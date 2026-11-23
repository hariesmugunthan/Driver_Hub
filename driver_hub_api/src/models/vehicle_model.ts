import mongoose, { Model, Schema } from "mongoose";

import requestLogManager from "../utils/request_log";

interface IVehicleData {
    vehicleId: string;
    registrationNumber: string;
    vehicleType: string;
    brand: string;
    model: string;
    fuelType: string;
    seatingCapacity: number;
    isAvailable: boolean;
    createdAt: Date;
    updatedAt: Date;
}

interface IFindVehicleByIdData {
    vehicleId: string;
}

interface IFindVehicleByRegistrationNumberData {
    registrationNumber: string;
}

interface IUpdateVehicleData {
    vehicleId: string;
    vehicleData: Partial<IVehicleData>;
}

interface IDeleteVehicleData {
    vehicleId: string;
}

class VehicleModel {
    private static readonly vehicleModel: Model<IVehicleData> =
        mongoose.models.Vehicle ||
        mongoose.model<IVehicleData>(
            "Vehicle",
            new Schema<IVehicleData>(
                {
                    vehicleId: { type: String, required: true, unique: true, index: true },
                    registrationNumber: { type: String, required: true, unique: true, trim: true, uppercase: true, index: true },
                    vehicleType: { type: String, required: true, trim: true },
                    brand: { type: String, required: true, trim: true },
                    model: { type: String, required: true, trim: true },
                    fuelType: { type: String, required: true, trim: true },
                    seatingCapacity: { type: Number, required: true, min: 1 },
                    isAvailable: { type: Boolean, required: true, default: true }
                },
                { timestamps: true }
            )
        );

    public static async findVehicleById(vehicleData: IFindVehicleByIdData): Promise<IVehicleData | null> {
        requestLogManager.addEvent("Checking vehicle ID in database");

        const vehicle = await this.vehicleModel
            .findOne({ vehicleId: vehicleData.vehicleId })
            .lean<IVehicleData>()
            .exec();

        requestLogManager.addEvent(vehicle ? "Vehicle found in database" : "Vehicle not found in database");

        return vehicle;
    }

    public static async findVehicleByRegistrationNumber(vehicleData: IFindVehicleByRegistrationNumberData): Promise<IVehicleData | null> {
        requestLogManager.addEvent("Checking vehicle registration number in database");

        const vehicle = await this.vehicleModel
            .findOne({ registrationNumber: vehicleData.registrationNumber })
            .lean<IVehicleData>()
            .exec();

        requestLogManager.addEvent(
            vehicle
                ? "Vehicle registration number found in database"
                : "Vehicle registration number not found in database"
        );

        return vehicle;
    }

    public static async createVehicle(vehicleData: IVehicleData): Promise<IVehicleData> {
        requestLogManager.addEvent("Creating vehicle in database");

        const vehicle = new this.vehicleModel(vehicleData);

        const createdVehicle = await vehicle.save();

        requestLogManager.addEvent("Vehicle saved in database");

        return createdVehicle.toObject() as IVehicleData;
    }

    public static async findAllVehicles(): Promise<IVehicleData[]> {
        requestLogManager.addEvent("Checking all vehicles in database");

        const vehicleList = await this.vehicleModel.find({}).sort({ createdAt: -1 }).lean<IVehicleData[]>().exec();

        requestLogManager.addEvent(`Found ${vehicleList.length} vehicles in database`);

        return vehicleList;
    }

    public static async findAvailableVehicles(): Promise<IVehicleData[]> {
        return await this.vehicleModel.find({ isAvailable: true });
    }

    public static async updateVehicle(updateData: IUpdateVehicleData): Promise<IVehicleData | null> {
        requestLogManager.addEvent("Updating vehicle in database");

        const updatedVehicle = await this.vehicleModel
            .findOneAndUpdate(
                { vehicleId: updateData.vehicleId },
                updateData.vehicleData,
                { new: true, runValidators: true }
            )
            .lean<IVehicleData>()
            .exec();

        requestLogManager.addEvent(updatedVehicle ? "Vehicle updated in database" : "Vehicle not found for update");

        return updatedVehicle;
    }

    public static async deleteVehicle(vehicleData: IDeleteVehicleData): Promise<IVehicleData | null> {
        requestLogManager.addEvent("Deleting vehicle from database");

        const deletedVehicle = await this.vehicleModel
            .findOneAndDelete({ vehicleId: vehicleData.vehicleId })
            .lean<IVehicleData>()
            .exec();

        requestLogManager.addEvent(deletedVehicle ? "Vehicle deleted from database" : "Vehicle not found for deletion");

        return deletedVehicle;
    }
}

export default VehicleModel;

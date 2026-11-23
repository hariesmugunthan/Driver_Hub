import { v4 as uuidv4 } from "uuid";
import VehicleModel from "../models/vehicle_model";
import requestLogManager from "../utils/request_log";

interface ICreateVehicleData {
    registrationNumber: string;
    vehicleType: string;
    brand: string;
    model: string;
    fuelType: string;
    seatingCapacity: number;
    isAvailable?: boolean;
}

interface IGetVehicleData {
    vehicleId: string;
}

interface IUpdateVehicleData {
    vehicleId: string;
    registrationNumber?: string;
    vehicleType?: string;
    brand?: string;
    model?: string;
    fuelType?: string;
    seatingCapacity?: number;
    isAvailable?: boolean;
}

interface IDeleteVehicleData {
    vehicleId: string;
}

interface IVehicleResponse {
    vehicleId: string;
    registrationNumber: string;
    vehicleType: string;
    brand: string;
    model: string;
    fuelType: string;
    seatingCapacity: number;
    isAvailable: boolean;
}

class VehicleService {
    public static async createVehicle(vehicleData: ICreateVehicleData): Promise<IVehicleResponse> {
        const normalizedRegistrationNumber = vehicleData.registrationNumber?.trim().toUpperCase();

        const normalizedVehicleType = vehicleData.vehicleType?.trim();

        const normalizedBrand = vehicleData.brand?.trim();

        const normalizedModel = vehicleData.model?.trim();

        const normalizedFuelType = vehicleData.fuelType?.trim();

        if (
            !normalizedRegistrationNumber ||
            !normalizedVehicleType ||
            !normalizedBrand ||
            !normalizedModel ||
            !normalizedFuelType
        ) {
            throw new Error("All vehicle details are required");
        }

        if (!Number.isInteger(vehicleData.seatingCapacity) || vehicleData.seatingCapacity < 1) {
            throw new Error("Seating capacity must be a positive integer");
        }

        const existingVehicle = await VehicleModel.findVehicleByRegistrationNumber({
            registrationNumber: normalizedRegistrationNumber
        });

        if (existingVehicle) {
            throw new Error("Vehicle with this registration number already exists");
        }

        const newVehicleId = uuidv4();

        const currentDate = new Date();

        const createdVehicle = await VehicleModel.createVehicle({
            vehicleId: newVehicleId,
            registrationNumber: normalizedRegistrationNumber,
            vehicleType: normalizedVehicleType,
            brand: normalizedBrand,
            model: normalizedModel,
            fuelType: normalizedFuelType,
            seatingCapacity: vehicleData.seatingCapacity,
            isAvailable: vehicleData.isAvailable ?? true,
            createdAt: currentDate,
            updatedAt: currentDate
        });

        requestLogManager.addEvent("Vehicle created successfully");

        return this.createVehicleResponse(createdVehicle);
    }

    public static async getVehicle(vehicleData: IGetVehicleData): Promise<IVehicleResponse> {
        const normalizedVehicleId = vehicleData.vehicleId?.trim();

        if (!normalizedVehicleId) {
            throw new Error("Vehicle ID is required");
        }

        const vehicle = await VehicleModel.findVehicleById({ vehicleId: normalizedVehicleId });

        if (!vehicle) {
            throw new Error("Vehicle not found");
        }

        requestLogManager.addEvent("Vehicle retrieved successfully");

        return this.createVehicleResponse(vehicle);
    }

    public static async getAllVehicles(): Promise<IVehicleResponse[]> {
        const vehicleList = await VehicleModel.findAllVehicles();

        requestLogManager.addEvent("All vehicles retrieved successfully");

        return vehicleList.map(function (vehicle) {
            return VehicleService.createVehicleResponse(vehicle);
        });
    }

    public static async getAvailableVehicles(): Promise<IVehicleResponse[]> {
        const availableVehicleList = await VehicleModel.findAvailableVehicles();

        const vehicleResponseList: IVehicleResponse[] = [];

        for (const vehicle of availableVehicleList) {
            vehicleResponseList.push(this.createVehicleResponse(vehicle));
        }

        requestLogManager.addEvent(`Found ${vehicleResponseList.length} available vehicles`);

        return vehicleResponseList;
    }

    public static async updateVehicle(vehicleData: IUpdateVehicleData): Promise<IVehicleResponse> {
        const normalizedVehicleId = vehicleData.vehicleId?.trim();

        if (!normalizedVehicleId) {
            throw new Error("Vehicle ID is required");
        }

        const existingVehicle = await VehicleModel.findVehicleById({ vehicleId: normalizedVehicleId });

        if (!existingVehicle) {
            throw new Error("Vehicle not found");
        }

        const updateData: Partial<ICreateVehicleData> = {};

        if (vehicleData.registrationNumber !== undefined) {
            const normalizedRegistrationNumber = vehicleData.registrationNumber.trim().toUpperCase();

            if (!normalizedRegistrationNumber) {
                throw new Error("Registration number cannot be empty");
            }

            const existingVehicleByRegistration = await VehicleModel.findVehicleByRegistrationNumber({
                registrationNumber: normalizedRegistrationNumber
            });

            if (existingVehicleByRegistration && existingVehicleByRegistration.vehicleId !== normalizedVehicleId) {
                throw new Error("Another vehicle already uses this registration number");
            }

            updateData.registrationNumber = normalizedRegistrationNumber;
        }

        if (vehicleData.vehicleType !== undefined) {
            if (!vehicleData.vehicleType.trim()) {
                throw new Error("Vehicle type cannot be empty");
            }

            updateData.vehicleType = vehicleData.vehicleType.trim();
        }

        if (vehicleData.brand !== undefined) {
            if (!vehicleData.brand.trim()) {
                throw new Error("Brand cannot be empty");
            }

            updateData.brand = vehicleData.brand.trim();
        }

        if (vehicleData.model !== undefined) {
            if (!vehicleData.model.trim()) {
                throw new Error("Model cannot be empty");
            }

            updateData.model = vehicleData.model.trim();
        }

        if (vehicleData.fuelType !== undefined) {
            if (!vehicleData.fuelType.trim()) {
                throw new Error("Fuel type cannot be empty");
            }

            updateData.fuelType = vehicleData.fuelType.trim();
        }

        if (vehicleData.seatingCapacity !== undefined) {
            if (!Number.isInteger(vehicleData.seatingCapacity) || vehicleData.seatingCapacity < 1) {
                throw new Error("Seating capacity must be a positive integer");
            }

            updateData.seatingCapacity = vehicleData.seatingCapacity;
        }

        if (vehicleData.isAvailable !== undefined) {
            updateData.isAvailable = vehicleData.isAvailable;
        }

        if (Object.keys(updateData).length === 0) {
            throw new Error("At least one vehicle field is required for update");
        }

        const updatedVehicle = await VehicleModel.updateVehicle({
            vehicleId: normalizedVehicleId,
            vehicleData: updateData
        });

        if (!updatedVehicle) {
            throw new Error("Vehicle update failed");
        }

        requestLogManager.addEvent("Vehicle updated successfully");

        return this.createVehicleResponse(updatedVehicle);
    }

    public static async deleteVehicle(vehicleData: IDeleteVehicleData): Promise<IVehicleResponse> {
        const normalizedVehicleId = vehicleData.vehicleId?.trim();

        if (!normalizedVehicleId) {
            throw new Error("Vehicle ID is required");
        }

        const deletedVehicle = await VehicleModel.deleteVehicle({ vehicleId: normalizedVehicleId });

        if (!deletedVehicle) {
            throw new Error("Vehicle not found");
        }

        requestLogManager.addEvent("Vehicle deleted successfully");

        return this.createVehicleResponse(deletedVehicle);
    }

    private static createVehicleResponse(vehicle: {
        vehicleId: string;
        registrationNumber: string;
        vehicleType: string;
        brand: string;
        model: string;
        fuelType: string;
        seatingCapacity: number;
        isAvailable: boolean;
    }): IVehicleResponse {
        return {
            vehicleId: vehicle.vehicleId,
            registrationNumber: vehicle.registrationNumber,
            vehicleType: vehicle.vehicleType,
            brand: vehicle.brand,
            model: vehicle.model,
            fuelType: vehicle.fuelType,
            seatingCapacity: vehicle.seatingCapacity,
            isAvailable: vehicle.isAvailable
        };
    }
}

export default VehicleService;

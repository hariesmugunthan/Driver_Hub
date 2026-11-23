import { NextFunction, Request, Response } from "express";

import VehicleService from "../services/vehicle_service";

class VehicleController {
    public static async ioCreateVehicle(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const vehicleData = request.body;
            const createdVehicle = await VehicleService.createVehicle(vehicleData);

            response.status(201).json({
                success: true,
                message: "Vehicle created successfully",
                data: createdVehicle
            });
        } catch (error) {
            next(error);
        }
    }

    public static async ioGetVehicle(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const vehicleData = request.body;
            const vehicle = await VehicleService.getVehicle(vehicleData);

            response.status(200).json({
                success: true,
                message: "Vehicle retrieved successfully",
                data: vehicle
            });
        } catch (error) {
            next(error);
        }
    }

    public static async ioGetAllVehicles(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const vehicleList = await VehicleService.getAllVehicles();

            response.status(200).json({
                success: true,
                message: "Vehicles retrieved successfully",
                data: vehicleList
            });
        } catch (error) {
            next(error);
        }
    }

    public static async ioGetAvailableVehicles(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const availableVehicleList = await VehicleService.getAvailableVehicles();

            response.status(200).json({
                success: true,
                message: "Available vehicles retrieved successfully",
                data: availableVehicleList
            });
        } catch (error) {
            next(error);
        }
    }

    public static async ioUpdateVehicle(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const vehicleData = request.body;
            const updatedVehicle = await VehicleService.updateVehicle(vehicleData);

            response.status(200).json({
                success: true,
                message: "Vehicle updated successfully",
                data: updatedVehicle
            });
        } catch (error) {
            next(error);
        }
    }

    public static async ioDeleteVehicle(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const vehicleData = request.body;
            const deletedVehicle = await VehicleService.deleteVehicle(vehicleData);

            response.status(200).json({
                success: true,
                message: "Vehicle deleted successfully",
                data: deletedVehicle
            });
        } catch (error) {
            next(error);
        }
    }
}

export default VehicleController;
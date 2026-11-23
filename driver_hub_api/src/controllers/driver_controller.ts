import { NextFunction, Request, Response } from "express";

import DriverService from "../services/driver_service";

class DriverController {
    public static async ioCreateDriver(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const driverData = request.body;

            const createdDriver = await DriverService.createDriver(driverData);

            response.status(201).json({
                success: true,
                message: "Driver created successfully",
                data: createdDriver
            });
        } catch (error) {
            next(error);
        }
    }

    public static async ioGetDriver(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const driverData = request.body;

            const driver = await DriverService.getDriver(driverData);

            response.status(200).json({
                success: true,
                message: "Driver retrieved successfully",
                data: driver
            });
        } catch (error) {
            next(error);
        }
    }

    public static async ioGetAllDrivers(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const driverList = await DriverService.getAllDrivers();

            response.status(200).json({
                success: true,
                message: "Drivers retrieved successfully",
                data: driverList
            });
        } catch (error) {
            next(error);
        }
    }

    public static async ioGetAvailableDrivers(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const availableDriverList = await DriverService.getAvailableDrivers();

            response.status(200).json({
                success: true,
                message: "Available drivers retrieved successfully",
                data: availableDriverList
            });
        } catch (error) {
            next(error);
        }
    }

    public static async ioUpdateDriver(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const driverData = request.body;

            const updatedDriver = await DriverService.updateDriver(driverData);

            response.status(200).json({
                success: true,
                message: "Driver updated successfully",
                data: updatedDriver
            });
        } catch (error) {
            next(error);
        }
    }

    public static async ioDeleteDriver(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const driverData = request.body;

            const deletedDriver = await DriverService.deleteDriver(driverData);

            response.status(200).json({
                success: true,
                message: "Driver deleted successfully",
                data: deletedDriver
            });
        } catch (error) {
            next(error);
        }
    }
}

export default DriverController;
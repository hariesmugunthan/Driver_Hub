import { Request, Response, NextFunction } from "express";

import TripService from "../services/trip_service";
import requestLogManager from "../utils/request_log";

class TripController {
    public static async ioCreateTrip(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const createdTrip = await TripService.createTrip(request.body);

            response.status(201).json({
                success: true,
                message: "Trip created successfully",
                data: createdTrip
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to create trip");

            next(error);
        }
    }

    public static async ioGetTrip(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const trip = await TripService.getTrip(request.body);

            response.status(200).json({
                success: true,
                message: "Trip retrieved successfully",
                data: trip
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to retrieve trip");

            next(error);
        }
    }

    public static async ioStartTrip(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const startedTrip = await TripService.startTrip({
                tripId: request.body.tripId,
                driverId: request.body.driverId
            });

            response.status(200).json({
                success: true,
                message: "Trip started successfully",
                data: startedTrip
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to start trip");

            next(error);
        }
    }

    public static async ioEndTrip(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const endedTrip = await TripService.endTrip({
                tripId: request.body.tripId,
                driverId: request.body.driverId,
                totalDistanceMeters: request.body.totalDistanceMeters
            });

            response.status(200).json({
                success: true,
                message: "Trip ended successfully",
                data: endedTrip
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to end trip");

            next(error);
        }
    }

    public static async ioGetTripsByDriverId(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const tripList = await TripService.getTripsByDriverId(request.body);

            response.status(200).json({
                success: true,
                message: "Driver trips retrieved successfully",
                data: tripList
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to retrieve driver trips");

            next(error);
        }
    }

    public static async ioGetDriverPerformance(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const performance = await TripService.getDriverPerformance(request.body);

            response.status(200).json({
                success: true,
                message: "Driver performance retrieved successfully",
                data: performance
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to retrieve driver performance");

            next(error);
        }
    }

    public static async ioGetAllTrips(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const tripList = await TripService.getAllTrips();

            response.status(200).json({
                success: true,
                message: "All trips retrieved successfully",
                data: tripList
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to retrieve all trips");

            next(error);
        }
    }

    public static async ioUpdateTrip(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const updatedTrip = await TripService.updateTrip(request.body);

            response.status(200).json({
                success: true,
                message: "Trip updated successfully",
                data: updatedTrip
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to update trip");

            next(error);
        }
    }

    public static async ioCancelTrip(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const cancelledTrip = await TripService.cancelTrip(request.body);

            response.status(200).json({
                success: true,
                message: "Trip cancelled successfully",
                data: cancelledTrip
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to cancel trip");

            next(error);
        }
    }

    public static async ioDeleteTrip(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const deletedTrip = await TripService.deleteTrip(request.body);

            response.status(200).json({
                success: true,
                message: "Trip deleted successfully",
                data: deletedTrip
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to delete trip");

            next(error);
        }
    }
}

export default TripController;
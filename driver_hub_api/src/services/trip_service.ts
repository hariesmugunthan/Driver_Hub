import {v4 as uuidv4} from "uuid";
import GoogleRoutesService from "./google_routes_service";
import TripModel from "../models/trip_model";
import UserModel from "../models/user_model";
import VehicleModel from "../models/vehicle_model";
import requestLogManager from "../utils/request_log";

type TripStatus = "scheduled" | "inProgress" | "delayed" | "completed" | "cancelled";

interface ICreateTripData {
    driverId: string;
    vehicleId: string;
    startLocation: string;
    endLocation: string;
    startLatitude: number;
    startLongitude: number;
    endLatitude: number;
    endLongitude: number;
    description?: string | null;
}

interface IGetTripData {
    tripId: string;
}

interface IGetTripsByDriverIdData {
    driverId: string;
}

interface IDriverPerformanceResponse {
    driverId: string;
    totalAssignedTrips: number;
    completedTrips: number;
    totalDistanceMeters: number;
    totalDistanceKilometers: number;
    totalDrivingHours: number;
    averageTripDistanceKilometers: number;
    averageTripDurationHours: number;
    completionRate: number;
}

interface IUpdateTripData {
    tripId: string;
    driverId?: string;
    vehicleId?: string;
    startLocation?: string;
    endLocation?: string;
    startLatitude?: number;
    startLongitude?: number;
    endLatitude?: number;
    endLongitude?: number;
    description?: string | null;
}

interface IDeleteTripData {
    tripId: string;
}

interface ICancelTripData {
    tripId: string;
}

interface ITripResponse {
    tripId: string;
    driverId: string;
    vehicleId: string;
    startLocation: string;
    endLocation: string;
    startLatitude: number;
    startLongitude: number;
    endLatitude: number;
    endLongitude: number;
    actualStartTime: Date | null;
    actualEndTime: Date | null;
    status: TripStatus;
    description: string | null;
    totalDistanceMeters: number | null;
}

interface IDriverTripResponse extends ITripResponse {
    vehicle: { registrationNumber: string; brand: string; model: string } | null;
}

interface IAdminTripResponse extends ITripResponse {
    driverName: string;
    vehicle: { registrationNumber: string; brand: string; model: string } | null;
}

interface ITripUpdateFields {
    driverId?: string;
    vehicleId?: string;
    startLocation?: string;
    endLocation?: string;
    startLatitude?: number;
    startLongitude?: number;
    endLatitude?: number;
    endLongitude?: number;
    description?: string | null;
}

class TripService {
    public static async createTrip(tripData: ICreateTripData): Promise<ITripResponse> {
        const normalizedDriverId = tripData.driverId?.trim();

        const normalizedVehicleId = tripData.vehicleId?.trim();

        const normalizedStartLocation = tripData.startLocation?.trim();

        const normalizedEndLocation = tripData.endLocation?.trim();

        if (!normalizedDriverId || !normalizedVehicleId || !normalizedStartLocation || !normalizedEndLocation) {
            throw new Error("Driver, vehicle and location details are required");
        }

        this.validateCoordinates({
            startLatitude: tripData.startLatitude,
            startLongitude: tripData.startLongitude,
            endLatitude: tripData.endLatitude,
            endLongitude: tripData.endLongitude
        });

        await this.validateDriverAndVehicle({
            driverId: normalizedDriverId,
            vehicleId: normalizedVehicleId,
            checkAvailability: true
        });

        const currentDate = new Date();

        const createdTrip = await TripModel.createTrip({
            tripId: uuidv4(),
            driverId: normalizedDriverId,
            vehicleId: normalizedVehicleId,
            startLocation: normalizedStartLocation,
            endLocation: normalizedEndLocation,
            startLatitude: tripData.startLatitude,
            startLongitude: tripData.startLongitude,
            endLatitude: tripData.endLatitude,
            endLongitude: tripData.endLongitude,
            actualStartTime: null,
            actualEndTime: null,
            status: "scheduled",
            description: tripData.description?.trim() || null,
            createdAt: currentDate,
            updatedAt: currentDate
        });

        requestLogManager.addEvent("Trip created successfully");

        return this.createTripResponse(createdTrip);
    }

    public static async getTrip(tripData: IGetTripData): Promise<ITripResponse> {
        const normalizedTripId = tripData.tripId?.trim();

        if (!normalizedTripId) {
            throw new Error("Trip ID is required");
        }

        const trip = await TripModel.findTripById({tripId: normalizedTripId});

        if (!trip) {
            throw new Error("Trip not found");
        }

        requestLogManager.addEvent("Trip retrieved successfully");

        return this.createTripResponse(trip);
    }

    public static async startTrip(tripData: { tripId: string; driverId: string }): Promise<ITripResponse> {
        const normalizedTripId = tripData.tripId?.trim();

        const normalizedDriverId = tripData.driverId?.trim();

        if (!normalizedTripId || !normalizedDriverId) {
            throw new Error("Trip ID and driver ID are required");
        }

        const existingTrip = await TripModel.findTripById({tripId: normalizedTripId});

        if (!existingTrip) {
            throw new Error("Trip not found");
        }

        if (existingTrip.driverId !== normalizedDriverId) {
            throw new Error("This trip is not assigned to the specified driver");
        }

        if (existingTrip.status !== "scheduled") {
            throw new Error("Only scheduled trips can be started");
        }

        const startedTrip = await TripModel.startTrip({
            tripId: normalizedTripId,
            driverId: normalizedDriverId,
            actualStartTime: new Date()
        });

        if (!startedTrip) {
            throw new Error("Trip could not be started. Its status may have changed.");
        }

        requestLogManager.addEvent("Trip started successfully");

        return this.createTripResponse(startedTrip);
    }

    public static async endTrip(
        tripData: { tripId: string; driverId: string; totalDistanceMeters?: number }
    ): Promise<ITripResponse> {
        const normalizedTripId = tripData.tripId?.trim();
        const normalizedDriverId = tripData.driverId?.trim();

        if (!normalizedTripId || !normalizedDriverId) {
            throw new Error("Trip ID and driver ID are required");
        }

        if (
            tripData.totalDistanceMeters !== undefined &&
            (!Number.isFinite(tripData.totalDistanceMeters) || tripData.totalDistanceMeters < 0)
        ) {
            throw new Error("Total distance must be a valid non-negative number");
        }

        const existingTrip = await TripModel.findTripById({tripId: normalizedTripId});

        if (!existingTrip) {
            throw new Error("Trip not found");
        }

        if (existingTrip.driverId !== normalizedDriverId) {
            throw new Error("This trip is not assigned to the specified driver");
        }

        if (existingTrip.status === "completed") {
            requestLogManager.addEvent("Trip was already completed");

            return this.createTripResponse(existingTrip);
        }

        if (existingTrip.status !== "inProgress") {
            throw new Error("Only in-progress trips can be ended");
        }

        const endedTrip = await TripModel.endTrip({
            tripId: normalizedTripId,
            driverId: normalizedDriverId,
            actualEndTime: new Date(),
            totalDistanceMeters: tripData.totalDistanceMeters
        });

        if (endedTrip) {
            requestLogManager.addEvent("Trip ended successfully");

            return this.createTripResponse(endedTrip);
        }

        const latestTrip = await TripModel.findTripById({tripId: normalizedTripId});

        if (latestTrip && latestTrip.driverId === normalizedDriverId && latestTrip.status === "completed") {
            requestLogManager.addEvent("Trip was completed by another request");

            return this.createTripResponse(latestTrip);
        }

        throw new Error("Trip could not be ended. Its status may have changed.");
    }

    public static async getTripsByDriverId(tripData: IGetTripsByDriverIdData): Promise<IDriverTripResponse[]> {
        const normalizedDriverId = tripData.driverId?.trim();

        if (!normalizedDriverId) {
            throw new Error("Driver ID is required");
        }

        const driver = await UserModel.findUserByUserId({userId: normalizedDriverId});

        if (!driver || !driver.role.includes("driver")) {
            throw new Error("Driver not found");
        }

        const tripList = await TripModel.findTripsByDriverId({driverId: normalizedDriverId});

        const driverTripList: IDriverTripResponse[] = [];

        for (const trip of tripList) {
            const vehicle = await VehicleModel.findVehicleById({vehicleId: trip.vehicleId});

            const driverTrip: IDriverTripResponse = {
                ...this.createTripResponse(trip),

                vehicle: vehicle
                    ? {registrationNumber: vehicle.registrationNumber, brand: vehicle.brand, model: vehicle.model}
                    : null
            };

            driverTripList.push(driverTrip);
        }

        requestLogManager.addEvent("Driver trips retrieved successfully");

        return driverTripList;
    }

    public static async getDriverPerformance(tripData: IGetTripsByDriverIdData): Promise<IDriverPerformanceResponse> {
        const normalizedDriverId = tripData.driverId?.trim();

        if (!normalizedDriverId) {
            throw new Error("Driver ID is required");
        }

        const driver = await UserModel.findUserByUserId({userId: normalizedDriverId});

        if (!driver || !driver.role.includes("driver")) {
            throw new Error("Driver not found");
        }

        const tripList = await TripModel.findTripsByDriverId({driverId: normalizedDriverId});

        const completedTripArray = tripList.filter(function (trip) {
            return trip.status === "completed";
        });

        let totalDistanceMeters = 0;
        let totalDrivingMilliseconds = 0;

        for (const trip of completedTripArray) {
            const route = await GoogleRoutesService.computeRoute({
                startLatitude: trip.startLatitude,
                startLongitude: trip.startLongitude,
                endLatitude: trip.endLatitude,
                endLongitude: trip.endLongitude
            });

            totalDistanceMeters += route.distanceMeters;

            if (trip.actualStartTime && trip.actualEndTime) {
                totalDrivingMilliseconds +=
                    new Date(trip.actualEndTime).getTime() - new Date(trip.actualStartTime).getTime();
            }
        }

        const completedTripCount = completedTripArray.length;

        const totalDrivingHours = totalDrivingMilliseconds / (1000 * 60 * 60);

        const totalDistanceKilometers = totalDistanceMeters / 1000;

        const averageTripDistanceKilometers = completedTripCount > 0 ? totalDistanceKilometers / completedTripCount : 0;

        const averageTripDurationHours = completedTripCount > 0 ? totalDrivingHours / completedTripCount : 0;

        const completionRate = tripList.length > 0 ? (completedTripCount / tripList.length) * 100 : 0;

        requestLogManager.addEvent("Driver performance calculated successfully");

        return {
            driverId: normalizedDriverId,
            totalAssignedTrips: tripList.length,
            completedTrips: completedTripCount,
            totalDistanceMeters,
            totalDistanceKilometers: Number(totalDistanceKilometers.toFixed(2)),
            totalDrivingHours: Number(totalDrivingHours.toFixed(2)),
            averageTripDistanceKilometers: Number(averageTripDistanceKilometers.toFixed(2)),
            averageTripDurationHours: Number(averageTripDurationHours.toFixed(2)),
            completionRate: Number(completionRate.toFixed(2))
        };
    }

    public static async getAllTrips(): Promise<IAdminTripResponse[]> {
        const tripList = await TripModel.findAllTrips();

        const adminTripList: IAdminTripResponse[] = [];

        for (const trip of tripList) {
            const driver = await UserModel.findUserByUserId({userId: trip.driverId});

            const vehicle = await VehicleModel.findVehicleById({vehicleId: trip.vehicleId});

            const adminTrip: IAdminTripResponse = {
                ...this.createTripResponse(trip),

                driverName: driver ? driver.name : "Unknown Driver",

                vehicle: vehicle
                    ? {registrationNumber: vehicle.registrationNumber, brand: vehicle.brand, model: vehicle.model}
                    : null
            };

            adminTripList.push(adminTrip);
        }

        requestLogManager.addEvent("All trips retrieved successfully");

        return adminTripList;
    }

    public static async updateTrip(tripData: IUpdateTripData): Promise<ITripResponse> {
        const restrictedFieldArray = ["status", "actualStartTime", "actualEndTime"];

        const providedRestrictedFields = restrictedFieldArray.filter(function (field) {
            return Object.prototype.hasOwnProperty.call(tripData, field);
        });

        if (providedRestrictedFields.length > 0) {
            throw new Error("Trip status and actual timestamps can only be changed using trip start and end operations");
        }

        const normalizedTripId = tripData.tripId?.trim();

        if (!normalizedTripId) {
            throw new Error("Trip ID is required");
        }

        const existingTrip = await TripModel.findTripById({tripId: normalizedTripId});

        if (!existingTrip) {
            throw new Error("Trip not found");
        }

        const normalizedDriverId = tripData.driverId !== undefined ? tripData.driverId.trim() : existingTrip.driverId;

        const normalizedVehicleId =
            tripData.vehicleId !== undefined ? tripData.vehicleId.trim() : existingTrip.vehicleId;

        if (!normalizedDriverId || !normalizedVehicleId) {
            throw new Error("Driver ID and vehicle ID cannot be empty");
        }

        await this.validateDriverAndVehicle({
            driverId: normalizedDriverId,
            vehicleId: normalizedVehicleId,
            checkAvailability: false
        });

        const assignmentChanged =
            normalizedDriverId !== existingTrip.driverId || normalizedVehicleId !== existingTrip.vehicleId;

        if (assignmentChanged) {
            await this.validateDriverAndVehicle({
                driverId: normalizedDriverId,
                vehicleId: normalizedVehicleId,
                checkAvailability: true
            });
        }

        const updateData: ITripUpdateFields = {};

        updateData.driverId = normalizedDriverId;
        updateData.vehicleId = normalizedVehicleId;

        if (tripData.startLocation !== undefined) {
            const normalizedLocation = tripData.startLocation.trim();

            if (!normalizedLocation) {
                throw new Error("Start location cannot be empty");
            }

            updateData.startLocation = normalizedLocation;
        }

        if (tripData.endLocation !== undefined) {
            const normalizedLocation = tripData.endLocation.trim();

            if (!normalizedLocation) {
                throw new Error("End location cannot be empty");
            }

            updateData.endLocation = normalizedLocation;
        }

        const startLatitude = tripData.startLatitude ?? existingTrip.startLatitude;

        const startLongitude = tripData.startLongitude ?? existingTrip.startLongitude;

        const endLatitude = tripData.endLatitude ?? existingTrip.endLatitude;

        const endLongitude = tripData.endLongitude ?? existingTrip.endLongitude;

        this.validateCoordinates({startLatitude, startLongitude, endLatitude, endLongitude});

        if (tripData.startLatitude !== undefined) {
            updateData.startLatitude = tripData.startLatitude;
        }

        if (tripData.startLongitude !== undefined) {
            updateData.startLongitude = tripData.startLongitude;
        }

        if (tripData.endLatitude !== undefined) {
            updateData.endLatitude = tripData.endLatitude;
        }

        if (tripData.endLongitude !== undefined) {
            updateData.endLongitude = tripData.endLongitude;
        }

        if (tripData.description !== undefined) {
            updateData.description = tripData.description?.trim() || null;
        }

        if (Object.keys(updateData).length === 0) {
            throw new Error("At least one trip field is required for update");
        }

        const updatedTrip = await TripModel.updateTrip({tripId: normalizedTripId, tripData: updateData});

        if (!updatedTrip) {
            throw new Error("Trip update failed");
        }

        requestLogManager.addEvent("Trip updated successfully");

        return this.createTripResponse(updatedTrip);
    }

    public static async cancelTrip(tripData: ICancelTripData): Promise<ITripResponse> {
        const normalizedTripId = tripData.tripId?.trim();

        if (!normalizedTripId) {
            throw new Error("Trip ID is required");
        }

        const existingTrip = await TripModel.findTripById({tripId: normalizedTripId});

        if (!existingTrip) {
            throw new Error("Trip not found");
        }

        if (existingTrip.status !== "scheduled") {
            throw new Error("Only scheduled trips can be cancelled");
        }

        const cancelledTrip = await TripModel.cancelTrip({tripId: normalizedTripId});

        if (!cancelledTrip) {
            throw new Error("Trip could not be cancelled. Its status may have changed.");
        }

        requestLogManager.addEvent("Trip cancelled successfully");

        return this.createTripResponse(cancelledTrip);
    }

    public static async deleteTrip(tripData: IDeleteTripData): Promise<ITripResponse> {
        const normalizedTripId = tripData.tripId?.trim();

        if (!normalizedTripId) {
            throw new Error("Trip ID is required");
        }

        const existingTrip = await TripModel.findTripById({tripId: normalizedTripId});

        if (!existingTrip) {
            throw new Error("Trip not found");
        }

        if (existingTrip.status === "inProgress" || existingTrip.status === "delayed") {
            throw new Error("Trips that are in progress or delayed cannot be deleted");
        }

        const deletedTrip = await TripModel.deleteTrip({tripId: normalizedTripId});

        if (!deletedTrip) {
            throw new Error("Trip could not be deleted");
        }

        requestLogManager.addEvent("Trip deleted successfully");

        return this.createTripResponse(deletedTrip);
    }

    private static async validateDriverAndVehicle(
        validationData: { driverId: string; vehicleId: string; checkAvailability: boolean }
    ): Promise<void> {
        const {driverId, vehicleId, checkAvailability} = validationData;

        const driver = await UserModel.findUserByUserId({userId: driverId});

        if (!driver || !driver.role.includes("driver") || !driver.driver) {
            throw new Error("Invalid driver ID or driver profile not found");
        }

        const vehicle = await VehicleModel.findVehicleById({vehicleId});

        if (!vehicle) {
            throw new Error("Vehicle not found");
        }

        if (checkAvailability) {
            if (!driver.driver.isAvailable) {
                throw new Error("Driver is currently unavailable");
            }

            if (!vehicle.isAvailable) {
                throw new Error("Vehicle is currently unavailable");
            }
        }
    }

    private static validateCoordinates(
        coordinatesData: { startLatitude: number; startLongitude: number; endLatitude: number; endLongitude: number }
    ): void {
        const {startLatitude, startLongitude, endLatitude, endLongitude} = coordinatesData;

        const coordinates = [startLatitude, startLongitude, endLatitude, endLongitude];

        if (
            !coordinates.every(function (coordinate) {
                return typeof coordinate === "number" && Number.isFinite(coordinate);
            })
        ) {
            throw new Error("All coordinates must be valid numbers");
        }

        if (startLatitude < -90 || startLatitude > 90 || endLatitude < -90 || endLatitude > 90) {
            throw new Error("Latitude must be between -90 and 90");
        }

        if (startLongitude < -180 || startLongitude > 180 || endLongitude < -180 || endLongitude > 180) {
            throw new Error("Longitude must be between -180 and 180");
        }
    }

    private static createTripResponse(
        trip: {
            tripId: string;
            driverId: string;
            vehicleId: string;
            startLocation: string;
            endLocation: string;
            startLatitude: number;
            startLongitude: number;
            endLatitude: number;
            endLongitude: number;
            actualStartTime: Date | null;
            actualEndTime: Date | null;
            totalDistanceMeters?: number | null;
            status: TripStatus;
            description: string | null;
        }
    ): ITripResponse {
        return {
            tripId: trip.tripId,
            driverId: trip.driverId,
            vehicleId: trip.vehicleId,
            startLocation: trip.startLocation,
            endLocation: trip.endLocation,
            startLatitude: trip.startLatitude,
            startLongitude: trip.startLongitude,
            endLatitude: trip.endLatitude,
            endLongitude: trip.endLongitude,
            actualStartTime: trip.actualStartTime,
            actualEndTime: trip.actualEndTime,
            totalDistanceMeters: trip.totalDistanceMeters ?? null,
            status: trip.status,
            description: trip.description
        };
    }
}

export default TripService;

import TripService from "./trip_service";
import GoogleRoutesService from "./google_routes_service";

import SimulatedLocationModel, { ISimulatedLocationData } from "../models/simulated_location_model";

interface IGetSimulationRouteData {
    tripId: string;
}

interface ISimulationRouteResponse {
    tripId: string;
    driverId: string;
    vehicleId: string;
    encodedPolyline: string;
    distanceMeters: number;
    duration: string;
}

interface IUpdateSimulatedLocationData {
    tripId: string;
    latitude: number;
    longitude: number;
    speed: number;
    heading: number;
    accuracy: number;
}

class SimulationService {
    public static async getSimulationRoute(routeData: IGetSimulationRouteData): Promise<ISimulationRouteResponse> {
        const tripId = routeData.tripId?.trim();

        if (!tripId) {
            throw new Error("Trip ID is required");
        }

        const trip = await TripService.getTrip({ tripId: tripId });

        if (trip.status !== "inProgress") {
            throw new Error("Simulation is only allowed for an in-progress trip");
        }

        const computedRoute = await GoogleRoutesService.computeRoute({
            startLatitude: trip.startLatitude,
            startLongitude: trip.startLongitude,
            endLatitude: trip.endLatitude,
            endLongitude: trip.endLongitude
        });

        const simulationRoute: ISimulationRouteResponse = {
            tripId: trip.tripId,
            driverId: trip.driverId,
            vehicleId: trip.vehicleId,
            encodedPolyline: computedRoute.encodedPolyline,
            distanceMeters: computedRoute.distanceMeters,
            duration: computedRoute.duration
        };

        return simulationRoute;
    }

    public static async updateSimulatedLocation(locationData: IUpdateSimulatedLocationData): Promise<ISimulatedLocationData> {
        const tripId = locationData.tripId?.trim();

        if (!tripId) {
            throw new Error("Trip ID is required");
        }

        this.validateLocationData(locationData);

        const trip = await TripService.getTrip({ tripId: tripId });

        if (trip.status !== "inProgress") {
            throw new Error("Cannot update location for a trip that is not in progress");
        }

        const simulatedLocation: ISimulatedLocationData = {
            tripId: trip.tripId,
            driverId: trip.driverId,
            vehicleId: trip.vehicleId,
            latitude: locationData.latitude,
            longitude: locationData.longitude,
            speed: locationData.speed,
            heading: locationData.heading,
            accuracy: locationData.accuracy
        };

        return await SimulatedLocationModel.updateLatestLocation(simulatedLocation);
    }

    private static validateLocationData(locationData: IUpdateSimulatedLocationData): void {
        const valueArray = [
            locationData.latitude,
            locationData.longitude,
            locationData.speed,
            locationData.heading,
            locationData.accuracy
        ];

        for (const value of valueArray) {
            if (typeof value !== "number" || !Number.isFinite(value)) {
                throw new Error("All location values must be valid numbers");
            }
        }

        if (locationData.latitude < -90 || locationData.latitude > 90) {
            throw new Error("Invalid latitude");
        }

        if (locationData.longitude < -180 || locationData.longitude > 180) {
            throw new Error("Invalid longitude");
        }

        if (locationData.speed < 0) {
            throw new Error("Speed cannot be negative");
        }

        if (locationData.heading < 0 || locationData.heading > 360) {
            throw new Error("Invalid heading");
        }

        if (locationData.accuracy < 0) {
            throw new Error("Accuracy cannot be negative");
        }
    }

    public static async getSimulatedLocation(locationData: { tripId: string }): Promise<ISimulatedLocationData | null> {
        const tripId = locationData.tripId?.trim();

        if (!tripId) {
            throw new Error("Trip ID is required");
        }

        const trip = await TripService.getTrip({ tripId: tripId });

        return await SimulatedLocationModel.findLocationByTripId({ tripId: trip.tripId });
    }
}

export default SimulationService;

import mongoose, { Model, Schema } from "mongoose";

import requestLogManager from "../utils/request_log";

type TripStatus = "scheduled" | "inProgress" | "delayed" | "completed" | "cancelled";

interface ITripData {
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

    createdAt: Date;
    updatedAt: Date;
}

interface IFindTripByIdData {
    tripId: string;
}

interface IFindTripsByDriverIdData {
    driverId: string;
}

interface IStartTripData {
    tripId: string;
    driverId: string;
    actualStartTime: Date;
}

interface IEndTripData {
    tripId: string;
    driverId: string;
    actualEndTime: Date;
    totalDistanceMeters?: number;
}

interface ICancelTripData {
    tripId: string;
}

interface IUpdateTripData {
    tripId: string;
    tripData: Partial<ITripData>;
}

interface IDeleteTripData {
    tripId: string;
}

class TripModel {
    private static readonly tripModel: Model<ITripData> =
        mongoose.models.Trip ||
        mongoose.model<ITripData>(
            "Trip",
            new Schema<ITripData>(
                {
                    tripId: { type: String, required: true, unique: true, index: true },
                    driverId: { type: String, required: true, index: true },
                    vehicleId: { type: String, required: true, index: true },
                    startLocation: { type: String, required: true, trim: true },
                    endLocation: { type: String, required: true, trim: true },
                    startLatitude: { type: Number, required: true, min: -90, max: 90 },
                    startLongitude: { type: Number, required: true, min: -180, max: 180 },
                    endLatitude: { type: Number, required: true, min: -90, max: 90 },
                    endLongitude: { type: Number, required: true, min: -180, max: 180 },
                    actualStartTime: { type: Date, default: null },
                    actualEndTime: { type: Date, default: null },
                    totalDistanceMeters: { type: Number, default: null, min: 0 },
                    status: {
                        type: String,
                        enum: ["scheduled", "inProgress", "delayed", "completed", "cancelled"],
                        required: true,
                        default: "scheduled"
                    },
                    description: { type: String, default: null, trim: true }
                },
                { timestamps: true }
            )
        );

    public static async findTripById(tripData: IFindTripByIdData): Promise<ITripData | null> {
        requestLogManager.addEvent("Checking trip ID in database");

        const trip = await this.tripModel.findOne({ tripId: tripData.tripId }).lean<ITripData>().exec();

        requestLogManager.addEvent(trip ? "Trip found in database" : "Trip not found in database");

        return trip;
    }

    public static async startTrip(tripData: IStartTripData): Promise<ITripData | null> {
        requestLogManager.addEvent("Starting trip in database");

        const startedTrip = await this.tripModel
            .findOneAndUpdate(
                { tripId: tripData.tripId, driverId: tripData.driverId, status: "scheduled" },
                { $set: { status: "inProgress", actualStartTime: tripData.actualStartTime } },
                { new: true, runValidators: true }
            )
            .lean<ITripData>()
            .exec();

        requestLogManager.addEvent(startedTrip ? "Trip started in database" : "Trip could not be started");

        return startedTrip;
    }

    public static async endTrip(tripData: IEndTripData): Promise<ITripData | null> {
        requestLogManager.addEvent("Ending trip in database");

        const updateData: { status: TripStatus; actualEndTime: Date; totalDistanceMeters?: number } = {
            status: "completed",
            actualEndTime: tripData.actualEndTime
        };

        if (typeof tripData.totalDistanceMeters === "number") {
            updateData.totalDistanceMeters = tripData.totalDistanceMeters;
        }

        const endedTrip = await this.tripModel
            .findOneAndUpdate(
                { tripId: tripData.tripId, driverId: tripData.driverId, status: "inProgress" },
                { $set: updateData },
                { new: true, runValidators: true }
            )
            .lean<ITripData>()
            .exec();

        requestLogManager.addEvent(endedTrip ? "Trip ended in database" : "Trip could not be ended");

        return endedTrip;
    }

    public static async cancelTrip(tripData: ICancelTripData): Promise<ITripData | null> {
        requestLogManager.addEvent("Cancelling scheduled trip in database");

        const cancelledTrip = await this.tripModel
            .findOneAndUpdate(
                { tripId: tripData.tripId, status: "scheduled" },
                { $set: { status: "cancelled" } },
                { new: true, runValidators: true }
            )
            .lean<ITripData>()
            .exec();

        requestLogManager.addEvent(cancelledTrip ? "Trip cancelled in database" : "Trip could not be cancelled");

        return cancelledTrip;
    }

    public static async findTripsByDriverId(tripData: IFindTripsByDriverIdData): Promise<ITripData[]> {
        requestLogManager.addEvent("Checking trips assigned to driver in database");

        const tripList = await this.tripModel
            .find({ driverId: tripData.driverId })
            .sort({ createdAt: -1 })
            .lean<ITripData[]>()
            .exec();

        requestLogManager.addEvent(`Found ${tripList.length} trips for driver`);

        return tripList;
    }

    public static async findAllTrips(): Promise<ITripData[]> {
        requestLogManager.addEvent("Checking all trips in database");

        const tripList = await this.tripModel.find({}).sort({ createdAt: -1 }).lean<ITripData[]>().exec();

        requestLogManager.addEvent(`Found ${tripList.length} trips in database`);

        return tripList;
    }

    public static async createTrip(tripData: ITripData): Promise<ITripData> {
        requestLogManager.addEvent("Creating trip in database");

        const trip = new this.tripModel(tripData);

        const createdTrip = await trip.save();

        requestLogManager.addEvent("Trip saved in database");

        return createdTrip.toObject() as ITripData;
    }

    public static async updateTrip(updateData: IUpdateTripData): Promise<ITripData | null> {
        requestLogManager.addEvent("Updating trip in database");

        const updatedTrip = await this.tripModel
            .findOneAndUpdate({ tripId: updateData.tripId }, updateData.tripData, { new: true, runValidators: true })
            .lean<ITripData>()
            .exec();

        requestLogManager.addEvent(updatedTrip ? "Trip updated in database" : "Trip not found for update");

        return updatedTrip;
    }

    public static async deleteTrip(tripData: IDeleteTripData): Promise<ITripData | null> {
        requestLogManager.addEvent("Deleting trip from database");

        const deletedTrip = await this.tripModel
            .findOneAndDelete({ tripId: tripData.tripId, status: { $nin: ["inProgress", "delayed"] } })
            .lean<ITripData>()
            .exec();

        requestLogManager.addEvent(deletedTrip ? "Trip deleted from database" : "Trip not found for deletion");

        return deletedTrip;
    }
}

export default TripModel;

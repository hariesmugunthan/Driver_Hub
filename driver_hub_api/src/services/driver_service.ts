import { v4 as uuidv4 } from "uuid";

import UserModel, { IDriverDetails, IUserDocument } from "../models/user_model";
import requestLogManager from "../utils/request_log";

interface ICreateDriverData {
    name: string;
    mobileNumber: string;
    email: string;
    dateOfBirth?: Date;
    gender?: string;
    address?: string;
    licenseNumber: string;
    licenseExpiryDate: Date;
    isAvailable?: boolean;
}

interface IGetDriverData {
    userId: string;
}

interface IUpdateDriverData {
    userId: string;
    name: string;
    mobileNumber: string;
    email: string;
    dateOfBirth?: Date;
    gender?: string;
    address?: string;
    licenseNumber: string;
    licenseExpiryDate: Date;
    isAvailable: boolean;
}

interface IDeleteDriverData {
    userId: string;
}

interface IDriverResponse {
    userId: string;
    name: string;
    mobileNumber: string;
    email: string;
    dateOfBirth?: Date;
    gender?: string;
    address?: string;
    licenseNumber: string;
    licenseExpiryDate: Date;
    isAvailable: boolean;
}

class DriverService {
    public static async createDriver(driverData: ICreateDriverData): Promise<IDriverResponse> {
        requestLogManager.addEvent("Validating driver details");

        const normalizedName = driverData.name?.trim();
        const normalizedMobileNumber = driverData.mobileNumber?.trim();
        const normalizedEmail = driverData.email?.trim().toLowerCase();
        const normalizedLicenseNumber = driverData.licenseNumber?.trim();

        if (!normalizedName) {
            throw new Error("Driver name is required");
        }

        if (!normalizedMobileNumber) {
            throw new Error("Driver mobile number is required");
        }

        if (!normalizedEmail) {
            throw new Error("Driver email is required");
        }

        if (!normalizedLicenseNumber) {
            throw new Error("Driver license number is required");
        }

        if (!driverData.licenseExpiryDate) {
            throw new Error("Driver license expiry date is required");
        }

        requestLogManager.addEvent("Driver details validated");

        const existingUser = await UserModel.findUserByEmail({ email: normalizedEmail });

        if (existingUser?.role.includes("driver")) {
            throw new Error("Driver email already exists");
        }

        const existingUserByLicense = await UserModel.findUserByLicenseNumber({
            licenseNumber: normalizedLicenseNumber
        });

        if (existingUserByLicense) {
            throw new Error("Driver license number already exists");
        }

        const driverDetails: IDriverDetails = {
            dateOfBirth: driverData.dateOfBirth,
            gender: driverData.gender?.trim(),
            address: driverData.address?.trim(),
            licenseNumber: normalizedLicenseNumber,
            licenseExpiryDate: driverData.licenseExpiryDate,
            isAvailable: driverData.isAvailable ?? true
        };

        let createdUser: IUserDocument | null;

        if (existingUser) {
            requestLogManager.addEvent("Adding driver role to existing user");

            createdUser = await UserModel.addDriverRole({
                userId: existingUser.userId,
                name: normalizedName,
                mobileNumber: normalizedMobileNumber,
                driverDetails
            });

            if (!createdUser) {
                throw new Error("Failed to add driver role to existing user");
            }
        } else {
            const userId = `USR-${uuidv4()}`;

            createdUser = await UserModel.createUser({
                userId,
                name: normalizedName,
                email: normalizedEmail,
                mobileNumber: normalizedMobileNumber,
                role: ["driver"],
                driver: driverDetails
            });
        }

        requestLogManager.addEvent("Driver created successfully");

        return this.createDriverResponse(createdUser);
    }

    public static async getDriver(driverData: IGetDriverData): Promise<IDriverResponse> {
        const normalizedUserId = driverData.userId?.trim();

        if (!normalizedUserId) {
            throw new Error("User ID is required");
        }

        const user = await UserModel.findUserByUserId({ userId: normalizedUserId });

        if (!user || !user.role.includes("driver") || !user.driver) {
            throw new Error("Driver not found");
        }

        requestLogManager.addEvent("Driver retrieved successfully");

        return this.createDriverResponse(user);
    }

    public static async getAllDrivers(): Promise<IDriverResponse[]> {
        requestLogManager.addEvent("Retrieving all drivers");

        const driverList = await UserModel.findAllDrivers();

        requestLogManager.addEvent("All drivers retrieved successfully");

        return driverList.map((user) => this.createDriverResponse(user));
    }

    public static async getAvailableDrivers(): Promise<IDriverResponse[]> {
        requestLogManager.addEvent("Retrieving available drivers");

        const availableDriverList = await UserModel.findAvailableDrivers();

        const driverResponseList: IDriverResponse[] = [];

        for (const user of availableDriverList) {
            driverResponseList.push(this.createDriverResponse(user));
        }

        requestLogManager.addEvent(`Found ${driverResponseList.length} available drivers`);

        return driverResponseList;
    }

    public static async updateDriver(driverData: IUpdateDriverData): Promise<IDriverResponse> {
        const normalizedUserId = driverData.userId?.trim();
        const normalizedName = driverData.name?.trim();
        const normalizedMobileNumber = driverData.mobileNumber?.trim();
        const normalizedEmail = driverData.email?.trim().toLowerCase();
        const normalizedLicenseNumber = driverData.licenseNumber?.trim();

        if (!normalizedUserId) {
            throw new Error("User ID is required");
        }

        if (!normalizedName) {
            throw new Error("Driver name is required");
        }

        if (!normalizedMobileNumber) {
            throw new Error("Driver mobile number is required");
        }

        if (!normalizedEmail) {
            throw new Error("Driver email is required");
        }

        if (!normalizedLicenseNumber) {
            throw new Error("Driver license number is required");
        }

        if (!driverData.licenseExpiryDate) {
            throw new Error("Driver license expiry date is required");
        }

        const existingUser = await UserModel.findUserByUserId({ userId: normalizedUserId });

        if (!existingUser || !existingUser.role.includes("driver")) {
            throw new Error("Driver not found");
        }

        const existingUserByEmail = await UserModel.findUserByEmail({ email: normalizedEmail });

        if (existingUserByEmail && existingUserByEmail.userId !== normalizedUserId) {
            throw new Error("Email already exists");
        }

        const existingUserByLicense = await UserModel.findUserByLicenseNumber({
            licenseNumber: normalizedLicenseNumber
        });

        if (existingUserByLicense && existingUserByLicense.userId !== normalizedUserId) {
            throw new Error("Driver license number already exists");
        }

        const updatedUser = await UserModel.updateDriver({
            userId: normalizedUserId,
            updateData: {
                name: normalizedName,
                mobileNumber: normalizedMobileNumber,
                email: normalizedEmail,
                dateOfBirth: driverData.dateOfBirth,
                gender: driverData.gender?.trim(),
                address: driverData.address?.trim(),
                licenseNumber: normalizedLicenseNumber,
                licenseExpiryDate: driverData.licenseExpiryDate,
                isAvailable: driverData.isAvailable
            }
        });

        if (!updatedUser) {
            throw new Error("Driver update failed");
        }

        requestLogManager.addEvent("Driver updated successfully");

        return this.createDriverResponse(updatedUser);
    }

    public static async deleteDriver(driverData: IDeleteDriverData): Promise<IDriverResponse> {
        const normalizedUserId = driverData.userId?.trim();

        if (!normalizedUserId) {
            throw new Error("User ID is required");
        }

        const existingUser = await UserModel.findUserByUserId({ userId: normalizedUserId });

        if (!existingUser || !existingUser.role.includes("driver") || !existingUser.driver) {
            throw new Error("Driver not found");
        }

        // Capture the driver details before deleting the driver role.
        const deletedDriverResponse = this.createDriverResponse(existingUser);

        const deletedUser = await UserModel.deleteDriver({ userId: normalizedUserId });

        if (!deletedUser) {
            throw new Error("Driver deletion failed");
        }

        requestLogManager.addEvent("Driver deleted successfully");

        return deletedDriverResponse;
    }

    private static createDriverResponse(user: IUserDocument): IDriverResponse {
        if (!user.driver) {
            throw new Error("Driver details not found");
        }

        return {
            userId: user.userId,
            name: user.name,
            mobileNumber: user.mobileNumber ?? "",
            email: user.email,
            dateOfBirth: user.driver.dateOfBirth,
            gender: user.driver.gender,
            address: user.driver.address,
            licenseNumber: user.driver.licenseNumber,
            licenseExpiryDate: user.driver.licenseExpiryDate,
            isAvailable: user.driver.isAvailable
        };
    }
}

export default DriverService;

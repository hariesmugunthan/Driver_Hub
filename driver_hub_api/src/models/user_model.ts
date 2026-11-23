import mongoose, { Document, Model, Schema } from "mongoose";

export type UserRole = "admin" | "driver";

export interface IDriverDetails {
    dateOfBirth?: Date;
    gender?: string;
    address?: string;
    licenseNumber: string;
    licenseExpiryDate: Date;
    isAvailable: boolean;
}

export interface IUserData {
    userId: string;
    name: string;
    email: string;
    mobileNumber?: string;
    role: UserRole[];
    driver?: IDriverDetails;
    createdAt?: Date;
    updatedAt?: Date;
}

export interface IUserDocument extends IUserData, Document { }

export interface IAddDriverRoleData {
    userId: string;
    name: string;
    mobileNumber: string;
    driverDetails: IDriverDetails;
}

export interface IAddUserRoleData {
    userId: string;
    role: UserRole;
}

export interface IFindUserByUserIdData {
    userId: string;
}

export interface IFindUserByEmailData {
    email: string;
}

export interface IFindUserByLicenseNumberData {
    licenseNumber: string;
}

export interface IUpdateDriverData {
    userId: string;
    updateData: Partial<IUserData> & Partial<IDriverDetails>;
}

export interface IDeleteDriverData {
    userId: string;
}

const driverDetailsSchema = new Schema<IDriverDetails>(
    {
        dateOfBirth: { type: Date },
        gender: { type: String },
        address: { type: String },
        licenseNumber: { type: String, required: true, trim: true },
        licenseExpiryDate: { type: Date, required: true },
        isAvailable: { type: Boolean, default: true },
    },
    { _id: false }
);
//defining scheme
const userSchema = new Schema<IUserDocument>(
    {
        userId: { type: String, required: true, unique: true, trim: true },
        name: { type: String, required: true, trim: true },
        email: { type: String, required: true, unique: true, lowercase: true, trim: true },
        mobileNumber: { type: String, trim: true },
        role: { type: [String], enum: ["admin", "driver"], required: true },
        driver: { type: driverDetailsSchema },
    },
    { timestamps: true }
);

// Ensure license numbers are unique when a driver profile exists.
userSchema.index(
    { "driver.licenseNumber": 1 },
    { unique: true, partialFilterExpression: { "driver.licenseNumber": { $type: "string" } } }
);

class UserModel {
    public static async addDriverRole(data: IAddDriverRoleData): Promise<IUserDocument | null> {
        return await this.userModel.findOneAndUpdate(
            { userId: data.userId, role: { $ne: "driver" } },
            {
                $addToSet: { role: "driver" },
                $set: { name: data.name, mobileNumber: data.mobileNumber, driver: data.driverDetails },
            },
            { new: true, runValidators: true }
        );
    }

    public static async addUserRole(data: IAddUserRoleData): Promise<IUserDocument | null> {
        return await this.userModel.findOneAndUpdate(
            { userId: data.userId },
            { $addToSet: { role: data.role } },
            { new: true, runValidators: true }
        );
    }

    private static readonly userModel: Model<IUserDocument> =
        mongoose.models.User || mongoose.model<IUserDocument>("User", userSchema);

    public static async findUserByUserId(data: IFindUserByUserIdData): Promise<IUserDocument | null> {
        return await this.userModel.findOne({ userId: data.userId });
    }

    public static async findUserByEmail(data: IFindUserByEmailData): Promise<IUserDocument | null> {
        return await this.userModel.findOne({ email: data.email });
    }

    public static async findUserByLicenseNumber(data: IFindUserByLicenseNumberData): Promise<IUserDocument | null> {
        return await this.userModel.findOne({ "driver.licenseNumber": data.licenseNumber });
    }

    public static async createUser(userData: IUserData): Promise<IUserDocument> {
        return await this.userModel.create(userData);
    }

    public static async findAllDrivers(): Promise<IUserDocument[]> {
        return await this.userModel.find({ role: "driver" });
    }

    public static async findAvailableDrivers(): Promise<IUserDocument[]> {
        return await this.userModel.find({ role: "driver", "driver.isAvailable": true });
    }

    public static async updateDriver(data: IUpdateDriverData): Promise<IUserDocument | null> {
        const updateFields: Record<string, unknown> = {};

        if (data.updateData.name !== undefined) {
            updateFields.name = data.updateData.name;
        }

        if (data.updateData.email !== undefined) {
            updateFields.email = data.updateData.email;
        }

        if (data.updateData.mobileNumber !== undefined) {
            updateFields.mobileNumber = data.updateData.mobileNumber;
        }

        const driverFieldArray: (keyof IDriverDetails)[] = [
            "dateOfBirth", "gender", "address", "licenseNumber", "licenseExpiryDate", "isAvailable",
        ];

        for (const field of driverFieldArray) {
            if (data.updateData[field] !== undefined) {
                updateFields[`driver.${field}`] = data.updateData[field];
            }
        }

        return await this.userModel.findOneAndUpdate(
            { userId: data.userId, role: "driver" },
            { $set: updateFields },
            { new: true, runValidators: true }
        );
    }

    public static async deleteDriver(data: IDeleteDriverData): Promise<IUserDocument | null> {
        const user = await this.userModel.findOne({ userId: data.userId, role: "driver" });

        if (!user) {
            return null;
        }

        // Preserve the account if the user also has the admin role.
        if (user.role.length > 1) {
            return await this.userModel.findOneAndUpdate(
                { userId: data.userId },
                { $pull: { role: "driver" }, $unset: { driver: 1 } },
                { new: true }
            );
        }

        // Delete the entire user only when they have no other role.
        return await this.userModel.findOneAndDelete({ userId: data.userId });
    }
}

export default UserModel;

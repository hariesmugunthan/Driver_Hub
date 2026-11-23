import { v4 as uuidv4 } from "uuid";

import UserModel from "../models/user_model";
import environmentConfig from "../configs/environment_config";
import requestLogManager from "../utils/request_log";

interface IRegisterAdminData {
    name: string;
    email: string;
    masterPassword: string;
}

class AdminService {
    public static async registerAdmin(adminData: IRegisterAdminData): Promise<{ userId: string; name: string; email: string; }> {
        this.validateMasterAdminPassword(adminData.masterPassword);

        const normalizedEmail = adminData.email.trim().toLowerCase();

        const existingUser = await UserModel.findUserByEmail({ email: normalizedEmail });

        let createdUser;

        if (existingUser) {
            if (existingUser.role.includes("admin")) {
                throw new Error("Admin with this email already exists");
            }

            createdUser = await UserModel.addUserRole({ userId: existingUser.userId, role: "admin" });

            if (!createdUser) {
                throw new Error("Failed to add admin role to existing user");
            }
        } else {
            const userId = `USR-${uuidv4()}`;

            createdUser = await UserModel.createUser({
                userId,
                name: adminData.name.trim(),
                email: normalizedEmail,
                role: ["admin"],
            });
        }

        requestLogManager.addEvent("Admin created successfully");

        return { userId: createdUser.userId, name: createdUser.name, email: createdUser.email };
    }

    private static validateMasterAdminPassword(masterPassword: string): boolean {
        if (masterPassword !== environmentConfig.masterAdminPassword) {
            throw new Error("Invalid master admin password");
        }

        return true;
    }
}

export default AdminService;

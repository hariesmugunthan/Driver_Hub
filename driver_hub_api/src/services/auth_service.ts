import UserModel from "../models/user_model";
import requestLogManager from "../utils/request_log";
import FirebaseAuthService from "./firebase_auth_service";

type UserRole = "admin" | "driver";

interface IAuthenticateUserData {
    firebaseToken: string;
    role: UserRole;
}

interface IAdminAuthResponse {
    userId: string;
    name: string;
    email: string;
}

interface IDriverAuthResponse {
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

class AuthService {
    public static async authenticateUser(loginData: IAuthenticateUserData): Promise<IAdminAuthResponse | IDriverAuthResponse> {
        const firebaseToken = loginData.firebaseToken;
        const selectedRole = loginData.role;

        if (!firebaseToken) {
            throw new Error("Firebase token is required");
        }

        if (selectedRole !== "admin" && selectedRole !== "driver") {
            throw new Error("Invalid user role");
        }

        // Verify Firebase ID token.
        const decodedToken = await FirebaseAuthService.verifyFirebaseToken(firebaseToken);

        const firebaseEmail = decodedToken.email ?? "";

        if (!firebaseEmail) {
            throw new Error("Firebase account email not found");
        }

        const normalizedEmail = firebaseEmail.trim().toLowerCase();

        // Find the user using the verified Firebase email.
        const user = await UserModel.findUserByEmail({ email: normalizedEmail });

        if (!user) {
            throw new Error("User account not found");
        }

        // Verify that the user has the selected role.
        if (!user.role.includes(selectedRole)) {
            throw new Error(`User is not authorized to login as ${selectedRole}`);
        }

        // Return admin-specific response.
        if (selectedRole === "admin") {
            requestLogManager.addEvent("Admin authenticated successfully");

            return { userId: user.userId, name: user.name, email: user.email };
        }

        // Verify driver details exist.
        if (!user.driver) {
            throw new Error("Driver details not found");
        }

        // Return the existing driver response structure.
        requestLogManager.addEvent("Driver authenticated successfully");

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

export default AuthService;

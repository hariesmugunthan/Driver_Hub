import { NextFunction, Request, Response } from "express";

import AuthService from "../services/auth_service";

class AuthController {
    public static async ioAuthenticateUser(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const loginData = request.body;

            const authenticatedUser = await AuthService.authenticateUser(loginData);

            const selectedRole = loginData.role;

            const message = selectedRole === "admin" ? "Admin login successful" : "Driver login successful";

            response.status(200).json({
                success: true,
                message,
                data: authenticatedUser
            });
        } catch (error) {
            next(error);
        }
    }
}

export default AuthController;
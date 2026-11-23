import { NextFunction, Request, Response } from "express";

import AdminService from "../services/admin_service";

class AdminController {
    public static async ioRegisterAdmin(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const adminData = request.body;

            const createdAdmin = await AdminService.registerAdmin(adminData);

            response.status(201).json({
                success: true,
                message: "Admin registered successfully",
                data: createdAdmin
            });
        } catch (error) {
            next(error);
        }
    }
}

export default AdminController;
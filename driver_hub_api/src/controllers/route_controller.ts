import { Request, Response, NextFunction } from "express";

import GoogleRoutesService from "../services/google_routes_service";
import requestLogManager from "../utils/request_log";

class RouteController {
    public static async ioComputeRoute(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const computedRoute = await GoogleRoutesService.computeRoute(request.body);

            response.status(200).json({
                success: true,
                message: "Driving route calculated successfully",
                data: computedRoute
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to calculate driving route");

            next(error);
        }
    }
}

export default RouteController;
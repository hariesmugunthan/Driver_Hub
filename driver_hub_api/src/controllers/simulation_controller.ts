import { Request, Response, NextFunction } from "express";

import SimulationService from "../services/simulation_service";
import requestLogManager from "../utils/request_log";

class SimulationController {
    public static async ioGetSimulationRoute(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const simulationRoute = await SimulationService.getSimulationRoute(request.body);

            response.status(200).json({
                success: true,
                message: "Simulation route retrieved successfully",
                data: simulationRoute
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to retrieve simulation route");

            next(error);
        }
    }

    public static async ioUpdateSimulatedLocation(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const updatedLocation = await SimulationService.updateSimulatedLocation(request.body);

            response.status(200).json({
                success: true,
                message: "Simulated location updated successfully",
                data: updatedLocation
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to update simulated location");

            next(error);
        }
    }

    public static async ioGetSimulatedLocation(request: Request, response: Response, next: NextFunction): Promise<void> {
        try {
            const location = await SimulationService.getSimulatedLocation(request.body);

            if (!location) {
                response.status(404).json({
                    success: false,
                    message: "Simulated location not found"
                });
                return;
            }

            response.status(200).json({
                success: true,
                message: "Simulated location retrieved successfully",
                data: location
            });
        } catch (error) {
            requestLogManager.addEvent("Failed to retrieve simulated location");

            next(error);
        }
    }
}

export default SimulationController;
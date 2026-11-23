import { Router } from "express";
import SimulationController from "../controllers/simulation_controller";
import TripController from "../controllers/trip_controller";
import AdminController from "../controllers/admin_controller";
import AuthController from "../controllers/auth_controller";
import DriverController from "../controllers/driver_controller";
import VehicleController from "../controllers/vehicle_controller";
import RouteController from "../controllers/route_controller";

class Route {
    public router: Router;

    public constructor() {
        this.router = Router();

        // Admin registration and authentication
        this.router.post("/admin/register", AdminController.ioRegisterAdmin);
        this.router.post("/admin/login", AuthController.ioAuthenticateUser);

        // Driver routes
        this.router.post("/driver/create", DriverController.ioCreateDriver);
        this.router.post("/driver/get", DriverController.ioGetDriver);
        this.router.post("/driver/get_all", DriverController.ioGetAllDrivers);
        this.router.post("/driver/update", DriverController.ioUpdateDriver);
        this.router.post("/driver/delete", DriverController.ioDeleteDriver);
        this.router.post("/driver/get_available", DriverController.ioGetAvailableDrivers);

        // Vehicle routes
        this.router.post("/vehicle/create", VehicleController.ioCreateVehicle);
        this.router.post("/vehicle/get", VehicleController.ioGetVehicle);
        this.router.post("/vehicle/get_all", VehicleController.ioGetAllVehicles);
        this.router.post("/vehicle/update", VehicleController.ioUpdateVehicle);
        this.router.post("/vehicle/delete", VehicleController.ioDeleteVehicle);
        this.router.post("/vehicle/get_available", VehicleController.ioGetAvailableVehicles);

        // Trip routes
        this.router.post("/trip/create", TripController.ioCreateTrip);
        this.router.post("/trip/get", TripController.ioGetTrip);
        this.router.post("/trip/start", TripController.ioStartTrip);
        this.router.post("/trip/end", TripController.ioEndTrip);
        this.router.post("/trip/get_by_driver", TripController.ioGetTripsByDriverId);
        this.router.post("/trip/get_driver_performance", TripController.ioGetDriverPerformance);
        this.router.post("/trip/get_all", TripController.ioGetAllTrips);
        this.router.post("/trip/update", TripController.ioUpdateTrip);
        this.router.post("/trip/delete", TripController.ioDeleteTrip);
        this.router.post("/trip/cancel", TripController.ioCancelTrip);

        // Route calculation
        this.router.post("/route/compute", RouteController.ioComputeRoute);

        // Simulation routes
        this.router.post("/simulation/get_route", SimulationController.ioGetSimulationRoute);
        this.router.post("/simulation/update_location", SimulationController.ioUpdateSimulatedLocation);
        this.router.post("/simulation/get_location", SimulationController.ioGetSimulatedLocation);
    }
}

const route = new Route();

export default route;
import environmentConfig from "../configs/environment_config";
import requestLogManager from "../utils/request_log";

interface IRouteCoordinates {
    startLatitude: number;
    startLongitude: number;
    endLatitude: number;
    endLongitude: number;
}

interface IGoogleRoutesApiResponse {
    routes?: {
        distanceMeters: number;
        duration: string;
        polyline: { encodedPolyline: string; };
    }[];
}

interface IComputedRoute {
    encodedPolyline: string;
    distanceMeters: number;
    duration: string;
}

class GoogleRoutesService {
    //asking Google Maps to calculate a driving route between two locations.
    private static readonly routesApiUrl = "https://routes.googleapis.com/directions/v2:computeRoutes";

    //Instead of requesting unnecessary route information, your backend requests only the three fields it needs
    private static readonly responseFieldMask = "routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline";

    public static async computeRoute(coordinates: IRouteCoordinates): Promise<IComputedRoute> {
        this.validateCoordinates(coordinates);

        const apiKey = environmentConfig.googleRoutesApiKey;

        if (!apiKey) {
            throw new Error("Google Routes API key is not configured");
        }

        //preparing the request body that will be sent to Google Routes API to calculate a driving route.

        const requestBody = {
            origin: {
                location: { latLng: { latitude: coordinates.startLatitude, longitude: coordinates.startLongitude } }
            },
            destination: {
                location: { latLng: { latitude: coordinates.endLatitude, longitude: coordinates.endLongitude } }
            },
            travelMode: "DRIVE",
            routingPreference: "TRAFFIC_UNAWARE",
            polylineQuality: "OVERVIEW" //A simplified representation of the route.
        };

        //fetch() is a built-in JavaScript function used to send an HTTP request to another server

        const response = await fetch(this.routesApiUrl, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-Goog-Api-Key": apiKey,
                "X-Goog-FieldMask": this.responseFieldMask
            },
            //But fetch() expects the HTTP request body as a string (for this JSON request).
            body: JSON.stringify(requestBody)
        });

        /*if Google's HTTP response indicates a failure, execute the code inside this block.
        Google might return:
        - 400 – Bad Request.
        - 403 – Forbidden (for example, an API key or permission issue).
        - 500 – Internal Server Error.*/

        if (!response.ok) {
            const errorResponse = await response.text();

            console.error(
                `[google_routes_error] Status: ${response.status} | Response: ${errorResponse.replace(/\s+/g, " ")}`
            );

            throw new Error("Unable to calculate the driving route");
        }

        const routeResponse = await response.json() as IGoogleRoutesApiResponse;

        const calculatedRoute = routeResponse.routes?.[0];

        if (!calculatedRoute || !calculatedRoute.polyline?.encodedPolyline) {
            throw new Error("Google Routes API did not return a valid route");
        }

        const computedRoute: IComputedRoute = {
            encodedPolyline: calculatedRoute.polyline.encodedPolyline,
            distanceMeters: calculatedRoute.distanceMeters,
            duration: calculatedRoute.duration
        };

        requestLogManager.addEvent("Driving route calculated successfully");

        return computedRoute;
    }

    private static validateCoordinates(coordinates: IRouteCoordinates): void {
        const coordinateValues = [
            coordinates.startLatitude,
            coordinates.startLongitude,
            coordinates.endLatitude,
            coordinates.endLongitude
        ];

        for (const coordinate of coordinateValues) {
            if (typeof coordinate !== "number" || !Number.isFinite(coordinate)) {
                throw new Error("All coordinates must be valid numbers");
            }
        }

        if (
            coordinates.startLatitude < -90 ||
            coordinates.startLatitude > 90 ||
            coordinates.endLatitude < -90 ||
            coordinates.endLatitude > 90
        ) {
            throw new Error("Latitude must be between -90 and 90");
        }

        if (
            coordinates.startLongitude < -180 ||
            coordinates.startLongitude > 180 ||
            coordinates.endLongitude < -180 ||
            coordinates.endLongitude > 180
        ) {
            throw new Error("Longitude must be between -180 and 180");
        }
    }
}

export default GoogleRoutesService;

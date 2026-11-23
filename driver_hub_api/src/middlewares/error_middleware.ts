import { NextFunction, Request, Response } from "express";

import requestLogManager from "../utils/request_log";

class ErrorMiddleware {
    public static ioHandleError(error: Error, request: Request, response: Response, next: NextFunction): void {
        requestLogManager.addEvent("Request failed");

        response.status(400).json({ success: false, message: error.message });
    }
}

export default ErrorMiddleware;

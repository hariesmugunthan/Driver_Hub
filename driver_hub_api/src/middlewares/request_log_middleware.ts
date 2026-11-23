import { NextFunction, Request, Response } from "express";

import { RequestLog } from "../utils/request_log";
import requestLogManager from "../utils/request_log";

class RequestLogMiddleware {
    public static ioHandleRequestLog(request: Request, response: Response, next: NextFunction): void {
        const requestLog = new RequestLog();

        requestLog.addEvent("Request received");

        requestLogManager.runWithRequestLog(requestLog, function (): void {
            response.on("finish", function (): void {
                const eventList = requestLogManager.getLogEvents();

                const logLevel = response.statusCode >= 400 ? "error" : "info";

                console.log(`[${logLevel}] ${request.method} ${request.originalUrl} | ${eventList.join(" | ")}`);
            });

            next();
        });
    }
}

export default RequestLogMiddleware;

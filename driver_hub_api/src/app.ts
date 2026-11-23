import express from "express";
import ErrorMiddleware from "./middlewares/error_middleware";
import route from "./routes/route";
import errorMiddleware from "./middlewares/error_middleware";
import RequestLogMiddleware from "./middlewares/request_log_middleware";

const app = express();

app.use(express.json());

app.use(RequestLogMiddleware.ioHandleRequestLog);

app.use(route.router);

app.use(ErrorMiddleware.ioHandleError);

export default app;

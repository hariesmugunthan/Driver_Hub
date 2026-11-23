import app from "./src/app";
import DatabaseConfig from "./src/configs/database_config";
import environmentConfig from "./src/configs/environment_config";

async function startServer(): Promise<void> {
    await DatabaseConfig.connectToDatabase();

    app.listen(environmentConfig.port, function (): void {
        console.log(`[server_start_server] Server started on port ${environmentConfig.port}`);
    });
}

startServer();

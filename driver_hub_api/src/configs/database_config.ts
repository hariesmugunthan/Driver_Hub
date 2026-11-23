import mongoose from "mongoose";

import environmentConfig from "./environment_config";

class DatabaseConfig {
    public static async connectToDatabase(): Promise<void> {
        await mongoose.connect(environmentConfig.mongodbUri);

        console.log("[database_config_connect_to_database] MongoDB connected successfully");
    }
}

export default DatabaseConfig;

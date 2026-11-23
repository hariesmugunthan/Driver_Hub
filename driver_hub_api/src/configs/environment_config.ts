import "dotenv/config";

class EnvironmentConfig {
    public port: number;
    public mongodbUri: string;
    public masterAdminPassword: string;
    public firebaseProjectId: string;
    public firebaseClientEmail: string;
    public firebasePrivateKey: string;
    public googleRoutesApiKey: string;

    public constructor() {
        this.port = Number(process.env.PORT);
        this.mongodbUri = process.env.MONGODB_URI ?? "";
        this.masterAdminPassword = process.env.MASTER_ADMIN_PASSWORD ?? "";
        this.firebaseProjectId = process.env.FIREBASE_PROJECT_ID ?? "";
        this.firebaseClientEmail = process.env.FIREBASE_CLIENT_EMAIL ?? "";
        this.firebasePrivateKey = process.env.FIREBASE_PRIVATE_KEY ?? "";
        this.googleRoutesApiKey = process.env.GOOGLE_ROUTES_API_KEY ?? "";
    }
}

const environmentConfig = new EnvironmentConfig();

export default environmentConfig;

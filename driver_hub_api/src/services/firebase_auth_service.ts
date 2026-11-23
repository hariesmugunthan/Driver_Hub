import { DecodedIdToken } from "firebase-admin/auth";

import firebaseConfig from "../configs/firebase_config";
import requestLogManager from "../utils/request_log";

class FirebaseAuthService {
    public static async verifyFirebaseToken(firebaseToken: string): Promise<DecodedIdToken> {
        requestLogManager.addEvent("Verifying Firebase token");

        const decodedToken = await firebaseConfig.firebaseAuth.verifyIdToken(firebaseToken);

        requestLogManager.addEvent("Firebase token verified successfully");

        return decodedToken;
    }
}

export default FirebaseAuthService;

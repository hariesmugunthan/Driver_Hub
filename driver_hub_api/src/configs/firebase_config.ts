import { App, cert, getApps, initializeApp } from "firebase-admin/app";
import { Auth, getAuth } from "firebase-admin/auth";
import environmentConfig from "./environment_config";

class FirebaseConfig {
    private firebaseApp: App;//for connection
    public firebaseAuth: Auth;//for auth operation

    public constructor() {
        const appList = getApps();

        this.firebaseApp =
            appList.length > 0
                ? appList[0]//assign 1st application and assigns it to this.firebaseApp.
                : initializeApp({ //if not firebase  initilization nadakudhu
                    credential: cert({
                        projectId: environmentConfig.firebaseProjectId,
                        clientEmail: environmentConfig.firebaseClientEmail,
                        privateKey: environmentConfig.firebasePrivateKey.replace(/\\n/g, "\n")
                    })
                });
        ///getAuth retrieves the Firebase Authentication service associated with the given Firebase application.
        this.firebaseAuth = getAuth(this.firebaseApp);
    }
}

const firebaseConfig = new FirebaseConfig();

export default firebaseConfig;

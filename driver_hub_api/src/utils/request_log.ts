import { AsyncLocalStorage } from "async_hooks";

class RequestLog {
    private eventList: string[];

    public constructor() {
        this.eventList = [];
    }

    public addEvent(event: string): void {
        this.eventList.push(event);
    }

    public getLogEvents(): string[] {
        return this.eventList;
    }
}

class RequestLogManager {
    private asyncLocalStorage: AsyncLocalStorage<RequestLog>;

    public constructor() {
        this.asyncLocalStorage = new AsyncLocalStorage<RequestLog>();
    }

    public runWithRequestLog(requestLog: RequestLog, callback: () => void): void {
        this.asyncLocalStorage.run(requestLog, callback);
    }

    public addEvent(event: string): void {
        const requestLog = this.asyncLocalStorage.getStore();

        if (!requestLog) {
            return;
        }

        requestLog.addEvent(event);
    }

    public getLogEvents(): string[] {
        const requestLog = this.asyncLocalStorage.getStore();

        if (!requestLog) {
            return [];
        }

        return requestLog.getLogEvents();
    }
}

const requestLogManager = new RequestLogManager();

export { RequestLog };

export default requestLogManager;

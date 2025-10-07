import 'dotenv/config';
import awsLambdaFastify from '@fastify/aws-lambda';

import { buildApp } from '#/infrastructure/server/app';

const isLocal = process.env.NODE_ENV === 'dev';

const appPromise = buildApp();

let lambdaProxy: any;

if (isLocal) {
    (async () => {
        const app = await appPromise;
        const port = Number(process.env.PORT || 3000);
        await app.listen({ port, host: '0.0.0.0' });
        console.log(`🚀 Server running locally at http://localhost:${port}`);
    })();
}

export const handler = async (event: any, context: any): Promise<any> => {
    if (!lambdaProxy) {
        const app = await appPromise;
        lambdaProxy = awsLambdaFastify(app);
    }
    return lambdaProxy(event, context);
};

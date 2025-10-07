import awsLambdaFastify from '@fastify/aws-lambda';
import 'dotenv/config';

import { startServer } from '#/infrastructure/server/server';

const createHandler = async () => {
    const app = await startServer();
    return awsLambdaFastify(app);
};

export const handler = createHandler();

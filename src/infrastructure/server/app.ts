import fastify from 'fastify';
import { serializerCompiler, validatorCompiler } from 'fastify-type-provider-zod';

import { container } from '#/infrastructure/config/di/container';
import { authRoute } from '#/interfaces/http/routes/auth.route';

export async function buildApp() {
    const app = fastify({ logger: true });

    app.decorate('container', container);

    app.setSerializerCompiler(serializerCompiler);
    app.setValidatorCompiler(validatorCompiler);

    await app.register(authRoute);

    return app;
}

import fastify from 'fastify';

import { container } from '#/infrastructure/config/di/container';
import { authRoute } from '#/interfaces/http/routes/auth.route';

export async function buildApp() {
    const app = fastify({ logger: true });

    app.decorate('container', container);

    await app.register(authRoute);

    return app;
}

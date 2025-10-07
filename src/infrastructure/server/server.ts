import { env } from '#/infrastructure/config/env';
import { buildApp } from '#/infrastructure/server/app';

export async function startServer() {
    const isLocal = env.NODE_ENV === 'dev';

    const app = await buildApp();

    if (!isLocal) {
        return app;
    }

    const port = process.env.PORT ? Number(process.env.PORT) : 3000;
    app.listen({ port, host: '0.0.0.0' }, (err, address) => {
        if (err) {
            app.log.error(err);
            process.exit(1);
        }
        app.log.info(`🚀 Server running at ${address}`);
    });
    return app;
}

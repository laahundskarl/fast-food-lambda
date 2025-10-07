import { FastifyInstance } from 'fastify';

import { AuthDto } from '#/application/use-cases/auth/auth.dto';
import { TYPES } from '#/infrastructure/config/di/types';
import { IAuthController } from '#/interfaces/controller/interfaces/auth';
import { authSchema } from '#/interfaces/http/schemas/auth/auth.route-schema';

export const authRoute = (app: FastifyInstance) => {
    const controller = app.container.get<IAuthController>(TYPES.AuthController);

    app.post('/auth', authSchema, async (req, reply) => {
        const body = req.body as AuthDto;
        const response = await controller.getToken(body);
        console.log('RESPONSE', response);
        return reply.status(200).send(response);
    });
};

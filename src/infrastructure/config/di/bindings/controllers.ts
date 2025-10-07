import { Container } from 'inversify';

import { TYPES } from '#/infrastructure/config/di/types';
import { AuthController } from '#/interfaces/controller/auth.controller';
import { IAuthController } from '#/interfaces/controller/interfaces/auth';

export function bindControllers(container: Container) {
    container.bind<IAuthController>(TYPES.AuthController).to(AuthController).inTransientScope();
}

import { Container } from 'inversify';

import { Auth } from '#/application/use-cases/auth/auth';
import { IAuthUseCase } from '#/application/use-cases/auth/auth.use-case';
import { TYPES } from '#/infrastructure/config/di/types';

export function bindUseCases(container: Container) {
    container.bind<IAuthUseCase>(TYPES.AuthUseCase).to(Auth).inTransientScope();
}

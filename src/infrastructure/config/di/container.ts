import { PrismaClient } from '@prisma/client';
import { Container } from 'inversify';

import { bindControllers } from '#/infrastructure/config/di/bindings/controllers';
import { bindRepositories } from '#/infrastructure/config/di/bindings/repositories';
import { bindServices } from '#/infrastructure/config/di/bindings/services';
import { bindUseCases } from '#/infrastructure/config/di/bindings/use-cases';
import { TYPES } from '#/infrastructure/config/di/types';

const container = new Container();

// PrismaClient
container
    .bind<PrismaClient>(TYPES.PrismaClient)
    .toDynamicValue((): PrismaClient => {
        return new PrismaClient();
    })
    .inSingletonScope();

bindControllers(container);
bindRepositories(container);
bindServices(container);
bindUseCases(container);

export { container };

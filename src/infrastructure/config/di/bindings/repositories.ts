import { Container } from 'inversify';

import { IClientRepository } from '#/domain/repositories/client.repository';
import { TYPES } from '#/infrastructure/config/di/types';
import { PrismaClientRepository } from '#/infrastructure/repositories/prisma/prisma-client.repository';

export function bindRepositories(container: Container) {
    container.bind<IClientRepository>(TYPES.ClientRepository).to(PrismaClientRepository).inSingletonScope();
}

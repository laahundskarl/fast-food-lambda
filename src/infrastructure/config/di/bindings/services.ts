import { Container } from 'inversify';

import { ITokenGeneratorService } from '#/domain/services/token-generator.service';
import { TYPES } from '#/infrastructure/config/di/types';
import { JwtTokenGeneratorService } from '#/infrastructure/services/jwt-token-generator.service';

export function bindServices(container: Container) {
    container.bind<ITokenGeneratorService>(TYPES.TokenGeneratorService).to(JwtTokenGeneratorService);
}

import { inject, injectable } from 'inversify';

import { AuthDto } from '#/application/use-cases/auth/auth.dto';
import { AuthOutput, IAuthUseCase } from '#/application/use-cases/auth/auth.use-case';
import { UnauthorizedError } from '#/domain/errors';
import { IClientRepository } from '#/domain/repositories/client.repository';
import { ITokenGeneratorService } from '#/domain/services/token-generator.service';
import { TYPES } from '#/infrastructure/config/di/types';

@injectable()
export class Auth implements IAuthUseCase {
    constructor(
        @inject(TYPES.ClientRepository) private readonly clientRepository: IClientRepository,
        @inject(TYPES.TokenGeneratorService) private readonly tokenGeneratorService: ITokenGeneratorService,
    ) {}

    async execute(request: AuthDto): Promise<AuthOutput> {
        const client = await this.clientRepository.findByCpf(request.cpf);
        if (!client) {
            throw new UnauthorizedError('Unauthorized');
        }

        const { token, expiresIn } = this.tokenGeneratorService.sign(client);

        return { token, expiresIn };
    }
}

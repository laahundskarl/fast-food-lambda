import { inject, injectable } from 'inversify';

import { AuthDto } from '#/application/use-cases/auth/auth.dto';
import { IAuthUseCase } from '#/application/use-cases/auth/auth.use-case';
import { TYPES } from '#/infrastructure/config/di/types';
import { IAuthController } from '#/interfaces/controller/interfaces/auth';
import { AuthResponseDTO } from '#/interfaces/presenter/auth/auth-response.dto';
import { AuthPresenter } from '#/interfaces/presenter/auth/auth.presenter';

@injectable()
export class AuthController implements IAuthController {
    constructor(@inject(TYPES.AuthUseCase) private readonly authUseCase: IAuthUseCase) {}

    async get(request: AuthDto): Promise<AuthResponseDTO> {
        const response = await this.authUseCase.execute(request);
        return AuthPresenter.toDTO(response);
    }
}

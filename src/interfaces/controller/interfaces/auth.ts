import { AuthDto } from '#/application/use-cases/auth/auth.dto';
import { AuthResponseDTO } from '#/interfaces/presenter/auth/auth-response.dto';

export interface IAuthController {
    getToken(request: AuthDto): Promise<AuthResponseDTO>;
}

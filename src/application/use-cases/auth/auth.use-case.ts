import { AuthDto } from '#/application/use-cases/auth/auth.dto';

export interface AuthOutput {
    token: string;
    expiresIn: string;
}

export interface IAuthUseCase {
    execute(request: AuthDto): Promise<AuthOutput>;
}

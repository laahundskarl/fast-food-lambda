import { Client } from '#/domain/entities/client.entity';

export interface TokenResult {
    token: string;
    expiresIn: string;
}

export interface ITokenGeneratorService {
    sign(payload: Client): TokenResult;
}

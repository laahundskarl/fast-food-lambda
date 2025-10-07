import jwt from 'jsonwebtoken';

import { ITokenGeneratorService, TokenResult } from '#/domain/services/token-generator.service';
import { env } from '#/infrastructure/config/env';

export class JwtTokenGeneratorService implements ITokenGeneratorService {
    private readonly secret = env.JWT_SECRET ?? 'default_secret';
    private readonly expiresIn = '1h';

    sign(payload: object): TokenResult {
        const token = jwt.sign(payload, this.secret, { expiresIn: this.expiresIn });

        const expiresIn = new Date(Date.now() + this.parseExpiresIn(this.expiresIn)).toISOString();

        return { token, expiresIn };
    }

    private parseExpiresIn(expiresIn: string): number {
        const match = expiresIn.match(/^(\d+)([smhd])$/);
        if (!match) return 3600 * 1000;

        const value = parseInt(match[1], 10);
        const unit = match[2];

        switch (unit) {
            case 's':
                return value * 1000;
            case 'm':
                return value * 60 * 1000;
            case 'h':
                return value * 60 * 60 * 1000;
            case 'd':
                return value * 24 * 60 * 60 * 1000;
            default:
                return 3600 * 1000;
        }
    }
}

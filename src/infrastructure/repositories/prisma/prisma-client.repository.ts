import { PrismaClient } from '@prisma/client';
import { inject, injectable } from 'inversify';

import { Client } from '#/domain/entities/client.entity';
import { IClientRepository } from '#/domain/repositories/client.repository';
import { TYPES } from '#/infrastructure/config/di/types';
import { PrismaClientMapper } from '#/infrastructure/repositories/prisma/mappers/prisma-client.mapper';

@injectable()
export class PrismaClientRepository implements IClientRepository {
    constructor(@inject(TYPES.PrismaClient) private readonly prisma: PrismaClient) {}

    async findByCpf(cpf: string): Promise<Client | null> {
        const data = await this.prisma.client.findFirst({
            where: { cpf },
        });
        if (!data) return null;
        return PrismaClientMapper.toDomain(data);
    }
}

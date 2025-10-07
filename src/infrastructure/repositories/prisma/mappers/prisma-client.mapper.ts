import { Prisma } from '@prisma/client';

import { Client } from '#/domain/entities/client.entity';

export class PrismaClientMapper {
    static toDomain(data: any): Client {
        return new Client(
            data.id,
            data.name,
            data.cpf,
            data.email,
        );
    }
}

import { Client } from '#/domain/entities/client.entity';

export interface IClientRepository {
    findByCpf(cpf: string): Promise<Client | null>;
}

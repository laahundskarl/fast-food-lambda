export const TYPES = {
    // Database
    PrismaClient: Symbol.for('PrismaClient'),

    // Repositories
    ClientRepository: Symbol.for('ClientRepository'),

    // Use Cases
    AuthUseCase: Symbol.for('AuthUseCase'),

    // Controllers
    AuthController: Symbol.for('AuthController'),

    // Services
    TokenGeneratorService: Symbol.for('TokenGeneratorService'),
} as const;

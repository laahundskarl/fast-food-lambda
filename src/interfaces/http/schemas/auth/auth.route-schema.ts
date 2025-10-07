import {
    authValidator,
    authResponseSchema,
    errorResponseValidationSchema,
    errorUnauthorizedSchema,
} from '#/interfaces/http/schemas/auth/auth.schema';

export const authSchema = {
    schema: {
        tags: ['Autenticação'],
        summary: 'Autentica cliente pelo CPF',
        body: authValidator,
        response: {
            200: authResponseSchema,
            401: errorUnauthorizedSchema,
            400: errorResponseValidationSchema,
        },
    },
};

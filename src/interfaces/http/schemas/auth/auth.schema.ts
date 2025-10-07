import { cpf } from 'cpf-cnpj-validator';
import z from 'zod';

export const authValidator = z.object({
    cpf: z
        .string({ required_error: 'CPF is required' })
        .refine(value => cpf.isValid(value), { message: 'Invalid CPF' }),
});

export const authResponseSchema = z.object({
    token: z.string().describe('Token do cliente'),
    expiresIn: z.number().describe('Data de expiração do token'),
});

const baseErrorSchema = z.object({
    error: z.string().describe('Tipo de erro HTTP'),
    message: z.string().describe('Mensagem geral do erro'),
});

const validationDetailsSchema = z.object({
    details: z
        .array(
            z.object({
                field: z.string().describe('Campo que apresentou erro'),
                message: z.string().describe('Mensagem de erro para o campo'),
            }),
        )
        .optional()
        .describe('Lista de detalhes dos erros de validação'),
});

const createErrorSchema = (errorType: string, withDetails = false) => {
    const schema = baseErrorSchema.extend({
        error: z.literal(errorType).describe('Tipo de erro HTTP'),
    });

    return withDetails ? schema.merge(validationDetailsSchema) : schema;
};

export const errorResponseValidationSchema = createErrorSchema('Bad Request', true);
export const errorUnauthorizedSchema = createErrorSchema('Unauthorized');

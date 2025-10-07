import { FastifyError, FastifyReply, FastifyRequest } from 'fastify';

const StatusCodes = {
    BAD_REQUEST: 400,
    UNAUTHORIZED: 401,
    INTERNAL_ERRO: 500,
};

export function errorHandler(error: FastifyError, request: FastifyRequest, reply: FastifyReply) {
    request.log.error(error);
    const statusCode = error.statusCode ?? 500;

    if (error.validation) {
        const details = error.validation.map(err => ({
            field: err.instancePath.replace('/', ''),
            message: err.message,
        }));

        return reply.status(StatusCodes.BAD_REQUEST).send({
            error: 'Bad Request',
            message: 'Validation failed',
            details,
        });
    }

    if (statusCode === StatusCodes.UNAUTHORIZED) {
        return reply.status(StatusCodes.UNAUTHORIZED).send({
            error: 'Unauthorized',
            message: error.message || 'Authentication required',
        });
    }

    return reply.status(statusCode).send({
        error: error.name || 'Internal Server Error',
        message: error.message || 'Unexpected error occurred',
    });
}

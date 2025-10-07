export class AppError extends Error {
    constructor(
        public message: string = 'Internal server error',
        public statusCode = 500,
        public code = 'InternalServerException',
    ) {
        super(message);
    }
}

export class UnauthorizedError extends AppError {
    constructor(message = 'UnauthorizedException') {
        super(message, 401, 'UnauthorizedException');
    }
}

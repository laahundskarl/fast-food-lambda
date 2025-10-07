import { AuthResponseDTO } from '#/interfaces/presenter/auth/auth-response.dto';

interface ValidateCustomerResponse {
    token: string;
    expiresIn: string;
}

export class AuthPresenter {
    static toDTO(data: ValidateCustomerResponse): AuthResponseDTO {
        return {
            token: data.token,
            expiresIn: data.expiresIn,
        };
    }
}

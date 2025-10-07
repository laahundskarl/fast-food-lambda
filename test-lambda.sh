#!/bin/bash

# FastFood Lambda - Test Script
# Este script testa a função Lambda localmente e na AWS

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para mostrar progresso
show_step() {
    echo -e "\n${BLUE}[$(date '+%H:%M:%S')] $1${NC}"
}

# Função para mostrar sucesso
show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Função para mostrar aviso
show_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Função para mostrar erro
show_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "🧪 FastFood Lambda - Test Suite"
echo "==============================="

# Verificar se curl está disponível
if ! command -v curl &> /dev/null; then
    show_error "curl não encontrado. Instale curl primeiro."
    exit 1
fi

# Função para testar endpoint
test_endpoint() {
    local url=$1
    local description=$2
    
    show_step "Testando $description..."
    
    # Teste com CPF válido
    echo "Testando com CPF válido (12345678901)..."
    response=$(curl -s -w "\n%{http_code}" -X POST "$url" \
        -H "Content-Type: application/json" \
        -d '{"cpf":"12345678901"}' || echo "000")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        show_success "Teste com CPF válido passou (HTTP $http_code)"
        echo "Response: $body" | head -c 200
        echo "..."
    else
        show_warning "Teste com CPF válido falhou (HTTP $http_code)"
        echo "Response: $body"
    fi
    
    echo ""
    
    # Teste com CPF inválido
    echo "Testando com CPF inválido (123)..."
    response=$(curl -s -w "\n%{http_code}" -X POST "$url" \
        -H "Content-Type: application/json" \
        -d '{"cpf":"123"}' || echo "000")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "400" ] || [ "$http_code" = "422" ]; then
        show_success "Teste com CPF inválido passou (HTTP $http_code)"
    else
        show_warning "Teste com CPF inválido teve resultado inesperado (HTTP $http_code)"
    fi
    
    echo "Response: $body" | head -c 200
    echo ""
}

# Função para testar Lambda na AWS
test_aws_lambda() {
    show_step "Testando Lambda na AWS..."
    
    # Verificar se AWS CLI está disponível
    if ! command -v aws &> /dev/null; then
        show_warning "AWS CLI não encontrado. Pulando testes AWS."
        return
    fi
    
    # Verificar se a função existe
    if ! aws lambda get-function --function-name fast-food-auth &> /dev/null; then
        show_warning "Função Lambda 'fast-food-auth' não encontrada na AWS."
        return
    fi
    
    # Testar invocação direta da Lambda
    echo "Testando invocação direta da Lambda..."
    
    # Criar payload de teste
    payload='{"httpMethod":"POST","path":"/auth","headers":{"Content-Type":"application/json"},"body":"{\"cpf\":\"12345678901\"}"}'
    
    # Invocar função
    aws lambda invoke \
        --function-name fast-food-auth \
        --payload "$payload" \
        response.json &> /dev/null
    
    if [ $? -eq 0 ]; then
        show_success "Invocação direta da Lambda funcionou"
        echo "Response:"
        cat response.json | head -c 300
        echo "..."
        rm -f response.json
    else
        show_error "Falha na invocação direta da Lambda"
    fi
}

# Função para obter URL do API Gateway
get_api_gateway_url() {
    if command -v terraform &> /dev/null && [ -f "terraform/terraform.tfstate" ]; then
        cd terraform
        api_url=$(terraform output -raw api_gateway_url 2>/dev/null || echo "")
        cd ..
        echo "$api_url"
    else
        echo ""
    fi
}

# Menu principal
echo "Selecione o tipo de teste:"
echo "1) Teste local (http://localhost:3000/auth)"
echo "2) Teste AWS API Gateway"
echo "3) Teste AWS Lambda diretamente"
echo "4) Todos os testes"
echo "5) Teste customizado (inserir URL)"
echo ""
read -p "Escolha uma opção (1-5): " choice

case $choice in
    1)
        test_endpoint "http://localhost:3000/auth" "endpoint local"
        ;;
    2)
        api_url=$(get_api_gateway_url)
        if [ -n "$api_url" ]; then
            test_endpoint "$api_url" "API Gateway AWS"
        else
            show_error "URL do API Gateway não encontrada. Execute terraform apply primeiro."
        fi
        ;;
    3)
        test_aws_lambda
        ;;
    4)
        # Teste local
        test_endpoint "http://localhost:3000/auth" "endpoint local"
        
        # Teste API Gateway
        api_url=$(get_api_gateway_url)
        if [ -n "$api_url" ]; then
            test_endpoint "$api_url" "API Gateway AWS"
        else
            show_warning "API Gateway não configurado. Pulando teste."
        fi
        
        # Teste Lambda direto
        test_aws_lambda
        ;;
    5)
        read -p "Digite a URL completa do endpoint: " custom_url
        test_endpoint "$custom_url" "endpoint customizado"
        ;;
    *)
        show_error "Opção inválida"
        exit 1
        ;;
esac

echo ""
echo "🎉 Testes concluídos!"
echo ""
echo "📋 Próximos passos:"
echo "   - Para desenvolvimento local: npm run dev"
echo "   - Para deploy na AWS: npm run deploy:aws"
echo "   - Para cleanup: use as GitHub Actions ou terraform destroy"
#!/bin/bash

# FastFood Lambda - Build and Package Script
# Este script automatiza o processo de build e criação do pacote de deployment

set -e

echo "🚀 FastFood Lambda - Build and Package"
echo "====================================="

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

# Verificar se Node.js está instalado
if ! command -v node &> /dev/null; then
    show_error "Node.js não encontrado. Instale Node.js 22+ primeiro."
    exit 1
fi

# Verificar se npm está instalado
if ! command -v npm &> /dev/null; then
    show_error "npm não encontrado. Instale npm primeiro."
    exit 1
fi

# Verificar versão do Node.js
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    show_error "Node.js versão 18+ é requerida. Versão atual: $(node --version)"
    exit 1
fi

show_step "Verificando ambiente..."
show_success "Node.js $(node --version) encontrado"
show_success "npm $(npm --version) encontrado"

# Limpar diretórios anteriores
show_step "Limpeza de arquivos anteriores..."
rm -rf dist/
rm -f lambda-deployment.zip
show_success "Limpeza concluída"

# Instalar dependências
show_step "Instalando dependências..."
npm ci
show_success "Dependências instaladas"

# Gerar Prisma Client
show_step "Gerando Prisma Client..."
npm run prisma:generate
show_success "Prisma Client gerado"

# Build da aplicação
show_step "Executando build da aplicação..."
npm run build
show_success "Build concluído"

# Verificar se o build foi bem-sucedido
if [ ! -d "dist" ]; then
    show_error "Diretório dist não foi criado. Verifique o build."
    exit 1
fi

# Criar pacote de deployment
show_step "Criando pacote de deployment..."

# Entrar no diretório dist
cd dist

# Criar ZIP inicial com código compilado
zip -r ../lambda-deployment.zip . -x "*.map" "*.test.*" "*.spec.*"
show_success "Código compilado empacotado"

# Voltar para o diretório raiz
cd ..

# Adicionar node_modules essenciais
show_step "Adicionando dependências de produção..."

# Criar diretório temporário para node_modules limpo
mkdir -p temp_build
cd temp_build

# Copiar package.json e instalar apenas dependências de produção
cp ../package.json .
cp ../package-lock.json .
npm ci --only=production --no-audit --no-fund

# Adicionar node_modules de produção ao ZIP
zip -ru ../lambda-deployment.zip node_modules/ -x "node_modules/*/test/*" "node_modules/*/tests/*" "node_modules/*/.nyc_output/*" "node_modules/*/coverage/*" "node_modules/*/docs/*"

# Voltar e limpar
cd ..
rm -rf temp_build

show_success "Dependências de produção adicionadas"

# Verificar tamanho do pacote
PACKAGE_SIZE=$(ls -lh lambda-deployment.zip | awk '{print $5}')
show_step "Verificando pacote final..."
show_success "Pacote criado: lambda-deployment.zip (${PACKAGE_SIZE})"

# Verificar conteúdo do pacote
echo ""
echo "📦 Conteúdo do pacote:"
unzip -l lambda-deployment.zip | head -20
echo "..."
echo "$(unzip -l lambda-deployment.zip | wc -l) arquivos total"

# Validação final
show_step "Validação final..."

# Verificar se o arquivo index.js existe no pacote
if unzip -l lambda-deployment.zip | grep -q "index.js"; then
    show_success "index.js encontrado no pacote"
else
    show_error "index.js não encontrado no pacote!"
    exit 1
fi

# Verificar se as dependências essenciais estão presentes
REQUIRED_DEPS=("@fastify/aws-lambda" "@prisma/client" "fastify" "jsonwebtoken")
for dep in "${REQUIRED_DEPS[@]}"; do
    if unzip -l lambda-deployment.zip | grep -q "node_modules/$dep/"; then
        show_success "$dep encontrado"
    else
        show_warning "$dep não encontrado - pode causar problemas"
    fi
done

echo ""
echo "🎉 Build and Package concluído com sucesso!"
echo ""
echo "📋 Próximos passos:"
echo "   1. Execute 'cd terraform && terraform init' para inicializar Terraform"
echo "   2. Execute 'terraform plan -var=\"lambda_filename=../lambda-deployment.zip\"' para planejar deploy"  
echo "   3. Execute 'terraform apply -var=\"lambda_filename=../lambda-deployment.zip\"' para fazer deploy"
echo ""
echo "   Ou use as GitHub Actions para deploy automatizado:"
echo "   - Workflow: 'Infrastructure - Deploy Lambda'"
echo ""
echo "💰 Dica: Use 'Cleanup - Destroy Lambda' quando não precisar mais da infraestrutura"
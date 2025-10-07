# FastFood Lambda Authentication

Este repositório contém a função Lambda de autenticação para o projeto FastFood, implementando autenticação JWT via serverless.

## 🏗️ **Arquitetura Desacoplada**

Faz parte da infraestrutura desacoplada do projeto FastFood:

- **[fast-food](https://github.com/laahundskarl/fast-food)** - Aplicação principal FastFood
- **[fast-food-db-infra](https://github.com/laahundskarl/fast-food-db-infra)** - Infraestrutura Database (RDS MySQL)
- **[fast-food-k8s-infra](https://github.com/laahundskarl/fast-food-k8s-infra)** - Infraestrutura Kubernetes (EKS + ECR)
- **[fast-food-lambda](https://github.com/laahundskarl/fast-food-lambda)** (este repositório) - Função Lambda de Autenticação

## 🎯 **Funcionalidade**

A Lambda de autenticação oferece:

- **Autenticação por CPF**: Validação de CPF e geração de JWT
- **Integração com RDS**: Conecta-se ao mesmo banco MySQL dos outros serviços
- **API Gateway**: Endpoint REST para autenticação via HTTPS
- **Hexagonal Architecture**: Mesma arquitetura dos outros repositórios
- **Serverless**: Pay-per-request, escalabilidade automática

### Endpoint de Autenticação

```http
POST /auth
Content-Type: application/json

{
  "cpf": "12345678901"
}
```

**Resposta:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "client": {
    "id": "uuid",
    "name": "Nome do Cliente",
    "cpf": "12345678901",
    "email": "cliente@email.com"
  }
}
```

## 📁 Estrutura do Projeto

```
src/
├── application/            → Casos de uso
│   └── use-cases/
│       └── auth/           → Autenticação JWT
├── domain/                 → Entidades e regras de negócio
│   ├── entities/           → Client entity
│   ├── repositories/       → Interfaces de repositório
│   └── services/           → Serviços de domínio (JWT)
├── infrastructure/         → Implementações técnicas
│   ├── config/             → Configuração e DI
│   ├── database/           → Prisma schema
│   ├── repositories/       → Implementação Prisma
│   ├── server/             → Fastify + AWS Lambda
│   └── services/           → JWT implementation
└── interfaces/             → Controllers e HTTP
    ├── controller/         → Auth controller
    ├── http/               → Routes, schemas, middlewares
    └── presenter/          → Response formatters

terraform/                  → Infraestrutura as Code
├── main.tf                → Lambda, API Gateway, IAM
├── variables.tf           → Variáveis de configuração
├── outputs.tf             → Outputs de integração
└── providers.tf           → Providers AWS

.github/workflows/          → CI/CD pipelines
├── ci-build-test.yml      → Build, lint, testes
├── infrastructure-deploy-lambda.yml → Deploy da Lambda
└── cleanup-destroy-lambda.yml → Cleanup dos recursos
```

## ⚙️ Como Rodar Localmente

### Pré-requisitos:
- Node.js 22+
- Docker (opcional, para banco local)

### Passos:
1. Clone o repositório:
   ```bash
   git clone https://github.com/laahundskarl/fast-food-lambda.git
   cd fast-food-lambda
   ```

2. Configure as variáveis de ambiente:
   ```bash
   cp .env.example .env
   # Edite .env com suas configurações
   ```

3. Instale as dependências:
   ```bash
   npm install
   ```

4. Gere o Prisma Client:
   ```bash
   npm run prisma:generate
   ```

5. Execute em modo desenvolvimento:
   ```bash
   npm run dev
   ```

6. Teste o endpoint:
   ```bash
   curl -X POST http://localhost:3000/auth \
     -H "Content-Type: application/json" \
     -d '{"cpf":"12345678901"}'
   ```

## 🚀 Deploy Automatizado na AWS

### 📋 **Deploy via GitHub Actions (Recomendado)**

O sistema utiliza **pipeline CI/CD automatizado**:

1. **Push para `main`** → Executa CI (build, lint, testes)
2. **Workflow manual** → Deploy da infraestrutura Lambda via Terraform
3. **Auto-integração** → Conecta-se automaticamente ao RDS existente

**✅ Vantagens:**
- Deploy serverless automatizado
- Integração automática com RDS do projeto
- API Gateway configurado com CORS
- Monitoramento via CloudWatch
- Cleanup sob demanda para gestão de custos

### 🛠️ **Deploy Manual (Avançado)**

**Pré-requisitos:**
- AWS CLI configurado
- Terraform >= 1.0 instalado
- Conta AWS com permissões Lambda, API Gateway, IAM

### Passo 1: Configurar Credenciais AWS

```bash
# AWS Academy (se necessário)
aws configure
# Inserir: Access Key, Secret Key, Region (us-east-1)
```

### Passo 2: Build da Lambda

```bash
# Build da aplicação
npm run build

# Criar pacote de deployment
cd dist
zip -r ../lambda-deployment.zip .
cd ..
zip -r lambda-deployment.zip node_modules/
```

### Passo 3: Deploy da Infraestrutura

```bash
cd terraform

# Inicializar Terraform
terraform init

# Planejar deployment
terraform plan -var="lambda_filename=../lambda-deployment.zip"

# Aplicar mudanças
terraform apply -var="lambda_filename=../lambda-deployment.zip"
```

### Passo 4: Verificar Deploy

```bash
# Obter URL do API Gateway
terraform output api_gateway_url

# Testar função Lambda
aws lambda invoke \
  --function-name fast-food-auth \
  --payload '{"httpMethod":"POST","path":"/auth","body":"{\"cpf\":\"12345678901\"}"}' \
  response.json

cat response.json
```

## 🔗 **Integração com Outros Serviços**

### Integração com FastFood App

A aplicação principal pode usar a Lambda para autenticação:

```typescript
// No fast-food app
const authenticateUser = async (cpf: string) => {
  const response = await fetch(`${LAMBDA_AUTH_URL}/auth`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ cpf })
  });
  
  const { token, client } = await response.json();
  return { token, client };
};
```

### Integração com Kubernetes

A Lambda pode ser integrada via ingress ou service mesh:

```yaml
# No K8s cluster
apiVersion: v1
kind: ConfigMap
metadata:
  name: auth-config
data:
  AUTH_LAMBDA_URL: "https://api-gateway-url.amazonaws.com/prod/auth"
```

## 📊 **Workflows CI/CD Implementadas**

Seguindo convenções padronizadas do projeto FastFood:

### 🔍 **CI - Build and Test**
- Build da aplicação TypeScript
- Linting com ESLint
- Auditoria de segurança npm
- Validação de configurações
- Geração de artefatos de build

### 🚀 **Infrastructure - Deploy Lambda**
- Build e empacotamento da Lambda
- Deploy via Terraform (Lambda, API Gateway, IAM)
- Configuração automática de variáveis de ambiente
- Integração automática com RDS existente
- Validação pós-deploy

### 🗑️ **Cleanup - Destroy Lambda**
- **lambda-only**: Remove apenas a função Lambda
- **full-infrastructure**: Remove toda infraestrutura (Lambda, API Gateway, IAM, logs)
- Análise de custos pós-cleanup
- Confirmação obrigatória via "DESTROY"

## 💰 **Gestão de Custos**

⚠️ **IMPORTANTE**: Para evitar custos desnecessários:

### **Cleanup via GitHub Actions (Recomendado)**

**🔄 Cleanup Apenas Lambda** (mantém API Gateway):
```
1. Vá para Actions no repositório fast-food-lambda
2. Execute "Cleanup - Destroy Lambda"
3. Selecione "lambda-only" e digite "DESTROY"
```

**🚨 Cleanup Completo** (remove toda infraestrutura):
```
1. Vá para Actions no repositório fast-food-lambda
2. Execute "Cleanup - Destroy Lambda"
3. Selecione "full-infrastructure" e digite "DESTROY"
```

**💡 Economia esperada:** ~$0-16/mês (pay-per-request)

### **Cleanup Manual** (caso necessário)
```bash
cd terraform
terraform destroy -var="lambda_filename=../lambda-deployment.zip"
```

## 🏛️ **Arquitetura AWS**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   API Gateway   │───▶│  Lambda Function │───▶│   RDS MySQL     │
│  (HTTPS/REST)   │    │  (Node.js 18.x)  │    │  (Shared DB)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CloudWatch    │    │   IAM Roles      │    │   VPC/Subnets   │
│   (Logs/Metrics)│    │  (Permissions)   │    │  (Network)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Recursos AWS Utilizados

- **Lambda Function**: Serverless compute para autenticação
- **API Gateway**: Endpoint HTTPS público
- **IAM Roles**: Permissões granulares para Lambda
- **CloudWatch**: Logs e monitoramento
- **RDS MySQL**: Banco compartilhado (criado pelo fast-food-db-infra)

## 🔒 **Segurança**

- **JWT Tokens**: Assinados com chave secreta configurável
- **CPF Validation**: Validação usando `cpf-cnpj-validator`
- **CORS**: Configurado no API Gateway
- **IAM**: Permissões mínimas necessárias
- **VPC**: Integração segura com RDS (se necessário)
- **Environment Variables**: Secrets via AWS Lambda environment

## 🧪 **Testes e Validação**

```bash
# Linting
npm run lint

# Build
npm run build

# Testes locais
curl -X POST http://localhost:3000/auth \
  -H "Content-Type: application/json" \
  -d '{"cpf":"12345678901"}'

# Teste na AWS (após deploy)
curl -X POST https://your-api-gateway-url/prod/auth \
  -H "Content-Type: application/json" \
  -d '{"cpf":"12345678901"}'
```

## 📋 **Variáveis de Ambiente**

```bash
# .env
DATABASE_URL="mysql://admin:password@host:3306/fastfood?allowPublicKeyRetrieval=true"
JWT_SECRET="your-secret-key"
NODE_ENV="production"
```

## 🤝 **Contribuição**

Este repositório segue os mesmos padrões do projeto FastFood:

1. **Hexagonal Architecture** - Separação clara de camadas
2. **TypeScript** - Tipagem estática
3. **InversifyJS** - Injeção de dependência
4. **Prisma** - ORM para banco de dados
5. **Zod** - Validação de schemas
6. **ESLint/Prettier** - Padronização de código
7. **GitHub Actions** - CI/CD automatizado

## 📝 **Licença**

Este projeto é parte do Tech Challenge do curso SOAT FIAP - Grupo 277.

---

**📝 Nota:** Este repositório é parte de uma arquitetura desacoplada. Para deploy completo do sistema FastFood, consulte os outros repositórios de infraestrutura.

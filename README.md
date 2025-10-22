# Modernização da Esteira de Deploy — Desafio DevOps

Este repositório contém a prova de conceito (PoC) para a primeira fase de
modernização da infraestrutura e do ciclo de vida de uma aplicação web legada.
O objetivo é demonstrar práticas de containerização, CI (Integração Contínua),
IaC (Infraestrutura como Código) e uma proposta de CD (Entrega Contínua) e
observabilidade.

Importante: o desafio original especificava uma aplicação em PHP, mas o
repositório não me foi fornecido, nesta entrega usei uma aplicação de exemplo em Node.js
localizada na raiz (`server.js`). Todas as decisões descritas aqui continuam
válidas para uma aplicação web tradicional.

## Sumário
- Objetivo
- O que está no repositório
- Assunções e adaptações
- Containerização (Dockerfile)
- Pipeline de CI (GitHub Actions)
- Infraestrutura como Código (Terraform)
- Como estender CI -> CD (deploy automático)
- Estratégia de Observabilidade
- Como testar localmente / rodar
- Próximos passos sugeridos

## Objetivo

Criar uma fundação segura e reprodutível para o ciclo de vida da aplicação,
substituindo o processo manual de deploy por um fluxo automatizado que inclua
build de imagem, análise de vulnerabilidades, publicação em registro e
integração com infraestrutura provisionada via Terraform (AWS).

## O que está no repositório

- `Dockerfile` — Dockerfile da aplicação (Node.js no repo fornecido).
- `.github/workflows/workflow.yml` — pipeline de CI que roda em pushes para
  `main`: build de imagem, scan com Trivy e push para Docker Hub.
- `k8s/` — manifests Kubernetes: `deployment.yaml`, `service.yaml`, `ingress.yaml` e
  `nginx-ingress-controller.yaml` (exemplos para deploy no EKS).
- `terraform/` — módulos Terraform para AWS: `vpc`, `eks`, `rds` (estrutura
  demonstrativa).
- `server.js`, `package.json` — aplicação de exemplo (Node.js) usada para a PoC.

## Containerização

- Multi-stage build: separa a etapa de build (instalação de dependências e
  geração de artefatos) da imagem runtime final, reduzindo o tamanho e a
  superfície de ataque da imagem final.
- Execução com usuário não-root: o container roda com um usuário `appuser`,
  melhorando a postura de segurança.
- Labels: adicionadas labels OCP/OCI (`org.opencontainers.image.source`,
  `maintainer`, `license`) para rastreabilidade da imagem.

Essas mudanças tornam a imagem mais adequada para execução em Kubernetes
produção (EKS) e facilitam criação de readiness/liveness probes a partir do
manifest `deployment.yaml`.

## Pipeline de CI (GitHub Actions)

Arquivo: `.github/workflows/workflow.yml`

O workflow já implementado realiza as seguintes etapas em cada push na
branch `main`:

1. Checkout do código (`actions/checkout@v3`).
2. (Opcional) Instala `kubectl` (prévia para deploy em cluster).
3. Configura credenciais do Docker Hub (`docker/login-action@v2`).
4. Define tag de imagem a partir do commit SHA (7 caracteres).
5. Constrói a imagem Docker localmente: `docker build -t <user>/repo:tag .`.
6. Analisa vulnerabilidades da imagem com Trivy (`aquasecurity/trivy-action`).
7. Realiza `docker push` para o Docker Hub **somente se** as etapas anteriores
  (incluindo o scan) forem bem-sucedidas — isso evita publicar imagens com
  vulnerabilidades de severidade alta/critica.

Como visualizar o relatório do Trivy (após a execução do workflow):

1. Vá na página do run do workflow no GitHub Actions.
2. No resumo do job, procure pela seção "Artifacts" e baixe o artifact
  `trivy-report-<image_tag>` (ele contém `trivy-report.json`).
3. Para visualizar de forma legível, você pode usar ferramentas como
  `jq` ou converter o JSON para uma tabela usando utilitários web.
.

## Infraestrutura como Código (Terraform)

O diretório `terraform/` contém módulos para `vpc`, `eks` e `rds`. A opção
escolhida aqui foi provisionar um cluster Kubernetes (EKS) por dois motivos:

1. O repositório já inclui manifests Kubernetes (`k8s/`).
2. EKS é a escolha natural quando se quer portar facilmente workloads
   conteinerizadas entre ambientes, usar ingress controllers, service meshes,
   e tirar proveito de ecossistema (Horizontal Pod Autoscaler, Cert-Manager,
   etc).

Resumo do que os módulos devem prover:
- `vpc/` — VPC, subnets públicas/privadas, roteamento, internet gateway e
  NAT (quando necessário).
- `eks/` — Cluster EKS, node groups, roles/iam.
- `rds/` — Banco de dados relacional gerenciado (opcional) para a aplicação.

Como aplicar (alinhamento/checagem antes de rodar):

1. Configure `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY` no ambiente ou
   como secrets do GitHub Actions.
2. Dentro de `terraform/` ajustar `vars.tf` com regiões, nomes e CIDRs.
3. Executar:

```bash
cd terraform
terraform init
terraform plan -out plan.tfplan
terraform apply "plan.tfplan"
```

Nota de segurança: não comitar credenciais no repositório. Use variáveis
de ambiente e/ou o `aws-vault`/`sso` para gerenciar credenciais locais.

## Como estender CI -> CD (Deploy automático)

Fluxo proposto para CD (alto nível):

1. CI constrói e publica a imagem no Docker Hub com tag baseada em SHA e em
   um `latest` semântica quando apropriado.
2. Workflow de CD (pode ser outro job no mesmo workflow ou um workflow
   separado acionado por push na imagem/por tag) autentica na AWS e atualiza
   o contexto do `kubectl` para o cluster EKS provisionado.
3. Aplicar manifests Kubernetes (`kubectl apply -f k8s/`) e atualizar a
   imagem do Deployment (ex: `kubectl set image deployment/<app> <container>=<image>:<tag>`).
4. Aguardar rollout (`kubectl rollout status deployment/<app>`). Se falhar,
   reverter automaticamente (opcional) ou notificar time de SRE.

## Estratégia de Observabilidade (descrita)

Stack sugerida:

- Logs: Loki mandando os logs para grafana.
- Metrics: Prometheus + Grafana.

Justificativa: essa combinação é padrão da indústria, com ótima integração
com Kubernetes e amplo suporte da comunidade.

Três métricas principais que eu implantaria para monitorar a aplicação:

1. Uso de CPU
2. Uso de memória
3. Média de tempo de resposta por request

## Como testar localmente / rodar

- Pré-requisitos: Docker instalado.
- A imagem está disponível em: https://hub.docker.com/repository/docker/abraaorochapb/teste-abraao/general

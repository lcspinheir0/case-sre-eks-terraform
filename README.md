# case-sre-eks-terraform
## 🏗️ Arquitetura & Decisões Técnicas

- **100% IaC com Terraform, usando módulos oficiais e boas práticas.**
- **Segurança:** IRSA (OIDC) ativado por padrão (pronto pra uso seguro de service accounts Kubernetes + IAM Roles).
- **Separação de ambientes:** código preparado para múltiplos workspaces (`dev`, `hmg`, `prd`), facilitando pipelines multi-stage.
- **Observabilidade:** arquitetura pronta para sidecars (OpenTelemetry, Datadog) e SLI/SLOs.
- **Rollback fácil:** basta reverter código, rodar `terraform apply` e tudo volta ao último estado validado.

<img src="https://github.com/user-attachments/assets/51aeec08-876a-439b-b3ea-ffbd4d491036" width="600" />

- **Veja detalhes dos motivos de cada escolha e trade-offs** em [APRENDIZADO.md](./APRENDIZADO.md).

## 🔐 Segurança Avançada com IRSA (OIDC)

- O cluster EKS já sai pronto para usar [IAM Roles for Service Accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).
- Permite que pods acessem recursos AWS **sem expor chaves**, cada workload com mínimo privilégio.
- Veja exemplos em `/infra/argocd` e scripts de aplicação do OIDC.

---

## 🛡️ Propósito

Provisiona toda base para Kubernetes EKS em ambiente regulado (bancário/enterprise) com foco em:
- Segurança (least privilege, sem IP público em subnet privada)
- Segregação de ambientes (Dev, HMG, PRD)
- CI/CD, GitOps e governança de código
- Alta disponibilidade e fácil rollback

---

## 🚀 Como usar

```bash
git clone https://github.com/lcspinheir0/case-sre-eks-terraform.git
cd case-sre-eks-terraform

# Configure variáveis se necessário (terraform.tfvars)
# Exemplo do conteudo do terraform.tfvars:
# public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
# azs             = ["us-east-1a", "us-east-1b"]
# private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

terraform init
terraform apply -var-file=terraform.tfvars

# Para destruir (apague recursos e evite custos!)
terraform destroy -var-file=terraform.tfvars
```

---

## 📦 Recursos provisionados

- VPC dedicada, subnets públicas/privadas, IGW, NAT GW e route tables
- Roles IAM para EKS e Node Group (menor privilégio)
- Cluster EKS em subnets privadas
- Node Group gerenciado (EC2) em subnets privadas
- ECR privado para imagens Docker
- Outputs claros para integração CI/CD
- GitOps com ArgoCD

---
## 🚦 GitOps com ArgoCD

- **ArgoCD instalado** no cluster via Helm, script versionado em `/infra/argocd`.
- **Repositório GitOps dedicado:** [https://github.com/SEU-USUARIO/case-sre-eks-gitops](https://github.com/SEU-USUARIO/case-sre-eks-gitops)
- Deploys 100% automatizados: qualquer alteração no repositório GitOps é sincronizada automaticamente no cluster via ArgoCD.
- Application do ArgoCD versionado (`argocd-application.yaml`) aponta para o repositório e path dos manifests/apps.
- **Acesso ao ArgoCD:** via port-forward (documentado no APRENDIZADO.md).


## 🔄 Fluxo de Branch e Versionamento

- **main:** apenas produção, merge via PR aprovado e CI obrigatório
- **dev:** homologação e integração
- **hmg:** ambiente intermediário (opcional)
- **feat/**, **fix/**, **hotfix/**: para desenvolvimento, cada mudança em branch separada
- **Merge apenas via Pull Request, revisão e CI**
- **Proteção de branch**: push direto, force push e delete proibidos

---

## 🔔 Proteção de Branch & CI

- PR obrigatório para `main` e `dev`
- Aprovação mínima de 1 revisor
- Status checks: `terraform fmt`, `terraform validate` e `tflint` obrigatórios em todo PR
- [Configuração recomendada de branch protection (docs)](https://docs.github.com/pt/repositories/configuring-branches-and-merges-in-your-repository/managing-branches-in-your-repository/about-protected-branches)

---

## 📤 Outputs principais

| Output                 | Descrição                             |
|------------------------|---------------------------------------|
| vpc_id                 | ID da VPC                             |
| private_subnet_ids     | IDs das subnets privadas              |
| eks_cluster_name       | Nome do cluster EKS                   |
| eks_cluster_endpoint   | Endpoint Kubernetes                   |
| ecr_repository_url     | URL do repositório Docker ECR         |
| oidc_provider_arn      | (Novo) ARN do OIDC provider           |


## 🚀 Provisionando com Módulos Oficiais

Este projeto utiliza módulos validados da comunidade:

- [`terraform-aws-modules/vpc`](https://github.com/terraform-aws-modules/terraform-aws-vpc)
- [`terraform-aws-modules/eks`](https://github.com/terraform-aws-modules/terraform-aws-eks)
- [`terraform-aws-modules/ecr`](https://github.com/terraform-aws-modules/terraform-aws-ecr)

---

## 🛠️ Troubleshooting rápido

- **AccessDenied:**  
  > Verifique as permissões IAM do usuário. Anexe temporariamente `IAMFullAccess`/`AdministratorAccess` ou apenas as policies mínimas necessárias.
- **terraform fmt check falha:**  
  > Rode localmente `terraform fmt`, commit e push novamente.

---

## 📚 Links úteis

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS Docs](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
- [EKS IAM Role](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html)
- [Proteção de Branch GitHub](https://docs.github.com/pt/repositories/configuring-branches-and-merges-in-your-repository/managing-branches-in-your-repository/about-protected-branches)

---

## 👨‍💻 Autor

Lucas  
Case Técnico SRE

---

> Para detalhes, exemplos linha a linha, explicações e troubleshooting aprofundado, veja o arquivo **APRENDIZADO.md** neste repositório.

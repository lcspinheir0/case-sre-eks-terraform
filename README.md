# case-sre-eks-terraform

Infraestrutura completa, segura e auditável para EKS (AWS) provisionada 100% com Terraform.

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
git clone https://github.com/SEU-USUARIO/case-sre-eks-terraform.git
cd case-sre-eks-terraform

# Configure variáveis se necessário (terraform.tfvars)
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

---

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
- Status check: `terraform fmt` obrigatório em todo PR
- [Configuração recomendada de branch protection (docs)](https://docs.github.com/pt/repositories/configuring-branches-and-merges-in-your-repository/managing-branches-in-your-repository/about-protected-branches)

---

## 📤 Outputs principais

| Output                 | Descrição                     |
|------------------------|-------------------------------|
| vpc_id                 | ID da VPC                     |
| private_subnet_ids     | IDs das subnets privadas      |
| eks_cluster_name       | Nome do cluster EKS           |
| eks_cluster_endpoint   | Endpoint Kubernetes           |
| eks_nodegroup_name     | Nome do node group            |
| ecr_repository_url     | URL do repositório Docker ECR |

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

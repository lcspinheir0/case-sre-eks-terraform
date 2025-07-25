# case-sre-eks-terraform
# Desafio 1 abaixo, desafio 2 no repositório:
 - https://github.com/lcspinheir0/case-sre-eks-tshoot

<img width="3165" height="3840" alt="Untitled diagram _ Mermaid Chart-2025-07-13-010803" src="https://github.com/user-attachments/assets/51aeec08-876a-439b-b3ea-ffbd4d491036" />

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
---

# Observabilidade com Prometheus e Grafana

Esta seção explica como implementar monitoramento e observabilidade no cluster EKS utilizando ferramentas open source: Prometheus e Grafana.

## Instalação via Helm

Recomenda-se versionar os manifests/Helm charts em um diretório dedicado, como `/infra/observability` ou `/infra/prometheus-grafana`.

### 1. Adicionando os repositórios Helm

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### 2. Instalando Prometheus Stack

```bash
kubectl create namespace monitoring
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

> O kube-prometheus-stack já instala Prometheus, Alertmanager e Grafana pré-configurados para Kubernetes.

### 3. Instalando Grafana (caso queira separado)

```bash
helm install grafana grafana/grafana -n monitoring
```

## Configuração e Outputs

- Após o deploy, exponha o serviço do Grafana conforme sua necessidade:
  - **NodePort**
  - **LoadBalancer**
  - **Port-forward** (mais prático para dev/teste):

```bash
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
```

- Acesse o dashboard: http://localhost:3000
- Usuário/senha padrão: `admin` / `prom-operator` (ou conforme definido no Helm Chart).

> Documente no README como acessar o dashboard e alterar credenciais no primeiro acesso.

## Organização dos Módulos

- **Terraform:** Um módulo `observability` pode ser adicionado para criar permissões IAM necessárias, security groups e outputs de endpoints.
- **Helm/Manifests:** Mantenha os arquivos Helm ou YAML em `/infra/observability` ou em um repositório GitOps dedicado, sincronizado via ArgoCD.

## Integração com GitOps

- Os manifests/Helm charts de observabilidade podem ser versionados no repositório GitOps.
- Exemplo de estrutura:
  ```
  apps/
    observability/
      prometheus-release.yaml
      grafana-release.yaml
  ```
- O ArgoCD irá cuidar do deploy e atualização automática desses componentes no cluster.

---

> Com esta abordagem, sua stack Kubernetes estará monitorada, com dashboards de fácil acesso e integração com alertas.


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
- Status checks: `terraform fmt`, `terraform validate` e `tflint` obrigatórios em todo PR
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

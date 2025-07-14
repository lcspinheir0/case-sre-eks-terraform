# case-sre-eks-terraform
## Segurança

- Usuário IAM criado apenas para este case, com permissões mínimas (VPC/EC2), acesso restrito via CLI.
- A chave será removida após o uso.
- Em produção, recomenda-se sempre adotar IAM Role/OIDC, evitando uso de chaves estáticas.
## Etapa 1 – VPC e Subnets Públicas

### O que foi provisionado

- **VPC dedicada** (`case-sre-eks-terraform-vpc`) com bloco CIDR `10.0.0.0/16`
- **2 Subnets públicas** em zonas de disponibilidade diferentes (`us-east-1a`, `us-east-1b`)
  - CIDRs: `10.0.1.0/24`, `10.0.2.0/24`
  - Auto-assign public IP ativado

**Racional:** 

- Subnets públicas são necessárias para permitir saída direta à Internet (via IGW/NAT futuramente) e para recursos públicos/LoadBalancers.
- Cada subnet está em uma AZ diferente para garantir alta disponibilidade.

**Como validar:** 

- Acesse AWS Console > VPC > Subnets
- Confira se as duas subnets foram criadas, estão associadas à VPC e com *Auto-assign public IPv4 address* ativado.

### Subnets Privadas

- 2 Subnets privadas criadas em diferentes zonas de disponibilidade (`us-east-1a`, `us-east-1b`)
  - CIDRs: `10.0.101.0/24`, `10.0.102.0/24`
  - *Auto-assign public IP* desativado para garantir que instâncias nessas subnets não sejam expostas à internet.
- Essas subnets serão usadas para recursos internos (ex: nodes do EKS, bancos, etc).

**Como validar:**  
AWS Console > VPC > Subnets — confira as subnets privadas, suas AZs e o campo “Auto-assign public IP” desabilitado.

### Internet Gateway (IGW)

- IGW criado e associado à VPC `case-sre-eks-terraform-vpc`.
- Responsável por permitir tráfego de internet para as subnets públicas.
**Como validar:**  
AWS Console > VPC > Internet Gateways — conferir se o IGW está criado e anexado à VPC.



### NAT Gateway

- 2 NAT Gateways criados, um em cada subnet pública (alta disponibilidade).
- 2 Endereços IP elásticos (EIP) associados aos NATs.
- Função: permitir que instâncias nas subnets privadas acessem a internet sem exposição direta de IP público.
**Como validar:** 
AWS Console > VPC > NAT Gateways — conferir 2 NATs em "Available".  
AWS Console > VPC > Elastic IPs — conferir 2 IPs alocados para os NATs.

### Route Tables e Associações

**Route Table Pública:**  
  - Tabela de rotas criada para as subnets públicas, enviando todo o tráfego externo (`0.0.0.0/0`) para o Internet Gateway (IGW).
  - Ambas subnets públicas associadas a esta tabela.
**Route Tables Privadas:**  
  - Duas tabelas privadas, uma para cada AZ/subnet privada.
  - Cada tabela direciona todo tráfego externo (`0.0.0.0/0`) para seu respectivo NAT Gateway.
  - Subnets privadas associadas às tabelas privadas.

**Validação:**  
AWS Console > VPC > Route Tables — confira as rotas, associações e gateways.

**Doc:**  
- [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)
- [aws_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)
- [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)


## CI - Terraform Format

- Workflow do GitHub Actions garante qualidade de código com três etapas:
  - `terraform fmt` verifica formatação
  - `terraform validate` valida a configuração
  - `tflint` aplica boas práticas
- Pull Requests só podem ser aprovados se todos os checks passarem.


### IAM Roles para EKS

- IAM Role específica para o EKS Cluster (`AmazonEKSClusterPolicy`, `AmazonEKSServicePolicy`)
- IAM Role para os Node Groups (EC2 workers), com políticas:
  - `AmazonEKSWorkerNodePolicy`
  - `AmazonEKS_CNI_Policy`
  - `AmazonEC2ContainerRegistryReadOnly`
- Ambas roles seguem o princípio do menor privilégio.

**Doc AWS:**  
- [EKS IAM Role](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html)
- [EKS Node IAM Role](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html)

### Cluster EKS

- Cluster Kubernetes (EKS) gerenciado pela AWS, provisionado em subnets privadas.
- VPC e subnets privadas já criadas via Terraform.
- Role IAM do cluster conectada com permissões mínimas.
- Versão do Kubernetes configurável (default: 1.29).
- Outputs expostos: nome do cluster, endpoint, ARN.

**Doc:**  
- [aws_eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster)

### Node Group EKS

- Node Group gerenciado pelo EKS em subnets privadas.
- IAM Role com permissões mínimas vinculada aos nodes.
- Autoscaling configurado: mínimo 1, desejado 1, máximo 1 instâncias(como é para teste)
- Tipo de instância: `t3.medium` (ajustável conforme budget/necessidade).

**Doc:**  
- [aws_eks_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group)

### Elastic Container Registry (ECR)

- Repositório ECR privado criado para armazenar imagens Docker.
- Mutabilidade de tags ativada (permite atualizar tags para testes rápidos).
- Criptografia em repouso (AES256).
- Output expõe a URL do repositório para integração com CI/CD.

**Doc:**  
- [aws_ecr_repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)



### Outputs para Integração

- IDs e ARNs dos principais recursos (VPC, subnets, roles)
- Endpoint, nome e ARN do cluster EKS
- Nome do node group e URL do repositório ECR
- Pronto para consumo por CI/CD, integração com ArgoCD, geração de kubeconfig e deploy de workloads.

Exemplo de obtenção automática:
```bash
terraform output eks_cluster_endpoint
terraform output ecr_repository_url
```













## Dúvidas e Troubleshooting

### Erro 1: `Unsupported argument` ao criar aws_eip

Ao rodar o `terraform apply`, pode aparecer:
│ Error: Unsupported argument
│ 
│   on main.tf line 54, in resource "aws_eip" "nat":
│   54:   vpc   = true
│ 
│ An argument named "vpc" is not expected here.
**Causa:**  
A opção `vpc = true` não é mais aceita nas versões recentes do provider AWS.

**Solução:**  
Remova a linha `vpc = true` do bloco do `aws_eip`.  
O bloco deve ficar assim:
```hcl
resource "aws_eip" "nat" {
  count = 2
}
```

[documentação oficial do recurso aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)


### Erro 2: `Erro: AccessDenied ao criar roles IAM` ao criar role
**Causa:**  
Esse erro ocorre quando o usuário utilizado no Terraform não possui permissões IAM suficientes.

**Solução:**  
No ambiente de case, adicione a policy `IAMFullAccess` ou uma customizada permitindo:
- `iam:CreateRole`
- `iam:AttachRolePolicy`
- `iam:PassRole`
Após criar as roles necessárias, pode remover a policy para seguir o princípio do menor privilégio.

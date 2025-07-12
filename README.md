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

### Racional

- Subnets públicas são necessárias para permitir saída direta à Internet (via IGW/NAT futuramente) e para recursos públicos/LoadBalancers.
- Cada subnet está em uma AZ diferente para garantir alta disponibilidade.

### Como validar

- Acesse AWS Console > VPC > Subnets
- Confira se as duas subnets foram criadas, estão associadas à VPC e com *Auto-assign public IPv4 address* ativado.

### Subnets Privadas

- 2 Subnets privadas criadas em diferentes zonas de disponibilidade (`us-east-1a`, `us-east-1b`)
  - CIDRs: `10.0.101.0/24`, `10.0.102.0/24`
  - *Auto-assign public IP* desativado para garantir que instâncias nessas subnets não sejam expostas à internet.
- Essas subnets serão usadas para recursos internos (ex: nodes do EKS, bancos, etc).

**Como validar:**  
AWS Console > VPC > Subnets — confira as subnets privadas, suas AZs e o campo “Auto-assign public IP” desabilitado.
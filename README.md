# case-sre-eks-terraform
## Segurança

- Usuário IAM criado apenas para este case, com permissões mínimas (VPC/EC2), acesso restrito via CLI.
- A chave será removida após o uso.
- Em produção, recomenda-se sempre adotar IAM Role/OIDC, evitando uso de chaves estáticas.


## Configuração

### Terraform 0.12.28

- **Linux**

Faça o download da versão `12.28`do Terraform:

```bash
wget https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
```

Caso não tenha, instale o `unzip`;
```bash
sudo apt-get install unzip
```

Descompacte o arquivo `.zip`:
```bash
unzip terraform_0.12.28_linux_amd64.zip
```

Mova o executável para a pasta de arquivos binários do sistema:
```bash
sudo mv terraform /usr/local/bin/
```

Confira a versão:
```bash
terraform --version 
```

### Credenciais

Instale o AWS CLI
```bash
sudo apt-get install awscli
```

Configure as suas credenciais da AWS:

```bash
aws configure
```

Caso prefira, também é possível configurar as credenciais criando o arquivo de credenciais de forma manual:

Crie o diretório `.aws` no seu home e crie o arquivo `credentials` dentro:
```bash
mkdir ~/.aws
touch ~/.aws/credentials
```

Abra o arquivo para edição:
```bash
vi ~/.aws/credentials
```

Insira as suas credenciais e salve as alterações:
```
[default]
aws_access_key_id=XXXXXXXXX
aws_secret_access_key=XXXXXXXXXX
region=us-east-1
```

### Terraform State

Para o controle do Terraform State foi utilizado o módulo [terraform-aws-tfstate-backend](https://github.com/cloudposse/terraform-aws-tfstate-backend), o qual cria o Bucket S3 encriptado para o armazenamento do Terraform State e cria também uma tabela no DynamoDB para gerenciar o Lock do state, a fim de evitar inconsistências e conflitos.

Após executar o apply, o módulo gera o arquivo **`backend.tf`** com as especificações de gerenciamento de estado da infra. O ambiente e nome do bucket são criados de forma dinâmica, a partir do ambiente que está sendo executado.

Além do controle de estado, a ideia do uso deste módulo é abstrair a necessidade de especificação de um arquivo de configuração de backend de forma manual.

Para executar o projeto no ambiente local, você precisa apenas excluir o arquivo `backend.tf`:

```bash
rm -rf backend.tf
```


### Namespace

Para evitar conflitos como nome de bucket, que deve ser único, adicionei a variável **`namespace`**, a qual é adicionada no padrão de nomeclatura dos componentes do projeto.

O namespace **default** está definido nos arquivos de variáveis: `values/dev.tfvars` e `values/prod.tfvars`.

Para criar os recuros com um outro namespace basta adicionar a seguinte opção na frente dos comandos de execução comando 

```bash
-var="namespace=hm"
```

### Executando

Segue abaixo uma lista de comandos para você criar o projeto em uma outra conta AWS.

#### Removendo a configuração de state

Remova a configuração de state que está linkada à infra do projeto. Não se preocupe, o projeto irá criar os recursos necessários para gerenciar o state e gerar um novo arquivo `backend.tf` para você

```bash
rm -rf backend.tf
```

#### Inicializando os módulos

```bash
terraform init
```

#### Validando a configuração

```bash
terraform validate
```

#### Planejando as alterações

Para os passos a seguir, inclua a zona do Route 53 que você irá utilizar. Para isso, basta substituir o `[route_53_zone]` pela sua zona. O valor default está no arquivo `tfvars`, no entanto você deverá utilizar um outro =)

```bash
terraform plan -var-file=values/prod.tfvars -var="namespace=hm" -var="aws_route53_zone=[route_53_zone]"
```

#### Aplicando as alterações

```bash
terraform apply -var-file=values/prod.tfvars -var="namespace=hm" -var="aws_route53_zone=[route_53_zone]"
```

Exemplo com zona:

```bash
terraform apply -var-file=values/prod.tfvars -var="namespace=hm" -var="aws_route53_zone=devsforlife.org"
```

:warning: **Atenção:**  Salve o valor do output `acm_certificate_arn`, ele será necessário nos próximos passos.

#### Cloudfront Distribution

A distribuição do cloudfront ficou em um módulo que deve ser executado depois da criação do módulo principal, pois o ALB é criado pelo Ingress Controller, o que torna inviável para o Terraform saber se o ALB está disponível ou não, resultando em erro na criação da distribution do Cloudfront.

Entre no módulo do cloudfront:

```bash
cd modules/cloudfront_multiorigin
```

Inicialize o terraform informando o arquivo de gerenciamento de estado criado anteriormente automáticamente na primeira execução:

```bash
terraform init 
```

Valide:

```bash
terraform validate
```

Para planejar e aplicar as alterações será necessário incluir a variável `acm_certificate_arn`, que foi um output do primeiro módulo:

```bash
terraform plan -var-file=values/prod.tfvars -var="namespace=hm" -var="aws_route53_zone=[route_53_zone]" -var="acm_certificate_arn=[acm_certificate_arn]"
```

Aplique as alterações:

```bash
terraform apply -var-file=values/prod.tfvars -var="namespace=hm" -var="aws_route53_zone=[route_53_zone]" -var="acm_certificate_arn=[acm_certificate_arn]"
```

### Validação

Assim que o processamento terminar, a aplicação estará disponível em `https://happ.[route_53_zone]`;

- **Frontend:** https://happ.devsforlife.org/frontend
- **Backend:** https://happ.devsforlife.org/backend

#### Destruindo a infra criada

Primeiramente, destrua a infra referente ao primeiro módulo:

```bash
cd happ/infra
terraform destroy -var-file=values/prod.tfvars -var="namespace=hm" -var="aws_route53_zone=[route_53_zone]"
```

Posteriormente acesse o módulo cloudfront para a destruição  do mesmo:

```bash
cd happ/infra
```

:warning: **Atenção:** Conforme issues https://github.com/terraform-providers/terraform-provider-aws/issues/1721 e https://github.com/terraform-providers/terraform-provider-aws/issues/5818, existe um bug atual ao deletar Lambda@Edge functions. A [documentação da aws](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html) diz que só é possível realizar a exclusão após uma desassociação do Lambda@Edge com o Cloudfront e esperar alguamas horas:

> If you remove all the associations for a Lambda function version, you can typically delete the function version a few hours later.

Dessa forma, sugiro rodar o script criado para deletar a infraestrutura com o cloudfront, pois ele irá deletar todos os recursos, exceto o Lambda@Edge, o qual poderá ser deletado posteriormente de forma manual algumas horas depois.

```bash
bash scripts/destroy.sh -var-file=values/prod.tfvars -var="namespace=hm" -var="aws_route53_zone=[route_53_zone]"
```

## Arquitetura

![Arquitetura HTMKT](https://user-images.githubusercontent.com/22299426/86080248-d91ad180-ba68-11ea-8496-641b8d917417.png)

![Arquitetura HTMKT - pt2](https://user-images.githubusercontent.com/22299426/85935889-cc14ab80-b8cb-11ea-8e87-93d0b5af54e5.png)

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

Para evitar conflitos como nome de bucket, que devem ser únicos, adicionei a variável namespace, a qual define o **`namespace`**, a qual é adicionada no padrão de nomeclatura do projeto.

O namespace default está definido nos arquivos de variáveis: `values/dev.tfvars` e `values/prod.tfvars`.

Para criar os recuros com um outro namespace basta adicionar a seguinte opção na frente dos comandos de execução comando 

```bash
-var="namespace=hm"
```

### Executando

Removendo configuração de state:
```bash
rm -rf backend.tf
```

Setando o workspace:

```bash
terraform workspace new dev
```

Inicializando os módulos:

```bash
terraform init
```

Validando a configuração:

```bash
terraform validate
```

Planejando as alterações:

```bash
terraform plan -var-file=values/dev.tfvars -var="namespace=hm"
```

Aplicando as alterações:

```bash
terraform apply -var-file=values/dev.tfvars -var="namespace=hm"
```

## Arquitetura

![Arquitetura HTMKT](https://user-images.githubusercontent.com/22299426/85886829-21ae6280-b7bd-11ea-907f-a4b165a80952.png)

![Arquitetura HTMKT - pt2](https://user-images.githubusercontent.com/22299426/85935889-cc14ab80-b8cb-11ea-8e87-93d0b5af54e5.png)

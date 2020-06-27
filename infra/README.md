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

### Running

Para executar, utilize o script `happ.sh`. O script foi adicionado para automatizar o controle do `terraform.state`, realizando o download e o upload para o S3, mantendo o estado atual da infra gerenciado.

Os parâmetros esperados pelo script são:

- `$1`: Operação [apply, plan, destroy, show]
- `$2`: Ambiente [dev, prod]
- `$3`: Opções extras do Terraform. Examplo: -auto-approve

#### Examplos

Exibindo estado atual da infra:
```bash
./happ.sh show dev
```

Planejando as alterações a serem aplicadas:
```bash
./happ.sh plan dev
```

Aplicando as alterações na infra:
```bash
./happ.sh apply dev
```

Destruindo a infra atual:
```bash
./happ.sh destroy dev
```

Para scripts, é possível utilizar o comando abaixo para evitar uma confirmação como entrada:
```bash
./happ.sh apply dev -auto-approve
```

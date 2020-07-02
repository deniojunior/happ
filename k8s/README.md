## K8s

### Configuração

Instalando microk8s

```bash
sudo snap install microk8s --classic --channel=1.17/stable
```

Habilitando Core DNS para resolução dos domínios no cluster:

```bash
sudo microk8s.enable dns
```

Confirmando se tá instalado:

```bash
sudo microk8s.status 
```

Para facilitar, é possível utilizar um alias, adicionando no seu profile, exemplo:

```
echo 'alias kubectl="microk8s.kubectl' >> ~/.bashrc
source ~/.bashrc
```

### Placeholders

Os arquivos que descrevem os componentes do cluster possuem algumas variáveis que devem ser setadas antes da execução. 

Primeiramente, exporte as variáveis de ambiente com o valor desejado:

```bash
export ECR_REGISTRY="[REGISTRY]"
export ECR_REPOSITORY_URL="[REPOSITORY_URL]"
export CERT_ARN="[ACM_CERT_MANAGER_ARN]"
export IMAGE_TAG="[IMAGE_TAG]"
export K8S_NAMESPACE="[K8S_NAMESPACE]"
```

Depois processe os arquivos  utilizando o comando `envsubst`, gerando arquivops com os valores finais:

```bash
mkdir final
envsubst < namespace.yaml > final/namespace.yaml
envsubst < deployment.yaml > final/deployment.yaml
envsubst < service.yaml > final/service.yaml
envsubst < ingress.yaml > final/ingress.yaml
```

### Execução

Com os arquivos já processados com os valores desejados, aplique as alterações:

```bash        
kubectl apply -f final/namespace.yaml --kubeconfig ~/.kube/config
kubectl apply -f final/deployment.yaml --kubeconfig ~/.kube/config
kubectl apply -f final/service.yaml --kubeconfig ~/.kube/config
kubectl apply -f final/ingress.yaml --kubeconfig ~/.kube/config
```

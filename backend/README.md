# Backend App

API básica em python.

**API Doc:** https://app.swaggerhub.com/apis/deniojunior/backend-api

---

### Desenvolvimento

Instale as deṕendências do projeto:
```bash
pipenv sync --dev --three
```

Para executar a aplicação local execute o comando abaixo:

```bash
pipenv run python run.py -c config.yaml
```

É possível também rodar local com o Guinicorn:

```bash
pipenv run gunicorn -w 2 --timeout 3600 -b 0.0.0.0:8080 "app.server:create_app(config='config.yaml')"
```

### Testes
Para executar os testes, execute o comando abaixo:

```bash
pipenv run coverage run --omit="tests/*" --include="app/*" --branch -m unittest discover -s tests/unit -p "*_test.py"
```

### Docker

Para fazer o build da imagem docker, execute o comando abaixo:

```bash
docker build -t backend-api .
```

Para rodar um container, execute:

```bash
docker container run -p 8080:8080 -d --name backend-app backend-api
```

A pós subir o container, a aplicação estará disponível no endereço: [http://localhost:8080](http://localhost:8080)

# Frontend App

Frontend básico criado com React.


### Desenvolvimento

Instale o NodeJs:

```bash
sudo apt install nodejs
```

**PS:** Caso tenha problemas com a instalação do Node, siga o [link para instalação manual](https://github.com/nodejs/help/wiki/Installation)

Com a instalação do NodeJs o NPM deve estar disponível, para confirmar execute:

```bash
npm version
```

Para instalar as dependências, execute:

```bash
npm install
```

Para executar a aplicação local execute:

```bash
npm start
```
A aplicação ficará disponível em [http://localhost:3000](http://localhost:3000)

Para executar os testes, basta rodar:

```bash
npm test
```

### Build

Para buildar a aplicação basta executar:

```bash
npm run build
```

Este comando irá otimizar todas as imagens, minificar os arquivos e jogá-los no diretório `build`.

Para servir os arquivos buildados, instale o `serve`:

```bash
npm install -g serve
```

Execute o comando para servir a aplicação de distribuição:

```bash
serve -s build
```

### Build

Para fazer o build da imagem docker, execute o comando abaixo:

```bash
docker build -t frontend .
```

Para rodar um container, execute:

```bash
docker container run -p 8081:5000 -d --name frontend-app frontend
```

A pós subir o container, a aplicação estará disponível no endereço: [http://localhost:8081](http://localhost:8081)

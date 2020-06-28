<h1> <img src="./icon.png"
  width="48"
  height="48"
  style="float:left;"> 
Happ

### 
Happ é um projeto que provém uma infraestrutura completa para servir aplicações frontend e backend com alta disponibilidade, segurança, escalabilidade e tolerância a falhas.

![Arquitetura HTMKT](https://user-images.githubusercontent.com/22299426/85886829-21ae6280-b7bd-11ea-907f-a4b165a80952.png)
![Arquitetura HTMKT - pt2](https://user-images.githubusercontent.com/22299426/85935889-cc14ab80-b8cb-11ea-8e87-93d0b5af54e5.png)

### Estrutura

Para centralizar, foram todos os projetos referentes ao **happ** foram incluídos neste mesmo repositório, sendo divididos por diretórios, conforme abaixo:

- **/frontend:** Aplicação frontend simples feita em React
- **/backend:** Aplicação backend simples, sendo uma API básica feita em Python com Flask
- **/infra:** Código IaC feito com Terraform descrevendo a infraestrutura da aplicação

### Documentação

Cada um dos diretórios acima possuem o seu arquivo `README` próprio, junto das instruções de configuração para rodar os projetos no ambiente local. Tanto as aplicações **frontend** e **backend** possuem um `Dockerfile`, bem como as instruções para rodar as aplicações como container. Em relação ao projeto de **infra**, o readme dá todas as instruções para configuração do Terraform e as instruções para criação da infra na Cloud.

Link para instruções de cada projeto:
- [Documentação Backend](./backend)
- [Documentação Frontend](./frontend)
- [Documentação Infra](./infra)

### Planejamento

O planejamento foi uma etapa muito importante do projeto, bem como toda a organização, fluxo de desenvolvimento e metodologia utilizados. Todos estes processos foram documentados e podem ser encontrados na [issue principal de planejamento](https://github.com/deniojunior/happ/issues/1).

Conforme mencionado por lá, o projeto foi dividido em Milestones e acompanhado por um Kanban utilizando o próprio Projects do Github. No [Projects](https://github.com/deniojunior/happ/projects) é possível encontrar todos os Milestones planejados e levantados na issue de planejamento.

O primeiro Milestone foi somente tarefas operacionais iniciais e planejamentos de estrutura e arquitetura. Deixo abaixo o link rápido para os assuntos mais importantes:

- **[Fluxo de entrega](https://github.com/deniojunior/happ/issues/4#issuecomment-650580765)**
- **[Decisões de arquitetura](https://github.com/deniojunior/happ/issues/3#issuecomment-649901316)** 
- **[Análise de custos](https://github.com/deniojunior/happ/issues/3#issuecomment-650566656)**

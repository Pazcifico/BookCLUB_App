# BOOKCLUB - Desenvolvido por Diogo Ribeiro, Gustavo Henrique Andrade e Caio Pacífico

Sistema cliente Flutter para uma rede social de leitura dinâmica, voltada para grupos de leitura, discussão de livros e interação entre leitores.

Sistema API (Django/DRF) disponível em: https://github.com/add-gutto/BookCLUB.git

## Tecnologias Utilizadas
- Flutter (Dart)
- WebSocket
- API do Google Books 

## Funcionalidades

- Cadastro de usuários com criação automática de perfil
- Criação e gerenciamento de Grupos de Leitura
- Criação de Tópicos vinculados a um livro
- Envio de mensagens via WebSocket, com suporte a marcação de spoilers
- Avaliação de livros 

## Instalação e Configuração

Siga estes passos para configurar o ambiente de desenvolvimento.

### 1. Pré-requisitos

* Flutter (3.x ou superior)

### 2. Passos de Instalação

1.  Clone o repositório:
    ```bash
    git clone https://github.com/Pazcifico/BookCLUB_App.git
    cd BookCLUB_App
    ```

2.  Crie o arquivo .env na raiz do projeto:
    ```env
    API_DOMAIN_API=http://SEU_DOMINIO:8080
    API_DOMAIN_BOOK=https://www.googleapis.com/books/v1/volumes

    ```
3. Executar o Projeto:
    ```bash
    ./run.sh

    ```

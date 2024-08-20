Aqui está um `README.md` mais detalhado que reflete as informações fornecidas sobre o uso dos parâmetros no script `aux-digibeectl.sh`:

```markdown
# DigibeeCTL Automation Script

Este repositório contém um script shell (`aux-digibeectl.sh`) criado para interagir com a ferramenta `digibeectl`, automatizando a gestão de pipelines no ambiente Digibee.

## Índice

- [Visão Geral](#visão-geral)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Uso](#uso)
  - [Parâmetros de Uso](#parâmetros-de-uso)
    - [--menu](#--menu)
    - [--list-pipelines](#--list-pipelines)
    - [--list-deploys](#--list-deploys)
    - [--search-global](#--search-global)
    - [--search-capsule](#--search-capsule)
    - [--search-account](#--search-account)
    - [--deploy](#--deploy)
    - [--delete-deploy](#--delete-deploy)
    - [--find-text](#--find-text)
    - [--get-config](#--get-config)
    - [--set-config](#--set-config)
- [Logging](#logging)
- [Contribuição](#contribuição)
- [Licença](#licença)

## Visão Geral

O `aux-digibeectl.sh` foi desenvolvido para facilitar a interação com o `digibeectl`, fornecendo automação para tarefas como listagem, busca e deploy de pipelines em diferentes ambientes (realms).

### Autor e Manutenção

- **Autor:** Walter Moura
- **Data de Criação:** 01/08/2022
- **Última Modificação:** 10/07/2024

## Pré-requisitos

Antes de usar este script, certifique-se de que você tenha:

- **Bash** (versão 4.0+ recomendada)
- **digibeectl** (Digibee Command Line Interface)
- **jq** (ferramenta para processamento de JSON)
- **Acesso** aos ambientes do Digibee

## Instalação

1. Clone o repositório ou baixe o script `aux-digibeectl.sh`.
2. Certifique-se de que o script é executável:
   ```bash
   chmod +x aux-digibeectl.sh
   ```
3. Coloque o script em um diretório que esteja no seu `PATH`, ou execute-o diretamente do local onde está armazenado.

## Uso

Para utilizar o script, execute-o com os parâmetros necessários:

```bash
./aux-digibeectl.sh <param1> <param2> ...
```

### Parâmetros de Uso

Aqui está uma descrição detalhada dos parâmetros que podem ser utilizados com o script:

#### `--menu`

Abre um menu interativo com as opções de uso.

#### `--list-pipelines`

Lista os pipelines existentes nos realms.

#### `--list-deploys`

Busca os pipelines deployados no ambiente especificado.

- Parâmetros opcionais:
  - `--environment`: Define o ambiente para a busca (`test` ou `prod`). O valor padrão é `test`.

#### `--search-global`

Busca uma global específica no realm.

- Parâmetros opcionais:
  - `--global=valor`: Define o valor da global a ser buscada.
  
  **Observação:** Caso o parâmetro não seja informado, as globals serão buscadas dentro do arquivo `global.txt`. Neste caso, pode-se buscar múltiplas globals.

#### `--search-capsule`

Busca uma cápsula específica no realm.

- Parâmetros opcionais:
  - `--capsule=capsule-name`: Define o nome da cápsula a ser buscada.
  
  **Observação:** Caso o parâmetro não seja informado, as cápsulas serão buscadas dentro do arquivo `capsules.txt`. Neste caso, pode-se buscar múltiplas cápsulas.

#### `--search-account`

Busca uma conta específica no realm.

- Parâmetros opcionais:
  - `--account=account-name`: Define o nome da conta a ser buscada.
  
  **Observação:** Caso o parâmetro não seja informado, as contas serão buscadas dentro do arquivo `accounts.txt`. Neste caso, pode-se buscar múltiplas contas.

#### `--deploy`

Realiza o deploy/re-deploy dos pipelines existentes no arquivo `pipelines-deploys.csv`.

#### `--delete-deploy`

Remove deploys dos pipelines listados no arquivo `pipelines-remove.csv`.

#### `--find-text`

Busca um texto específico dentro dos pipelines.

- Parâmetros obrigatórios:
  - `--text=valor`: Define o texto a ser buscado nos pipelines.

#### `--get-config`

Exibe as informações de configuração atuais do `digibeectl` e informações do realm.

#### `--set-config`

Aplica as configurações de ambiente conforme o arquivo `config.conf`.

- Parâmetros opcionais:
  - `--realm=nomeDoRealm`: Define o realm a ser configurado.

## Logging

O script gera logs detalhados para cada ação executada. Esses logs são armazenados no diretório de logs (`$LOG_DIR`), permitindo a revisão e a depuração das operações.

## Contribuição

Contribuições são bem-vindas! Se você quiser contribuir para o projeto, faça um fork do repositório e envie um pull request.

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo `LICENSE` para mais detalhes.
```
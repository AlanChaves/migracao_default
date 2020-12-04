# Migração de registros entre banco de dados

Componente criado com o objetivo de facilitar a cópia de registros de um banco de dados X para o banco de dados Y. Apenas definindo quais serão as tabelas e campos correspondentes.

* **100%** - Open Source

### Banco de Dados

* Firebird para Firebird - **OK**

## Definições

![alt text](https://devalltech.com/img/componentes/propriedades.jpg)

### Pré-Requisitos

* É necessário informar qual será o driver de conexão, que fica na palheta **FireDAC Links**;
* E o componente **TFDGUIxWaitCursor** que fica na palheta **FireDAC UI**

### Principais propriedades

* **Origem** - Qual o banco de dados que será tirado as informações;
* **Destino** - Qual o banco de dados que receberá os dados de origem;
* **Campos** - Relação dos campos entre as tabelas;
* **TransacaoAutomatica** - Define se você ou o componente irá gerenciar as transações ao banco de dados de destino.

### Origem / Destino

* **Caminho** - Onde está o banco de dados;
* **Driver** - Qual o tipo de banco de dados;
* **SQL** - Qual o comando que será executado, origem selects e destino insert, update ou delete;
* **Tabela** - Caso não informado o SQL será utilizado para montar o comando SQL;
* **Usuario e Senha** - Autenticação ao banco de dados.

### Campos

![alt text](https://devalltech.com/img/componentes/propriedades-campos.jpg)

* **Nome** - Campo da tabela do destino, que receberá o valor do campo equivalente;
* **Equivalente** - Campo da origem correspondente ao nome;
* **IgnorarZero** - Caso o campo de origem esteja com o valor 0 (zero) ele substituirá por Null;
* **PermiteNulo** - Se o campo de destino permite nulo;
* **StrSoNumero** - Remove qualquer valor diferente de um número;
* **StrUpper** - Deixa o texto em caixa alta;
* **Tamanho** - Define o tamanho máximo de um texto, será cortado caso seja maior;
* **Tipo** - O tipo do campo de destino, usado para converter os valores que serão recebidos;
* **ValorDefault** - Caso o campo de origem esteja nulo será substituído pelo valor que estiver aqui.

### Eventos

* Ainda existem os eventos de incremento do ProgressBar para uma melhor análise do andamento da migração;
* Mensagem do que está acontecendo a cada momento;
* Validar se o registro todo será migrado ou não.

* **Campos** - Antes de receber o valor pode ser tratado mais alguma validação.

### Iniciar

```
  DevAllMigracao1.Executar;
```

### Controlar as transações

* Para casos em que seja necessário uma tabela depender da outra

```
  DevAllMigracao1.IniciarTransacao; // Start transaction
  DevAllMigracao1.Descarregar; // Commit
  DevAllMigracao1.Desfazer; // Rollback
```

## Para colaboração com o projeto

* Entrar em contato **alanchavesdasilva@gmail.com**
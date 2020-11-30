# Migração Default
Migração entre banco de dados

## Migrar dados de um banco de dados para outro
A ideia inicial é criar um componente para a padronização de migração de registros entre banco de dados locais. Utiliza select em campos de tabelas de banco de dados Firebird para montar o comando de inserção.

```
SELECT RDB$FIELD_NAME FROM RDB$RELATION_FIELDS WHERE RDB$RELATION_NAME = NOME_TABELA;
```

* **100%** - Open Source

### Componente de conexão

* **Firedac** - Componente de conexão para os banco de dados mais utilizados

### Banco de Dados

* Firebird para Firebird - **OK**

## Modo de usar

![alt text](https://devalltech.com/img/componentes/comp_devall_migracao.jpg)

### Object Inspector

* **Origem** - Indicar qual o tipo do banco de dados, o caminho, qual tabela a ser transferida e o sql caso tenha que pegar registro de mais de uma tabela ou fazer where para alguns registros apenas, se não precisar o componente montará o SQL simples nos campos relacionados;
* **Destino** - Indicar qual o tipo do banco de dados, o caminho e qual tabela receberá os registros;
* **Campos** - Relação dos campos entre as tabelas.

## Para colaboração com o projeto

* Entrar em contato **alanchavesdasilva@gmail.com**
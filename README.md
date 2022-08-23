# URBS Open Data Analysis

Repositório para código auxiliar do Trabalho de Conclusão do curso de Sistemas de Informação (UTFPR).

<!-- TOC -->
* [URBS Open Data Analysis](#urbs-open-data-analysis)
  * [Dicionário de dados](#dicionrio-de-dados)
    * [Tabela `linha`](#tabela-linha)
    * [Tabela `pontosLinha`](#tabela-pontoslinha)
    * [Tabela `shapeLinha`](#tabela-shapelinha)
    * [Tabela `tabelaLinha`](#tabela-tabelalinha)
    * [Tabela `tabelaVeiculo`](#tabela-tabelaveiculo)
    * [Tabela `veiculos`](#tabela-veiculos)
<!-- TOC -->

## Dicionário de dados

Mapeamento de alterações nas nomenclaturas de tabelas e colunas.

### Tabela `linha`

**Renomeação:** `linha` -> `bus_line`

| **Original**      | **Remapeado** | **Tipo** | **Definição**            |
|-------------------|---------------|----------|--------------------------|
| COD               | id            | varchar  | Identificador da linha   |
| NOME              | name          | varchar  | Nome da linha            |
| SOMENTE_CARTAO    | card_only     | bool     | Tipo de pagamento aceito |
| CATEGORIA_SERVICO | category      | varchar  | Categoria da linha       |
| NOME_COR          | color         | varchar  | Cor da linha             |


### Tabela `pontosLinha`

**Renomeação:** `pontosLinha` -> `bus_stop`

| **Original** | **Remapeado**        | **Tipo**             | **Definição**               |
|--------------|----------------------|----------------------|-----------------------------|
| NOME         | name                 | text                 | Nome do ponto               |
| NUM          | id                   | bigint               | Número do ponto             |
| LAT          | latitude             | double precision     | Latitude                    |
| LON          | longitude            | double precision     | Longitude                   |
| SEQ          | sequence             | bigint               | Sequência do ponto          |
| GRUPO        | group                | text                 | Agrupadores de pontos       |
| SENTIDO      | direction            | text                 | Sentido do veículo na linha |
| TIPO         | type                 | text                 | Tipo de ponto               |
| ITINERARY_ID | \> coluna deletada < | \> coluna deletada < | \> coluna deletada <        |
| COD          | bus_line_id          | text                 | Código da linha             |


### Tabela `shapeLinha`

**Renomeação:** `shapeLinha` -> `bus_line_shape`

| **Original** | **Remapeado** | **Tipo**         | **Definição**                    |
|--------------|---------------|------------------|----------------------------------|
| SHP          | shape_id      | bigint           | Identificador do shape           |
| LAT          | latitude      | double precision | Latitude do shape                |
| LON          | longitude     | double precision | Longitude do shape               |
| COD          | bus_line_id   | text             | Identificador da linha de ônibus |

### Tabela `tabelaLinha`

**Renomeação:** `tabelaLinha` -> `bus_line_timetable`

| **Original** | **Remapeado**         | **Tipo** | **Definição**                                                             |
|--------------|-----------------------|----------|---------------------------------------------------------------------------|
| HORA         | time                  | text     | Horário de parada do ônibus                                               |
| PONTO        | bus_stop_name         | text     | Nome do ponto de ônibus                                                   |
| DIA          | type_of_day           | int      | Tipo de dia - 1 = dia útil; 2 = sábado; 3 = domingo; 4 = feriado          |
| NUM          | bus_stop_id           | bigint   | Identificador do ponto de ônibus                                          |
| TABELA       | bus_line_timetable_id | text     | Identificador da tabela de horários a qual o veículo está operando no dia |
| ADAPT        | accessibility         | text     | Tipo de equipamento de acessibilidade disponível na parada de ônibus      |
| COD          | bus_line_id           | text     | Identificador da linha de ônibus                                          |

### Tabela `tabelaVeiculo`

**Renomeação:** `tabelaVeiculo` -> `bus_vehicle_timetable`

| **Original** | **Remapeado**        | **Tipo** | **Definição**                                  |
|--------------|----------------------|----------|------------------------------------------------|
| COD_PONTO    | bus_stop_id          | bigint   | Identificador do ponto de ônibus               |
| COD_LINHA    | bus_line_id          | text     | Identificador da linha de ônibus               |
| NOME_LINHA   | bus_line_name        | text     | Nome da linha de ônibus                        |
| VEICULO      | vehicle_id           | text     | Identificador do veículo                       |
| HORARIO      | time                 | text     | Horário de parada do veículo                   |
| TABELA       | vehicle_timetable_id | text     | Identificador da tabela de horários do veículo |

### Tabela `veiculos`

**Renomeação:** `veiculos` -> `vehicle_position`

| **Original** | **Remapeado** | **Tipo**         | **Definição**                    |
|--------------|---------------|------------------|----------------------------------|
| VEIC         | vehicle_id    | text             | Identificador do veículo         |
| LAT          | latitude      | double precision | Latitude da posição no instante  |
| LON          | longitude     | double precision | Longitude da posição no instante |
| DTHR         | timestamp     | timestamp        | Data e hora do instante          |
| COD_LINHA    | bus_line_id   | text             | Identificador da linha de ônibus |
# Trabalho de Otimização

## Passos

- Formular o problema escolhido como programa inteiro misto.
- Implementar a formulação (ex: com Julia / JuMP) e executar a
formulação sobre as instâncias dadas, com limite de tempo.
- Propor componentes para a meta-heurística escolhida resolver o
problema (vizinhan¸ca, condição de parada, crossover, etc).
- Implementar a meta-heurística proposta em qualquer linguagem
de programação.
- Executar a implementação sobre as instâncias dadas e apresentar
os resultados.
- Analisar criticamente os resultados, preferencialmente com dados,
tabelas, gráficos, etc.
- Escrever um relat´orio completo explicando o que foi feito, apresentando todos os resultados.

## Meta Heurística: busca local iterada

### O que é uma meta-heurística?

Uma meta-heurística é um método ou estratégia para resolver problemas de otimização de soluções complexas, onde não é possível garantir a obtenção da melhor solução possível em um tempo razoável. Os problemas podem envolver várias variáveis, restrições complexas e múltiplos ótimos locais.

### Meta-heurística da busca local iterada

-

## Problema do Torneio Esportivo

Considere um torneio esportivo com n times (com n par), onde cada time
deve jogar exatamente uma vez com cada outro time. O torneio ´e dividido
em n − 1 rodadas, onde em cada rodada cada time deve jogar exatamente
uma vez. Aléem disso, determinar que o jogo entre os times i, j ocorrerá na
rodada r possui um custo cijr.
Determinar a tabela dos jogos que ocorrer˜ao em cada rodada de modo a
minimizar o custo total.

### Pontos importantes

- **Nº de jogos:** C<sub>(2,n)</sub>
- **Nº rodadas:** n-1
- **nº jogos por rodada:**  C<sub>(2,n)</sub> / (n-1)

### Exemplo

Seja um campeonato de 4 equipes, temos:

#### Calculando número de jogos:

    C(2,4) = 4! / 2!(4-2)!
           = 4! / 2!2!
           = 4.3.2!/2!2!
           = 4.3/2.1
           = 2.3
           = 6 Jogos

#### Exemplo: sejam as equipes A, B, C e D, temos os seguintes seis jogos.

    #1 A x B
    #2 A x C
    #3 A x D
    #4 B x C
    #5 B x D
    #6 C x D

#### Calculando as rodadas:

    n-1 = 4 -1
        = 3 rodadas

#### Exemplo: os jogos devem ser jogados em 3 rodadas, R1, R2 e R3.

    #1 A x B => R1
    #2 A x C => R2
    #3 A x D => R3
    #4 B x C => R3
    #5 B x D => R2
    #6 C x D => R1

#### Calculando o número de jogos por rodada:

    C(2,4) / (n-1) => 6/3
                   => 2

#### Exemplo: deve haver dois jogos por rodadas, sendo, R1J1, R1J2, R2J1, R2J2, R3J1, R3J2.

    #1 A x B => R1J1
    #2 A x C => R2J1
    #3 A x D => R3J1

    #4 B x C => R3J2
    #5 B x D => R2J2
    #6 C x D => R1J2

Podemos afirmar que temos C<sub>ijrc</sub>, onde:

- i: equipe 1
- j: equipe 2
- r: rodada
- c: custo

#### Tabela de custos

| # |{A, B}|{A, C}|{A, D}|{B, C}|{B, D}|{C, D}|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 1 |2|1|2|3|4|5|
| 1 |1|2|1|2|3|4|
| 1 |2|1|2|1|2|3|

## Formulação do problema como programa inteiro misto

- 



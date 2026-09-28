#!/usr/bin/env bash
set -e

mkdir -p ./save
RUN="docker compose run --rm transfermarkt-scraper"

echo "==> Etapa 1: confederations"
$RUN tfmkt confederations > ./save/confederations.jsonl

echo "==> Etapa 2: competitions"
$RUN tfmkt competitions -p ./save/confederations.jsonl > ./save/competitions.jsonl

echo "==> Inspecionando 1a linha de competitions.jsonl (confira o nome do campo):"
head -n 1 ./save/competitions.jsonl | jq .

echo "==> Etapa 3: filtrando competitions para Brasileirão Série A"
grep -i "campeonato-brasileiro-serie-a" ./save/competitions.jsonl > ./save/competitions_brasil.jsonl
cat ./save/competitions_brasil.jsonl | jq -c .

echo "==> Etapa 4: clubs do Brasileirão"
$RUN tfmkt clubs -p ./save/competitions_brasil.jsonl -s 2010 > ./save/clubs.jsonl

echo "==> Inspecionando 1a linha de clubs.jsonl:"
head -n 1 ./save/clubs.jsonl | jq .

echo "==> Etapa 5: filtrando Atlético Mineiro"
grep -iE "atl[ée]tico.?mineiro|atlético-mg" ./save/clubs.jsonl > ./save/clube_atletico_mg.jsonl
cat ./save/clube_atletico_mg.jsonl | jq -c .

echo "==> Etapa 6: jogadores do Atlético Mineiro"
$RUN tfmkt players -p ./save/clube_atletico_mg.jsonl -s 2010 > ./save/jogadores_atletico_mg.jsonl

echo "==> Concluído. Jogadores salvos em ./save/jogadores_atletico_mg.jsonl"
jq -c . ./save/jogadores_atletico_mg.jsonl
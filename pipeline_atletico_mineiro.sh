#!/usr/bin/env bash
set -e

mkdir -p ./save
RUN="docker compose run --rm transfermarkt-scraper"

echo "==> Etapa 1: confederations"
$RUN tfmkt confederations > ./save/confederations.json

echo "==> Etapa 2: competitions"
$RUN tfmkt competitions -p ./save/confederations.json > ./save/competitions.json

echo "==> Inspecionando 1a linha de competitions.json (confira o nome do campo):"
head -n 1 ./save/competitions.json | jq .

#daqui pra baixo nao funciona

echo "==> Etapa 3: filtrando competitions para Brasileirão Série A"
grep -i "campeonato-brasileiro-serie-a" ./save/competitions.json > ./save/competitions_brasil.json
cat ./save/competitions_brasil.json | jq -c .

echo "==> Etapa 4: clubs do Brasileirão"
$RUN tfmkt clubs -p ./save/competitions_brasil.json -s 2026 > ./save/clubs.json

echo "==> Inspecionando 1a linha de clubs.json:"
head -n 1 ./save/clubs.json | jq .

echo "==> Etapa 5: filtrando Atlético Mineiro"
grep -iE "atl[ée]tico.?mineiro|atlético-mg" ./save/clubs.json > ./save/clube_atletico_mg.json
cat ./save/clube_atletico_mg.json | jq -c .

echo "==> Etapa 6: jogadores do Atlético Mineiro"
$RUN tfmkt players -p ./save/clube_atletico_mg.json -s 2026 > ./save/jogadores_atletico_mg.json

echo "==> Concluído. Jogadores salvos em ./save/jogadores_atletico_mg.json"
jq -c . ./save/jogadores_atletico_mg.json
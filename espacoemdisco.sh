#!/bin/bash

df -h | grep sd | while read linha; do
    particoes=( $(echo $linha | awk ' {print $1 $2 $4 $5}'))
    particao=${particoes[0]}
    tamanho=${particoes[1]}
    disponivel=${particoes[2]}
    usoPorcentagem=${particoes[3]}
done
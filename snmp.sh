#!/bin/bash
# snmpget -v2c -c public -Oqv $enderecoMaquina
# Maquina real 192.168.0.111

enderecoMaquina=$1

#total memoria ram
memoriaTotalKb=($(snmpget -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.4.5.0 | awk ' {print $1 }'))
memoriaTotalMb=$(($memoriaTotalKb / 1000))
# echo $memoriaTotalKb
#Total memoria ram livre
memoriaLivreKb=($(snmpget -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.4.6.0 | awk ' {print $1 }'))
memoriaLivreMb=$(($memoriaLivreKb / 1000))
# echo $memoriaLivreKb
#uso de memoria em %
memoriaPorcentagem=$((100 - ((100 * $memoriaLivreKb) / $memoriaTotalKb)))

#maquina fisica é 6 
#vm 3


while read p; do
    echo p
done < snmpbulkget -v2c -c public $enderecoMaquina .1.3.6.1.4.1.2021.9.1.3 | grep sda | cut -d. -f2 | cut -d" " -f1

#Nome disco
nomeDisco=($(snmpget  -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.9.1.3.6 | awk ' {print $1 }'))
# echo $nomeDisco
#Total disco
totalDiscoKb=($(snmpget  -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.9.1.6.6 | awk ' {print $1 }'))
totalDiscoMb=$(($totalDiscoKb / 1000))
# echo $totalDiscoKb
#Disco usado sda3
discoUsolKb=($(snmpget  -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.9.1.8.6 | awk ' {print $1 }'))
discoUsoMb=$(($discoUsolKb / 1000))
# echo $discoUsolKb
#disco usado % sda3
discoPorcentagem=($(snmpget  -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.9.1.9.6 | awk ' {print $1 }'))
# echo $discoPorcentagem
#disco usado % inodes sda3
discoPorcentagemInodes=($(snmpget  -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.9.1.10.6 | awk ' {print $1 }'))
# echo $discoPorcentagemInodes

#processos
numProcessos=($(snmpget -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.2.1.25.1.6.0 | awk ' {print $1 }'))
# echo $numProcessos
#usuarios
numUsuarios=($(snmpget -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.2.1.25.1.5.0 | awk ' {print $1 }'))
# echo $numUsuarios
#desde de quando ta ligado
# tempoLigado=($(snmpget -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.2.1.1.3.0 | awk ' {print $1 }'))
# echo $tempoLigado
#nome da maquina
nomeMaquina=($(snmpget -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.2.1.1.5.0 | awk ' {print $1 }'))
# echo $nomeMaquina
#uso de rede 



curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "memoria_total,server=$nomeMaquina value=$memoriaTotalMb"
curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "memoria_livre,server=$nomeMaquina value=$memoriaLivreMb"
curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "memoria_porcentagem,server=$nomeMaquina value=$memoriaPorcentagem"

curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "disco_total,server=$nomeMaquina value=$totalDiscoMb disco=$nomeDisco"
curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "disco_uso,server=$nomeMaquina value=$discoUsoMb disco=$nomeDisco"
curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "disco_porcentagem,server=$nomeMaquina value=$discoPorcentagem disco=$nomeDisco"
curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "disco_inodes,server=$nomeMaquina value=$discoPorcentagemInodes disco=$nomeDisco"

curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "processos,server=$nomeMaquina value=$numProcessos"
curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "usuarios,server=$nomeMaquina value=$numUsuarios"
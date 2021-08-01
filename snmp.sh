#!/bin/bash
# Maquina real 192.168.0.111

=$enderecoMaquina1

#nome da maquina
nomeMaquina=($(snmpget -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.2.1.1.5.0 | awk ' {print $1 }'))

#total memoria ram
memoriaTotalKb=($(snmpget -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.4.5.0 | awk ' {print $1 }'))
memoriaTotalMb=$(($memoriaTotalKb / 1000))

curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "memoria_total,server=$nomeMaquina value=$memoriaTotalMb"

#Total memoria ram livre
memoriaLivreKb=($(snmpget -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.4.6.0 | awk ' {print $1 }'))
memoriaLivreMb=$(($memoriaLivreKb / 1000))

curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "memoria_livre,server=$nomeMaquina value=$memoriaLivreMb"

#uso de memoria em %
memoriaPorcentagem=$((100 - ((100 * $memoriaLivreKb) / $memoriaTotalKb)))

curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "memoria_porcentagem,server=$nomeMaquina value=$memoriaPorcentagem"

discos=($(snmpbulkget -v2c -c public $enderecoMaquina .1.3.6.1.4.1.2021.9.1.3 | grep sda | cut -d. -f2 | cut -d" " -f1))
for i in "${discos[@]}"; do
    #Nome disco
    nomeDisco=($(snmpget  -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.9.1.3.$i | awk ' {print $1 }'))
    nomeDisco=($(echo $nomeDisco | cut -d/ -f3))
    #Total disco
    totalDiscoKb=($(snmpget  -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.9.1.6.$i | awk ' {print $1 }'))
    totalDiscoMb=$(($totalDiscoKb / 1000))

    #Disco usado 
    discoUsolKb=($(snmpget  -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.9.1.8.$i | awk ' {print $1 }'))
    discoUsoMb=$(($discoUsolKb / 1000))

    #disco usado 
    discoPorcentagem=($(snmpget  -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.9.1.9.$i | awk ' {print $1 }'))

    #disco usado % inodes 
    discoPorcentagemInodes=($(snmpget  -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.4.1.2021.9.1.10.$i | awk ' {print $1 }'))

    curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "disco_total,server=$nomeMaquina,disk=$nomeDisco value=$totalDiscoMb"
    curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "disco_uso,server=$nomeMaquina,disk=$nomeDisco value=$discoUsoMb"
    curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "disco_porcentagem,server=$nomeMaquina,disk=$nomeDisco value=$discoPorcentagem"
    curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "disco_inodes,server=$nomeMaquina,disk=$nomeDisco value=$discoPorcentagemInodes"
done

#processos
numProcessos=($(snmpget -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.2.1.25.1.6.0 | awk ' {print $1 }'))
curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "processos,server=$nomeMaquina value=$numProcessos"

#usuarios
numUsuarios=($(snmpget -v2c -c public -Oqv $enderecoMaquina .1.3.6.1.2.1.25.1.5.0 | awk ' {print $1 }'))
curl -i -XPOST 'http://localhost:8086/write?db=monitoramento' --data-binary "usuarios,server=$nomeMaquina value=$numUsuarios"
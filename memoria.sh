#!/bin/bash

memoria=( $(free --mega | awk '/Mem/ {print $2 $3}'))
total=${memoria[0]}
usada=${memoria[1]}
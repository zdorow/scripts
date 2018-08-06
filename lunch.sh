#!/bin/bash

dine=(
	Courtnhouse
	Livery
	Wigwam
	Galloway
	Ninja
	Dooleys
	ElPatio
	Mogies
	District
	GrandAve
	Plus
	Informalist
	Lakely
	Mousetrap
	AmberInn
	Hilltop
	BugEyedBettys
	Orchid
)

dash=(
	EggRollPlus
	Chipotle
	NelsonCheese
	ElPatio
	Burrachos
	ErbsAndGerbs
)

if [ "$1" == "list" ] ; then
	echo "-  Dine  -"
	for value in "${dine[@]}"; do 
	    printf "%-8s\n" "${value}"
	done | column
	echo "-  Dash  -"
	for value in "${dash[@]}"; do 
	    printf "%-8s\n" "${value}"
	done | column
elif [ "$1" == "dine" ] ; then
	size=${#dine[@]}
	index=$(($RANDOM % $size))
	echo ${dine[$index]}
elif [ "$1" == "dash" ] ; then
	size=${#dash[@]}
	index=$(($RANDOM % $size))
	echo ${dash[$index]}
elif [ "$1" == "roll" ] ; then
	echo "Enter each option on a new line, and submit with Ctrl+D:"
	while read line
	do
    	list=("${list[@]}" $line)
	done
	size=${#list[@]}
	index=$(($RANDOM % $size))
	echo Choice: ${list[$index]}
else
	echo "Valid commands are list, dine, dash, and roll"
fi



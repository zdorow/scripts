#!/bin/bash

counter="4"

while [ ${counter} != "0" ]
do
	counter=$[$counter-1]
	echo $counter
	sleep 1
done

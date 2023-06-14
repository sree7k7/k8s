#!/bin/bash

while true;
do 	
	cd ../..
	git add .
	git commit -m "test"
	git push
	sleep 5;
done



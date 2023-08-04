#!/bin/bash

#git pull

while true; 
do 
	git pull; 
	sleep 5; 
	git add .
        git commit -m "test"
        git push
        sleep 2;
done

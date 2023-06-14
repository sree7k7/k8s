#!/bin/bash

while true;
do 	
	cd /Users/sran/OneDrive/vscode/K8S/k8s
	git pull; sleep 2;
	git add .
	git commit -m "test"
	git push
	sleep 2;
done



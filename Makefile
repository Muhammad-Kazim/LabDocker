

all:
	docker build --pull -t ivoihrke2/labdocker:latest .
	docker rm -f labcontainer
	docker run -i -d -e DISPLAY=$$DISPLAY -v /mnt/c/Users/Ivo\ Ihrke/Desktop:/home/labuser/mnt  --name labcontainer ivoihrke2/labdocker:latest


run:
	docker exec -it labcontainer /bin/bash

push:
	docker login -u ivoihrke2 -p :D2wa=nW?BG=Yhq
	docker image push ivoihrke2/labdocker:latest

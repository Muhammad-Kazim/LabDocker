

all:
	docker build --pull -t labdocker:latest .
	docker rm -f labcontainer
	docker run -i -d --name labcontainer labdocker:latest


run:
	docker exec -it labcontainer /bin/bash

apptest:
	docker-compose run --rm app pytest

devtest:
	docker-compose run --rm dev pytest
bash:
	docker-compose run --rm dev

rmi:
	-docker rmi -f  $$(docker images -q -f "dangling=true")
rm:
	-docker rm $$(docker ps -q -f 'status=exited')
clean:
	-docker rmi -f keboola/app-tree

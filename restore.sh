docker container exec -i $(docker-compose ps -q database) psql ctapi -U ctapi < $1

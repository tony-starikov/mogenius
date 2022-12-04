service := php-laravel-template-service
name := php-laravel-service
expose := 8080

dev-all: dev-install dev-run

dev-install:
	cd src && composer install && cd ..;

dev-run:
	cd src && php artisan serve && cd ..;

prod-all: prod-build prod-run

prod-build: docker-rm-images
	docker build --progress plain --no-cache -t ${service}:latest .;

prod-run: docker-rm-container docker-rm-images
	docker run \
		-p ${expose}:8080 \
		--name ${name} \
		${service};

docker-rm-images:
		-docker image prune -f;

docker-rm-container:
		-docker rm $$(docker stop $$(docker ps -a -q --filter="name=${name}" --format="{{.ID}}"));
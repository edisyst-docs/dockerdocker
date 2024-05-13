Docker Commands:

MariaDB:
```bash
docker run -d --name mariadb `
-e ALLOW_EMPTY_PASSWORD=yes -e MARIADB_USER=my_user -e MARIADB_DATABASE=my_database -e MARIADB_PASSWORD=my_password `
docker.io/bitnami/mariadb:10.1-debian-10
```

Laravel Container with out Persistent Storage:
```bash
docker run -d --name laravel `
-p 3000:3000 `
--link mariadb `
-e DB_HOST=mariadb -e DB_USERNAME=my_user -e DB_DATABASE=my_database -e DB_PASSWORD=my_password `
docker.io/bitnami/laravel:7-debian-10
```

Laravel Container with Persistent Storage:
```bash
docker run -d --name laravel `
-p 3000:3000 `
--link mariadb `
-e DB_HOST=mariadb -e DB_USERNAME=my_user -e DB_DATABASE=my_database -e DB_PASSWORD=my_password `
-v laravel_app:/app `
docker.io/bitnami/laravel:7-debian-10
```

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

Example Laravel artisan commands:
```bash
docker exec -it laravel php artisan list

docker exec -it laravel composer require laravel/ui --dev

docker exec -it laravel php artisan ui:auth

docker exec -it laravel php artisan ui bootstrap --auth

docker exec -it laravel node -v
docker exec -it laravel npm -v 
```
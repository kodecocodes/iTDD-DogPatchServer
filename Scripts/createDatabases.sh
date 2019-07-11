docker run --name dog-patch -e POSTGRES_DB=dog-patch \
-e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password \
-p 5432:5432 -d postgres

docker run --name dog-patch-test -e POSTGRES_DB=dog-patch-test \
-e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password \
-p 5433:5432 -d postgres

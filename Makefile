all: clean html build image k8s

clean:
	git clean -xdf .

html:
	go run html.go

build:
	GOOS=linux GOARCH=amd64 go build kedu.go

image:
	docker build -t docker.io/thinpark/kedu:latest .
	docker push docker.io/thinpark/kedu:latest

k8s:
	kubectl delete all -l app=kedu
	kubectl create deployment kedu --image=thinpark/kedu --port=8080
	kubectl expose deployment/kedu --port=80 --target-port=8080

all: clean html docker k8s

clean:
	@git clean -xdf .

html:
	@go run html.go

docker:
	@docker build -t docker.io/thinpark/kedu:latest .
	@docker push docker.io/thinpark/kedu:latest

k8s:
	@kubectl delete all -l app=kedu
	@kubectl create deployment kedu --image=thinpark/kedu --port=8080
	@kubectl expose deployment/kedu --port=80 --target-port=8080

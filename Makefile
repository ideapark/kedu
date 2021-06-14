all: clean html linux/arm64 docker/arm64 k8s

clean:
	@git clean -xdf .

html:
	@go run html.go

linux/arm64:
	@GOOS=linux GOARCH=arm64 go build kedu.go

docker/arm64: clean html linux/arm64
	@docker build --platform linux/arm64 -t docker.io/thinpark/kedu:latest .
	@docker push docker.io/thinpark/kedu:latest

k8s:
	@kubectl delete all -l app=kedu
	@kubectl create deployment kedu --image=thinpark/kedu --port=8080
	@kubectl expose deployment/kedu --port=80 --target-port=8080

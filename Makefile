all: clean html kedu

html:
	@go run html.go

kedu:
	@go run kedu.go

linux/arm64:
	@go build kedu.go

clean:
	@git clean -xdf .

docker: clean html linux/arm64
	@docker build -t docker.io/thinpark/kedu:latest .
	@docker push docker.io/thinpark/kedu:latest

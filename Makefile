all: clean html kedu

html:
	@go run html.go

kedu:
	@go run kedu.go

build:
	@GOOS=linux GOARCH=amd64 go build kedu.go

clean:
	@git clean -xdf .

docker: clean html build
	@docker build -t docker.io/thinpark/kedu:latest .

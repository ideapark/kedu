all: clean html kedu

html:
	@go run html.go

kedu:
	@go run kedu.go

release:
	@go build kedu.go

clean:
	@git clean -xdf .

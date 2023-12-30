all: clean build image kubernetes

clean:
	git clean -xdf .

build:
	go generate
	GOOS=linux go build kedu.go

image:
	podman build -t docker.io/ideapark/kedu:latest .

kubernetes:
	kubectl delete all -l app=kedu
	kubectl create deployment kedu --image=ideapark/kedu:latest --port=8080
	kubectl expose deployment/kedu --port=80 --target-port=8080

package main

import (
	"embed"
	"fmt"
	"net/http"
)

//go:embed MOTTO
var motto string

//go:embed *.html
//go:embed */*.html
var htmlFS embed.FS

func main() {
	fmt.Println(motto)

	fmt.Println("server listenning on :8080")
	http.ListenAndServe(":8080", http.FileServer(http.FS(htmlFS)))
}

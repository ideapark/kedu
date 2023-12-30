//go:generate go run html.go
package main

import (
	"embed"
	"fmt"
	"net/http"
)

//go:embed MOTTO
var motto string

//go:embed *.png
//go:embed */*.png
//go:embed *.html
//go:embed */*.html
var webFS embed.FS

func main() {
	fmt.Println(motto)
	fmt.Println("kedu is serving on :8080")
	http.ListenAndServe(":8080", http.FileServer(http.FS(webFS)))
}

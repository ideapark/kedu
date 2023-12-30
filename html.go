package main

import (
	"embed"
	"fmt"
	"io/fs"
	"io/ioutil"
	"strings"

	"github.com/gomarkdown/markdown"
)

//go:embed index.md
//go:embed */*.md
var markdownFS embed.FS

func main() {
	fs.WalkDir(markdownFS, ".", func(markdownPath string, d fs.DirEntry, err error) error {
		if d.IsDir() {
			return nil
		}

		htmlPath := strings.TrimSuffix(markdownPath, ".md") + ".html"

		fmt.Printf("html: %s -> %s\n", markdownPath, htmlPath)

		markdownData, err := ioutil.ReadFile(markdownPath)
		if err != nil {
			return err
		}

		htmlData := markdown.ToHTML(markdownData, nil, nil)

		ioutil.WriteFile(htmlPath, htmlData, fs.ModePerm)

		return nil
	})
}

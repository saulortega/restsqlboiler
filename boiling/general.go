package boiling

import (
	"fmt"
	"log"
	"os"
	"strings"
	"text/template"
)

func WriteFiles(dir string, models []*Model) (int, int, error) {
	var ttl = len(models)
	var fls int

	//
	//rest_responses.go
	fileResponses, err := os.Create(dir + "rest_responses.go")
	if err != nil {
		return ttl, fls, err
	}

	defer fileResponses.Close()
	responses := template.Must(template.New("responses").Parse(tplResponses))
	err = responses.Execute(fileResponses, nil)
	if err != nil {
		return ttl, fls, err
	}

	//
	//rest_parsers.go
	fileParsers, err := os.Create(dir + "rest_parsers.go")
	if err != nil {
		return ttl, fls, err
	}

	defer fileParsers.Close()
	parsers := template.Must(template.New("parsers").Parse(tplParsers))
	err = parsers.Execute(fileParsers, nil)
	if err != nil {
		return ttl, fls, err
	}

	//
	//modelo_rest.go
	for _, m := range models {
		er := m.WriteTo(dir)
		if er != nil {
			err = er
			continue
		}

		fls++
	}

	if err != nil {
		log.Println(err)
	}

	return ttl, fls, err
}

func ReadDirAndWriteFiles(dir string) {
	dir = strings.TrimSpace(dir)
	dir = strings.TrimRight(dir, "/")
	dir = dir + "/"

	models, err := GetModelsFromDir(dir)
	if err != nil {
		log.Println("RESTSQLBoiler error:")
		panic(err)
		return
	}

	t, w, err := WriteFiles(dir, models)
	if err != nil {
		log.Println("RESTSQLBoiler error:")
		panic(err)
		return
	} else if t != w {
		log.Println(fmt.Sprintf("RESTSQLBoiler: %v of %v files written.", w, t))
		return
	}

	log.Println(fmt.Sprintf("RESTSQLBoiler: All %v files were written.", t))
}

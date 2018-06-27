package main

import (
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"regexp"
	"strings"
)

var (
	defaultInputDirSrc  = "/src/github.com/saulortega/restsqlboiler/templates"
	defaultOutputDirSrc = "/src/github.com/volatiletech/sqlboiler/templates"
	HomeDir             = strings.TrimRight(os.Getenv("HOME"), "/")
	GopathDir           = strings.TrimRight(os.Getenv("GOPATH"), "/")
	InputDir            = ""
	OutputDir           = ""
	Files               = 0
)

func main() {
	i := flag.String("i", "", "RESTSQLBoiler templates directory")
	o := flag.String("o", "", "SQLBoiler templates directory")
	flag.Parse()

	if len(*i) > 0 {
		InputDir = strings.TrimRight(*i, "/")
	} else {
		InputDir = defaultInputDir()
	}

	if len(*o) > 0 {
		OutputDir = strings.TrimRight(*o, "/")
	} else {
		OutputDir = defaultOutputDir()
	}

	if InputDir == "" || OutputDir == "" {
		if InputDir == "" {
			fmt.Println("* Enter the RESTSQLBoiler templates directory using the -i tag")
			fmt.Println("\tTipically it's /your/home/go" + defaultInputDirSrc)
		}
		if OutputDir == "" {
			fmt.Println("* Enter the SQLBoiler templates directory using the -o tag")
			fmt.Println("\tTipically it's /your/home/go" + defaultOutputDirSrc)
		}
		os.Exit(1)
	}

	if _, err := os.Stat(InputDir); os.IsNotExist(err) {
		fmt.Println("The RESTSQLBoiler templates directory not exists [" + InputDir + "]")
		fmt.Println("\tBe sure to enter it correctly using the -i tag")
		os.Exit(1)
	}

	if _, err := os.Stat(OutputDir); os.IsNotExist(err) {
		fmt.Println("The SQLBoiler templates directory not exists [" + OutputDir + "]")
		fmt.Println("\tBe sure to enter it correctly using the -o tag")
		os.Exit(1)
	}

	ReadDirAndCopyFiles(InputDir, OutputDir)

	if Files == 0 {
		fmt.Println("No files found")
		os.Exit(1)
	}

	fmt.Println("Done:", Files, "files copied.")
	os.Exit(0)
}

func defaultInputDir() string {
	return defaultDir(defaultInputDirSrc)
}

func defaultOutputDir() string {
	return defaultDir(defaultOutputDirSrc)
}

func defaultDir(d string) string {
	var dir string

	if len(HomeDir) > 1 {
		dir = HomeDir + "/go" + d
	} else if len(GopathDir) > 1 {
		dir = GopathDir + d
	}

	return dir
}

func CopyFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()

	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, in)
	if err != nil {
		return err
	}
	return out.Close()
}

func ReadDirAndCopyFiles(src, dst string) {
	files, err := ioutil.ReadDir(src)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	var dottpl = regexp.MustCompile(`.tpl$`)

	for _, file := range files {
		name := file.Name()
		fullSrcName := src + "/" + name
		fullDstName := dst + "/" + name

		if file.IsDir() {
			if _, err = os.Stat(fullDstName); os.IsNotExist(err) {
				os.Mkdir(fullDstName, os.ModePerm)
			}

			ReadDirAndCopyFiles(fullSrcName, fullDstName)
		} else {
			if !dottpl.MatchString(name) {
				fmt.Println("Skipped:", fullSrcName)
				continue
			}

			err = CopyFile(fullSrcName, fullDstName)
			if err != nil {
				fmt.Println("Error copying file «" + name + "» to " + dst)
				fmt.Println(err)
				os.Exit(1)
			}

			fmt.Println("Copied:", fullDstName)
			Files += 1
		}
	}
}

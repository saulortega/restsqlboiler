package main

import (
	"flag"
	"fmt"
	"github.com/saulortega/restsqlboiler/boiling"
)

func main() {
	d := flag.String("d", "", "Directorio")
	flag.Parse()

	if len(*d) > 0 {
		boiling.ReadDirAndWriteFiles(*d)
	} else {
		fmt.Println("Usage:")
		fmt.Println("\trestsqlboiler -d /path/to/sqlboiler/models")
	}
}

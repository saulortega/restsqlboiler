package boiling

import (
	"errors"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"text/template"
)

type Model struct {
	RawType      []byte //Contine resultaado ya filtrado de regexp.MustCompile(`(?ms)^type .+? struct \{.+?\tR \*.+?\tL .+?^\}`).Find(arch)
	RawFunc      []byte
	FileName     string
	SingularName string
	PluralName   string
	LowerName    string
	Fields       []Col
	Imports      []string
	HasUpdatedAt bool
	HasDeletedAt bool
}

type Col struct {
	JSON string
	Boil string
	Name string
	Type string
}

func GetModelsFromDir(dir string) ([]*Model, error) {
	var models = []*Model{}

	files, err := ioutil.ReadDir(dir)
	if err != nil {
		log.Println(err)
		return models, err
	}

	var restgo = regexp.MustCompile(`_rest\.go$`)
	var testgo = regexp.MustCompile(`_test\.go$`)
	var boil = regexp.MustCompile(`^boil_`)
	var rest = regexp.MustCompile(`^rest_`)
	var tgo = regexp.MustCompile(`\.go$`)

	for _, f := range files {
		if restgo.MatchString(f.Name()) || testgo.MatchString(f.Name()) || boil.MatchString(f.Name()) || rest.MatchString(f.Name()) || !tgo.MatchString(f.Name()) {
			continue
		}

		var M, er = NewModelFromFile(dir + f.Name())
		if er != nil {
			err = er
			break
		}

		models = append(models, M)
	}

	return models, err
}

func NewModelFromFile(file string) (*Model, error) {
	var M = new(Model)

	arch, err := ioutil.ReadFile(file)
	if err != nil {
		log.Println(err)
		return M, err
	}

	M.RawType = regexp.MustCompile(`(?ms)^type .+? struct \{.+?\tR \*.+?\tL .+?^\}`).Find(arch)
	M.RawFunc = regexp.MustCompile(`(?ms)^func ([A-Za-z]+?)\(exec boil\.Executor, mods \.\.\.qm\.QueryMod\) .+? \{.+?^\tmods = append\(mods, qm\.From\("\\"(.+?)\\""\)\).+?^\treturn .+?Query\{NewQuery\(exec, mods\.\.\.\)\}.+?^\}`).Find(arch)
	M.FileName = regexp.MustCompile(`\.go$`).ReplaceAllString(filepath.Base(file), "")

	err = M.buildAllFromRaw()
	if err != nil {
		log.Println("Error on file «" + file + "»:")
		log.Println("\t", err)
	}

	return M, err
}

func (m *Model) WriteTo(dir string) error {
	if m.FileName != "employees" && m.FileName != "dispatches_statuses" && m.FileName != "employee_positions" && !regexp.MustCompile(`^vehicle`).MatchString(m.FileName) && m.FileName != "schedules" && m.FileName != "shifts" && m.FileName != "identification_types" && m.FileName != "service_categories" && m.FileName != "geometry_categories" && m.FileName != "geometry_groups" && m.FileName != "service_types" && m.FileName != "devices" && m.FileName != "geometries" && m.FileName != "dispatches" && m.FileName != "users" && m.FileName != "assets" && m.FileName != "asset_properties" && m.FileName != "asset_categories" && m.FileName != "asset_category_properties" && m.FileName != "asset_category_issues" && m.FileName != "asset_supervisions" && m.FileName != "asset_maintenances" /*&& m.FileName != "asset_supervision_issues"*/ {
		return nil // ----------------- pruebas ------------------------------- quitar esto _------------------------------
	}

	fileObj, err := os.Create(dir + m.FileName + "_rest.go")
	if err != nil {
		return err
	}

	defer fileObj.Close()

	tpltObj := template.Must(template.New("obj").Parse(tplMain))
	err = tpltObj.Execute(fileObj, m)
	if err != nil {
		return err
	}

	return nil
}

func (m *Model) buildAllFromRaw() error {
	err := m.buildNames()
	if err == nil {
		err = m.buildFields()
		//if err == nil {
		//	err = m.buildImports()
		//}
	}

	if err != nil {
		log.Println(err)
	}

	return err
}

func (m *Model) buildNames() error {
	var encS = regexp.MustCompile(`^type ([A-Za-z]+?) struct \{`).FindSubmatch(m.RawType)
	if encS == nil || len(encS) != 2 {
		return errors.New("hfoa8473o3r")
	}

	m.SingularName = string(encS[1])

	var encP = regexp.MustCompile(`^func ([A-Za-z]+?)\(exec boil\.Executor`).FindSubmatch(m.RawFunc)
	if encP == nil || len(encP) != 2 {
		return errors.New("iyutsad98034h")
	}

	m.PluralName = string(encP[1])

	var encL = regexp.MustCompile(`\tR\s+?\*([a-z][A-Za-z]+?)R `).FindSubmatch(m.RawType)
	if encL == nil || len(encL) != 2 {
		return errors.New("oujusdy78ewn")
	}

	m.LowerName = string(encL[1])

	return nil
}

func (m *Model) buildFields() error {
	var pdzs = strings.Split(string(m.RawType), "\n")
	var mImptrs = map[string]bool{}
	m.Imports = []string{}
	m.Fields = []Col{}
	var err error

	for i, l := range pdzs {
		if i == 0 {
			continue
		}

		t := regexp.MustCompile("`").ReplaceAllString(l, "")
		t = regexp.MustCompile(`\s+`).ReplaceAllString(t, " ")
		t = regexp.MustCompile(`^\s`).ReplaceAllString(t, "")
		pds := strings.Split(t, " ")
		if t == "" {
			continue
		}
		if pds[0] == "R" {
			break
		}
		if len(pds) < 4 {
			err = errors.New("dsjgf874fdsf")
			break
		}
		if !regexp.MustCompile(`^boil:`).MatchString(pds[2]) {
			err = errors.New("zsfbrytiurte")
			break
		}

		if !regexp.MustCompile(`^json:`).MatchString(pds[3]) {
			err = errors.New("j455rdjyt")
			break
		}

		var col = Col{}
		col.Name = pds[0]
		col.Type = pds[1]
		col.Boil = strings.Trim(regexp.MustCompile(`^boil:`).ReplaceAllString(pds[2], ""), "\"")
		col.JSON = strings.Trim(regexp.MustCompile(`^json:`).ReplaceAllString(pds[3], ""), "\"")
		col.JSON = strings.Split(col.JSON, ",")[0]

		if col.Name == "UpdatedAt" {
			m.HasUpdatedAt = true
		} else if col.Name == "DeletedAt" {
			m.HasDeletedAt = true
			mImptrs["\"time\""] = true
			mImptrs["\"gopkg.in/volatiletech/null.v6\""] = true
		}

		m.Fields = append(m.Fields, col)
	}

	for imprt := range mImptrs {
		m.Imports = append(m.Imports, imprt)
	}

	return err
}

/*func (m *Model) buildImports() error {
	var mImptrs = map[string]bool{}
	m.Imports = []string{}
	var err error

	for _, f := range m.Fields {
		if f.Type == "string" {
			continue
		}

		if f.Type == "int64" || f.Type == "bool" || f.Type == "float64" {
			mImptrs["\"strconv\""] = true
		} else if f.Type == "time.Time" {
			mImptrs["\"time\""] = true
		} else if f.Type == "null.Time" || f.Type == "null.Int" || f.Type == "null.Int64" || f.Type == "null.Float64" || f.Type == "null.Bool" || f.Type == "null.String" {
			mImptrs["\"gopkg.in/volatiletech/null.v6\""] = true
		} else {
			err = errors.New("unsupported type: «" + f.Type + "»")
			break
		}
	}

	for imprt := range mImptrs {
		m.Imports = append(m.Imports, imprt)
	}

	return err
}*/

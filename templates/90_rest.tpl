{{- $dot := . -}}
{{- $modelName := .Table.Name | singular | titleCase -}}
{{- $varNameSingular := .Table.Name | singular | camelCase -}}

var OmitFieldsOnBuilding{{$modelName}} = []string{}

var Validate{{$modelName}} = func(boil.Executor, *{{$modelName}}) error {
	return nil
}

var Validate{{$modelName}}OnUpdate = func(boil.Executor, *{{$modelName}}) error {
	return nil
}

var Validate{{$modelName}}OnInsert = func(boil.Executor, *{{$modelName}}) error {
	return nil
}

var Build{{$modelName}} = func(boil.Executor, *{{$modelName}}, *http.Request) error {
	return nil
}

var AfterUpdate{{$modelName}} = func(boil.Transactor, *{{$modelName}}, *http.Request) error {
	return nil
}

var AfterInsert{{$modelName}} = func(boil.Transactor, *{{$modelName}}, *http.Request) error {
	return nil
}

var Rebuild{{$modelName}}OnFind = func(exec boil.Executor, Obj *{{$modelName}}) (interface{}, error) {
	return interface{}(Obj), nil
}



func (o *{{$modelName}}) BuildFromForm(exec boil.Executor, r *http.Request) error {
	var err error

	{{range $column := .Table.Columns }}
	{{- if eq (titleCase $column.Name) "ID" "CreatedAt" "UpdatedAt" "DeletedAt"}}
	{{- else -}}
	{{- if eq $column.Type "string" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}} = r.FormValue("{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
	}
	{{else if eq $column.Type "bool" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}}, err = parseBoolFromForm(r, "{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$varNameSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "int" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}}, err = parseIntFromForm(r, "{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$varNameSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "int64" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}}, err = parseInt64FromForm(r, "{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$varNameSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "float64" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}}, err = parseFloat64FromForm(r, "{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$varNameSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "time.Time" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}}, err = parseTimeFromForm(r, "{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$varNameSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.String" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}} = parseNullStringFromForm(r, "{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
	}
	{{else if eq $column.Type "null.Bool" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}}, err = parseNullBoolFromForm(r, "{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Int" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}}, err = parseNullIntFromForm(r, "{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Int64" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}}, err = parseNullInt64FromForm(r, "{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Float64" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}}, err = parseNullFloat64FromForm(r, "{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Time" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$modelName}}){
		o.{{titleCase $column.Name}}, err = parseNullTimeFromForm(r, "{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{end -}}
	{{end -}}
	{{end}}

	return Build{{$modelName}}(exec, o, r)
}
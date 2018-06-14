
{{$modelName := .Table.Name | singular | titleCase -}}
{{- $varNameSingular := .Table.Name | singular | camelCase -}}

func DeleteAndResponse{{$modelName}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	if in("deleted_at", {{$varNameSingular}}Columns){
		SoftDeleteAndResponse{{$modelName}}(exec, w, r)
	} else {
		HardDeleteAndResponse{{$modelName}}(exec, w, r)
	}
}

func SoftDeleteAndResponse{{$modelName}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$modelName}})
	var err error
	var id int64

	id, err = GetIDFromURL(r)
	if err != nil || id == 0 {
		ResponseNoID(w)
		return
	}

	Obj, err = Find{{$modelName}}(exec, id)
	if err != nil {
		ResponseFindError(w, id, err)
		return
	}

	// Esto es un poco rebuscado, mejorarlo... ----------------------------------------- pendiente, revisar .tpl -----------------------------------------
	{{range $column := .Table.Columns -}}
	{{- if eq (titleCase $column.Name) "DeletedAt" -}}
	Obj.DeletedAt = null.NewTime(time.Now(), true)
	err = Obj.Update(exec, "deleted_at")
	if err != nil {
		ResponseInternalServerError(w, err, "4872")
		return
	}
	{{end -}}
	{{end -}}

	w.Header().Set("X-Id", fmt.Sprintf("%v", Obj.ID))
	w.WriteHeader(http.StatusOK)
}

func HardDeleteAndResponse{{$modelName}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$modelName}})
	var err error
	var id int64

	id, err = GetIDFromURL(r)
	if err != nil || id == 0 {
		ResponseNoID(w)
		return
	}

	Obj, err = Find{{$modelName}}(exec, id)
	if err != nil {
		ResponseFindError(w, id, err)
		return
	}

	err = Obj.Delete(exec)
	if err != nil {
		ResponseInternalServerError(w, err, "6921")
		return
	}

	w.Header().Set("X-Id", fmt.Sprintf("%v", Obj.ID))
	w.WriteHeader(http.StatusOK)
}

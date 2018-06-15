
{{$modelName := .Table.Name | singular | titleCase -}}
{{- $hasDeletedAt := setInclude "deleted_at" (columnNames .Table.Columns) -}}
{{- $varNameSingular := .Table.Name | singular | camelCase -}}

func DeleteAndResponse{{$modelName}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	{{if $hasDeletedAt -}}
		SoftDeleteAndResponse{{$modelName}}(exec, w, r)
	{{- else -}}
		HardDeleteAndResponse{{$modelName}}(exec, w, r)
	{{- end -}}
}

{{if $hasDeletedAt -}}
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

	Obj.DeletedAt = null.NewTime(time.Now(), true)
	err = Obj.Update(exec, "deleted_at")
	if err != nil {
		ResponseInternalServerError(w, err, "4872")
		return
	}

	w.Header().Set("X-Id", fmt.Sprintf("%v", Obj.ID))
	w.WriteHeader(http.StatusOK)
}
{{- end}}

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

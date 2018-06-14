{{- $modelName := .Table.Name | singular | titleCase -}}

// FindAndResponse{{$modelName}} retrieves and write to http.ResponseWriter a single record by ID obtained from Request URL.
func FindAndResponse{{$modelName}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var obj = new({{$modelName}})
	var Obj interface{}
	var err error
	var id int64

	id, err = GetIDFromURL(r)
	if err != nil || id == 0 {
		ResponseNoID(w)
		return
	}

	obj, err = Find{{$modelName}}(exec, id)
	if err != nil {
		ResponseFindError(w, id, err)
		return
	}

	Obj, err = Rebuild{{$modelName}}OnFind(exec, obj)
	if err != nil {
		ResponseFindError(w, id, err)
		return
	}

	ResponseFindSuccess(w, id, Obj)
}

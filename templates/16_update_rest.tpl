
{{$modelName := .Table.Name | singular | titleCase -}}

func UpdateAndResponse{{$modelName}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$modelName}})
	var TX = new(sql.Tx)
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

	err = Obj.BuildFromForm(exec, r)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	err = Validate{{$modelName}}(exec, Obj)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	err = Validate{{$modelName}}OnUpdate(exec, Obj)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	TX, err = exec.(*sql.DB).Begin()
	if err != nil {
		ResponseInternalServerError(w, err, "2926")
		return
	}

	err = Obj.Update(TX)
	if err != nil {
		ResponseInternalServerError(w, err, "8252")
		TX.Rollback()
		return
	}

	err = AfterUpdate{{$modelName}}(TX, Obj, r)
	if err != nil {
		ResponseInternalServerError(w, err, "3076")
		TX.Rollback()
		return
	}

	err = TX.Commit()
	if err != nil {
		ResponseInternalServerError(w, err, "0363")
		return
	}

	w.Header().Set("X-Id", fmt.Sprintf("%v", Obj.ID))
	w.WriteHeader(http.StatusOK)
}







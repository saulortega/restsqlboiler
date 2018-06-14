
{{$modelName := .Table.Name | singular | titleCase -}}

func InsertAndResponse{{$modelName}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$modelName}})
	var TX = new(sql.Tx)
	var err error

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

	err = Validate{{$modelName}}OnInsert(exec, Obj)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	TX, err = exec.(*sql.DB).Begin()
	if err != nil {
		ResponseInternalServerError(w, err, "6120")
		return
	}

	err = Obj.Insert(TX)
	if err != nil {
		ResponseInternalServerError(w, err, "3984")
		TX.Rollback()
		return
	}

	err = AfterInsert{{$modelName}}(TX, Obj, r)
	if err != nil {
		ResponseInternalServerError(w, err, "9172")
		TX.Rollback()
		return
	}

	err = TX.Commit()
	if err != nil {
		ResponseInternalServerError(w, err, "2074")
		return
	}

	w.Header().Set("X-Id", fmt.Sprintf("%v", Obj.ID))
	w.WriteHeader(http.StatusCreated)
}


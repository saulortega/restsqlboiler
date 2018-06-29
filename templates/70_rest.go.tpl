


{{- $model := .Aliases.Table .Table.Name -}}
{{- $hasDeletedAt := setInclude "deleted_at" (columnNames .Table.Columns) -}}




// ---------- hasta aquí las variables nuevas definitivas ----------------



/*

--------- ANTES:::

{{/*

type {{$modelNameCamel}}R struct {
	{{range .Table.FKeys -}}
	{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
	{{$txt.Function.Name}} *{{$txt.ForeignTable.NameGo}}
	{{end -}}

	{{range .Table.ToOneRelationships -}}
	{{- $txt := txtsFromOneToOne $dot.Tables $dot.Table . -}}
	{{$txt.Function.Name}} *{{$txt.ForeignTable.NameGo}}
	{{end -}}

	{{range .Table.ToManyRelationships -}}
	{{- $txt := txtsFromToMany $dot.Tables $dot.Table . -}}
	{{$txt.Function.Name}} {{$txt.ForeignTable.Slice}}
	{{end -}}
//
}


----------- DESPUES:::



{{- $alias := .Aliases.Table .Table.Name -}}
// {{$alias.DownSingular}}R is where relationships are stored.
type {{$alias.DownSingular}}R struct {
	{{range .Table.FKeys -}}
	{{- $ftable := $.Aliases.Table .ForeignTable -}}
	{{- $relAlias := $alias.Relationship .Name -}}
	{{$relAlias.Foreign}} *{{$ftable.UpSingular}}
	{{end -}}

	{{range .Table.ToOneRelationships -}}
	{{- $ftable := $.Aliases.Table .ForeignTable -}}
	{{- $relAlias := $ftable.Relationship .Name -}}
	{{$relAlias.Local}} *{{$ftable.UpSingular}}
	{{end -}}

	{{range .Table.ToManyRelationships -}}
	{{- $ftable := $.Aliases.Table .ForeignTable -}}
	{{- $relAlias := $.Aliases.ManyRelationship .ForeignTable .Name .JoinTable .JoinLocalFKeyName -}}
	{{$relAlias.Local}} {{printf "%sSlice" $ftable.UpSingular}}
	{{end -}}
	//
}


---------------------------------------------------

MAS SIMPÑLIFICADO::::::

ANTES::::

{{range .Table.FKeys -}}
{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
{{$txt.Function.Name}} *{{$txt.ForeignTable.NameGo}}
{{end -}}


DESPUES:::

{{range .Table.FKeys -}}
{{- $ftable := $.Aliases.Table .ForeignTable -}}
{{- $relAlias := $alias.Relationship .Name -}}
{{$relAlias.Foreign}} *{{$ftable.UpSingular}}
{{end -}}


*/}}

*/




// ---------------------------------------------------------


var OmitFieldsOnBuilding{{$model.UpSingular}} = []string{}

var Validate{{$model.UpSingular}} = func(boil.Executor, *{{$model.UpSingular}}) error {
	return nil
}

var Validate{{$model.UpSingular}}OnUpdate = func(boil.Executor, *{{$model.UpSingular}}) error {
	return nil
}

var Validate{{$model.UpSingular}}OnInsert = func(boil.Executor, *{{$model.UpSingular}}) error {
	return nil
}

var Build{{$model.UpSingular}} = func(boil.Executor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var Build{{$model.UpSingular}}OnUpdate = func(boil.Executor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var Build{{$model.UpSingular}}OnInsert = func(boil.Executor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var AfterUpdate{{$model.UpSingular}} = func(boil.Transactor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var AfterInsert{{$model.UpSingular}} = func(boil.Transactor, *{{$model.UpSingular}}, *http.Request) error {
	return nil
}

var Rebuild{{$model.UpSingular}}OnFind = func(exec boil.Executor, Obj *{{$model.UpSingular}}) (interface{}, error) {
	return interface{}(Obj), nil
}


//
//
//
//
//
//




// FindAndResponse{{$model.UpSingular}} retrieves and write to http.ResponseWriter a single record by ID obtained from Request URL.
func FindAndResponse{{$model.UpSingular}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var obj = new({{$model.UpSingular}})
	var Obj interface{}
	var err error
	var id int64

	id, err = GetIDFromURL(r)
	if err != nil || id == 0 {
		ResponseNoID(w)
		return
	}

	obj, err = Find{{$model.UpSingular}}(exec, id)
	if err != nil {
		ResponseFindError(w, id, err)
		return
	}

	Obj, err = Rebuild{{$model.UpSingular}}OnFind(exec, obj)
	if err != nil {
		ResponseFindError(w, id, err)
		return
	}

	ResponseFindSuccess(w, id, Obj)
}



func InsertAndResponse{{$model.UpSingular}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var TX = new(sql.Tx)
	var err error

	err = Obj.BuildFromForm(exec, r)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	err = Build{{$model.UpSingular}}OnInsert(exec, Obj, r)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	err = Validate{{$model.UpSingular}}(exec, Obj)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	err = Validate{{$model.UpSingular}}OnInsert(exec, Obj)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	TX, err = exec.(*sql.DB).Begin()
	if err != nil {
		ResponseInternalServerError(w, err, "6120")
		return
	}

	err = Obj.Insert(TX, boil.Infer()) // ---------------------------- pendiente ver si agregar lista blanca en vez del Infer -----------------------------
	if err != nil {
		ResponseInternalServerError(w, err, "3984")
		TX.Rollback()
		return
	}

	err = AfterInsert{{$model.UpSingular}}(TX, Obj, r)
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



func UpdateAndResponse{{$model.UpSingular}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var TX = new(sql.Tx)
	var err error
	var id int64

	id, err = GetIDFromURL(r)
	if err != nil || id == 0 {
		ResponseNoID(w)
		return
	}

	Obj, err = Find{{$model.UpSingular}}(exec, id)
	if err != nil {
		ResponseFindError(w, id, err)
		return
	}

	err = Obj.BuildFromForm(exec, r)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	err = Build{{$model.UpSingular}}OnUpdate(exec, Obj, r)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	err = Validate{{$model.UpSingular}}(exec, Obj)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	err = Validate{{$model.UpSingular}}OnUpdate(exec, Obj)
	if err != nil {
		ResponseBadRequest(w, err)
		return
	}

	TX, err = exec.(*sql.DB).Begin()
	if err != nil {
		ResponseInternalServerError(w, err, "2926")
		return
	}

	_, err = Obj.Update(TX, boil.Infer()) // ---------------------------- pendiente ver si agregar lista blanca en vez del Infer -----------------------------
	if err != nil {
		ResponseInternalServerError(w, err, "8252")
		TX.Rollback()
		return
	}

	err = AfterUpdate{{$model.UpSingular}}(TX, Obj, r)
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

func DeleteAndResponse{{$model.UpSingular}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	{{if $hasDeletedAt -}}
		SoftDeleteAndResponse{{$model.UpSingular}}(exec, w, r)
	{{- else -}}
		HardDeleteAndResponse{{$model.UpSingular}}(exec, w, r)
	{{- end -}}
}

{{if $hasDeletedAt -}}
func SoftDeleteAndResponse{{$model.UpSingular}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var err error
	var id int64

	id, err = GetIDFromURL(r)
	if err != nil || id == 0 {
		ResponseNoID(w)
		return
	}

	Obj, err = Find{{$model.UpSingular}}(exec, id)
	if err != nil {
		ResponseFindError(w, id, err)
		return
	}

	Obj.DeletedAt = null.NewTime(time.Now(), true)
	_, err = Obj.Update(exec, boil.Whitelist("deleted_at"))
	if err != nil {
		ResponseInternalServerError(w, err, "4872")
		return
	}

	w.Header().Set("X-Id", fmt.Sprintf("%v", Obj.ID))
	w.WriteHeader(http.StatusOK)
}
{{- end}}

func HardDeleteAndResponse{{$model.UpSingular}}(exec boil.Executor, w http.ResponseWriter, r *http.Request) {
	var Obj = new({{$model.UpSingular}})
	var err error
	var id int64

	id, err = GetIDFromURL(r)
	if err != nil || id == 0 {
		ResponseNoID(w)
		return
	}

	Obj, err = Find{{$model.UpSingular}}(exec, id)
	if err != nil {
		ResponseFindError(w, id, err)
		return
	}

	_, err = Obj.Delete(exec)
	if err != nil {
		ResponseInternalServerError(w, err, "6921")
		return
	}

	w.Header().Set("X-Id", fmt.Sprintf("%v", Obj.ID))
	w.WriteHeader(http.StatusOK)
}


//
//
//


func (o *{{$model.UpSingular}}) BuildFromForm(exec boil.Executor, r *http.Request) error {
	var err error

	{{range $column := .Table.Columns }}
	{{- if eq (titleCase $column.Name) "ID" "CreatedAt" "UpdatedAt" "DeletedAt"}}
	{{- else -}}
	{{- if eq $column.Type "string" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}} = r.FormValue("{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
	}
	{{else if eq $column.Type "bool" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseBoolFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "int" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseIntFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "int64" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseInt64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "float64" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseFloat64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "time.Time" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseTimeFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}", !in("{{$column.Name}}", {{$model.DownSingular}}ColumnsWithDefault))
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.String" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}} = parseNullStringFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
	}
	{{else if eq $column.Type "null.Bool" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseNullBoolFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Int" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseNullIntFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Int64" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseNullInt64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Float64" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseNullFloat64FromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{else if eq $column.Type "null.Time" -}}
	if !in("{{$column.Name}}", OmitFieldsOnBuilding{{$model.UpSingular}}){
		o.{{titleCase $column.Name}}, err = parseNullTimeFromForm(r, "{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}")
		if err != nil {
			return err
		}
	}
	{{end -}}
	{{end -}}
	{{end}}

	{{/* Necesario en caso de que arriba sólo haya opciones sin retorno de errores */}}
	if err != nil {
		return err
	}

	return Build{{$model.UpSingular}}(exec, o, r)
}



{{range .Table.FKeys -}}

func Build{{$model.UpPlural}}With{{titleCase .Column}}sFromPostForm(r *http.Request, keys ...string) ([]*{{$model.UpSingular}}, error) {
	var objs = []*{{$model.UpSingular}}{}
	var key = "{{.Column}}"
	if len(keys) > 0 {
		key = keys[0]
	}

	{{if .Nullable -}}
	ids, err := NullIDsFromPostForm(r, key)
	{{- else -}}
	ids, err := IDsFromPostForm(r, key)
	{{- end}}
	if err != nil {
		return objs, err
	}

	objs = Build{{$model.UpPlural}}With{{titleCase .Column}}s(ids)

	return objs, nil
}

func Build{{$model.UpPlural}}With{{titleCase .Column}}s(ids []{{if .Nullable}}null.Int64{{else}}int64{{end}}) []*{{$model.UpSingular}} {
	var objs = []*{{$model.UpSingular}}{}

	for _, id := range ids {
		obj := new({{$model.UpSingular}})
		obj.{{titleCase .Column}} = id
		objs = append(objs, obj)
	}

	return objs
}

{{end}}






/*


//
//
// Empieza plantilla modal...
//
//


<template>

	<div class="modal fade modal-xs" id="Modal{{$model.UpSingular}}" tabindex="-1" role="dialog" aria-labelledby="" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">

				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">
						&times;
					</button>
					<h4 v-if="id"><strong>Editing {{$model.UpSingular}} <em>«{{`{{ id }}`}}»</em></strong></h4>
					<h4 v-else>Create new {{$model.UpSingular}}</h4>
				</div>

				<div class="modal-body">
					<child
					ref="{{$model.UpSingular}}"
					@get="onGet"
					@edit="onEdit"
					@create="onCreate"
					@delete="onDelete"
					@data-id="id = $event"
					@getting="getting = $event"
					@editing="editing = $event"
					@creating="creating = $event"
					@deleting="deleting = $event"></child>
					<!--
					@created="console.log('mmmmmm')" ==> componente, no el dato del hijo...
					@mounted="console.log('mmmmmm')" ==> componente, no el dato del hijo...
					-->
				</div>

				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">
						Cancel
					</button>
					<button type="button" class="btn btn-primary" v-if="!id" v-on:click="create" :disabled="creating">
						Create {{$model.UpSingular}}
					</button>
					<button type="button" class="btn btn-primary" v-if="id" v-on:click="edit" :disabled="editing">
						Save {{$model.UpSingular}}
					</button>
				</div>

			</div>
		</div><!-- /.modal-dialog -->
	</div>

</template>



<script>
	var opcns = {
		data: function () {
			return {
				id: '',
				getting: false,
				editing: false,
				creating: false,
				deleting: false,
			}
		},
		components: {
			'child': ObtnCpnt('{{.Table.Name | singular}}'),
		},
		mounted: function(){
			//
		},
		methods: {
			new: function(){
				this.$refs.{{$model.UpSingular}}.clean()
				$('#Modal{{$model.UpSingular}}').modal('show')
			},
			get: function(id){
				this.$refs.{{$model.UpSingular}}.get(id)
			},
			edit: function(){
				this.$refs.{{$model.UpSingular}}.edit()
			},
			create: function(){
				this.$refs.{{$model.UpSingular}}.create()
			},
			onGet: function(ok, data){
				if(ok){
					$('#Modal{{$model.UpSingular}}').modal('show')
				}
				this.$emit('get', ok, data)
			},
			onEdit: function(ok, data){
				if(ok){
					$('#Modal{{$model.UpSingular}}').modal('hide')
				}
				this.$emit('edit', ok, data)
			},
			onCreate: function(ok, data){
				if(ok){
					$('#Modal{{$model.UpSingular}}').modal('hide')
				}
				this.$emit('create', ok, data)
			},
			onDelete: function(ok, data){
				this.$emit('delete', ok, data)
			},
		},
	}

</script>





//
//
// Empieza plantilla genérica vacía...
//
//



<template>

	<div>
		<div class="row">
			<div class="col-xs-12 col-xs-12">
				<div class="form-group">
					<label> ooooooooooooooooooooo: </label>
					<select class="form-control" v-model="Data.ooooooooooooooooooooo">
						<option></option>
						<option v-for="{{`e in $root.Recursos.ooooooooooooooooooooo`}}" v-if="{{`e.enabled`}}" :value="{{`e.id`}}">{{`{{e.description}}`}}</option>
					</select>
				</div>
			</div>
			<div class="col-xs-12 col-xs-12">
				<div class="form-group">
					<label> ooooooooooooooooooooo </label>
					<input type="text" class="form-control" v-model="Data.ooooooooooooooooooooo" maxlength="100" placeholder="ooooooooooooooooooooo" required>
				</div>
			</div>
		</div>
	</div>

</template>


<script>
	var opcns = {
		data: function () {
			return {}
		},
		mixins: [Mixin{{$model.UpSingular}}],
		mounted: function(){
			//
		},
		methods: {
			//
		},
	}

</script>




*/


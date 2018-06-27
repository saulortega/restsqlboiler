


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

// ---

*/}}

----------- DESPUES:::


{{/*

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

// --

*/}}



{{/*

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



// --------------------- hasta aquí, pruebas  ---------------------------




// ---------------------------------------------------------

{{- $dot := . -}}
{{- $modelName := .Table.Name | singular | titleCase -}}
{{- $modelNamePlural := .Table.Name | plural | titleCase -}}
{{- $varNameSingular := .Table.Name | singular | camelCase -}}
{{- $alias := .Aliases.Table .Table.Name -}}  {{/*                  -------------- esta reemplazará a algunas de las anteriors ----------------- */}}

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

var Build{{$modelName}}OnUpdate = func(boil.Executor, *{{$modelName}}, *http.Request) error {
	return nil
}

var Build{{$modelName}}OnInsert = func(boil.Executor, *{{$modelName}}, *http.Request) error {
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


//
//
//
//
//
//




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

	err = Build{{$modelName}}OnInsert(exec, Obj, r)
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

	err = Obj.Insert(TX, boil.Infer()) // ---------------------------- pendiente ver si agregar lista blanca en vez del Infer -----------------------------
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

	err = Build{{$modelName}}OnUpdate(exec, Obj, r)
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

	_, err = Obj.Update(TX, boil.Infer()) // ---------------------------- pendiente ver si agregar lista blanca en vez del Infer -----------------------------
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
	_, err = Obj.Update(exec, boil.Whitelist("deleted_at"))
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

	{{/* Necesario en caso de que arriba sólo haya opciones sin retorno de errores */}}
	if err != nil {
		return err
	}

	return Build{{$modelName}}(exec, o, r)
}



{{range .Table.FKeys -}}
{{/* {{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}  ------------- quitar esto ------------- */}}



// ------ pruebas -----


{{- $ftable := $.Aliases.Table .ForeignTable -}}
{{- $relAlias := $alias.Relationship .Name -}}

// $ftable =============:: {{$ftable}}
// $relAlias =============:: {{$relAlias}}


{{/*

antes::::::::::::::::::

{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
{{$txt.Function.Name}} *{{$txt.ForeignTable.NameGo}}

despues ::::::::::::::::::::

{{- $ftable := $.Aliases.Table .ForeignTable -}}
{{- $relAlias := $alias.Relationship .Name -}}
{{$relAlias.Foreign}} *{{$ftable.UpSingular}}





func Build{{$modelNamePlural}}With{{$txt.LocalTable.ColumnNameGo}}sFromPostForm(r *http.Request, keys ...string) ([]*{{$modelName}}, error) {
	var objs = []*{{$modelName}}{}
	var key = "{{$txt.ForeignKey.Column}}"
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

	objs = Build{{$modelNamePlural}}With{{$txt.LocalTable.ColumnNameGo}}s(ids)

	return objs, nil
}


func Build{{$modelNamePlural}}With{{$txt.LocalTable.ColumnNameGo}}s(ids []{{if .Nullable}}null.Int64{{else}}int64{{end}}) []*{{$modelName}} {
	var objs = []*{{$modelName}}{}

	for _, id := range ids {
		obj := new({{$modelName}})
		obj.{{$txt.LocalTable.ColumnNameGo}} = id
		objs = append(objs, obj)
	}

	return objs
}

*/}}

{{end}}



// ////////////////// -------------- pendiente borrar lo que no sea 70 y 000 -------------------------





/*


//
//
// Empieza plantilla modal...
//
//


<template>

	<div class="modal fade modal-xs" id="Modal{{$modelName}}" tabindex="-1" role="dialog" aria-labelledby="" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">

				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">
						&times;
					</button>
					<h4 v-if="id"><strong>Editing {{$modelName}} <em>«{{`{{ id }}`}}»</em></strong></h4>
					<h4 v-else>Create new {{$modelName}}</h4>
				</div>

				<div class="modal-body">
					<child
					ref="{{$modelName}}"
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
						Create {{$modelName}}
					</button>
					<button type="button" class="btn btn-primary" v-if="id" v-on:click="edit" :disabled="editing">
						Save {{$modelName}}
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
				this.$refs.{{$modelName}}.clean()
				$('#Modal{{$modelName}}').modal('show')
			},
			get: function(id){
				this.$refs.{{$modelName}}.get(id)
			},
			edit: function(){
				this.$refs.{{$modelName}}.edit()
			},
			create: function(){
				this.$refs.{{$modelName}}.create()
			},
			onGet: function(ok, data){
				if(ok){
					$('#Modal{{$modelName}}').modal('show')
				}
				this.$emit('get', ok, data)
			},
			onEdit: function(ok, data){
				if(ok){
					$('#Modal{{$modelName}}').modal('hide')
				}
				this.$emit('edit', ok, data)
			},
			onCreate: function(ok, data){
				if(ok){
					$('#Modal{{$modelName}}').modal('hide')
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
		mixins: [Mixin{{$modelName}}],
		mounted: function(){
			//
		},
		methods: {
			//
		},
	}

</script>




*/

{{/* {{$txt.ForeignTable.Slice}} __ {{$txt.ForeignTable.NameGo}} __ {{$txt.ForeignTable.NamePluralGo}} __ {{$txt.ForeignTable.NameHumanReadable}} __ {{$txt.ForeignTable.ColumnNameGo}} */}}

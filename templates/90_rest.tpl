{{- $dot := . -}}
{{- $modelName := .Table.Name | singular | titleCase -}}
{{- $modelNamePlural := .Table.Name | plural | titleCase -}}
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




/*


//Esto es global, pendiente en sqlboiler v3 -------------------------

class HttpRequest {
	static Get(src) {
		return this.Request(src, 'get') //Esto debe recibir datos de búsqueda ------------------------------------ pendiente -------------------------
	}
	static Post(src, data) {
		return this.Request(src, 'post', data)
	}
	static Put(src, data) {
		return this.Request(src, 'put', data)
	}
	static Delete(src) {
		return this.Request(src, 'delete')
	}
	static Request(src, mtd, data) {
		return axios({
			method: mtd,
			url: src,
			data: data, //Agregar a la url si es get ??????????????????? o automáticamente se convierten a url si es get ????? ----- pendiente -.------------ revisar -------------
			responseType: 'json',
			headers: {
				'Accept': 'application/json',
				'Content-Type': 'multipart/form-data',
			},
		});
	}
	//Pendiente manejar el data ------------------------------------------------
}









////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////









//headers: {
//	'Accept': 'application/json',
//	'Content-Type': 'multipart/form-data',
//},



class {{$modelName}} {
	constructor() {
		this.Data = {
			{{- range $column := .Table.Columns -}}
			{{- if eq (titleCase $column.Name) "CreatedAt" "UpdatedAt" "DeletedAt" -}}
			{{- else}}
			{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}: '',
			{{- end}}
			{{- end}}
		}
		console.log('constructor..')

		{{range .Table.FKeys -}}
		{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
		this.{{$txt.ForeignTable.NameGo}} = {}
		{{end -}}

		{{range .Table.ToManyRelationships -}}
		{{- $txt := txtsFromToMany $dot.Tables $dot.Table . -}}
		this.{{$txt.ForeignTable.NamePluralGo}} = []
		{{end}}
	}

	static get Source() {
		return '/{{.Table.Name}}'
	}

	static Get(id) {
		//return HttpRequest.Get(`${this.Source}/${id}`)
		return axios.get(`${this.Source}/${id}`)
	}

	static Create(data) {
		//return HttpRequest.Post(this.Source, data)
		return axios.post(this.Source, data)
	}

	static Edit(id, data) {
		//return HttpRequest.Put(`${this.Source}/${id}`, data)
		return axios.put(`${this.Source}/${id}`, data)
	}

	static Delete(id) {
		//return HttpRequest.Delete(`${this.Source}/${id}`)
		return axios.delete(`${this.Source}/${id}`)
	}

	{{range .Table.FKeys -}}
	{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
	get{{$txt.ForeignTable.NameGo}}(){
		return new Promise( (resolve, reject) => {
			if(!this.Data.{{.Column}}){
				if(this.Data.id){
					this.{{$txt.ForeignTable.NameGo}} = {}
					resolve({'data': {}})
				} else {
					reject()
				}
				return
			}

			{{$txt.ForeignTable.NameGo}}.Get(this.Data.{{.Column}}).then( res => {
				console.log('resssssssssss sing ', res)
				this.{{$txt.ForeignTable.NameGo}} = res.data
				resolve(res)
			}).catch( res => {
				reject(res)
			})
		})

		//
		//if(!this.Data.{{.Column}}){
		//	return this.Data.id ? (new Promise( (resolve, reject) => {  resolve({'data': {}}) })) : (new Promise( (resolve, reject) => {  reject() }))
		//}

		//let P = {{$txt.ForeignTable.NameGo}}.Get(this.Data.{{.Column}})
		//P.then( res => {
		//	console.log('resssssssssss sing ', res)
		//	this.{{$txt.ForeignTable.NameGo}} = res.data
		//})
		//return P
	}
	{{end -}}

	{{range .Table.ToManyRelationships -}}
	{{- $txt := txtsFromToMany $dot.Tables $dot.Table . -}}
	get{{$txt.ForeignTable.NamePluralGo}}(params){
		return new Promise( (resolve, reject) => {
			if(!this.Data.id){
				reject()
				return
			}

			{{$txt.ForeignTable.NamePluralGo}}.Get({'{{.ForeignColumn}}': this.Data.id}).then( res => {
				console.log('resssssssssss plur ', res)
				this.{{$txt.ForeignTable.NamePluralGo}} = res.data
				resolve(res)
			}).catch( res => {
				reject(res)
			})
		})

		//
		//if(!this.Data.id){
		//	return (new Promise( (resolve, reject) => {  reject() }))
		//}

		//let P = {{$txt.ForeignTable.NamePluralGo}}.Get({'{{.ForeignColumn}}': this.Data.id})
		//P.then( res => {
		//	console.log('resssssssssss plur ', res)
		//	this.{{$txt.ForeignTable.NamePluralGo}} = res.data
		//})
		//return P
	}
	{{end}}

	{{/* dentro de range :: {{$txt.ForeignTable.Slice}} __ {{$txt.ForeignTable.NameGo}} __ {{$txt.ForeignTable.NamePluralGo}} __ {{$txt.ForeignTable.NameHumanReadable}} __ {{$txt.ForeignTable.ColumnNameGo}} */}}
}

class {{$modelNamePlural}} {
	constructor() {
		//
	}

	static get Source() {
		return '/{{.Table.Name}}'
	}

	static Get(params) {
		return axios.get(this.Source, { params: (params || {}), transformResponse: function(data){ return (data || []) } })
	}
}


// =========================================================== Empieza Vue ===========================================================


var Mixin{{$modelName}} = {
	data: function () {
		return {
			//Resource: '/{{.Table.Name}}',
			getting: false,
			editing: false,
			creating: false,
			deleting: false,
			Data: {
				{{- range $column := .Table.Columns -}}
				{{- if eq (titleCase $column.Name) "CreatedAt" "UpdatedAt" "DeletedAt" -}}
				{{- else}}
				{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}: '',
				{{- end}}
				{{- end}}
			},
			{{range .Table.FKeys -}}
			{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
			{{$txt.ForeignTable.NameGo}}: {},
			{{end -}}

			{{range .Table.ToManyRelationships -}}
			{{- $txt := txtsFromToMany $dot.Tables $dot.Table . -}}
			{{$txt.ForeignTable.NamePluralGo}}: [],
			{{end}}
		}
	},
	created: function(){
		this.$emit('created', true)
	},
	mounted: function(){
		this.$emit('mounted', true)
	},
	watch: {
		'Data.id': function(v){
			this.$emit('data-id', v)
		},
		'getting': function(v){
			this.$emit('getting', v)
		},
		'editing': function(v){
			this.$emit('editing', v)
		},
		'creating': function(v){
			this.$emit('creating', v)
		},
		'deleting': function(v){
			this.$emit('deleting', v)
		},
	},
	methods: {
		get: function(id) {
			this.clean()
			this.getting = true
			{{$modelName}}.Get(id).then( res => {
				console.log('get vue ', res)
				this.Data = res.data
				this.getting = false
				this.$emit('get', true, JSON.parse(JSON.stringify(this.Data)))
			}).catch( res => {
				this.getting = false
				this.$emit('get', false, JSON.parse(JSON.stringify(this.Data)))
			})
		},
		edit: function() {
			this.editing = true
			{{$modelName}}.Edit(this.Data.id, this.Data).then( res => {
				console.log('edit vue ', res)
				this.editing = false
				this.$emit('edit', true, JSON.parse(JSON.stringify(this.Data)))
			}).catch( res => {
				this.editing = false
				this.$emit('edit', false, JSON.parse(JSON.stringify(this.Data)))
			})
		},
		create: function() {
			this.creating = true
			{{$modelName}}.Create(this.Data).then( res => {
				console.log('create vue ', res)
				this.creating = false
				this.Data.id = (res.headers['X-Id'] || res.headers['x-id'] || this.Data.id || '')
				this.$emit('create', true, JSON.parse(JSON.stringify(this.Data)))
			}).catch( res => {
				this.creating = false
				this.$emit('create', false, JSON.parse(JSON.stringify(this.Data)))
			})
		},
		delete: function() {
			this.deleting = true
			{{$modelName}}.Delete(this.Data.id).then( res => {
				console.log('delete vue ', res)
				this.deleting = false
				this.$emit('delete', true, JSON.parse(JSON.stringify(this.Data)))
				this.clean()
			}).catch( res => {
				this.deleting = false
				this.$emit('delete', false, JSON.parse(JSON.stringify(this.Data)))
			})
		},
		clean: function() {
			{{- range $column := .Table.Columns -}}
			{{- if eq (titleCase $column.Name) "CreatedAt" "UpdatedAt" "DeletedAt" -}}
			{{- else}}
			this.Data.{{if eq $dot.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}} = ''
			{{- end}}
			{{- end}}
		},
		{{range .Table.FKeys -}}
		{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
		get{{$txt.ForeignTable.NameGo}}: function(){
			return new Promise( (resolve, reject) => {
				if(!this.Data.{{.Column}}){
					this.{{$txt.ForeignTable.NameGo}} = {}
					resolve()
					return
				}

				{{$txt.ForeignTable.NameGo}}.Get(this.Data.{{.Column}}).then( res => {
					console.log('resssssssssss sing vue ', res)
					this.{{$txt.ForeignTable.NameGo}} = res.data
					resolve()
				}).catch( res => {
					reject()
				})
			})
			//if(!this.Data.{{.Column}}){
			//	this.{{$txt.ForeignTable.NameGo}} = {}
			//	return
			//}
		},
		{{end -}}

		{{range .Table.ToManyRelationships -}}
		{{- $txt := txtsFromToMany $dot.Tables $dot.Table . -}}
		get{{$txt.ForeignTable.NamePluralGo}}: function(){
			return new Promise( (resolve, reject) => {
				if(!this.Data.id){
					this.{{$txt.ForeignTable.NamePluralGo}} = []
					resolve()
					return
				}

				{{$txt.ForeignTable.NamePluralGo}}.Get({'{{.ForeignColumn}}': this.Data.id}).then( res => {
					console.log('resssssssssss plur vue ', res)
					this.{{$txt.ForeignTable.NamePluralGo}} = res.data
					resolve()
				}).catch( res => {
					reject()
				})
			})
		},
		{{end}}
	},
}



var Mixin{{$modelNamePlural}} = {
	// -------- quizás no...
}




*/

{{/* {{$txt.ForeignTable.Slice}} __ {{$txt.ForeignTable.NameGo}} __ {{$txt.ForeignTable.NamePluralGo}} __ {{$txt.ForeignTable.NameHumanReadable}} __ {{$txt.ForeignTable.ColumnNameGo}} */}}




{{- $model := .Aliases.Table .Table.Name -}}


//headers: {
//	'Accept': 'application/json',
//	'Content-Type': 'multipart/form-data',
//},



class {{$model.UpSingular}} {
	constructor() {
		this.Data = {
			{{- range $column := .Table.Columns -}}
			{{- if eq (titleCase $column.Name) "CreatedAt" "UpdatedAt" "DeletedAt" -}}
			{{- else}}
			{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}: '',
			{{- end}}
			{{- end}}
		}
		console.log('constructor..')

		{{range .Table.FKeys -}}
		{{- $ftable := $.Aliases.Table .ForeignTable -}}
		this.{{$ftable.UpSingular}} = {}
		{{end -}}

		{{range .Table.ToManyRelationships -}}
		{{- $ftable := $.Aliases.Table .ForeignTable -}}
		this.{{$ftable.UpPlural}}
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
	{{- $ftable := $.Aliases.Table .ForeignTable -}}
	get{{$ftable.UpSingular}}(){
		return new Promise( (resolve, reject) => {
			if(!this.Data.{{.Column}}){
				if(this.Data.id){
					this.{{$ftable.UpSingular}} = {}
					resolve({'data': {}})
				} else {
					reject()
				}
				return
			}

			{{$ftable.UpSingular}}.Get(this.Data.{{.Column}}).then( res => {
				console.log('resssssssssss sing ', res)
				this.{{$ftable.UpSingular}} = res.data
				resolve(res)
			}).catch( res => {
				reject(res)
			})
		})

		//
		//if(!this.Data.{{.Column}}){
		//	return this.Data.id ? (new Promise( (resolve, reject) => {  resolve({'data': {}}) })) : (new Promise( (resolve, reject) => {  reject() }))
		//}

		//let P = {{$ftable.UpSingular}}.Get(this.Data.{{.Column}})
		//P.then( res => {
		//	console.log('resssssssssss sing ', res)
		//	this.{{$ftable.UpSingular}} = res.data
		//})
		//return P
	}
	{{end -}}

	{{range .Table.ToManyRelationships -}}
	{{- $ftable := $.Aliases.Table .ForeignTable -}}
	get{{$ftable.UpPlural}}(params){
		return new Promise( (resolve, reject) => {
			if(!this.Data.id){
				reject()
				return
			}

			{{$ftable.UpPlural}}.Get({'{{.ForeignColumn}}': this.Data.id}).then( res => {
				console.log('resssssssssss plur ', res)
				this.{{$ftable.UpPlural}} = res.data
				resolve(res)
			}).catch( res => {
				reject(res)
			})
		})

		//
		//if(!this.Data.id){
		//	return (new Promise( (resolve, reject) => {  reject() }))
		//}

		//let P = {{$ftable.UpPlural}}.Get({'{{.ForeignColumn}}': this.Data.id})
		//P.then( res => {
		//	console.log('resssssssssss plur ', res)
		//	this.{{$ftable.UpPlural}} = res.data
		//})
		//return P
	}
	{{end}}
}

class {{$model.UpPlural}} {
	constructor() {
		//
	}

	static get Source() {
		return '/{{.Table.Name}}'
	}

	static Get(params) {
		return axios.get(this.Source, { params: (params || {}), transformResponse: function(data){ return (data || []) }, responseType: 'json' })
	}

	{{range .Table.FKeys -}}
	{{- $ftable := $.Aliases.Table .ForeignTable -}}
	static GetBy{{$ftable.UpSingular}}ID(id, params) {
		return axios.get(this.Source, { params: (Object.assign({'{{.Column}}': id}, (params || {}))), transformResponse: function(data){ return (data || []) }, responseType: 'json' })
	}
	{{- end}}
}


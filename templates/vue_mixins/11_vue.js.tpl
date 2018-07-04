{{/* // MixinSingular fuera de estas plantillas... */}}

{{$model := .Aliases.Table .Table.Name -}}

var Mixin{{$model.UpSingular}} = {
	data: function () {
		return {
			source: '/{{.Table.Name}}',
			Data: {
				{{- range $column := .Table.Columns -}}
				{{- if eq (titleCase $column.Name) "CreatedAt" "UpdatedAt" "DeletedAt" -}}
				{{- else}}
				{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}}: '',
				{{- end}}
				{{- end}}
			},
			{{range .Table.FKeys -}}
			{{- $ftable := $.Aliases.Table .ForeignTable -}}
			{{$ftable.UpSingular}}: {},
			{{end -}}

			{{range .Table.ToManyRelationships -}}
			{{- $ftable := $.Aliases.Table .ForeignTable -}}
			{{$ftable.UpPlural}}: [],
			{{end}}
		}
	},
	methods: {
		clean: function() {
			{{- range $column := .Table.Columns -}}
			{{- if eq (titleCase $column.Name) "CreatedAt" "UpdatedAt" "DeletedAt" -}}
			{{- else}}
			this.Data.{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}} = ''
			{{- end}}
			{{- end}}

			if(this.onClean){
				this.onClean()
			}
		},
		{{range .Table.FKeys -}}
		{{- $ftable := $.Aliases.Table .ForeignTable -}}
		get{{$ftable.UpSingular}}: function(){
			return new Promise( (resolve, reject) => {
				if(!this.Data.{{.Column}}){
					this.{{$ftable.UpSingular}} = {}
					resolve()
					return
				}

				//{{$ftable.UpSingular}}.Get(this.Data.{{.Column}}).then( res => {
				axios.get(`/{{.ForeignTable}}/${this.Data.{{.Column}}}`).then( res => {
					console.log('resssssssssss sing vue ', res)
					this.{{$ftable.UpSingular}} = res.data || {}
					resolve()
				}).catch( res => {
					reject()
				})
			})
		},
		{{end -}}

		{{range .Table.ToManyRelationships -}}
		{{- $ftable := $.Aliases.Table .ForeignTable -}}
		get{{$ftable.UpPlural}}: function(){
			return new Promise( (resolve, reject) => {
				if(!this.Data.id){
					this.{{$ftable.UpPlural}} = []
					resolve()
					return
				}

				//{{$ftable.UpPlural}}.Get({'{{.ForeignColumn}}': this.Data.id}).then( res => {
				axios.get(`/{{.ForeignTable}}`, { params: {'{{.ForeignColumn}}': this.Data.id} }).then( res => {
					console.log('resssssssssss plur vue ', res)
					this.{{$ftable.UpPlural}} = res.data || []
					resolve()
				}).catch( res => {
					reject()
				})
			})
		},
		{{end}}
	},
}



var Mixin{{$model.UpPlural}} = {
	// -------- quizás no...
}

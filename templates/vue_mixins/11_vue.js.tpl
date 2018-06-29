{{- $model := .Aliases.Table .Table.Name -}}

var Mixin{{$model.UpSingular}} = {
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
			{{$model.UpSingular}}.Get(id).then( res => {
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
			{{$model.UpSingular}}.Edit(this.Data.id, this.Data).then( res => {
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
			{{$model.UpSingular}}.Create(this.Data).then( res => {
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
			{{$model.UpSingular}}.Delete(this.Data.id).then( res => {
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
			this.Data.{{if eq $.StructTagCasing "camel"}}{{$column.Name | camelCase}}{{else}}{{$column.Name}}{{end}} = ''
			{{- end}}
			{{- end}}
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

				{{$ftable.UpSingular}}.Get(this.Data.{{.Column}}).then( res => {
					console.log('resssssssssss sing vue ', res)
					this.{{$ftable.UpSingular}} = res.data || {}
					resolve()
				}).catch( res => {
					reject()
				})
			})
			//if(!this.Data.{{.Column}}){
			//	this.{{$ftable.UpSingular}} = {}
			//	return
			//}
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

				{{$ftable.UpPlural}}.Get({'{{.ForeignColumn}}': this.Data.id}).then( res => {
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

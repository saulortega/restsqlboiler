# restsqlboiler

## [Español](README.es.md) - [English](README.en.md)


#### ¿Qué es?

Esta herramienta extiende la funcionalidad de [SQLBoiler](https://github.com/volatiletech/sqlboiler) permitiendo implementar una API REST.


#### ¿Cómo funciona?

RESTSQLBoiler lee e interpreta los archivos generados por SQLBoiler y genera nuevos archivos con nuevas funciones que extienden la funcionalidad de SQLBoiler.


#### ¿Cómo se usa?

```go
var BD, err = sql.Open("postgres", "postgres://postgres:clavesegura@localhost/contabilidad")
if err != nil {
	panic(err)
}

//BD: boil.Executor
//r: *http.Request
//w: http.ResponseWriter
switch r.Method {
case "GET":
	models.FindAndResponseFactura(BD, w, r)
case "POST":
	models.InsertAndResponseFactura(BD, w, r)
case "PUT":
	models.UpdateAndResponseFactura(BD, w, r)
case "DELETE":
	models.DeleteAndResponseFactura(BD, w, r)
}
```

Las funciones anteriores responden automáticamente la solicitud.


#### ¿Cómo empiezo?

```bash
go get -u https://github.com/saulortega/restsqlboiler
restsqlboiler -d /ruta/a/sqlboiler/models
```

#### Restricciones a tener en cuenta:

- Aún en desarrollo.
- Probado únicamente con Postgres.
- La llave primaria de las tablas debe ser de tipo `bigserial` (más precisamente, `int64` en Go) y debe llamarse `id`.
- Aún se requiere el llamado manual de las funciones, por lo que el usuario debe manejar el receptor http y desde allí llamar las funciones de RESTSQLBoiler.


#### Definición de funciones:

```go
func FindAndResponseFactura(exec boil.Executor, w http.ResponseWriter, r *http.Request)
```
- Obtiene el ID desde la URL (/facturas/34)
- Obtiene el objeto desde BD usando el ID anterior (Llama a FindFactura(exec, 34))
- Responde el objeto codificado en JSON (o bien, responde error)


```go
func UpdateAndResponseFactura(exec boil.Executor, w http.ResponseWriter, r *http.Request)
```
- Obtiene el ID desde la URL (/facturas/34)
- Obtiene el objeto desde BD usando el ID anterior (Llama a FindFactura(exec, 34))
- Construye los datos recibidos desde la solicitud PUT. Se espera que los datos lleguen con las mismas llaves JSON del objeto generado por SQLBoiler
- - Se puede omitir campos a construir automáticamente con la variable `OmitFieldsOnBuildingFactura`: `models.OmitFieldsOnBuildingFactura = []string{"campo_omitido"}`
- Opcionalmente, puede sobrescribir los datos a su gusto con la función `BuildFactura`: `models.BuildFactura = func(obj \*models.Factura, r \*http.Request) error { return nil }`
- Puede validar el objeto con la función `ValidateFactura` (tanto para actualización como para inserción): `models.ValidateFactura = func(obj \*models.Factura) error { return nil }`
- `ValidateFacturaOnUpdate` funciona como la anterior, pero sólo para actualización
- Actualiza el objeto en BD
- Responde


```go
func InsertAndResponseFactura(exec boil.Executor, w http.ResponseWriter, r *http.Request)
```
- Construye los datos recibidos desde la solicitud POST. Se espera que los datos lleguen con las mismas llaves JSON del objeto generado por SQLBoiler
- - Se puede omitir campos a construir automáticamente con la variable `OmitFieldsOnBuildingFactura`: `models.OmitFieldsOnBuildingFactura = []string{"campo_omitido"}`
- Opcionalmente, puede sobrescribir los datos a su gusto con la función `BuildFactura`: `models.BuildFactura = func(obj \*models.Factura, r \*http.Request) error { return nil }`
- Puede validar el objeto con la función `ValidateFactura` (tanto para actualización como para inserción): `models.ValidateFactura = func(obj \*models.Factura) error { return nil }`
- `ValidateFacturaOnInsert` funciona como la anterior, pero sólo para inserción de nuevos objetos
- Actualiza el objeto en BD
- Responde


```go
func SoftDeleteAndResponseFactura(exec boil.Executor, w http.ResponseWriter, r *http.Request)
```

- Obtiene el ID desde la URL (/facturas/34)
- Obtiene el objeto desde BD usando el ID anterior (Llama a FindFactura(exec, 34))
- Actualiza la columna `deleted_at` del objeto
- Responde


```go
func HardDeleteAndResponseFactura(exec boil.Executor, w http.ResponseWriter, r *http.Request)
```
- Obtiene el ID desde la URL (/facturas/34)
- Obtiene el objeto desde BD usando el ID anterior (Llama a FindFactura(exec, 34))
- Elimina el registro de la base de datos
- Responde


```go
func DeleteAndResponseFactura(exec boil.Executor, w http.ResponseWriter, r *http.Request)
```
- `SoftDeleteAndResponseFactura` si existe la columna `deleted_at`. `HardDeleteAndResponseFactura` en caso contrario.


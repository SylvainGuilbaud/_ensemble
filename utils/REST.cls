Class utils.REST Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/" Method="GET" Call="version"/>
<Route Url="/version" Method="GET" Call="version"/>
<Route Url="/version/:a" Method="GET" Call="version"/>
<Route Url="/pop/:classname/:nb" Method="GET" Call="pop"/>
<Route Url="/nb/:classname" Method="GET" Call="nb"/>
<Route Url="/kill/:classname" Method="GET" Call="kill"/>
<Route Url="/list/:classname" Method="GET" Call="list"/>
<Route Url="/list/:classname/:nb" Method="GET" Call="listTop"/>
<Route Url="/sqllist/:classname" Method="GET" Call="listSQLAll"/>
<Route Url="/sqllist/:classname/:nb" Method="GET" Call="listSQLTop"/>
<Route Url="/import/data/:classname" Method="POST" Call="importJSON"/>
<Route Url="/import/data/array/:classname" Method="POST" Call="importArrayJSON"/>
<Route Url="/load" Method="POST" Call="load"/>
<Route Url="/import" Method="POST" Call="import"/>
<Route Url="/import/data" Method="POST" Call="importGlobals"/>
<Route Url="/namespaces" Method="GET" Call="GetNamespaces"/>
<Route Url="/namespace/exist/:namespace" Method="GET" Call="namespaceExists"/>
<Route Url="/namespace" Method="POST" Call="createNamespace" />
<Route Url="/namespace" Method="DELETE" Call="deleteNamespace" />
<Route Url="/namespace/enable/:namespace" Method="GET" Call="enableNamespace" />
<Route Url="/namespace/enable/:namespace" Method="PUT" Call="enableNamespace" />
<Route Url="/namespace/disable/:namespace" Method="GET" Call="disableNamespace" />
<Route Url="/service" Method="GET" Call="service" />
<Route Url="/production" Method="POST" Call="createProduction" />
<Route Url="/_spec" Method="GET" Call="SwaggerSpec" />
</Routes>
}

ClassMethod version() As %Status
{
    set start=$zh
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set json.version=$zv
    set json.date=$zdt($h,3)
    set json.system=$System
    set json.username=$Username
    set json.roles=$Roles
    set json.namespace=$Namespace
    set json.elapse=$zh-start
    write json.%ToJSON()
    return sc
}

ClassMethod pop(classname As %String, nb As %String) As %Status
{
    set start=$zh
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set json.classname=classname
    set json.nb=nb
    set json.inserted=$CLASSMETHOD(classname,"Populate",nb)
    set json.elapse=$zh-start
    write json.%ToJSON()
    return sc
}

ClassMethod nb(classname As %String) As %Status
{
 set start=$zh
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set json.classname=classname
    set class=##class(%Dictionary.CompiledClass).%OpenId(classname)
    set json.tableName=class.SqlSchemaName_"."_class.SqlTableName
    set tStatement=##class(%SQL.Statement).%New(1) 
    set sql = 2
    set sql(1) = "select count(*)" 
    set sql(2) = "from "_json.tableName
    set sc = tStatement.%Prepare(.sql) 
    set result = tStatement.%Execute() 
    if 'result.%SQLCODE {  
        do result.%Next()
        set json.nb=result.%GetData(1)
    }
    set json.elapse=$zh-start
    write json.%ToJSON()
    return sc
}

ClassMethod kill(classname As %String) As %Status
{
    set start=$zh
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set json.classname=classname
    set json.status=$CLASSMETHOD(classname,"%KillExtent")
    set json.elapse=$zh-start
    write json.%ToJSON()
    return sc
}

ClassMethod list(classname As %String) As %Status
{
    set start=$zh
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set json.classname=classname
    set json.list=[]
    set tStatement=##class(%SQL.Statement).%New() 
    set sc = tStatement.%PrepareClassQuery(classname,"Extent") 
    set result = tStatement.%Execute() 
    if 'result.%SQLCODE {  
        while result.%Next() { 
            set a=$CLASSMETHOD(classname,"%OpenId",result.%GetData(1))
            set sc=a.%JSONExportToString(.str)
            do json.list.%Push({}.%FromJSON(str))
            set i=i+1
        } 
    }
    set json.nb=json.%Size()
    set json.elapse=$zh-start
    write json.%ToJSON()
    return sc
}

ClassMethod listTop(classname As %String, nb As %Integer) As %Status
{
    set start=$zh
    set sc=$$$OK,i=0
    set %response.ContentType="application/json"
    set json=[]
    set tStatement=##class(%SQL.Statement).%New() 
    set sc = tStatement.%PrepareClassQuery(classname,"Extent") 
    set result = tStatement.%Execute() 
    if 'result.%SQLCODE {  
        while i<nb && result.%Next() { 
            set a=$CLASSMETHOD(classname,"%OpenId",result.%GetData(1))
            set sc=a.%JSONExportToString(.str)
            do json.%Push({}.%FromJSON(str))
            set i=i+1        } 
    }
    write json.%ToJSON()
    return sc
}

ClassMethod listSQLAll(classname As %String) As %Status
{
    set start=$zh
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set json.classname=classname
    set json.list=[]
    set class=##class(%Dictionary.CompiledClass).%OpenId(classname)
    set json.tableName=class.SqlSchemaName_"."_class.SqlTableName
    set tStatement=##class(%SQL.Statement).%New(1) 
    set sql($i(query)) = "select" 
    set sql($i(query)) = "id"
    set sql($i(query)) = ",name"
    set sql($i(query)) = ",dob"
    set sql($i(query)) = ",score"
    set sql($i(query)) = ",category"
    #; set sql($i(query)) = ",activ"
    set sql($i(query)) = "from "_class.SqlSchemaName_"."_class.SqlTableName
    set sql = query
    set sc = tStatement.%Prepare(.sql) 
    set result = tStatement.%Execute() 
    if 'result.%SQLCODE {  
        while result.%Next() { 
            set elem={}  
            #; set elem.id=result."id" 
            set elem.name=result."name" 
            set elem.dob=result."dob" 
            set elem.score=result."score" 
            set elem.category=result."category" 
            #; set elem.activ=result.activ
            do json.list.%Push(elem)
            set i=i+1
        } 
    }
    set json.nb=json.%Size()
    set json.elapse=$zh-start
    write json.%ToJSON()
    return sc
}

ClassMethod listSQLTop(classname As %String, nb As %String) As %Status
{
    set start=$zh
    set sc=$$$OK
    set %response.ContentType="application/json"
    #; set json={}
    #; set json.classname=classname
    #; set json.top=nb
    #; set json.list=[]
    set json=[]
    set class=##class(%Dictionary.CompiledClass).%OpenId(classname)
    #; set json.tableName=class.SqlSchemaName_"."_class.SqlTableName
    set tStatement=##class(%SQL.Statement).%New(1) 
    set sql(2) = "from "_class.SqlSchemaName_"."_class.SqlTableName
    set sql($i(query)) = "select" 
    set sql($i(query)) = "top ?" 
    set sql($i(query)) = "id"
    set sql($i(query)) = ",name"
    set sql($i(query)) = ",dob"
    set sql($i(query)) = ",score"
    set sql($i(query)) = ",category"
    #; set sql($i(query)) = ",activ"
    set sql($i(query)) = "from "_class.SqlSchemaName_"."_class.SqlTableName
    set sql = query
    set sc = tStatement.%Prepare(.sql) 
    set result = tStatement.%Execute(nb) 
    if 'result.%SQLCODE {  
        while result.%Next() { 
            set elem={}  
            #; set elem.id=result."id" 
            set elem.name=result."name" 
            set elem.dob=result."dob" 
            set elem.score=result."score" 
            set elem.category=result."category" 
            #; set elem.activ=result.activ
            do json.%Push(elem)
        } 
    }
    set json.nb=json.%Size()
    #; set json.elapse=$zh-start
    write json.%ToJSON()
    return sc
}

ClassMethod importJSON(classname) As %Status
{
    set start=$zh
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set payload={}.%FromJSON(%request.Content)
    set a=$CLASSMETHOD(classname,"%New")
    set json.import=a.%JSONImport(payload)
    set json.status=a.%Save()
    set json.name=payload.name
    set json.elapse=$zh-start
    write json.%ToJSON()
    return sc
}

ClassMethod importArrayJSON(classname) As %Status
{
    set start=$zh
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set json.method="importArrayJSON"
    set json.classname=classname
    set payload=[].%FromJSON(%request.Content)
    set array = payload.%GetIterator()
    set json.array=[]
    while array.%GetNext(.key,.value) {
        set a=$CLASSMETHOD(classname,"%New"),elem={}
 		set elem.import=a.%JSONImport(value)
        set elem.status=a.%Save()
        set elem.id=a.%Id()
        do json.array.%Push(elem)
    }
    set json.elapse=$zh-start
    write json.%ToJSON()
    return sc
}

ClassMethod load() As %Status
{
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set payload={}.%FromJSON(%request.Content)
    
    set ns=$namespace
    try {
        set namespaces = payload."namespaces".%GetIterator()
        set json.results=[]
        while namespaces.%GetNext(.key , .value ) {
            zn value."name"
            kill errors
            set sc=$system.OBJ.Load(value."file","cbk-d",.errors)
            set result={}
            set result.namespace=value."name"
            set result.file=value."file"
            set result.status=sc
            merge ^["USER"]LoadErrors(value."name")=errors
            do json.results.%Push(result) 
	    }
    }
    catch e {
        set sc=e.AsStatus()
        set msg="erreur durant l'import("_$system.Status.GetErrorText(sc)_")",severity=1
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    }
    write json.%ToJSON()
    zn ns
    return sc
}

ClassMethod createNamespace() As %Status
{
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set payload={}.%FromJSON(%request.Content)
    set json.namespace=$zcvt(payload.namespace,"U")
    set json.directory=##class(%Library.File).NormalizeDirectory(payload.directory)_payload.namespace
    set json.directory=##class(%Library.File).NormalizeDirectory(json.directory)
    set json.interop=payload.interop

    try {
        if ..namespaceExists(json.namespace) {
            set alreadyExist = ##class(%Exception.General).%New("ALREADY EXIST","5001",,
                             json.namespace_" is already existing")
            throw alreadyExist
        }
        set vars("NAMESPACE")=json.namespace
        set vars("DATABASEDIR")=json.directory
        set vars("INTEROP")=json.interop
        set sc=##class(utils.installer.namespace).setup(.vars)
        set json.status=json.namespace_" successfully created"  
        set msg="création de l'espace de noms "_json.namespace_" depuis l'app "_$CLASSNAME(),severity=0
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    } catch e {
        set sc=e.AsStatus()
        set msg="erreur durant la création de l'espace de noms "_json.namespace_"("_$system.Status.GetErrorText(sc)_")",severity=1
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    }
    write json.%ToJSON()
    return sc
}

ClassMethod deleteNamespace() As %Status
{
    set sc=$$$OK
    set ns=$namespace
    zn "%SYS"
    set %response.ContentType="application/json"
    set json={}
    set payload={}.%FromJSON(%request.Content)
    set json.namespace=$zcvt(payload.namespace,"U")
    set json.directory=##class(%Library.File).NormalizeDirectory(payload.directory)_payload.namespace
    set json.directory=##class(%Library.File).NormalizeDirectory(json.directory)
    
    try {
       
        set:..namespaceExists(json.namespace) sc=##Class(Config.Namespaces).Delete(json.namespace)
        set:sc json.status=json.namespace_" successfully deleted"
        set json.databases=[]
        set json.resources=[]
        for dbType="_SRC","_DATA" {
            set dbName=json.directory_json.namespace_dbType
            set sc=##class(SYS.Database).DismountDatabase(dbName)
            set sc=##class(SYS.Database).DeleteDatabase(dbName)
            set sc=##class(Config.Databases).Delete(json.namespace_dbType)
            do json.databases.%Push(dbName_" successfully deleted")

            set resourceName="%DB_"_json.namespace_dbType
            set sc = ##class(Security.Resources).Delete(resourceName)
            
            do json.resources.%Push(resourceName_" successfully deleted")
        }
        
        set json.directoryDeleted=##class(%Library.File).RemoveDirectoryTree(json.directory)

        set sc=##class(Security.Applications).Delete("/csp/"_json.namespace)
        set:sc json.CSPApplication="/csp/"_json.namespace_" successfully deleted"
        set msg="suppression de l'espace de noms "_json.namespace_" depuis l'app "_$CLASSNAME(),severity=0
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    } catch e {
        set sc=e.AsStatus()
        set msg="erreur durant la création de l'espace de noms "_json.namespace_"("_$system.Status.GetErrorText(sc)_")",severity=1
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    }
    write json.%ToJSON()
    zn ns
    return sc
}

ClassMethod import() As %Status
{
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set payload={}.%FromJSON(%request.Content)
    
    set json.sourceServer=payload.server
    set json.sourcePort=payload.port
    set json.sourceNamespace=payload.sourceNamespace
    set json.targetNamespace=payload.targetNamespace
    set ns=$namespace
    try {
        // check if namespace exist !!
        zn json.targetNamespace
        set httpRequest=##class(%Net.HttpRequest).%New()
        set httpRequest.Server=json.sourceServer
        set httpRequest.Port=json.sourcePort
        set httpRequest.Username="_system"
        set httpRequest.Password="SYS"
        set sc=httpRequest.Get("http://"_json.sourceServer_":"_json.sourcePort_"/source/export/"_json.sourceNamespace)
        // localhost:57772/source/export/user
        if $$$ISOK(sc) && $IsObject(httpRequest.HttpResponse.Data) {
            set sc=##class(%SYSTEM.OBJ).LoadStream(httpRequest.HttpResponse.Data,"-d",.errors,.list)
            do httpRequest.HttpResponse.Data.Rewind()
            set json.export=httpRequest.HttpResponse.Data.Read(256)
            set json.errors=[]
            set key=$ORDER(errors(""))
            while (key'="") {
                do json.errors.%Push(key) 
                set key = $ORDER(errors(key))
            }
            set json.list=[]
            set key=$ORDER(list(""))
            while (key'="") {
                do json.list.%Push(key) 
                set key = $ORDER(list(key))
            }
        }
        
    }
    catch e {
        set sc=e.AsStatus()
        set msg="erreur durant l'import vers l'espace de noms "_json.targetNamespace_"("_$system.Status.GetErrorText(sc)_")",severity=1
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    }
    set json.status=json.sourceNamespace_" successfully imported in namespace "_json.targetNamespace_" from "_json.sourceServer
    write json.%ToJSON()
    zn ns
    return sc
}

ClassMethod importGlobals() As %Status
{
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set payload={}.%FromJSON(%request.Content)
    
    set json.sourceServer=payload.server
    set json.sourcePort=payload.port
    set json.sourceNamespace=payload.sourceNamespace
    set json.targetNamespace=payload.targetNamespace
    set json.globals=payload.globals
    set ns=$namespace
    try {
        // check if namespace exist !!
        zn json.targetNamespace
        set httpRequest=##class(%Net.HttpRequest).%New()
        set httpRequest.Server=json.sourceServer
        set httpRequest.Port=json.sourcePort
        set httpRequest.Username="_system"
        set httpRequest.Password="SYS"
        do HttpRequest.EntityBody.Write(json.globals.%ToJSON())
        set sc=httpRequest.Get("http://"_json.sourceServer_":"_json.sourcePort_"/source/export/"_json.sourceNamespace)
        // localhost:57772/source/export/data/user
        if $$$ISOK(sc) && $IsObject(httpRequest.HttpResponse.Data) {
            set sc=##class(%SYSTEM.OBJ).LoadStream(httpRequest.HttpResponse.Data,"-d",.errors,.list)
            do httpRequest.HttpResponse.Data.Rewind()
            set json.export=httpRequest.HttpResponse.Data.Read(256)
            set json.errors=[]
            set key=$ORDER(errors(""))
            while (key'="") {
                do json.errors.%Push(key) 
                set key = $ORDER(errors(key))
            }
            set json.list=[]
            set key=$ORDER(list(""))
            while (key'="") {
                do json.list.%Push(key) 
                set key = $ORDER(list(key))
            }
        }
        
    }
    catch e {
        set sc=e.AsStatus()
         set msg="erreur durant l'import de données vers l'espace de noms "_json.targetNamespace_"("_$system.Status.GetErrorText(sc)_")",severity=1
       do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    }
    set json.status=json.sourceNamespace_" successfully imported in namespace "_json.targetNamespace_" from "_json.sourceServer
    write json.%ToJSON()
    zn ns
    return sc
}

ClassMethod enableNamespace(namespace As %String) As %Status
{
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set json.namespace=namespace
    
    try {
        #; if '##class(%Library.EnsembleMgr).IsEnsembleNamespace(namespace){
            set sc=##class(%Library.EnsembleMgr).EnableNamespace(namespace,0)
            set json.status=namespace_" successfully enabled to function with interoperability"
        #; }        
    } catch e {
        set sc=e.AsStatus()
        set msg="erreur durant la création de l'espace de noms "_namespace_"("_$system.Status.GetErrorText(sc)_")",severity=1
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    }
    
    write json.%ToJSON()
    return sc
}

ClassMethod disableNamespace(namespace As %String) As %Status
{
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set json.namespace=namespace
    
    try {
        if ##class(%Library.EnsembleMgr).IsEnsembleNamespace(namespace){
            set sc=##class(%Library.EnsembleMgr).DisableNamespace(namespace,0)
            set json.status=namespace_" successfully disabled to function with interoperability"
        }        
    } catch e {
        set sc=e.AsStatus()
        set msg="erreur durant la création de l'espace de noms "_namespace_"("_$system.Status.GetErrorText(sc)_")",severity=1
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    }
    
    write json.%ToJSON()
    return sc
}

// 1. Create %Dictionary.ClassDefinition object for your test production

// 2. Create Ens.Config.Production object

// 3. Create %Dictionary.XDataDefinition

// 4. Serialize (2) into (3)

// 5. Insert XData (3) into (1)

// 6. Save and compile (1)

ClassMethod createProduction() As %Status
{
    set sc=$$$OK
    set %response.ContentType="application/json"
    set json={}
    set payload={}.%FromJSON(%request.Content)
    set json.namespace=payload.namespace
    set json.production=payload.production
    

    try {
        set ns=$Namespace
        zn json.namespace
        if ##Class(Ens.Config.Production).%ExistsId(json.production) {
            set alreadyExist = ##class(%Exception.General).%New("ALREADY EXIST","5001",,
                             json.production_" is already existing in "_json.namespace)
            throw alreadyExist
        }
        set a=##class(%Dictionary.ClassDefinition).%New()
        set a.Name=json.production
        set a.Super="Ens.Production"
        

        set prod=##class(Ens.Config.Production).%New()
        set prod.Name=json.production
        
        set service=##class(Ens.Config.Item).%New()
        set service.Name="from a file"
        set service.ClassName="EnsLib.File.PassthroughService"
        set target=##class(Ens.Config.Setting).%New()
        set target.Name="TargetConfigNames"
        set target.Value="router"
        do service.Settings.Insert(target)
        set FilePath=##class(Ens.Config.Setting).%New()
        set FilePath.Name="FilePath"
        set FilePath.Value="/file/in"
        do service.Settings.Insert(FilePath)
        set FileSpec=##class(Ens.Config.Setting).%New()
        set FileSpec.Name="FileSpec"
        set FileSpec.Value="*.txt"
        do service.Settings.Insert(FileSpec)

        do prod.Items.Insert(service)

        set process=##class(Ens.Config.Item).%New()
        set process.Name="router"
        set process.ClassName="EnsLib.MsgRouter.RoutingEngine"
        do prod.Items.Insert(process)

        set operation=##class(Ens.Config.Item).%New()
        set operation.Name="to a file"
        set operation.ClassName="EnsLib.File.PassthroughOperation"
        do prod.Items.Insert(operation)
        
        set sc=prod.%Save()
        
        set xdata=##class(%Dictionary.XDataDefinition).%New()
        set xdata.Name="ProductionDefinition"
        set sc=prod.XMLExportToStream(xdata.Data,,",indent")
        set sc=a.XDatas.Insert(xdata)

        set sc=a.%Save()
        set sc=$system.OBJ.Compile(json.production,"-d")

        set json.status=json.production_" successfully created in "_json.namespace_" ("_sc_")"
        zn ns
    } catch e {
        set sc=e.AsStatus()
        set msg="erreur durant la création de la production "_json.production_"("_$system.Status.GetErrorText(sc)_")",severity=1
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    }
    write json.%ToJSON()
    return sc
}

ClassMethod service() As %Status
{
 try {
	set sc=$$$OK
	set %response.ContentType="application/json"

	set payload=%request.Content

	set tSC=##class(Ens.Director).CreateBusinessService("training.service.REST",.tService)

	set request=##class(Ens.StringRequest).%New()
	set request.StringValue=payload.Read()

	set sc=tService.ProcessInput(request,.response)
	set retour={}
	set retour.data=response.StringValue
	write retour.%ToJSON()
	} catch e {
		throw e
	}
	return sc
}

ClassMethod namespaceExists(namespace As %String) As %Boolean
{
    set ns=$Namespace
    zn "%sys"
    set exist=##Class(Config.Namespaces).Exists(namespace)
    zn ns
    return exist
}

/// This method returns a list of namespaces for this server
ClassMethod GetNamespaces() As %Status
{
    #dim tSC As %Status = $$$OK
    #dim tList,tNS,tFilteredList,tValue As %String
    
    #; Get the list of namespaces
    Do List^%SYS.NAMESPACE(.tList)
    Set tNS="" For  {
    
        Set tNS=$Order(tList(tNS),1,tValue) If tNS="" Quit
    
        #; Only want namespaces which are enabled and are not remote
        If $List(tValue,1)=1&&$List(tValue,2)=0 {
            Set tFilteredList(tNS)=""
        }
    }
    
    #; If we have been asked for json
    If $Get(%request.CgiEnvs("HTTP_ACCEPT"))="application/json" {
        
        #; Set the response header to JSON
        Set %response.ContentType="application/json"
        
        #; Create a JSON proxy
        Set tProxy = ##class(%ZEN.proxyObject).%New()
        
        #; And a list to hold the namespaces
        Set tList=##class(%Library.ListOfDataTypes).%New()
        
        #; Add the namespaces to the list
        Set tNS="" For  {
            Set tNS=$Order(tFilteredList(tNS)) If tNS="" Quit
            Do tList.Insert(tNS)
        }
        
        #; Set the namespace property
        Set tProxy.namespaces=tList
        
        #; Output the JSON
        Do tProxy.%ToJSON()
        
    } else {
        
        Set tNS="" For  {
            Set tNS=$Order(tFilteredList(tNS)) If tNS="" Quit
            Write tNS,!
        }
    }
    Quit tSC
}

// ClassMethod SwaggerSpec() As %Status

// {

//   Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)

//   Do swagger.info.%Remove("x-ISC_Namespace")

//   Set swagger.basePath = "/crud"

//   Set swagger.info.title = "InterSystems IRIS REST CRUD demo"

//   Set swagger.info.version = "0.1"

//   Set swagger.host = "localhost:52773"

//   Return ..%ProcessResult($$$OK, swagger)

// }

}

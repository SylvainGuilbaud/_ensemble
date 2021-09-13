Class utils.admin
{

ClassMethod create(namespace As %String = "myapp") As %Status
{
    set sc=$$$OK
    set payload={}
    set payload.namespace=namespace
    set payload.directory="/Users/guilbaud/data"
    set payload.interop=1
    set sc=..createNamespace(payload)
    return sc
}

ClassMethod delete(namespace As %String = "myapp") As %Status
{
    set sc=$$$OK
    set payload={}
    set payload.namespace=namespace
    set payload.directory="/Users/guilbaud/data"
    set sc=..deleteNamespace(payload)
    return sc
}

ClassMethod createNamespace(payload As %DynamicObject) As %Status
{
    set sc=$$$OK
    
    set json={}
    set json.namespace=$zcvt(payload.namespace,"U")
    set json.directory=##class(%Library.File).NormalizeDirectory(payload.directory)_payload.namespace
    set json.directory=##class(%Library.File).NormalizeDirectory(json.directory)
    set json.interop=payload.interop

    try {
        set ns=$namespace
        zn "%SYS"
        if ##Class(Config.Namespaces).Exists(json.namespace) {
            set alreadyExist = ##class(%Exception.General).%New("ALREADY EXIST","5001",,
                             json.namespace_" is already existing")
            throw alreadyExist
        }
        zn ns
        set vars("NAMESPACE")=json.namespace
        set vars("DATABASEDIR")=json.directory
        set vars("INTEROP")=json.interop
        set sc=##class(utils.installer.namespace).setup(.vars)
        set json.status=json.namespace_" successfully created"  
    } catch e {
        set sc=e.AsStatus()
        set msg="erreur durant la création de l'espace de noms "_json.namespace_"("_$system.Status.GetErrorText(sc)_")",severity=1
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    }
    write json.%ToJSON()
    zn ns
    return sc
}

ClassMethod deleteNamespace(payload As %DynamicObject) As %Status
{
    set sc=$$$OK
    set json={}
    set json.namespace=$zcvt(payload.namespace,"U")
    set json.directory=##class(%Library.File).NormalizeDirectory(payload.directory)_payload.namespace
    set json.directory=##class(%Library.File).NormalizeDirectory(json.directory)
    
    try {
        set ns=$namespace
        zn "%SYS"
        set:##Class(Config.Namespaces).Exists(json.namespace) sc=##Class(Config.Namespaces).Delete(json.namespace)
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
        zn ns
    } catch e {
        set sc=e.AsStatus()
        set msg="erreur durant la création de l'espace de noms "_json.namespace_"("_$system.Status.GetErrorText(sc)_")",severity=1
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    }
    write json.%ToJSON()
    
    return sc
}

}

Class utils.database
{

ClassMethod delete(directory As %String = "/usr/cache/bases", verbose As %Boolean = 1) As %Status
{
    set ns=$NAMESPACE,sc=$$$OK,msg="",severity=0
    try {
        zn "%sys"
        set directory = ##class(%Library.File).NormalizeDirectory(directory)
        for dbType = "DBNA","PBNA" {
            set dbName=directory_dbType
            set sc=##class(SYS.Database).DismountDatabase(dbName)
            if sc {
                set msg="base "_dbName_" démontée avec succès depuis "_$CLASSNAME(),severity=0
                do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
            } else {
                set msg="erreur durant le démontage de la base "_dbName_" depuis "_$CLASSNAME()_" ("_$system.Status.GetErrorText(sc)_")",severity=1
                do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
            }
            write:verbose !,msg,!
        
            set sc=##class(SYS.Database).DeleteDatabase(dbName)
            if sc {
                set msg="base "_dbName_" supprimée avec succès depuis "_$CLASSNAME(),severity=0
                do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
            } else {
                set msg="erreur durant la suppression de la base "_dbName_" depuis "_$CLASSNAME()_" ("_$system.Status.GetErrorText(sc)_")",severity=1
                do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
            }
            write:verbose !,msg,!

            set sc=##class(Config.Databases).Delete(dbType)
            if sc {
                set msg="configuration de la base "_dbName_" supprimée avec succès depuis "_$CLASSNAME(),severity=0
                do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
            } else {
                set msg="erreur durant la suppression de la configuration de la base "_dbName_" depuis "_$CLASSNAME()_" ("_$system.Status.GetErrorText(sc)_")",severity=1
                do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
            }
            write:verbose !,msg,!

            set resourceName="%DB_"_dbType
            set sc = ##class(Security.Resources).Delete(resourceName)
            if sc {
                set msg="ressource "_resourceName_" supprimée avec succès depuis "_$CLASSNAME(),severity=0
                do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
            } else {
                set msg="erreur durant la suppression de la ressource "_resourceName_" depuis "_$CLASSNAME()_" ("_$system.Status.GetErrorText(sc)_")",severity=1
                do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
            }
            write:verbose !,msg,!

            set sc = ##class(%Library.File).RemoveDirectoryTree(dbName)
            if sc {
                set msg="répertoire de la base "_dbName_" supprimé avec succès depuis "_$CLASSNAME(),severity=0
                do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
            } else {
                set msg="erreur durant la suppression du répertoire de la base "_dbName_" depuis "_$CLASSNAME()_" ("_$system.Status.GetErrorText(sc)_")",severity=1
                do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
            }
            write:verbose !,msg,!
        }
        
    } catch e {
        set sc=e.AsStatus()
        set msg="erreur durant la suppression des bases de données DBNA et PBNA depuis "_$CLASSNAME()_" ("_$system.Status.GetErrorText(sc)_")",severity=1
        do ##class(%SYS.System).WriteToConsoleLog(msg,0,severity)
    }
    zn ns
    return $$$OK
}

}

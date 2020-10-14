Class apiPub.utils.sql Extends apiPub.core.jsonBuilder
{

ClassMethod GetSQLMetaData(pSQLCommand As %String, Output pStatement As %SQL.Statement, Output pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try {
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"_")
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pSelectMode = $Select(pParams.selectMode'="":pParams.selectMode,1:1)
        Set pShowRelationships = $Select(pParams.showRelationships'="":pParams.showRelationships,1:1)

        Set tMetaData = {"columns":{},"relColumns":{},"parameters":{}}
        Set pStatement = ##class(%SQL.Statement).%New(pSelectMode)
        Set tSC = pStatement.%Prepare(pSQLCommand)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

        Set ctp(1)="BINARY"
        Set ctp(2)="DATE"
        Set ctp(3)="DOUBLE"
        Set ctp(4)="HANDLE"
        Set ctp(5)="INTEGER"
        Set ctp(6)="LIST"
        Set ctp(7)="LONGVARCHAR"
        Set ctp(8)="TIME"
        Set ctp(9)="TIMESTAMP"
        Set ctp(10)="VARCHAR"
        Set ctp(11)="STATUS"
        Set ctp(12)="BINARYSTREAM"
        Set ctp(13)="CHARACTERSTREAM"
        Set ctp(14)="NUMERIC"
        Set ctp(15)="CURRENCY"
        Set ctp(16)="BOOLEAN"
        Set ctp(17)="OID"
        Set ctp(18)="BIGINT"
        Set ctp(19)="FDATE"
        Set ctp(20)="FTIMESTAMP"

        //Get Metadata
        Set pkey=""
        While(1) {
            Set tColumn=pStatement.%Metadata.columns.GetNext(.pkey)
            Quit:(pkey="")
            Set tType = tColumn.typeClass
            Set tSQLTable = ""
            If tColumn.typeClass'="",'(tColumn.isKeyColumn),$Piece(tType,".",1)'="%Library",tColumn.typeClass.Super["Persistent" {
                Set tSQLTable =  $Tr($Piece(tColumn.typeClass.Name,".",1,*-1),".","_")_"."_tColumn.typeClass.SqlTableName
            }
            Do tMetaData.%Get("columns").%Set(pkey,{
                    "sqlTableName":(tSQLTable)
                    ,"sqlRowIdName":($Select(tColumn.typeClass.SqlRowIdName'="":tColumn.typeClass.SqlRowIdName,tSQLTable'="":"ID",1:""))
                    ,"sqlFieldName":(tColumn.property.SqlFieldName)
                    ,"propertyName":(tColumn.property.Name)
                    ,"colName":(tColumn.colName)
                    ,"clientType":($Get(ctp(tColumn.clientType),""))
                    ,"collection":(tColumn.property.Collection)
                    ,"isRowId":(tColumn.isRowId)
                    ,"isHidden":(tColumn.isHidden)
                    ,"isNullable":(tColumn.isNullable)
                    ,"readOnly":(tColumn.isReadOnly)
                    ,"label":(tColumn.label)
                    ,"precision":(tColumn.precision)
                    ,"typeClass":(tColumn.typeClass.Name)
                    ,"relationship":(tColumn.property.Relationship)
                    ,"cardinality":(tColumn.property.Cardinality)
                    ,"inverse":(tColumn.property.Inverse)
                    ,"jsonType":($Select("|3|5|14|15|18|"[("|"_tColumn.clientType_"|"):"number",tColumn.clientType=16:"boolean",tColumn.clientType'=4:"string",1:""))
            })
            Set tIsXMLAdaptor = 0
            If tColumn.typeClass.Name'="" Do ##class(apiPub.core.irisMetadata).GetClassDefInfo(tColumn.typeClass.Name,,.tIsXMLAdaptor)
            Do tMetaData.%Get("columns").%Get(pkey).%Set("xmlAdaptor",tIsXMLAdaptor)
        }
        Set pkey=""
        While(1) {
            Set tColumn=pStatement.%Metadata.columns.GetNext(.pkey)
            Quit:(pkey="")
            If (tColumn.isRowId) {
                If (pShowRelationships) {
                    Set tClassDef=##class(%Dictionary.ClassDefinition).%OpenId(tColumn.typeClass.Name)
                    If ('$IsObject(tClassDef)) {
                        Set tSC = $$$ERROR($$$GeneralError, "Invalid Object("_tColumn.typeClass.Name_")")
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                    }
                    Set pskey=""
                    While(1) {
                        Set tPropDef=tClassDef.Properties.GetNext(.pskey)
                        quit:(pskey="")
                        //Assure that is relationship prop
                        If (tPropDef.Relationship),((tPropDef.Cardinality="many")||(tPropDef.Cardinality="children")),tPropDef.SqlFieldName="",tPropDef.SqlColumnNumber="" {
                            Set tSQLTable =  $Tr($Piece(tPropDef.Type,".",1,*-1),".","_")_"."_$Piece(tPropDef.Type,".",*)
                            //Register RelationShip As Metadata
                            Do tMetaData.%Get("relColumns").%Set(tMetaData.%Get("relColumns").%Size()+1,{
                                    "sqlTableName":(tSQLTable)
                                    ,"sqlRowIdName":($Select(tClassDef.SqlRowIdName'="":tClassDef.SqlRowIdName,tSQLTable'="":"ID",1:""))
                                    ,"colName":(tPropDef.Name)
                                    ,"clientType":"HANDLE"
                                    ,"collection":"list"
                                    ,"typeClass":(tPropDef.Type)
                                    ,"relationship":1
                                    ,"cardinality":(tPropDef.Cardinality)
                                    ,"inverse":(tPropDef.Inverse)
                                    ,"jsonType":("")
                            })
                        }
                    }
                }
            }
        }
        Set pJSON = tMetaData
        If pPrintResults {
            Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
            Do tFormatter.FormatToString(pJSON.%ToJSON(),.jsonString)
            Write jsonString
        }
    }
	Catch(e) {
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

/// w ##class(apiPub.utils.sql).SQLToJSON("Select * from Sample.Person",{},.tJSON,{"deepSQL":1,"showRelationships":1})
ClassMethod SQLToJSON(pSQLCommand As %String, pSQLParams As %Library.DynamicObject, Output pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
            If '$Data(pParams) Set pParams={}
            If '$Data(pSQLParams) Set pSQLParams={}
            Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"_")
            Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:0)
            Set pShowNullColumns = $Select(pParams.showNullColumns'="":pParams.showNullColumns,1:0)
            Set pDeepSQL = $Select(pParams.deepSQL'="":pParams.deepSQL,1:1)
            Set pShowListOfSerialObjects = $Select(pParams.showListOfSerialObjects'="":pParams.showListOfSerialObjects,1:1)
            Set pShowRelationships = $Select(pParams.showRelationships'="":pParams.showRelationships,1:1)
            Set pShowMetadata = $Select(pParams.showMetadata'="":pParams.showMetadata,1:0)
            Set pShowSchema = $Select(pParams.showSchema'="":pParams.showSchema,1:0)
            Set pHideRowId = $Select(pParams.hideRowId'="":pParams.hideRowId,1:0)
            Set pFlatMode = $Select(pParams.flatMode'="":pParams.flatMode,1:0)
            Set pSelectMode = $Select(pParams.selectMode'="":pParams.selectMode,1:0)
            Set pCheckNotInformedParams = $Select(pParams.checkNotInformedParams'="":pParams.checkNotInformedParams,1:0)
        
            Kill pJSON
            If '$Data(pInternal) Set pInternal={"keyCtrl":{},"level":0}
            Set tParams = {}.%FromJSON(pParams.%ToJSON())
            Set tParams.printResults = 0

            Set tCommand=pSQLCommand
            Set pCommandParams = {}
            Set tAvoidILoop=""
            Set i = 1
            While tAvoidILoop'=tCommand,$Find(tCommand,"{")>0 {
                Set tAvoidILoop=tCommand  Set i=i+1
                Set tName = $Piece($Piece(tCommand,"{",2),"}",1)
                Set tVarName = "{"_tName_"}"
                If (pCheckNotInformedParams),pSQLParams.%IsDefined(tName)=0 {
                    Set tSC = $$$ERROR($$$GeneralError, "Parameter "_tName_" not informed")
                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                }
                Do pCommandParams.%Set(tName_i,pSQLParams.%Get(tName))
                Set $Extract(tCommand,$Find(tCommand,tVarName)-$Length(tVarName),$Find(tCommand,tVarName)-1)="?"
            }
            If tAvoidILoop=tCommand{
                Set tSC = $$$ERROR($$$GeneralError, "Invalid Parameters")
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }
            Set tSC = ..GetSQLMetaData(tCommand,.tStatement,.tMetaData,tParams)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

            Set pJSON = []
            Set tPars = 0
            Set tItParams = pCommandParams.%GetIterator()
            While (tItParams.%GetNext(.key,.value)) {
                Set tPars=tPars+1
                Set tPars(tPars)=value
            }
            Do tMetaData.%Set("parameters",pCommandParams)
            Set tRS = tStatement.%Execute(tPars...)
            If tRS.%SQLCODE=0 {
                Set tRowId = ""
                Set tMainClass = ""
                While tRS.%Next() {
                    Set tLineObj = {}
                    Set tCol = tMetaData.columns.%GetIterator()
                    While (tCol.%GetNext(.key,.value)) {
                        If value.%Get("isRowId")=1 {
                            Set tRowId = tRS.%GetData(key)
                            Set tMainClass = value.%Get("typeClass")
                        }
                        Set tListValues = []
                        If value.%Get("collection")="list",tRS.%GetData(key)'="" {
                            //Object Reference (List Of Ids)
                            If value.%Get("clientType")="HANDLE",value.%Get("sqlTableName")'="" {
                                If $Listvalid(tRS.%GetData(key)) {
                                    For i=1:1:$Listlength(tRS.%GetData(key)) {
                                        For ii=1:1:$Listlength($Listget(tRS.%GetData(key),i)) {
                                            Set tVal = $Listget($Listget(tRS.%GetData(key),i),ii)
                                            If tVal=+tVal Set tVal=+tVal
                                            Do tListValues.%Push(tVal)
                                        }
                                    }
                                }
                            }
                            Else {
                                If $Listvalid(tRS.%GetData(key)) {
                                    //List Of Types
                                    For i=1:1:$Listlength(tRS.%GetData(key)) {
                                        Set tVal = $Listget(tRS.%GetData(key),i)
                                        Do tListValues.%Push(tVal)
                                    }
                                } Else {
                                    For i=1:1:$Length(tRS.%GetData(key),",") {
                                        Set tVal = $Piece(tRS.%GetData(key),",",i)
                                        Do tListValues.%Push(tVal)
                                    }
                                }
                            }
                        }
                        Else { //Simple Values or References
                            Do tListValues.%Push(tRS.%GetData(key))
                        }
                        //Iterate Through values
                        Set tValues = tListValues.%GetIterator()
                        While (tValues.%GetNext(.tKey,.tValue)) {
                            If (pShowNullColumns)||(tRS.%GetData(key)'="") {
                                Set tDeepSQL = pDeepSQL
                                //Check if is a Child/Parent or One to Many/One
                                Set tCPRelationship = ((value.%Get("relationship")=1)&&("one parent"[value.%Get("cardinality"))&&(value.%Get("inverse")'=""))
                                If (tCPRelationship),pInternal.level>0 Continue
                                If (tCPRelationship) Set tDeepSQL = 0
                                //Take Reference Id and go deep to the next level based on RowId
                                If (tDeepSQL),value.%Get("sqlTableName")'="" {
                                    //Avoid circular ref (keyCtrl).
                                    If pInternal.%Get("level") = 0 Do pInternal.%Set("keyCtrl",{})
                                    Set tSQL = "Select * from "_value.%Get("sqlTableName")
                                    Set tRowIdName="ID"
                                    Set tSC = ..GetSQLMetaData($Piece(tSQL,"Where",1),.tStatRel,.tMetaDataRel,tParams)
                                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                    Set tColRel = tMetaDataRel.columns.%GetIterator()
                                    While (tColRel.%GetNext(.rkey,.rvalue)) {
                                        If rvalue.%Get("isRowId")=1 {
                                            Set tRowIdName = rvalue.%Get("colName")
                                            Quit 
                                        }
                                    }   
                                    Set tSQL = tSQL_" Where "_tRowIdName_" = {id}"                                 
                                    If pInternal.%Get("keyCtrl").%Get(value.%Get("colName")_"|"_value.%Get("sqlTableName")_"|"_tValue)="" {
                                        Do pInternal.%Get("keyCtrl").%Set(value.%Get("colName")_"|"_value.%Get("sqlTableName")_"|"_tValue,1)
                                        Set tSC = ..SQLToJSON(tSQL,{"id":(tValue)},.tSJSON,tParams,{"keyCtrl":(pInternal.keyCtrl),"level":(pInternal.level+1)})
                                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                        If $Data(tSJSON),tSJSON'="",tSJSON.%Size()>0 {
                                            Set tRes = tSJSON.%GetIterator()
                                            While (tRes.%GetNext(.rkey,.rvalue)) {
                                                Set tColName=value.%Get("colName")
                                                If (tColName["Aggregate")||(tColName["HostVar") Set tColName=$Replace(tColName,"_","")
                                                Do ..SetByLineKey(tLineObj,tColName_$Select(value.%Get("collection")="list":pDelim_"+",1:""),rvalue,,pDelim)
                                            }
                                        }
                                    }
                                // Not persistent Object (serial class)
                                } ElseIf value.%Get("clientType")="HANDLE",value.%Get("xmlAdaptor")=1,value.%Get("sqlTableName")="",tRowId'="",tMainClass'="",value.%Get("propertyName")'="" {
                                    Set tMObj = $ClassMethod(tMainClass,"%OpenId",tRowId)
                                    If $IsObject(tMObj) {
                                        Set tListObj = $Property(tMObj,value.%Get("propertyName"))
                                        If $ClassName(tListObj)="%Collection.ListOfObj" {
                                            Set tObj = tListObj.GetNext()
                                            Do {
                                                Set tSC = ##class(JSON.Utils).ObjToJSON(tObj,.tJsonObj,{"printResults":0})
                                                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                                Set tSC = ..SetByLineKey(tLineObj,value.%Get("colName")_$Select(value.%Get("collection")="list":pDelim_"+",1:""),tJsonObj,,pDelim)
                                                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                            } While tListObj.GetNext(tObj)
                                        }
                                    }
                                } Else {
                                    Set tColName=value.%Get("colName")
                                    If (tColName["Aggregate")||(tColName["HostVar") Set tColName=$Replace(tColName,"_","")
                                    Set tSC = 1
                                    If value.%Get("clientType")="TIMESTAMP",tValue'="" {
                                        Set $Extract(tValue,11)="T"
                                        If $Extract(tValue,20)=".",$Find(tValue,"Z")=0 Set tValue=tValue_"Z"
                                    }
                                    If value.%Get("clientType")="DATE",tValue'="",$Find(tValue,"-")=0 {
                                        Set tValue = $ZDT(tValue,3)                                    
                                    }
                                    If 'value.%Get("isRowId")||'(pHideRowId) Set tSC = ..SetByLineKey(tLineObj,tColName_$Select(value.%Get("collection")="list":pDelim_"+",1:""),tValue,value.%Get("jsonType"),pDelim)
                                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                }
                            }
                        }
                    }
                    //Get Children Relationship
                    Set tCol = tMetaData.relColumns.%GetIterator()
                    While ((tRowId'="")&&(tCol.%GetNext(.key,.value))) {
                        If pInternal.%Get("level") = 0 Do pInternal.%Set("keyCtrl",{})
                        Set tSQL = "Select * From "_value.%Get("sqlTableName")_ " Where "_value.%Get("inverse")_" = {id}"
                        Set tSC = ..SQLToJSON(tSQL,{"id":(tRowId)},.tSJSON,tParams,{"keyCtrl":(pInternal.keyCtrl),"level":(pInternal.level+1)})
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                        If $Data(tSJSON),tSJSON'="",tSJSON.%Size()>0 {
                            Set tRes = tSJSON.%GetIterator()
                            While (tRes.%GetNext(.rkey,.rvalue)) {
                                If (pDeepSQL) {
                                    Do ..SetByLineKey(tLineObj,value.%Get("colName")_pDelim_"+",rvalue,,pDelim)
                                } Else {
                                    Do ..SetByLineKey(tLineObj,value.%Get("colName")_pDelim_"+",rvalue.%Get(value.%Get("sqlRowIdName")),,pDelim)
                                }
                            }
                        }
                    }
                    Do pJSON.%Push(tLineObj)
                }
            } Else {
                Set tSC = $$$ERROR($$$GeneralError, "Invalid SQL Code("_tRS.%SQLCODE_") "_tRS.%Message)
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }
            If pInternal.%Get("level")=0 {
                //Flat Mode
                If pFlatMode {
                    Set tFlatResult = []
                    Set tRes = pJSON.%GetIterator()
                    While (tRes.%GetNext(.key,.value)) {
                        Set tSC = ..JSONToFlatJSON(value,.tFlatObj,{"printResults":0,"keyDelimiter":"."})
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                        Do tFlatResult.%Push(tFlatObj)
                    }
                    Set pJSON = tFlatResult
                }
                If (pShowSchema) {
                    Set tSC = ##class(apiPub.core.publisher).TemplateToOpenApiSchema(pJSON,"SchemaName",.tDocJSON,{"printResults":0})
                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                    Set pJSON = tDocJSON
                } ElseIf (pShowMetadata) {
                    Set pJSON = tMetaData
                }
                If pPrintResults {
                    Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                    Do tFormatter.FormatToString(pJSON.%ToJSON(),.jsonString)
                    Write jsonString
                }
            }
    }
    Catch(e) {
        //w $System.Status.GetOneErrorText(e.AsStatus()),!
        Set tSC = e.AsStatus()
    }
    Quit tSC
}

}

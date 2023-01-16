Class apiPub.wizard.api Extends apiPub.core.jsonBuilder [ ProcedureBlock ]
{

/// @apiPub[tag="Create & Publish API From JSON"]
/// @apiPub[path="/fromjson/viewschema"]
ClassMethod viewSchemaFromJSON(obj As %DynamicObject = "myObj", objName As %String, schemaPrefix As %String = "Sch-") As %DynamicObject [ WebMethod ]
{
    If objName="" set objName = "myObj"
    If (('$Data(objName)) || (obj.%Size()=0)) Set obj = {}
    Set tSC = ##class(apiPub.core.publisher).TemplateToOpenApiSchema(obj,objName,.schema,{"printResults":0,"schemaPrefix":(schemaPrefix)})
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    Quit schema
}

/// @apiPub[tag="Create & Publish API From JSON"]
/// @apiPub[response.outputType="text/html"]
/// @apiPub[path="/fromjson/publishApi"]
ClassMethod publishApiFromJSON(obj As %DynamicObject, objName As %String = "myObj", apiDescription As %String = "API Description", apiTitle As %String = "API Title", apiDomain As %String = "Api Domain", apiClassName As %String = "package.fromjson.api", moduleClassName As %String = "package.fromjson.module", appPath As %String = "/{namespace}/fromjsonApi", schemaPrefix As %String = "sch-", charSet As %String = "UTF-8", pReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    If objName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> objName param is required"))}
    If apiClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiClassName param is required"))}
    If moduleClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> moduleClassName param is required"))}
    If apiDomain="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiDomain param is required"))}
    Set $E(objName,1,1)=$ZConvert($E(objName,1,1),"U")
    If obj.%Size()=0 Set objName="object"
    Set tResponseLog = ##class(%Stream.GlobalCharacter).%New()

    Set tSC = ..getAPIPackage(apiClassName, moduleClassName, 0, apiDescription, apiTitle, .tApiPackage, .tAPIClass, .tXData, tResponseLog)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

    // Add validation methods
    If objName'="object",(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=$ZConvert(""Validate"_objName_""",""L"")")=-1) {
        Set tSC = ##class(apiPub.core.publisher).TemplateToOpenApiSchema(obj,objName,.tSchema1,{"printResults":0, "schemaPrefix":(schemaPrefix)})
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        While (..i(tSchema1,,.idx,.val,.it)) {
            If ..g(tXData,"schemas."_idx)="" {
                Do ..s(tXData,"schemas."_idx,val)
            }
        }
        Set tValidateSchemaMethod = {
                "_name":("validate"_objName),
                "Description":(
                    "@apiPub[tag=""api group""]"_$Char(13)_
                    "@apiPub[params.obj.schema="""_schemaPrefix_objName_"""]"_$Char(13)_
                    "@apiPub[response.schema="""_schemaPrefix_objName_"""]"
                ),
                "ClassMethod":1,
                "FormalSpec":"obj:%DynamicObject",
                "ReturnType":"%DynamicObject",
                "WebMethod":1,
                "Implementation":"    Quit obj"
        }
        Do tResponseLog.WriteLine("Method ""validate"_objName_""" created")
        Do ..s(tAPIClass,"Method.+",tValidateSchemaMethod)
    } ElseIf objName="object",..g(tAPIClass,"Method").%Size()=0 {
        // Add sample method
        Set tNewMethod = {
                "_name":"api",
                "Description":(
                    "@apiPub[tag=""api group""]"
                ),
                "ClassMethod":1,
                "FormalSpec":"param:%String",
                "ReturnType":"%Status",
                "WebMethod":1,
                "Implementation":"    Quit $$$OK"
        }
        Do tResponseLog.WriteLine("Method ""api"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    }
    Set tSC = ..createApiModule(tApiPackage, apiClassName, moduleClassName, apiDomain, charSet, 0, 0, tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tSC = ..importApiPackage(tApiPackage, tAPIClass, tXData)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tSC = ..createApiWebApp(appPath, moduleClassName, apiDescription, tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Do tResponseLog.WriteLine("")
    Do tResponseLog.WriteLine("Instructions  ====================================================================================================================")
    Do ..addAPIDocToIntrLog(pReq.RequestURL,appPath, tResponseLog)
    Do tResponseLog.WriteLine("==================================================================================================================================")

    Quit tResponseLog
}

/// @apiPub[tag="Create & Publish API From IRIS Production"]
/// @apiPub[response.outputType="text/html"]
/// @apiPub[path="/fromprod/publishApi"]
/// @apiPub[params.componentName.description="production component name to publish. * to publish all components"]
/// @apiPub[params.componentName.required="true"]
/// @apiPub[params.apiClassName.required="true"]
/// @apiPub[params.moduleClassName.required="true"]
/// @apiPub[params.apiDomain.required="true"]
ClassMethod publishApiFromProd(componentName As %String = "*", apiDescription As %String = "API Description", apiTitle As %String = "API Title", apiDomain As %String = "Api Domain", apiClassName As %String = "package.fromprod.api", moduleClassName As %String = "package.fromprod.module", appPath As %String = "/{namespace}/fromprodApi", charSet As %String = "UTF-8", pReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    If componentName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> componentName param is required"))}
    If apiClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiClassName param is required"))}
    If moduleClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> moduleClassName param is required"))}
    If apiDomain="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiDomain param is required"))}
    Set tResponseLog = ##class(%Stream.GlobalCharacter).%New()

    Set tSC = ..getProduction(.tInteropPackage,.tInteropClass,.tInteropComps,tResponseLog)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

    If componentName'="*",..find(..g(tInteropComps,"Production.Item"),"..g(value,""_Name"")="""_componentName_"""")=-1 {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> component "_componentName_" not found in production"))
    }
    Set tSC = ..getProductionMethods(tInteropComps,componentName,.tProductionMethods,tResponseLog)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

    Set tSC = ..getAPIPackage(apiClassName, moduleClassName, 1, apiDescription, apiTitle, .tApiPackage, .tAPIClass, .tXData, tResponseLog)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

    Set tEsc = $Char(13)
    While (..i(tProductionMethods,"",.idx,.val,.it)) {
        Set tSC = ..getClassDefInfo(..g(val,"class"),,,.isBusinessService,.isBusinessProcess,.isBusinessOperation)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        Set tSC = ..getClassDefInfo(..g(val,"inputType"),,.inputIsXMLAdaptor)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        Set tSC = ..getClassDefInfo(..g(val,"outputType"),,.outputIsXMLAdaptor)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        Set tMethodName = ..g(val,"method")_..normalizeCompName($Piece(..g(val,"component"),".",*-1,*))
        If inputIsXMLAdaptor=1,isBusinessService=0,$Piece(..g(val,"inputType"),".",1)'="apiPub" {
            If ((..g(tAPIClass,"Method")="") || (..find(..g(tAPIClass,"Method"),"$ZCVT(..g(value,""_name""),""L"")=$ZCVT("""_tMethodName_""",""L"")")=-1)) {
                Set tImpSync = tEsc_"    Set tResponse = ##class(Ens.Response).%New()"_
                            tEsc_"    Set tSC = ..SendRequestSync("""_..g(val,"component")_""",pRequest,.tResponse)"_
                            tEsc_"    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)"_
                            tEsc_"    Quit tResponse"_
                            tEsc
                Set tImpAsync = tEsc_"    Quit ..SendRequestAsync("""_..g(val,"component")_""",pRequest)"_tEsc
                Set tCompMethod = {
                        "_name":(tMethodName),
                        "Description":(
                            $Select(isBusinessProcess=1:tEsc_"@apiPub[verb=""put""]",1:"")_
                            tEsc_"@apiPub[tag="""_..g(val,"component")_"""]"_
                            tEsc_"@apiPub[path="""_..normalizeCompName($Piece(..g(val,"component"),".",*-1,*))_"/"_..g(val,"method")_"""]"
                        ),
                        "FormalSpec":("pRequest:"_..g(val,"inputType")_""),
                        "ReturnType":($Select(outputIsXMLAdaptor=1:..g(val,"outputType"),1:"%Status")),
                        "WebMethod":"1",
                        "Implementation":($Select(outputIsXMLAdaptor=1:tImpSync,1:tImpAsync))
                }
                Do tResponseLog.WriteLine("Method """_tMethodName_""" created")
                Do ..s(tAPIClass,"Method.+",tCompMethod)
            }
        }
    }
    Set tSC = ..createApiModule(tApiPackage, apiClassName, moduleClassName, apiDomain, charSet, 0, 1, tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tSC = ..importApiPackage(tApiPackage, tAPIClass, tXData)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tSC = ..createApiWebApp(appPath, moduleClassName, apiDescription, tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    //Automatic inclusion into production api 
    If ..g(tInteropComps,"Production.Item")'="",..find(..g(tInteropComps,"Production.Item"),"..g(value,""_ClassName"")="""_apiClassName_"""")=-1 {
        Set tNewBS = {
            "_Category":"",
            "_ClassName":(apiClassName),
            "_Comment":"",
            "_Enabled":"true",
            "_Foreground":"false",
            "_LogTraceEvents":"false",
            "_Name":(apiClassName),
            "_PoolSize":"0",
            "_Schedule":"",
            "$value":""
        } 
        Do ..s(tInteropComps,"Production.Item.+",tNewBS)
        Do tResponseLog.WriteLine(apiClassName_" added to production")         
        Set tSC = ..importProduction(tInteropPackage,tInteropClass,tInteropComps,tResponseLog)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    }
    Do tResponseLog.WriteLine("")
    Do tResponseLog.WriteLine("Instructions  ====================================================================================================================")
    Do ..addAPIDocToIntrLog(pReq.RequestURL,appPath, tResponseLog)
    Do tResponseLog.WriteLine("==================================================================================================================================")
    Quit tResponseLog
}

ClassMethod importProduction(interopPackage As %DynamicObject, interopClass As %DynamicObject, interopComponents As %DynamicObject, responseLog As %Stream.GlobalCharacter) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set tSC = ##class(apiPub.core.converter).JSONToXML(interopComponents,.tXMLXData,{"printResults":0})  
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        Do tXMLXData.ReadLine()
        Do ..s(interopClass,"XData.Data",tXMLXData.Read())
        Do ##class(apiPub.core.converter).JSONToXML(interopPackage,.xmlProdPackage,{"printResults":0})
        Do $system.OBJ.LoadStream(xmlProdPackage,"ck/displaylog=1")
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod addAPIDocToIntrLog(requestURL As %String, appPath As %String, ByRef logResponse As %Stream.GlobalCharacter)
{
    Do logResponse.WriteLine("API Documentation: "_$Piece(requestURL,"/",1,3)_"/swagger-ui/index.html?url="_$Piece(requestURL,"/",1,3)_$Replace(appPath,"{namespace}",$namespace)_"/_spec")
}

ClassMethod getProductionMethods(interopComponents As %DynamicObject, componentName As %String, Output interopMethods As %DynamicObject, responseLog As %Stream.GlobalCharacter) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set interopMethods = []
        While ..i(interopComponents,"Production.Item",.idx,.val,.it) {
            If componentName'="*",componentName'=..g(val,"_Name") continue
            If ..g(val,"_Enabled")'="true" continue
            Set xdataID=..g(val,"_ClassName")_"||MessageMap"
            Set tXDataMap=##class(%Dictionary.CompiledXData).%OpenId(xdataID)
            If $IsObject(tXDataMap) {
                Set tSC = ##class(apiPub.core.converter).XMLToJSON(tXDataMap.Data,{"list":{"MapItems^MapItem":1},"types":{},"circularRef":{}},.tJSONXDataMap,{"printResults":0})  
                If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
                While ..i(tJSONXDataMap,"MapItems.MapItem",.idxMap,.valMap,.itMap) {
                    Set tMD = ##class(%Dictionary.CompiledMethod).%OpenId(..g(val,"_ClassName")_"||"_..g(valMap,"Method"))
                    If $IsObject(tMD) {
                        Set tOutputType = ""
                        For i=1:1:$ListLength(tMD.FormalSpecParsed) {
                            Set (tParamName,tParamDesc,tParamType,tParamInOut,tParamDefault,tParamAtts)=""
                            Set tSerParam=$ListGet(tMD.FormalSpecParsed,i)
                            For si=1:1:$ListLength(tSerParam) {
                                If si=1 Set tParamName = $ListGet(tSerParam,si)
                                If si=2 Set tParamType = $ListGet(tSerParam,si)
                                If si=3 Set tParamInOut = $ListGet(tSerParam,si)                       
                            }
                            If (i=2) {
                                Set tOutputType = tParamType
                            } 
                        }
                        Do ..s(interopMethods,"+",{
                            "component":(..g(val,"_Name")),
                            "class":(..g(val,"_ClassName")),
                            "method":(..g(valMap,"Method")),
                            "inputType":(..g(valMap,"_MessageType")),
                            "outputType":(tOutputType)
                        })
                    }
                }
            } Else {
                Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(..g(val,"_ClassName")_"||ADAPTER")
                If $IsObject(tMParam) {
                    Set tSC = ..getClassDefInfo(..g(val,"_ClassName"),,,.isBusinessService,.isBusinessProcess,.isBusinessOperation)
                    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
                    If isBusinessService=0 {
                        Set tMD = ##class(%Dictionary.CompiledMethod).%OpenId(tMParam.Default_"||SendMessage")
                        If $IsObject(tMD) {
                            Set (tOutputType,tInputType) = ""
                            For i=1:1:$ListLength(tMD.FormalSpecParsed) {
                                Set (tParamName,tParamDesc,tParamType,tParamInOut,tParamDefault,tParamAtts)=""
                                Set tSerParam=$ListGet(tMD.FormalSpecParsed,i)
                                For si=1:1:$ListLength(tSerParam) {
                                    If si=1 Set tParamName = $ListGet(tSerParam,si)
                                    If si=2 Set tParamType = $ListGet(tSerParam,si)
                                    If si=3 Set tParamInOut = $ListGet(tSerParam,si)                       
                                }
                                If (i=1) {
                                    Set tInputType = tParamType
                                } ElseIf (i=2) {
                                    Set tOutputType = tParamType
                                } 
                            }
                            Do ..s(interopMethods,"+",{
                                "component":(..g(val,"_Name")),
                                "class":(..g(val,"_ClassName")),
                                "method":("SendMessage"),
                                "inputType":(tInputType),
                                "outputType":(tOutputType)
                            })
                        }
                    }
                }
            }
        }
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod getProduction(Output interopPackage As %DynamicObject, Output interopClass As %DynamicObject, Output interopComponents As %DynamicObject, responseLog As %Stream.GlobalCharacter) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set interopPackage = {}
        Set tProdClassDef = ##class(%Dictionary.ClassDefinition).%OpenId(##class(Ens.Director).GetActiveProductionName())
        If '$IsObject(tProdClassDef) {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Current Production isn't set"))
        }
        Set tSC = ##class(%SYSTEM.OBJ).ExportToStream(tProdClassDef.Name_".cls",.tXmlProdClass,"/displaylog=0",.errlog)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        Set tSC = ##class(apiPub.core.converter).XMLToJSON(tXmlProdClass,{"list":{"Export^Class":1,"Export^Class^Method":1,"Export^Class^Parameter":1},"types":{},"circularRef":{}},.interopPackage,{"printResults":0})  
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        Set tIdx = ..find(..g(interopPackage,"Export.Class"),"..g(value,""XData._name"")=""ProductionDefinition""")         
        If tIdx=-1 {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Current Production isn't set"))
        }
        Set tSC=##class(Ens.Director).GetProductionStatus(##class(Ens.Director).GetActiveProductionName(),.tProdState)    
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        //Unpack production
        Set interopClass = ..g(interopPackage,"Export.Class."_tIdx)
        Set tXMLXData = ##class(%Stream.GlobalCharacter).%New()
        Do tXMLXData.Write(..g(interopClass,"XData.Data")) 
        Set tSC = ##class(apiPub.core.converter).XMLToJSON(tXMLXData,{"list":{"Production^Item":1},"types":{},"circularRef":{}},.interopComponents,{"printResults":0})  
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        // Here is the place to manipulate Production items (interopComponents)
        While ..i(interopComponents,"Production.Item",.idx,.val,.it) {
            //fix invalid values
            If $Length($Replace($Replace(..g(val,"$value"),$char(10),"")," ",""))=0 Do ..s(interopComponents,"Production.Item."_idx_".$value","")
        }
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod createApiWebApp(appPath As %String, moduleClassName As %String, appDescription As %String, ByRef logResponse As %Stream.GlobalCharacter) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set tCurrentNS = $namespace
        Set appPath=$Replace(appPath,"{namespace}",tCurrentNS)
        Set webName = appPath
        zn "%SYS" 
        Set webName = appPath
        Set webProperties("DispatchClass") = moduleClassName 
        Set webProperties("NameSpace") = tCurrentNS
        Set webProperties("Description") = appDescription 
        Set webProperties("Enabled") = 1 
        Set webProperties("AutheEnabled") = 32 
        Set webProperties("DeepSeeEnabled")=1 
        If '(##class(Security.Applications).Exists(webName)) {
            Set tSC = ##class(Security.Applications).Create(webName, .webProperties)
            Do logResponse.WriteLine("App """_appPath_""" "_appDescription_" created"_$Char(10,13))
        }
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        zn tCurrentNS

    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod getClassDefInfo(aClassName As %String = "", ByRef timeChanged, Output isXMLAdaptor, Output isBusinessService, Output isBusinessProcess, Output isBusinessOperation, level = 0) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        If level=0 {
            Set (isXMLAdaptor,isBusinessService,isBusinessProcess,isBusinessOperation)=0
        }
        set classDefinition=##class(%Dictionary.ClassDefinition).%OpenId(aClassName)
        if ($isobject(classDefinition)) {
            If '$Data(timeChanged) Set timeChanged = classDefinition.TimeChanged
            If ##class(%Dictionary.ClassDefinition).%ExistsId("%SYSTEM.SQL.Functions")=1 {
                If $System.SQL.Functions.DATEDIFF("ms",$ZDT($Piece(timeChanged,".",1),3),$ZDT($Piece(classDefinition.TimeChanged,".",1),3))>0 Set timeChanged=classDefinition.TimeChanged
            } Else {
                If $System.SQL.DATEDIFF("ms",$ZDT($Piece(timeChanged,".",1),3),$ZDT($Piece(classDefinition.TimeChanged,".",1),3))>0 Set timeChanged=classDefinition.TimeChanged
            }
            if classDefinition.Super'="" {
                If isXMLAdaptor=0,classDefinition.Super["XML.Adaptor" Set isXMLAdaptor=1
                If isBusinessService=0,classDefinition.Super["Ens.BusinessService" Set isBusinessService=1
                If isBusinessProcess=0,classDefinition.Super["Ens.BusinessProcess" Set isBusinessProcess=1
                If isBusinessOperation=0,classDefinition.Super["Ens.BusinessOperation" Set isBusinessOperation=1
                for sup=1:1:$l(classDefinition.Super,",") {  continue:$p(classDefinition.Super,",",sup)=""
                    Set tSuper = $p(classDefinition.Super,",",sup)
                    If $Find(tSuper,"%")=0,$Length(tSuper,".")=1,$Length(aClassName,".")>1 {
                        Set tSuper = $Piece(aClassName,".",1,*-1)_"."_tSuper
                    }
                    Set tSC = ..getClassDefInfo(tSuper,.timeChanged,.isXMLAdaptor,.isBusinessService,.isBusinessProcess,.isBusinessOperation,level+1)
                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                }
            }
        }
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod createApiModule(apiPackage As %DynamicObject, apiClassName As %String, moduleClassName As %String, apiDomain As %String, charSet As %String, traceable As %Boolean = 0, interopApi As %Boolean = 0, ByRef logResponse As %Stream.GlobalCharacter) As %Status
{
	Set tSC = $System.Status.OK()
	Try {
        If ..find(..g(apiPackage,"Export.Class"),"..g(value,""_name"")="""_moduleClassName_"""")=-1 {
            Set tModuleClass =  {
                    "_name":(moduleClassName),
                    "Super":"apiPub.core.service",
                    "TimeChanged":($Now()),
                    "TimeCreated":($Now()),
                    "Parameter": [
                        {
                            "_name":"CHARSET",
                            "Description":"Charset for Output",
                            "Default":(charSet)
                        },                    
                        {
                            "_name":"OASPath",
                            "Description":"Target path for OAS Documentation",
                            "Type":"%String",
                            "Default":"Get:/_spec"
                        },
                        {
                            "_name":"DispatchClass",
                            "Description":"Target class that contains all API (Web Methods) for this module",
                            "Type":"%String",
                            "Default":(apiClassName)
                        },
                        {
                            "_name":"DispatchBSName",
                            "Description":"When the class is also a Business Service",
                            "Type":($Select(interopApi=1:"%String",1:"")),
                            "Default":($Select(interopApi=1:apiClassName,1:""))
                        },
                        {
                            "_name":"Traceable",
                            "Description":"Use IRIS Production to generate tracing and monitoring (dashboards)",
                            "Type":"%Boolean",
                            "Default":(traceable)
                        },
                        {
                            "_name":"APIDomain",
                            "Description":"Group for monitoring",
                            "Default":(apiDomain)
                        },
                        {
                            "_name":"OASNestedMode",
                            "Description":"If OASNestedMode=1 publisher avoid name conflict for OAS Schemas (Complex Requests and Responses)",
                            "Default":(interopApi)
                        }
                    ]
            }
            Do logResponse.WriteLine("Module """_moduleClassName_""" created")
            Do ..s(apiPackage,"Export.Class.+",tModuleClass)
        }
    }
	Catch(e) {
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod getAPIPackage(apiClassName As %String, moduleClassName As %String, interopApi As %Boolean = 0, apiDescription As %String, apiTitle As %String, Output apiPackage, Output apiClass, Output apiXData, ByRef logResponse As %Stream.GlobalCharacter) As %Status
{
	Set tSC = $System.Status.OK()
	Try {
        Set apiXData={}
        Set apiPackage = {
            "Export":{
                "_generator":"IRIS",
                "_version":"26",
                "_zv":($zv),
                "_ts":($ZDT($Now(),3)),
                "Class": [
                ]
            }
        }
        Set tClassesToExport=""
        If $IsObject(##class(%Dictionary.ClassDefinition).%OpenId(apiClassName)) Set tClassesToExport=apiClassName_".cls"
        If $IsObject(##class(%Dictionary.ClassDefinition).%OpenId(moduleClassName)) Set tClassesToExport=tClassesToExport_$Select(tClassesToExport'="":",",1:"")_moduleClassName_".cls"
        If tClassesToExport'="" {
            Set tSC = ##class(%SYSTEM.OBJ).ExportToStream(tClassesToExport,.tPack,"/displaylog=1",.errlog)
            If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
            Set tSC = ##class(apiPub.core.converter).XMLToJSON(tPack,{"list":{"Export^Class":1,"Export^Class^Method":1,"Export^Class^XData":1,"Export^Class^Parameter":1},"types":{},"circularRef":{}},.apiPackage,{"printResults":0})
            If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        Set tIdxClass = ..find(..g(apiPackage,"Export.Class"),"..g(value,""_name"")="""_apiClassName_"""")
        Set tInfo = {
                "description" : (apiDescription),
                "version" : "1.0.0",
                "title" : (apiTitle),
                "termsOfService" : "http://swagger.io/terms/",
                "contact" : {
                    "email" : "apiteam@swagger.io"
                },
                "license" : {
                    "name" : "Apache 2.0",
                    "url" : "http://www.apache.org/licenses/LICENSE-2.0.html"
                }
        }
        Set tXDataObj = {
            "_name":"apiPub",
            "MimeType":"application/json",
            "Data":"{}"
        }
        If tIdxClass=-1 {
            Set apiClass =  {
                        "_name":(apiClassName),
                        "ProcedureBlock":1,
                        "Super":("apiPub.core.jsonBuilder"_$Select(interopApi=1:",Ens.BusinessService",1:"")),
                        "TimeChanged":($Now()),
                        "TimeCreated":($Now()),
                        "Method": [],
                        "XData": [(tXDataObj)]
            }
            Do ..s(apiPackage,"Export.Class.+",apiClass)
            Do ..s(apiXData,"info",tInfo)
        } Else {
            Set apiClass = ..g(apiPackage,"Export.Class."_tIdxClass)
            If ..g(apiClass,"Method")="" {
                Do ..s(apiClass,"Method",[])
            }
            If '$IsObject(..g(apiClass,"XData")) {
                Do ..s(apiClass,"XData",[(tXDataObj)])
                Do ..s(apiXData,"info",tInfo)
            } Else {
                Set tApiPubXDataIdx = ..find(..g(apiClass,"XData"),"$ZConvert(..g(value,""_name""),""L"")=""apipub""")
                If tApiPubXDataIdx'=-1 {
                    Set apiXData = {}.%FromJSON(..g(apiClass,"XData."_tApiPubXDataIdx_".Data"))
                } Else {
                    Do ..s(apiClass,"XData.+",(tXDataObj))
                    Do ..s(apiXData,"info",tInfo)
                }
            }
        }
    }
	Catch(e) {
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod importApiPackage(apiPackage As %DynamicObject, apiClass As %DynamicObject, apiXData As %DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set tFormatter = ##class(%JSON.Formatter).%New()
        Set tFormSchema = ##class(%Stream.GlobalCharacter).%New()
        Set tSC = tFormatter.FormatToStream(apiXData,tFormSchema)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        Set tApiPubXDataIdx = ..find(..g(apiClass,"XData"),"$ZConvert(..g(value,""_name""),""L"")=""apipub""")
        Do ..s(apiClass,"XData."_tApiPubXDataIdx_".Data",$Char(13)_tFormSchema.Read())
        Do ##class(apiPub.core.converter).JSONToXML(apiPackage,.package,{"printResults":0})
        Do $system.OBJ.LoadStream(package,"ck/displaylog=1")
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod normalizeCompName(compName As %String) As %String
{
    Set tCompName = ""
    For i=1:1:$L(compName,".") {
        Set tPiece=$Piece(compName,".",i)
        Set $Extract(tPiece,1,1)=$ZConvert($Extract(tPiece,1,1),"U")
        Set $Extract(tPiece,2,*)=$ZConvert($Extract(tPiece,2,*),"L")
        Set tCompName=tCompName_tPiece
    }
    Quit tCompName
}

XData apiPub [ MimeType = application/json ]
{
{
        "info": {
            "description" : "Wizard Automation for apiPub",
            "version" : "1.0.0",
            "title" : "apiPub Wizard",
            "termsOfService" : "http://swagger.io/terms/",
            "contact" : {
                "email" : "apiteam@swagger.io"
            },
            "license" : {
                "name" : "Apache 2.0",
                "url" : "http://www.apache.org/licenses/LICENSE-2.0.html"
            }
        }
    }
}

}

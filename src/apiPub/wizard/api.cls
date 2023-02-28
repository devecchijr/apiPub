Class apiPub.wizard.api Extends apiPub.core.jsonBuilder [ ProcedureBlock ]
{

/// publish new APIs based on templates
/// @apiPub[tag="new"]
/// @apiPub[response.outputType="text/plain"]
/// @apiPub[path="/new/publishApi"]
/// @apiPub[params.template.schema.items.enum=["get output(status)","get output(text/plain)","get output(application/octet-stream)", "get output(application/json)", "put input/output(application/json)", "put input/output(text/plain)","put input/output(application/octet-stream)","post input/output(application/json)", "post input/output(text/plain)","post input/output(application/octet-stream)"]]
/// @apiPub[params.template.schema.default="get output(status)"]
/// @apiPub[params.apiClassName.description="Api classname (web methods)"]
/// @apiPub[params.moduleClassName.description="Module classname (api configuration options)"]
/// @apiPub[params.traceable.description="Enable http(req/resp) monitoring"]
/// @apiPub[params.apiTitle.description="Api title for OAS"]
/// @apiPub[params.apiDescription.description="Api description for OAS"]
/// @apiPub[params.appPath.description="Api path"]
/// @apiPub[params.oasAppPath.description="Dedicated path for Unathenticated Open API Specification App"]
/// @apiPub[params.apiDomain.description="Monitoring group (traceable on)"]
ClassMethod publishNewAPI(template As %String, apiTitle As %String = "{apiClassName}", apiDescription As %String = "{apiClassName}", apiDomain As %String = "Api Domain", apiClassName As %String = "package.name.api", moduleClassName As %String = "package.name.module", appPath As %String = "/{namespace}/myApi", oasAppPath As %String = "/{namespace}/myApi/oas", charSet As %String = "UTF-8", traceable As %Boolean = 0, pReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    If template="" Set template="object"
    Quit ..publishApiFromJSON({}, template, 0, apiTitle, apiDescription, apiDomain, apiClassName, moduleClassName, appPath, oasAppPath, "", charSet, traceable, pReq)
}

/// view OAS schema based on a JSON sample (object body)
/// @apiPub[tag="schema"]
/// @apiPub[path="/utils/fromjson/viewschema"]
/// @apiPub[params.obj.description="Inform your sample object to view its correspondent Open Api Schema (OAS)"]
/// @apiPub[params.nestedMode.description="Use nestedMode to avoid names conflict"]
ClassMethod viewSchemaFromJSON(obj As %DynamicObject, objName As %String = "myObj", schemaPrefix As %String = "Sch-", nestedMode As %Boolean = 0) As %DynamicObject [ WebMethod ]
{
    If nestedMode = "" set nestedMode = 0
    If objName="" set objName = "myObj"
    If (('$Data(objName)) || (obj.%Size()=0)) Set obj = {}
    Set tSC = ##class(apiPub.core.publisher).TemplateToOpenApiSchema(obj,objName,.schema,{"printResults":0,"schemaPrefix":(schemaPrefix),"nestedMode":(nestedMode)})
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    Quit schema
}

/// view OAS schema based on an IRIS class
/// @apiPub[tag="schema"]
/// @apiPub[path="/utils/fromclass/viewschema"]
/// @apiPub[params.className.description="Inform your classname (%XML.Adaptor inherited) to view its correspondent Open Api Schema (OAS)"]
/// @apiPub[params.nestedMode.description="Use nestedMode to avoid names conflict"]
ClassMethod viewSchemaFromClass(className As %String = "apiPub.samples.Pet", nestedMode As %Boolean = 0) As %DynamicObject [ WebMethod ]
{
    If nestedMode = "" set nestedMode = 0
    Set tSC = ##class(apiPub.core.publisher).GetOpenAPISchema(className,.schema,{"printResults":0,"nestedMode":(nestedMode)})
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    Quit schema
}

/// publish automatically an Api based on existing class/web methods
/// @apiPub[tag="existing web method"]
/// @apiPub[response.outputType="text/plain"]
/// @apiPub[path="/fromwebmethod/publishApi"]
/// @apiPub[params.apiClassName.description="Existing Class"]
/// @apiPub[params.moduleClassName.description="Module classname (api configuration options)"]
/// @apiPub[params.traceable.description="Enable http(req/resp) monitoring"]
/// @apiPub[params.apiTitle.description="Api title for OAS"]
/// @apiPub[params.apiDescription.description="Api description for OAS"]
/// @apiPub[params.appPath.description="Api path"]
/// @apiPub[params.oasAppPath.description="Dedicated path for Unathenticated Open API Specification App"]
/// @apiPub[params.apiDomain.description="Monitoring group (traceable on)"]
ClassMethod publishApiFromExistClass(apiClassName As %String = "existingClassName", moduleClassName As %String = "package.name.module", apiTitle As %String = "{apiClassName}", apiDescription As %String = "{apiClassName}", apiDomain As %String = "Api Domain", appPath As %String = "/{namespace}/myApi", oasAppPath As %String = "/{namespace}/myApi/oas", charSet As %String = "UTF-8", traceable As %Boolean = 0, pReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    If appPath="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> appPath param is required"))}
    If oasAppPath="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> oasAppPath param is required"))}
    If apiClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiClassName param is required"))}
    If moduleClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> moduleClassName param is required"))}
    If apiDomain="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiDomain param is required"))}
    Set tExClas=##class(%Dictionary.CompiledClass).%OpenId(apiClassName)
    If '$IsObject(tExClas) {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> "_apiClassName_" does'nt exist"))}
    Set tResponseLog = ##class(%Stream.GlobalCharacter).%New()
    Set tInstruct = ##class(%Stream.GlobalCharacter).%New()
    Set tInteropPackage = {}
    Set tInteropClass = {}
    Set tInteropComps = {}

    Set tSC = ..getClassDefInfo(apiClassName,,,.isBusinessService,.isBusinessProcess,.isBusinessOperation,.isSOAPService)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

    If (traceable) {
        Set tSC = ..getProduction(.tInteropPackage,.tInteropClass,.tInteropComps,tResponseLog)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    }

    Set tSC = ..getAPIPackage(apiClassName, isSOAPService, moduleClassName, 0, apiTitle, apiDescription, .tApiPackage, .tAPIClass, .tXData, tResponseLog)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    
    Set tSC = ..createApiModule(tApiPackage, apiClassName, isSOAPService, moduleClassName, appPath, apiDomain, charSet, traceable, isBusinessService, tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tSC = ..importApiPackage(tApiPackage, tAPIClass, tXData)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tCompileProd = 0
    If (traceable) {
        Set tSC = ..enableProdTracing(tInteropComps, tInstruct, .tCompileProd)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
    }

    If (tCompileProd) {
        Do tInstruct.WriteLine("Don't forget to update the current production")
        Set tSC = ..importProduction(tInteropPackage,tInteropClass,tInteropComps,tResponseLog)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    }

    Set tSC = ..createApiWebApp(appPath, oasAppPath, moduleClassName, $Replace(apiDescription,"{apiClassName}",apiClassName), tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Do ..addAPIDocToIntrLog(pReq.RequestURL, appPath, oasAppPath, tInstruct)
    Do tResponseLog.WriteLine("")
    Do tResponseLog.WriteLine("Instructions ")
    Do tResponseLog.WriteLine("========================================================================================================================")
    Do tResponseLog.Write(tInstruct.Read())
    Do tResponseLog.WriteLine("========================================================================================================================")
    Quit tResponseLog
}

/// create automatically an IRIS class based on a OAS 3.0 JSON File 
/// @apiPub[tag="api first"]
/// @apiPub[response.outputType="text/plain"]
/// @apiPub[path="/apifirst/fromfile"]
/// @apiPub[params.oasFilePath.description="Inform the path/file name for Open API Specification JSON file (OAS 3.0)"]
/// @apiPub[params.apiClassName.description="Api classname (web methods)"]
/// @apiPub[params.moduleClassName.description="Module classname (api configuration options)"]
/// @apiPub[params.traceable.description="Enable http(req/resp) monitoring"]
/// @apiPub[params.appPath.description="Api path"]
/// @apiPub[params.oasAppPath.description="Dedicated path for Unathenticated Open API Specification App"]
/// @apiPub[params.apiDomain.description="Monitoring group (traceable on)"]
ClassMethod createIRISClassFromOASFile(oasFilePath As %String = "/irisdev/app/tmpFiles/devecchijr7-Pet-1.0.0-swagger.json", apiDomain As %String = "Api Domain", apiClassName As %String = "package.name.fromOASApi", moduleClassName As %String = "package.name.fromOASModule", appPath As %String = "/{namespace}/fromOASApi", oasAppPath As %String = "/{namespace}/fromOASApi/oas", schemaPrefix As %String = "sch-", charSet As %String = "UTF-8", traceable As %Boolean = 0, pReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    Set stream=##class(%FileCharacterStream).%New()
    Set tSC = stream.LinkToFile(oasFilePath)
    If ('tSC)||(stream.SizeGet()=0) { Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> invalid OAS path")) }
    Try {
        Set tOAS = ##Class(%Library.DynamicObject).%FromJSON(stream.Read())
    } Catch (e) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> invalid OAS format"))
    }
    Quit ..createIRISClassFromOAS(tOAS, apiDomain, apiClassName, moduleClassName, appPath, oasAppPath, schemaPrefix, charSet, traceable, pReq)
}

/// create automatically an IRIS class based on a OAS 3.0 JSON payload content
/// @apiPub[tag="api first"]
/// @apiPub[response.outputType="text/plain"]
/// @apiPub[path="/apifirst/fromjson"]
/// @apiPub[params.oasContent.description="Open API Specification (OAS 3.0) JSON payload. Ex: https://petstore3.swagger.io/api/v3/openapi.json"]
/// @apiPub[params.apiClassName.description="Api classname (web methods)"]
/// @apiPub[params.moduleClassName.description="Module classname (api configuration options)"]
/// @apiPub[params.traceable.description="Enable http(req/resp) monitoring"]
/// @apiPub[params.appPath.description="Api path"]
/// @apiPub[params.oasAppPath.description="Dedicated path for Unathenticated Open API Specification App"]
/// @apiPub[params.apiDomain.description="Monitoring group (traceable on)"]
ClassMethod createIRISClassFromOAS(oasContent As %DynamicObject, apiDomain As %String = "Api Domain", apiClassName As %String = "package.name.fromOASApi", moduleClassName As %String = "package.name.fromOASModule", appPath As %String = "/{namespace}/fromOASApi", oasAppPath As %String = "/{namespace}/fromOASApi/oas", schemaPrefix As %String = "sch-", charSet As %String = "UTF-8", traceable As %Boolean = 0, pReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    If traceable="" Set traceable = 0
    If appPath="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> appPath param is required"))}
    If oasAppPath="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> oasAppPath param is required"))}
    If apiClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiClassName param is required"))}
    If moduleClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> moduleClassName param is required"))}
    If apiDomain="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiDomain param is required"))}
    Set tResponseLog = ##class(%Stream.GlobalCharacter).%New()
    Set tInstruct = ##class(%Stream.GlobalCharacter).%New()
    Set tInteropPackage = {}
    Set tInteropClass = {}
    Set tInteropComps = {}
    Set tOAS = {}
    Set tSpec = {}

    Set tExClas=##class(%Dictionary.CompiledClass).%OpenId(apiClassName)
    If $IsObject(tExClas) {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> "_apiClassName_" already exists"))}

    Set tExClas=##class(%Dictionary.CompiledClass).%OpenId(moduleClassName)
    If $IsObject(tExClas) {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> "_moduleClassName_" already exists"))}

    If (traceable) {
        Set tSC = ..getProduction(.tInteropPackage,.tInteropClass,.tInteropComps,tResponseLog)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    }
    Set tSC = ..getAPIPackage(apiClassName, 0, moduleClassName, 0, "{apiClassName}", "{apiClassName}", .tApiPackage, .tAPIClass, .tXData, tResponseLog)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

    Set tSC = ##class(apiPub.core.introspector).getApiClassFromOAS(oasContent, tAPIClass, .tXData, .apiDescription, tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tSC = ..createApiModule(tApiPackage, apiClassName, 0, moduleClassName, appPath, apiDomain, charSet, traceable, 0, tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tSC = ..importApiPackage(tApiPackage, tAPIClass, tXData)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tCompileProd = 0
    If (traceable) {
        Set tSC = ..enableProdTracing(tInteropComps, tInstruct, .tCompileProd)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
    }

    If (tCompileProd) {
        Do tInstruct.WriteLine("Don't forget to update the current production")
        Set tSC = ..importProduction(tInteropPackage,tInteropClass,tInteropComps,tResponseLog)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    }

    Set tSC = ..createApiWebApp(appPath, oasAppPath, moduleClassName, $Replace(apiDescription,"{apiClassName}",apiClassName), tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Do ..addAPIDocToIntrLog(pReq.RequestURL, appPath, oasAppPath, tInstruct)
    Do tResponseLog.WriteLine("")
    Do tResponseLog.WriteLine("Instructions ")
    Do tResponseLog.WriteLine("========================================================================================================================")
    Do tResponseLog.Write(tInstruct.Read())
    Do tResponseLog.WriteLine("========================================================================================================================")
    Quit tResponseLog
}

/// publish automatically an Api based on an IRIS class schema. It creates a JSON schema based on an iris class and relates to Api payload input parameter
/// @apiPub[tag="schema"]
/// @apiPub[response.outputType="text/plain"]
/// @apiPub[path="/fromclass/publishApi"]
/// @apiPub[params.classname.description="iris class name for schema generation"]
/// @apiPub[params.nestedMode.description="Use nestedMode to avoid names conflict"]
/// @apiPub[params.apiClassName.description="Api classname (web methods)"]
/// @apiPub[params.moduleClassName.description="Module classname (api configuration options)"]
/// @apiPub[params.traceable.description="Enable http(req/resp) monitoring"]
/// @apiPub[params.apiTitle.description="Api title for OAS"]
/// @apiPub[params.apiDescription.description="Api description for OAS"]
/// @apiPub[params.appPath.description="Api path"]
/// @apiPub[params.oasAppPath.description="Dedicated path for Unathenticated Open API Specification App"]
/// @apiPub[params.apiDomain.description="Monitoring group (traceable on)"]
ClassMethod publishApiFromClassname(className As %String = "apiPub.samples.Pet", nestedMode As %Boolean = 0, apiTitle As %String = "{apiClassName}", apiDescription As %String = "{apiClassName}", apiDomain As %String = "Api Domain", apiClassName As %String = "package.name.api", moduleClassName As %String = "package.name.module", appPath As %String = "/{namespace}/myApi", oasAppPath As %String = "/{namespace}/myApi/oas", charSet As %String = "UTF-8", traceable As %Boolean = 0, pReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    Set tSC = ##class(apiPub.core.publisher).GetOpenAPISchema(className,.tSchema1,{"printResults":0,"nestedMode":(nestedMode)})
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    Do ..i(tSchema1,,.objName,.tval,.tit)
    If nestedMode = "" set nestedMode = 0
    If traceable="" Set traceable = 0
    If appPath="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> appPath param is required"))}
    If oasAppPath="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> oasAppPath param is required"))}
    If objName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> objName param is required"))}
    If apiClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiClassName param is required"))}
    If moduleClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> moduleClassName param is required"))}
    If apiDomain="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiDomain param is required"))}
    Set tResponseLog = ##class(%Stream.GlobalCharacter).%New()
    Set tInstruct = ##class(%Stream.GlobalCharacter).%New()
    Set tInteropPackage = {}
    Set tInteropClass = {}
    Set tInteropComps = {}
    If (traceable) {
        Set tSC = ..getProduction(.tInteropPackage,.tInteropClass,.tInteropComps,tResponseLog)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    }

    Set tSC = ..getAPIPackage(apiClassName, 0, moduleClassName, 0, apiTitle, apiDescription, .tApiPackage, .tAPIClass, .tXData, tResponseLog)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

    // Add validation methods
    If objName'="object",$find(objName," ")=0,(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=$ZConvert(""validate"_..normalizeCompName(objName)_""",""L"")")=-1) {
        While (..i(tSchema1,,.idx,.val,.it)) {
            If ..g(tXData,"schemas^"_idx)="" {
                Do ..s(tXData,"schemas^"_idx,val,,"^")
            }
        }
        Set tValidateSchemaMethod = {
                "_name":("validate"_..normalizeCompName(objName)),
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "verb":"put",
                            "params.obj.schema":(objName),
                            "params.obj.parse":"true",
                            "response.schema":(objName)
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"obj:%DynamicObject",
                "ReturnType":"%DynamicObject",
                "WebMethod":1,
                "Implementation":("    Quit obj")
        }
        Do tResponseLog.WriteLine("Method ""validate"_..normalizeCompName(objName)_""" created")
        Do ..s(tAPIClass,"Method.+",tValidateSchemaMethod)
    }
    Set tSC = ..createApiModule(tApiPackage, apiClassName, 0, moduleClassName, appPath, apiDomain, charSet, traceable, 0, tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tSC = ..importApiPackage(tApiPackage, tAPIClass, tXData)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tCompileProd = 0
    If (traceable) {
        Set tSC = ..enableProdTracing(tInteropComps, tInstruct, .tCompileProd)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
    }

    If (tCompileProd) {
        Do tInstruct.WriteLine("Don't forget to update the current production")
        Set tSC = ..importProduction(tInteropPackage,tInteropClass,tInteropComps,tResponseLog)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    }

    Set tSC = ..createApiWebApp(appPath, oasAppPath, moduleClassName, $Replace(apiDescription,"{apiClassName}",apiClassName), tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Do ..addAPIDocToIntrLog(pReq.RequestURL, appPath, oasAppPath, tInstruct)
    Do tResponseLog.WriteLine("")
    Do tResponseLog.WriteLine("Instructions ")
    Do tResponseLog.WriteLine("========================================================================================================================")
    Do tResponseLog.Write(tInstruct.Read())
    Do tResponseLog.WriteLine("========================================================================================================================")
    Quit tResponseLog
}

/// publish automatically an Api based on a JSON sample. It creates a JSON schema based on a json sample and relates to Api payload input parameter
/// @apiPub[tag="schema"]
/// @apiPub[response.outputType="text/plain"]
/// @apiPub[path="/fromjson/publishApi"]
/// @apiPub[params.obj.description="This JSON will be used as a sample to generate automatically the API schema validation"]
/// @apiPub[params.nestedMode.description="Use nestedMode to avoid names conflict"]
/// @apiPub[params.apiClassName.description="Api classname (web methods)"]
/// @apiPub[params.moduleClassName.description="Module classname (api configuration options)"]
/// @apiPub[params.traceable.description="Enable http(req/resp) monitoring"]
/// @apiPub[params.apiTitle.description="Api title for OAS"]
/// @apiPub[params.apiDescription.description="Api description for OAS"]
/// @apiPub[params.appPath.description="Api path"]
/// @apiPub[params.oasAppPath.description="Dedicated path for Unathenticated Open API Specification App"]
/// @apiPub[params.apiDomain.description="Monitoring group (traceable on)"]
ClassMethod publishApiFromJSON(obj As %DynamicObject, objName As %String = "myObj", nestedMode As %Boolean = 0, apiTitle As %String = "{apiClassName}", apiDescription As %String = "{apiClassName}", apiDomain As %String = "Api Domain", apiClassName As %String = "package.name.api", moduleClassName As %String = "package.name.module", appPath As %String = "/{namespace}/myApi", oasAppPath As %String = "/{namespace}/myApi/oas", schemaPrefix As %String = "sch-", charSet As %String = "UTF-8", traceable As %Boolean = 0, pReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    If nestedMode = "" set nestedMode = 0
    If traceable="" Set traceable = 0
    If appPath="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> appPath param is required"))}
    If oasAppPath="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> oasAppPath param is required"))}
    If objName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> objName param is required"))}
    If apiClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiClassName param is required"))}
    If moduleClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> moduleClassName param is required"))}
    If apiDomain="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiDomain param is required"))}
    If $find(objName," ")=0 Set $E(objName,1,1)=$ZConvert($E(objName,1,1),"U")
    If obj.%Size()=0,$find(objName," ")=0 Set objName="object"
    Set tResponseLog = ##class(%Stream.GlobalCharacter).%New()
    Set tInstruct = ##class(%Stream.GlobalCharacter).%New()
    Set tInteropPackage = {}
    Set tInteropClass = {}
    Set tInteropComps = {}
    If (traceable) {
        Set tSC = ..getProduction(.tInteropPackage,.tInteropClass,.tInteropComps,tResponseLog)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    }

    Set tSC = ..getAPIPackage(apiClassName, 0, moduleClassName, 0, apiTitle, apiDescription, .tApiPackage, .tAPIClass, .tXData, tResponseLog)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

    // Add validation methods
    If objName'="object",$find(objName," ")=0,(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=$ZConvert(""validate"_objName_""",""L"")")=-1) {
        Set tSC = ##class(apiPub.core.publisher).TemplateToOpenApiSchema(obj,objName,.tSchema1,{"printResults":0, "schemaPrefix":(schemaPrefix), "nestedMode":(nestedMode)})
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        While (..i(tSchema1,,.idx,.val,.it)) {
            If ..g(tXData,"schemas."_idx)="" {
                Do ..s(tXData,"schemas."_idx,val)
            }
        }
        Set tValidateSchemaMethod = {
                "_name":("validate"_objName),
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "verb":"put",
                            "params.obj.schema":(schemaPrefix_objName),
                            "params.obj.parse":"true",
                            "response.schema":(schemaPrefix_objName)
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"obj:%DynamicObject",
                "ReturnType":"%DynamicObject",
                "WebMethod":1,
                "Implementation":("    Quit obj")
        }
        Do tResponseLog.WriteLine("Method ""validate"_objName_""" created")
        Do ..s(tAPIClass,"Method.+",tValidateSchemaMethod)
    } ElseIf objName="object",..g(tAPIClass,"Method").%Size()=0 {
        Set tNewMethod = {
                "_name":"apiMethod",
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "verb":"get",
                            "path":"apipath"
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"param:%String",
                "ReturnType":"%Status",
                "WebMethod":1,
                "Implementation":("    Quit $$$OK")
        }
        Do tResponseLog.WriteLine("Method ""apiMethod"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    } ElseIf objName="get output(status)",(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=""getoutstatus""")=-1) {
        Set tNewMethod = {
                "_name":"getOutStatus",
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "verb":"get",
                            "path":"getStatusPath/{param1}",
                            "params.param1.description":"param description"
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"param1:%String,param2:%Numeric,param3:%Boolean",
                "ReturnType":"%Status",
                "WebMethod":1,
                "Implementation":("    Quit $$$OK")
        }
        Do tResponseLog.WriteLine("Method ""getOutStatus"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    } ElseIf objName="get output(text/plain)",(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=""getoutcharstream""")=-1) {
        Set tNewMethod = {
                "_name":"getOutCharStream",
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "verb":"get",
                            "path":"getCharStreamPath/{param1}",
                            "params.param1.description":"param description",
                            "response.outputType":"text/plain"
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"param1:%String,param2:%Numeric,param3:%Boolean",
                "ReturnType":"%Stream.GlobalCharacter",
                "WebMethod":1,
                "Implementation":("    Set tResp = ##class(%Stream.GlobalCharacter).%New()"_$Char(13)_"    Quit tResp")
        }
        Do tResponseLog.WriteLine("Method ""getOutCharStream"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    } ElseIf objName="get output(application/octet-stream)",(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=""getoutbinstream""")=-1) {
        Set tNewMethod = {
                "_name":"getOutBinStream",
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "verb":"get",
                            "path":"getBinStreamPath/{param1}",
                            "params.param1.description":"param description",
                            "charset":"ISO-8859-1",
                            "response.outputType":"application/octet-stream"
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"param1:%String,param2:%Numeric,param3:%Boolean",
                "ReturnType":"%Stream.GlobalBinary",
                "WebMethod":1,
                "Implementation":("    Set tResp = ##class(%Stream.GlobalBinary).%New()"_$Char(13)_"    Quit tResp")
        }
        Do tResponseLog.WriteLine("Method ""getOutBinStream"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    } ElseIf objName="get output(application/json)",(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=""getoutjson""")=-1) {
        Set tNewMethod = {
                "_name":"getOutJSON",
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "verb":"get",
                            "path":"getJSONPath/{param1}",
                            "params.param1.description":"param description"
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"param1:%String,param2:%Numeric,param3:%Boolean",
                "ReturnType":"%Library.DynamicObject",
                "WebMethod":1,
                "Implementation":("    Set tResp = {""prop"":(param1)}"_$Char(13)_"    Quit tResp")
        }
        Do tResponseLog.WriteLine("Method ""getOutJSON"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    } ElseIf objName="put input/output(application/json)",(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=""putinoutjson""")=-1) {
        Set tNewMethod = {
                "_name":"putInOutJSON",
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "verb":"put",
                            "path":"putInOutJSON/{param1}",
                            "params.param1.description":"param description",
                            "params.param2.description":"payload description"
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"param1:%String,param2:%Library.DynamicObject",
                "ReturnType":"%Library.DynamicObject",
                "WebMethod":1,
                "Implementation":("    Quit param2")
        }
        Do tResponseLog.WriteLine("Method ""putInOutJSON"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    } ElseIf objName="put input/output(text/plain)",(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=""putinouttext""")=-1) {
        Set tNewMethod = {
                "_name":"putInOutText",
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "verb":"put",
                            "path":"putInOutText/{param1}",
                            "params.param1.description":"param description",
                            "params.param2.description":"payload description",
                            "params.param2.inputType":"text/plain",
                            "response.outputType":"text/plain"
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"param1:%String,param2:%Stream.GlobalCharacter",
                "ReturnType":"%Stream.GlobalCharacter",
                "WebMethod":1,
                "Implementation":("    Quit param2")
        }
        Do tResponseLog.WriteLine("Method ""putInOutText"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    } ElseIf objName="put input/output(application/octet-stream)",(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=""putinoutbinstream""")=-1) {
        Set tNewMethod = {
                "_name":"putInOutBinStream",
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "verb":"put",
                            "path":"putInOutBinStream/{param1}",
                            "params.param1.description":"param description",
                            "params.param2.description":"payload description",
                            "params.param2.inputType":"application/octet-stream",
                            "charset":"ISO-8859-1",
                            "response.outputType":"application/octet-stream"
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"param1:%String,param2:%Stream.GlobalBinary",
                "ReturnType":"%Stream.GlobalBinary",
                "WebMethod":1,
                "Implementation":("    Quit param2")
        }
        Do tResponseLog.WriteLine("Method ""putInOutBinStream"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    } ElseIf objName="post input/output(application/json)",(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=""postinoutjson""")=-1) {
        Set tNewMethod = {
                "_name":"postInOutJSON",
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "path":"postInOutJSON/{param1}",
                            "params.param1.description":"param description",
                            "params.param2.description":"payload description"
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"param1:%String,param2:%Library.DynamicObject",
                "ReturnType":"%Library.DynamicObject",
                "WebMethod":1,
                "Implementation":("    Quit param2")
        }
        Do tResponseLog.WriteLine("Method ""postInOutJSON"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    } ElseIf objName="post input/output(text/plain)",(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=""postinouttext""")=-1) {
        Set tNewMethod = {
                "_name":"postInOutText",
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "path":"postInOutText/{param1}",
                            "params.param1.description":"param description",
                            "params.param2.description":"payload description",
                            "params.param2.inputType":"text/plain",
                            "response.outputType":"text/plain"
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"param1:%String,param2:%Stream.GlobalCharacter",
                "ReturnType":"%Stream.GlobalCharacter",
                "WebMethod":1,
                "Implementation":("    Quit param2")
        }
        Do tResponseLog.WriteLine("Method ""postInOutText"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    } ElseIf objName="post input/output(application/octet-stream)",(..find(..g(tAPIClass,"Method"),"$ZConvert(..g(value,""_name""),""L"")=""postinoutbinstream""")=-1) {
        Set tNewMethod = {
                "_name":"postInOutBinStream",
                "Description":(
                    ..getApiPubNotation(
                        {
                            "description":"my api",
                            "tag":"api group",
                            "path":"postInOutBinStream/{param1}",
                            "params.param1.description":"param description",
                            "params.param2.description":"payload description",
                            "params.param2.inputType":"application/octet-stream",
                            "charset":"ISO-8859-1",
                            "response.outputType":"application/octet-stream"
                        }
                    )
                ),
                "ClassMethod":1,
                "FormalSpec":"param1:%String,param2:%Stream.GlobalBinary",
                "ReturnType":"%Stream.GlobalBinary",
                "WebMethod":1,
                "Implementation":("    Quit param2")
        }
        Do tResponseLog.WriteLine("Method ""postInOutBinStream"" created")
        Do ..s(tAPIClass,"Method.+",tNewMethod)
    }
    Set tSC = ..createApiModule(tApiPackage, apiClassName, 0, moduleClassName, appPath, apiDomain, charSet, traceable, 0, tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tSC = ..importApiPackage(tApiPackage, tAPIClass, tXData)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tCompileProd = 0
    If (traceable) {
        Set tSC = ..enableProdTracing(tInteropComps, tInstruct, .tCompileProd)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
    }

    If (tCompileProd) {
        Do tInstruct.WriteLine("Don't forget to update the current production")
        Set tSC = ..importProduction(tInteropPackage,tInteropClass,tInteropComps,tResponseLog)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    }

    Set tSC = ..createApiWebApp(appPath, oasAppPath, moduleClassName, $Replace(apiDescription,"{apiClassName}",apiClassName), tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Do ..addAPIDocToIntrLog(pReq.RequestURL, appPath, oasAppPath, tInstruct)
    Do tResponseLog.WriteLine("")
    Do tResponseLog.WriteLine("Instructions ")
    Do tResponseLog.WriteLine("========================================================================================================================")
    Do tResponseLog.Write(tInstruct.Read())
    Do tResponseLog.WriteLine("========================================================================================================================")
    Quit tResponseLog
}

/// view a JSON sample object based on an OAS schema
/// @apiPub[tag="schema"]
/// @apiPub[path="/utils/fromschema/viewjson"]
/// @apiPub[params.pSchema.description="Inform your JSON Open Api Schema (Children of components/schemas) to view its correspondent sample object. It must contain the other objects related to your main object (object references). "]
ClassMethod viewJSONFromSchema(pSchema As %DynamicObject, objName As %String = "Sch-MyObj") As %DynamicObject [ WebMethod ]
{
    If objName="" set objName = "Sch-MyObj"
    Set tSC = ##class(apiPub.core.publisher).OpenApiSchemaToTemplate(objName,pSchema,.flatSchema,{"printResults":false}) 
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
    Quit flatSchema
}

/// publish automatically an Api based on interoperability components (BP's and BO's from current production)
/// @apiPub[tag="interop"]
/// @apiPub[response.outputType="text/plain"]
/// @apiPub[path="/fromprod/publishApi"]
/// @apiPub[params.componentName.description="production component name to publish. * to publish all components. This generation is based on message mapping or SendMessage method"]
/// @apiPub[params.componentName.required="true"]
/// @apiPub[params.apiClassName.required="true"]
/// @apiPub[params.moduleClassName.required="true"]
/// @apiPub[params.apiDomain.required="true"]
/// @apiPub[params.apiClassName.description="Api classname (web methods)"]
/// @apiPub[params.moduleClassName.description="Module classname (api configuration options)"]
/// @apiPub[params.traceable.description="Enable http(req/resp) monitoring"]
/// @apiPub[params.apiTitle.description="Api title for OAS"]
/// @apiPub[params.apiDescription.description="Api description for OAS"]
/// @apiPub[params.appPath.description="Api path"]
/// @apiPub[params.oasAppPath.description="Dedicated path for Unathenticated Open API Specification App"]
/// @apiPub[params.apiDomain.description="Monitoring group (traceable on)"]
ClassMethod publishApiFromProd(componentName As %String = "*", apiTitle As %String = "{apiClassName}", apiDescription As %String = "{apiClassName}", apiDomain As %String = "Api Domain", apiClassName As %String = "package.name.interopApi", moduleClassName As %String = "package.name.interopModule", appPath As %String = "/{namespace}/myInteropApi", oasAppPath As %String = "/{namespace}/myInteropApi/oas", charSet As %String = "UTF-8", traceable As %Boolean = 0, pReq As apiPub.service.message) As %Stream.GlobalCharacter [ WebMethod ]
{
    If traceable="" Set traceable = 0
    If appPath="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> appPath param is required"))}
    If oasAppPath="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> oasAppPath param is required"))}
    If componentName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> componentName param is required"))}
    If apiClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiClassName param is required"))}
    If moduleClassName="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> moduleClassName param is required"))}
    If apiDomain="" {Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> apiDomain param is required"))}
    Set tResponseLog = ##class(%Stream.GlobalCharacter).%New()
    Set tInstruct = ##class(%Stream.GlobalCharacter).%New()

    Set tSC = ..getProduction(.tInteropPackage,.tInteropClass,.tInteropComps,tResponseLog)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

    If componentName'="*",..find(..g(tInteropComps,"Production.Item"),"..g(value,""_Name"")="""_componentName_"""")=-1 {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> component "_componentName_" not found in production"))
    }
    Set tSC = ..getProductionMethods(tInteropComps,componentName,.tProductionMethods,tResponseLog)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

    Set tSC = ..getAPIPackage(apiClassName, 0, moduleClassName, 1, apiTitle, apiDescription, .tApiPackage, .tAPIClass, .tXData, tResponseLog)
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
                Set tImpSync = tEsc_"    Set tSC = ..SendRequestSync("""_..g(val,"component")_""",pRequest,.tResponse)"_
                            tEsc_"    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)"_
                            tEsc_"    Quit tResponse"_
                            tEsc
                Set tImpAsync = tEsc_"    Quit ..SendRequestAsync("""_..g(val,"component")_""",pRequest)"_tEsc
                Set tCompMethod = {
                        "_name":(tMethodName),
                        "Description":(
                            ..getApiPubNotation(
                                {
                                    "description":("submit "_..g(val,"inputType")_" msg request to "_..g(val,"component")),
                                    "tag":(..g(val,"component")),
                                    "verb":($Select(isBusinessProcess=1:"put",1:"post")),
                                    "path":(..normalizeCompName($Piece(..g(val,"component"),".",*-1,*))_"/"_..g(val,"method"))
                                }
                            )
                        ),
                        "FormalSpec":("pRequest:"_..g(val,"inputType")_$Select(outputIsXMLAdaptor=1:",*tSC:%Status",1:"")),
                        "ReturnType":($Select(outputIsXMLAdaptor=1:..g(val,"outputType"),1:"%Status")),
                        "WebMethod":"1",
                        "Implementation":($Select(outputIsXMLAdaptor=1:tImpSync,1:tImpAsync))
                }
                Do tResponseLog.WriteLine("Method """_tMethodName_""" created")
                Do ..s(tAPIClass,"Method.+",tCompMethod)
            }
        }
    }
    Set tSC = ..createApiModule(tApiPackage, apiClassName, 0, moduleClassName, appPath, apiDomain, charSet, traceable, 1, tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tSC = ..importApiPackage(tApiPackage, tAPIClass, tXData)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tSC = ..createApiWebApp(appPath, oasAppPath, moduleClassName, $Replace(apiDescription,"{apiClassName}",apiClassName), tResponseLog)
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tCompileProd = 0
    If (traceable) {
        Set tSC = ..enableProdTracing(tInteropComps, tInstruct, .tCompileProd)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
    }

    Set tSC = ..enableProdClass(tInteropComps, apiClassName, tInstruct, .tCompileProd)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

    If (tCompileProd) 
    {
        Do tInstruct.WriteLine("Don't forget to update the current production")
        Set tSC = ..importProduction(tInteropPackage,tInteropClass,tInteropComps,tResponseLog)
        If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    }
 
    Do ..addAPIDocToIntrLog(pReq.RequestURL, appPath, oasAppPath, tInstruct)
    Do tResponseLog.WriteLine("")
    Do tResponseLog.WriteLine("Instructions ")
    Do tResponseLog.WriteLine("========================================================================================================================")
    Do tResponseLog.Write(tInstruct.Read())
    Do tResponseLog.WriteLine("========================================================================================================================")
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
        Set tStrContent = ""
        While (tXMLXData.AtEnd=0) {
            Set tStrContent = tStrContent_tXMLXData.Read()
        }
        Do ..s(interopClass,"XData.Data",tStrContent)
        Do ##class(apiPub.core.converter).JSONToXML(interopPackage,.xmlProdPackage,{"printResults":0})
        Do $system.OBJ.LoadStream(xmlProdPackage,"ck/displaylog=1")
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod enableProdClass(interopComponents As %DynamicObject, apiClassName As %String, instruct As %Stream.GlobalCharacter, ByRef compileProd As %Boolean) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set tDevEnv = ("TEST DEVELOPMENT"[$SYSTEM.Version.SystemMode())&&($SYSTEM.Version.SystemMode()'="")
        Set tProdItem = ..find(..g(interopComponents,"Production.Item"),"..g(value,""_ClassName"")="""_apiClassName_"""")
        If (tDevEnv),..g(interopComponents,"Production.Item")'="",tProdItem=-1 {
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
            Do ..s(interopComponents,"Production.Item.+",tNewBS)
            Do instruct.WriteLine(apiClassName_" added to production") 
            Set compileProd = 1        
        } ElseIf ..g(interopComponents,"Production.Item")'="",tProdItem=-1 {
            Do instruct.WriteLine("This is not a TEST or DEVELOPMENT environment")
            Do instruct.WriteLine("If so, configure the System Mode accordingly to automate this process")
            Do instruct.WriteLine("Please include """_apiClassName_""" into current production")
        }
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod enableProdTracing(interopComponents As %DynamicObject, instruct As %Stream.GlobalCharacter, ByRef compileProd As %Boolean) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set tDevEnv = ("TEST DEVELOPMENT"[$SYSTEM.Version.SystemMode())&&($SYSTEM.Version.SystemMode()'="")
        If ..g(interopComponents,"Production.Item")'="" {
            If '(tDevEnv) {
                Do instruct.WriteLine("This is not a TEST or DEVELOPMENT environment")
                Do instruct.WriteLine("If so, configure the System Mode accordingly to automate this process")
            }
            If ..find(..g(interopComponents,"Production.Item"),"..g(value,""_ClassName"")=""apiPub.tracer.bs""")=-1 {
                If '(tDevEnv) Do instruct.WriteLine("Please include ""apiPub.tracer.bs"" into current production for tracing")
                If (tDevEnv) {
                    Set tComp = {
                        "_Category":"",
                        "_ClassName":"apiPub.tracer.bs",
                        "_Comment":"",
                        "_Enabled":"true",
                        "_Foreground":"false",
                        "_LogTraceEvents":"false",
                        "_Name":"apiPub.tracer.bs",
                        "_PoolSize":"0",
                        "_Schedule":"",
                        "$value":""
                    } 
                    Do ..s(interopComponents,"Production.Item.+",tComp)
                    Do instruct.WriteLine("apiPub.tracer.bs added to production") 
                    Set compileProd = 1      
                }  
            }
            If ..find(..g(interopComponents,"Production.Item"),"..g(value,""_ClassName"")=""apiPub.tracer.bm""")=-1 {
                If '(tDevEnv) Do instruct.WriteLine("Please include ""apiPub.tracer.bm"" into current production for tracing")
                If (tDevEnv) {
                    Set tComp = {
                        "_Category":"",
                        "_ClassName":"apiPub.tracer.bm",
                        "_Comment":"",
                        "_Enabled":"true",
                        "_Foreground":"false",
                        "_LogTraceEvents":"false",
                        "_Name":"apiPub.tracer.bm",
                        "_PoolSize":"1",
                        "_Schedule":"",
                        "$value":""
                    } 
                    Do ..s(interopComponents,"Production.Item.+",tComp)
                    Do instruct.WriteLine("apiPub.tracer.bm added to production") 
                    Set compileProd = 1      
                }  
            }
            If ..find(..g(interopComponents,"Production.Item"),"..g(value,""_ClassName"")=""apiPub.tracer.bo""")=-1 {
                If '(tDevEnv) Do instruct.WriteLine("Please include ""apiPub.tracer.bo"" into current production for tracing")
                If (tDevEnv) {
                    Set tComp = {
                        "_Category":"",
                        "_ClassName":"apiPub.tracer.bo",
                        "_Comment":"",
                        "_Enabled":"true",
                        "_Foreground":"false",
                        "_LogTraceEvents":"false",
                        "_Name":"apiPub.tracer.bo",
                        "_PoolSize":"1",
                        "_Schedule":"",
                        "$value":""
                    } 
                    Do ..s(interopComponents,"Production.Item.+",tComp)
                    Do instruct.WriteLine("apiPub.tracer.bo added to production") 
                    Set compileProd = 1      
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

ClassMethod addAPIDocToIntrLog(requestURL As %String, appPath As %String, oasAppPath As %String, ByRef logResponse As %Stream.GlobalCharacter)
{
    Do logResponse.WriteLine("Open Api Spec: "_$Piece(requestURL,"/",1,3)_$Replace(oasAppPath,"{namespace}",$namespace)_"/_spec")
    Do logResponse.WriteLine("Swagger URL  : "_$Piece(requestURL,"/",1,3)_"/swagger-ui/index.html?url="_$Piece(requestURL,"/",1,3)_$Replace(oasAppPath,"{namespace}",$namespace)_"/_spec")
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
        If ..g(interopComponents,"Production.Item")="" Do ..s(interopComponents,"Production.Item",[])
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

ClassMethod createApiWebApp(appPath As %String, oasAppPath As %String, moduleClassName As %String, appDescription As %String, ByRef logResponse As %Stream.GlobalCharacter) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set tCurrentNS = $namespace
        Set appPath=$Replace(appPath,"{namespace}",tCurrentNS)
        Set oasAppPath=$Replace(oasAppPath,"{namespace}",tCurrentNS)
        zn "%SYS" 
        Set webName = appPath
        Set webProperties("DispatchClass") = moduleClassName 
        Set webProperties("NameSpace") = tCurrentNS
        Set webProperties("Description") = appDescription 
        Set webProperties("Enabled") = 1 
        Set webProperties("AutheEnabled") = 32 
        Set webProperties("DeepSeeEnabled")=1 
        If '($ClassMethod("Security.Applications","Exists",webName)) {
            Set tSC = $ClassMethod("Security.Applications","Create",webName,.webProperties)
            Do logResponse.WriteLine("App """_appPath_""" ("_appDescription_") created"_$Char(10,13))
        }
        Set webName = oasAppPath
        Set tOASModuleClassName = $Piece(moduleClassName,".",*)
        Set tOASModuleClassName = "oas"_$ZConvert($Extract(tOASModuleClassName,1,1),"U")_$Extract(tOASModuleClassName,2,*)
        If $Find(moduleClassName,".")>0 Set tOASModuleClassName=$Piece(moduleClassName,".",1,*-1)_"."_tOASModuleClassName
        Set webProperties("DispatchClass") = tOASModuleClassName 
        Set webProperties("NameSpace") = tCurrentNS
        Set webProperties("Description") = "unauthenticated specification App for "_appDescription 
        Set webProperties("Enabled") = 1 
        Set webProperties("AutheEnabled") = 64 
        Set webProperties("DeepSeeEnabled")=1 
        If '($ClassMethod("Security.Applications","Exists",webName)) {
            Set tSC = $ClassMethod("Security.Applications","Create",webName,.webProperties)
            Do logResponse.WriteLine("OAS App """_oasAppPath_""" ("_appDescription_") created"_$Char(10,13))
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

ClassMethod getClassDefInfo(aClassName As %String = "", ByRef timeChanged, Output isXMLAdaptor, Output isBusinessService, Output isBusinessProcess, Output isBusinessOperation, Output isSOAPService, level = 0) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        If level=0 {
            Set (isXMLAdaptor,isBusinessService,isBusinessProcess,isBusinessOperation,isSOAPService)=0
        }
        set classDefinition=##class(%Dictionary.ClassDefinition).%OpenId(aClassName)
        if ($isobject(classDefinition)) {
            If '$Data(timeChanged) Set timeChanged = +$TR($ZDatetime(classDefinition.TimeChanged,8,9)," :","")
            If +$TR($ZDatetime(classDefinition.TimeChanged,8,9)," :","")>timeChanged Set timeChanged=+$TR($ZDatetime(classDefinition.TimeChanged,8,9)," :","")
            if classDefinition.Super'="" {
                If isXMLAdaptor=0,classDefinition.Super["XML.Adaptor" Set isXMLAdaptor=1
                If isBusinessService=0,classDefinition.Super["Ens.BusinessService" Set isBusinessService=1
                If isBusinessProcess=0,classDefinition.Super["Ens.BusinessProcess" Set isBusinessProcess=1
                If isBusinessOperation=0,classDefinition.Super["Ens.BusinessOperation" Set isBusinessOperation=1
                If isSOAPService=0,classDefinition.Super["EnsLib.SOAP.Service" Set isSOAPService=1
                for sup=1:1:$l(classDefinition.Super,",") {  continue:$p(classDefinition.Super,",",sup)=""
                    Set tSuper = $p(classDefinition.Super,",",sup)
                    If $Find(tSuper,"%")=0,$Length(tSuper,".")=1,$Length(aClassName,".")>1 {
                        Set tSuper = $Piece(aClassName,".",1,*-1)_"."_tSuper
                    }
                    Set tSC = ..getClassDefInfo(tSuper,.timeChanged,.isXMLAdaptor,.isBusinessService,.isBusinessProcess,.isBusinessOperation,.isSOAPService,level+1)
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

ClassMethod createApiModule(apiPackage As %DynamicObject, apiClassName As %String, isSOAPService As %Boolean, moduleClassName As %String, appPath As %String, apiDomain As %String, charSet As %String, traceable As %Boolean = 0, interopApi As %Boolean = 0, ByRef logResponse As %Stream.GlobalCharacter) As %Status
{
	Set tSC = $System.Status.OK()
	Try {
        If (isSOAPService) Set traceable = 0
        Set tModuleIdx = ..find(..g(apiPackage,"Export.Class"),"..g(value,""_name"")="""_moduleClassName_"""")
        If tModuleIdx=-1 {
            Set tModuleClass =  {
                    "_name":(moduleClassName),
                    "Super":"apiPub.core.service",
                    "TimeChanged":($Now()),
                    "TimeCreated":($Now()),
                    "Parameter": [
                        {"_name":"CHARSET","Description":"Charset for Output","Default":(charSet)},                    
                        {"_name":"OASPath","Description":"Target path for OAS Documentation","Type":"%String","Default":"Get:/_spec"},
                        {"_name":"DispatchClass","Description":"Target class that contains all API (Web Methods) for this module","Type":"%String","Default":(apiClassName)},
                        {"_name":"DispatchBSName","Description":"When the class is also a Business Service","Type":($Select(interopApi=1:"%String",1:"")),"Default":($Select(interopApi=1:apiClassName,1:""))},
                        {"_name":"Traceable","Description":"Use IRIS Production to generate tracing and monitoring (dashboards)","Type":"%Boolean","Default":(traceable)},
                        {"_name":"APIDomain","Description":"Group for monitoring","Default":(apiDomain)},
                        {"_name":"OASNestedMode","Description":"If OASNestedMode=1 publisher avoid name conflict for OAS Schemas (Complex Requests and Responses)","Default":(interopApi)},
                        {"_name":"BeautifyJsonBodyRequest","Description":"format/prettify the JSON request body","Default":(traceable)},
                        {"_name":"BeautifyJsonBodyResponse","Description":"format/prettify the JSON response body","Default":(traceable)}
                    ]
            }
            Do logResponse.WriteLine("Module """_moduleClassName_""" created")
            Do ..s(apiPackage,"Export.Class.+",tModuleClass)
        } Else {
            Set tModuleClass = ..g(apiPackage,"Export.Class."_tModuleIdx)
            Set tParTraceable = ..find(..g(tModuleClass,"Parameter"),"..g(value,""_name"")=""Traceable""")
            If tParTraceable=-1 Do ..s(tModuleClass,"Parameter.+",{"_name":"Traceable","Description":"Use IRIS Production to generate tracing and monitoring (dashboards)","Type":"%Boolean","Default":(traceable)})
            If tParTraceable'=-1,traceable'=+..g(tModuleClass,"Parameter."_tParTraceable_".Default") {
                Do logResponse.WriteLine("Module """_moduleClassName_""" modified, parameter Traceable = "_traceable)            
                Do ..s(tModuleClass,"Parameter."_tParTraceable_".Default",traceable)
            }
            Do ..s(apiPackage,"Export.Class."_tModuleIdx,tModuleClass)
        }
        Set appPath=$Replace(appPath,"{namespace}",$namespace)
        Set tOASModuleClassName = $Piece(moduleClassName,".",*)
        Set tOASModuleClassName = "oas"_$ZConvert($Extract(tOASModuleClassName,1,1),"U")_$Extract(tOASModuleClassName,2,*)
        If $Find(moduleClassName,".")>0 Set tOASModuleClassName=$Piece(moduleClassName,".",1,*-1)_"."_tOASModuleClassName
        Set tOASModuleIdx = ..find(..g(apiPackage,"Export.Class"),"..g(value,""_name"")="""_tOASModuleClassName_"""")
        If tOASModuleIdx=-1 {
            Set tOASModuleClass =  {
                    "_name":(tOASModuleClassName),
                    "Super":"apiPub.core.service",
                    "TimeChanged":($Now()),
                    "TimeCreated":($Now()),
                    "Parameter": [
                        {"_name":"OnlyOAS","Description":"If false allows API Calling","Default":1},                    
                        {"_name":"DispatchBaseURL","Description":"Useful to treat documentation and api (urls) separately (different web applications)","Default":(appPath)},                    
                        {"_name":"CHARSET","Description":"Charset for Output","Default":(charSet)},                    
                        {"_name":"OASPath","Description":"Target path for OAS Documentation","Type":"%String","Default":"Get:/_spec"},
                        {"_name":"DispatchClass","Description":"Target class that contains all API (Web Methods) for this module","Type":"%String","Default":(apiClassName)},
                        {"_name":"DispatchBSName","Description":"When the class is also a Business Service","Type":($Select(interopApi=1:"%String",1:"")),"Default":($Select(interopApi=1:apiClassName,1:""))},
                        {"_name":"Traceable","Description":"Use IRIS Production to generate tracing and monitoring (dashboards)","Type":"%Boolean","Default":0},
                        {"_name":"APIDomain","Description":"Group for monitoring","Default":(apiDomain)},
                        {"_name":"OASNestedMode","Description":"If OASNestedMode=1 publisher avoid name conflict for OAS Schemas (Complex Requests and Responses)","Default":(interopApi)},
                        {"_name":"BeautifyJsonBodyRequest","Description":"format/prettify the JSON request body","Default":"0"},
                        {"_name":"BeautifyJsonBodyResponse","Description":"format/prettify the JSON response body","Default":"0"}
                    ]
            }
            Do logResponse.WriteLine("OAS Module """_tOASModuleClassName_""" created")
            Do ..s(apiPackage,"Export.Class.+",tOASModuleClass)
        } 
    }
	Catch(e) {
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod getAPIPackage(apiClassName As %String, isSOAPService As %Boolean, moduleClassName As %String, interopApi As %Boolean = 0, apiTitle As %String, apiDescription As %String, Output apiPackage, Output apiClass, Output apiXData, ByRef logResponse As %Stream.GlobalCharacter) As %Status
{
	Set tSC = $System.Status.OK()
	Try {
        Set apiTitle = $Replace(apiTitle,"{apiClassName}",apiClassName)
        Set apiDescription = $Replace(apiDescription,"{apiClassName}",apiClassName)
        Set apiXData={}
        Set apiClass={}
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
        If '(isSOAPService),$IsObject(##class(%Dictionary.ClassDefinition).%OpenId(apiClassName)) Set tClassesToExport=apiClassName_".cls"
        If $IsObject(##class(%Dictionary.ClassDefinition).%OpenId(moduleClassName)) Set tClassesToExport=tClassesToExport_$Select(tClassesToExport'="":",",1:"")_moduleClassName_".cls"
        Set tOASModuleClassName = $Piece(moduleClassName,".",*)
        Set tOASModuleClassName = "oas"_$ZConvert($Extract(tOASModuleClassName,1,1),"U")_$Extract(tOASModuleClassName,2,*)
        If $Find(moduleClassName,".")>0 Set tOASModuleClassName=$Piece(moduleClassName,".",1,*-1)_"."_tOASModuleClassName
        If $IsObject(##class(%Dictionary.ClassDefinition).%OpenId(tOASModuleClassName)) Set tClassesToExport=tClassesToExport_$Select(tClassesToExport'="":",",1:"")_tOASModuleClassName_".cls"
        If tClassesToExport'="" {
            Set tSC = ##class(%SYSTEM.OBJ).ExportToStream(tClassesToExport,.tPack,"/displaylog=1",.errlog)
            If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
            Set tSC = ##class(apiPub.core.converter).XMLToJSON(tPack,{"list":{"Export^Class":1,"Export^Class^Method":1,"Export^Class^XData":1,"Export^Class^Parameter":1},"types":{},"circularRef":{}},.apiPackage,{"printResults":0})
            If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
        }
        If '(isSOAPService) {
            Set tIdxClass = ..find(..g(apiPackage,"Export.Class"),"..g(value,""_name"")="""_apiClassName_"""")
            Set tInfo = {
                    "title" : (apiTitle),
                    "description" : (apiDescription),
                    "version" : "1.0.0",
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
                    }
                    If ..g(apiXData,"info")="" Do ..s(apiXData,"info",tInfo)
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
        If apiXData.%Size()'=0 {
            Set tFormatter = ##class(%JSON.Formatter).%New()
            Set tFormSchema = ##class(%Stream.GlobalCharacter).%New()
            Set tSC = tFormatter.FormatToStream(apiXData,tFormSchema)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            Set tApiPubXDataIdx = ..find(..g(apiClass,"XData"),"$ZConvert(..g(value,""_name""),""L"")=""apipub""")
            Set tStrContent = ""
            Do tFormSchema.Rewind()
            While (tFormSchema.AtEnd=0) {
                Set tStrContent = tStrContent_tFormSchema.Read()
            }
            Do ..s(apiClass,"XData."_tApiPubXDataIdx_".Data",$Char(13)_tStrContent)
        }
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

ClassMethod getApiPubNotation(params As %DynamicObject) As %String
{
    Set tRet = ""
    If ..g(params,"description")'="" Set tRet=..g(params,"description")
    If ..g(params,"desc")'="" Set tRet=..g(params,"desc")
    While (..i(params, ,.idx,.val,.it)) {
        If ((idx="description")||(idx="desc")) continue
        Set tRet = tRet_$Select(tRet'="":$Char(13,10),1:tRet)_"@apiPub["_idx_"="_$Select(($IsObject(val)):val.%ToJSON(),1:""""_val_"""")_"]"
    }
    Quit tRet
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
        },
        "tags": [
            {
            "name": "new",
            "description": "New APIs based on basic templates."
            },
            {
            "name": "existing web method",
            "description": "From existing class/web methods"
            },
            {
            "name": "schema",
            "description": "Payload validation with Open API Schema"
            },
            {
            "name": "interop",
            "description": "From interoperability components (Production)"
            },
            {
            "name": "api first",
            "description": "From Open API Specification (OAS 3.0) - API First"
            }
        ]
    }
}

}

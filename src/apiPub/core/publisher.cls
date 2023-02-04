Class apiPub.core.publisher Extends apiPub.core.jsonBuilder
{

ClassMethod GetOASFromClass(pClassName As %String, Output pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject, pBaseURL As %String) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        If '$Data(pParams) Set pParams={}
        If '$Data(pBaseURL) Set pBaseURL=""
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^")
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pIncludeXML = $Select(pParams.includeXML'="":pParams.includeXML,1:0)
        Set pNestedMode = $Select(pParams.nestedMode'="":pParams.nestedMode,1:0)
        Set pClassMethodOnly = $Select(pParams.classMethodOnly'="":pParams.classMethodOnly,1:0)
        Set pMethodName = $Select(pParams.methodName'="":pParams.methodName,1:"")
        Set pBasePath = $Select(pParams.basePath'="":pParams.basePath,1:"")
        Set pAuthMethod = $Select(pParams.authMethod'="":pParams.authMethod,1:"basic")
        Set pJSON = {}
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||SERVICENAME")
        Set tTitle=pClassName_" API"
        If $IsObject(tMParam) Set tTitle = tMParam.Default
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||TITLE")
        If $IsObject(tMParam) Set tTitle = tMParam.Default
        Set pNS=pBaseURL
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||SERVICEURL")
        If $IsObject(tMParam) Set pNS = tMParam.Default
        Set tSC = ##Class(apiPub.core.irisMetadata).GetMethodsInfo(pClassName,pMethodName,.mInfo,{"printResults":0})
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||DESCRIPTION")
        Set pDescription = pParams.description
        If $IsObject(tMParam) Set pDescription = tMParam.Default
        If pDescription="" Set pDescription = mInfo.%Get("description")
        If pDescription="" Set pDescription = tTitle
        Set tSchemas = {}
        Set tSchemaDef = {}
        Set tTitle = $Select(pParams.title'="":pParams.title,1:tTitle)
        Set tVersion = "1.0.0-oas3"
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||VERSION")
        If $IsObject(tMParam) Set tVersion = tMParam.Default
        Set tTermsOfService="http://swagger.io/terms/"
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||TERMSOFSERVICE")
        If $IsObject(tMParam) Set tTermsOfService = tMParam.Default
        Set tContactName = ""
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||CONTACTNAME")
        If $IsObject(tMParam) Set tContactName = tMParam.Default
        If tContactName'="" Do ..s(tSchemaDef,"info.contact.name",tContactName,,".")
        Set tContactEmail = "apiteam@swagger.io"
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||CONTACTEMAIL")
        If $IsObject(tMParam) Set tContactEmail = tMParam.Default
        Set tContactURL = ""
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||CONTACTURL")
        If $IsObject(tMParam) Set tContactURL = tMParam.Default
        Set tLicenseName = "Apache 2.0"
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||LICENSENAME")
        If $IsObject(tMParam) Set tLicenseName = tMParam.Default
        Set tLicenseURL = "http://www.apache.org/licenses/LICENSE-2.0.html"
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||LICENSEURL")
        If $IsObject(tMParam) Set tLicenseURL = tMParam.Default
        Set pTagName=pClassName
        Set (pTagDescription,pTagDocsDescription,pTagDocsUrl)=""
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||TAGNAME")
        If $IsObject(tMParam) Set pTagName = tMParam.Default
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||TAGDESCRIPTION")
        If $IsObject(tMParam) Set pTagDescription = tMParam.Default
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||TAGDOCSDESCRIPTION")
        If $IsObject(tMParam) Set pTagDocsDescription = tMParam.Default
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||TAGDOCSURL")
        If $IsObject(tMParam) Set pTagDocsUrl = tMParam.Default
        Set tTags=0
        Do ..s(tSchemaDef,"openapi","3.0.0",,".")
        If mInfo.%Get("customInfo")'="" {
            Do ..s(tSchemaDef,"info",mInfo.%Get("customInfo"),,".")
        } Else {
            Do ..s(tSchemaDef,"info.description",pDescription,,".")
            Do ..s(tSchemaDef,"info.version",tVersion,,".")
            Do ..s(tSchemaDef,"info.title",tTitle,,".")
            Do ..s(tSchemaDef,"info.termsOfService",tTermsOfService,,".")
            Do ..s(tSchemaDef,"info.contact.email", tContactEmail,,".")
            Do ..s(tSchemaDef,"info.contact.url", tContactURL,,".")
            Do ..s(tSchemaDef,"info.license.name",tLicenseName,,".")
            Do ..s(tSchemaDef,"info.license.url",tLicenseURL,,".")
        }
        If mInfo.%Get("customTags")'="" {
            Do ..s(tSchemaDef,"tags",mInfo.%Get("customTags"),,".")
            Set pTagName=mInfo.%Get("customTags").%Get(0).%Get("name")
        } Else {
            Do tSchemaDef.%Set("tags",[])
        }
        Do tSchemaDef.%Set("paths",{})
        If mInfo.%Get("customSchemas")'="" {
            Do ..s(tSchemaDef,"components.schemas",mInfo.%Get("customSchemas"),,".")
        }
        Set tMet = mInfo.%Get("methods").%GetIterator()
        While tMet.%GetNext(.key,.value) {
            Set (tTagDescription,tTagDocsDescription,tTagDocsUrl)=""
            If (pClassMethodOnly),'(value.%Get("classMethod")) Continue
            Set tOperationId = ..g(value,"customParams.operationId")
            If tOperationId="" Set tOperationId=key
            Set tSummary = ..g(value,"description")
            Set tDescription = ..g(value,"customParams.description")
            If tDescription="" Set tDescription = tOperationId_$Select(tSummary'="":" - "_tSummary,1:$Select(..g(value,"customParams.summary")'="":" - "_..g(value,"customParams.summary"),1:""))
            If ..g(value,"customParams.summary")'="" Set tSummary = ..g(value,"customParams.summary")
            Set tVerb=$zConvert(value.%Get("verb"),"L")
            Set tDeprecated=..g(value,"customParams.deprecated")
            If $ZConvert(tDeprecated,"L")="true" Set tDeprecated = 1
            If '(tDeprecated) Set tDeprecated = 0
            Set tInBodyObjCount = value.%Get("inputBodyParams").%Size()+value.%Get("byRefBodyParams").%Size()
            If value.%Get("customParams").%Get("path")'="" {
                Set tPath = $Replace("/"_$Select(pBasePath'="":pBasePath_"/",1:"")_value.%Get("customParams").%Get("path"),"//","/")
            } Else {
                Set tPath = $Replace("/"_$Select(pBasePath'="":pBasePath_"/",1:"")_key,"//","/")
            }
            Set tConsumes = ..g(value,"customParams.consumes")
            Set tProduces = ..g(value,"customParams.produces")
            Set tTagName=pTagName
            Set tCustomTag = ..g(value,"customParams.tag")
            If tCustomTag'="",$IsObject(tCustomTag) {
                If tCustomTag.%Get("name")'="" Set tTagName = tCustomTag.%Get("name")
            }
            If tCustomTag'="",'$IsObject(tCustomTag) Set tTagName = tCustomTag
            If tTagName=pTagName {
                If tTagDescription="" Set tTagDescription=pTagDescription
                If tTagDocsDescription="" Set tTagDocsDescription=pTagDocsDescription
                If tTagDocsUrl="" Set tTagDocsUrl=pTagDocsUrl
            }
            Set tTagKey=-1
            Set tTags = tSchemaDef.%Get("tags").%GetIterator()
            While tTags.%GetNext(.tkey,.tvalue) {
                If tvalue.%Get("name")=tTagName {
                    Set tTagKey = tkey
                }
            }
            If tTagKey=-1 {
                Set tTagKey=tSchemaDef.%Get("tags").%Size()
                Do ..s(tSchemaDef,"tags"_pDelim_tTagKey_pDelim_"name",tTagName,,pDelim)
            }
            If tTagDescription'="" Do ..s(tSchemaDef,"tags"_pDelim_tTagKey_pDelim_"description",tTagDescription,,pDelim)
            If tTagDocsDescription'="" Do ..s(tSchemaDef,"tags"_pDelim_tTagKey_pDelim_"externalDocs"_pDelim_"description",tTagDocsDescription,,pDelim)
            If tTagDocsUrl'="" Do ..s(tSchemaDef,"tags"_pDelim_tTagKey_pDelim_"externalDocs"_pDelim_"url",tTagDocsUrl,,pDelim)
            
            Set tPathKey="paths^"_tPath_"^"_tVerb_"^"
            Do ..s(tSchemaDef,tPathKey_"tags[0]",tTagName,,"^")
            If tSummary'="" Do ..s(tSchemaDef,tPathKey_"summary",tSummary,,"^")
            If tDescription'="" Do ..s(tSchemaDef,tPathKey_"description",tDescription,,"^")
            If (tDeprecated) Do ..s(tSchemaDef,tPathKey_"deprecated",tDeprecated,"boolean","^")
            Do ..s(tSchemaDef,tPathKey_"operationId",tOperationId,,"^")
            If tConsumes'="" Do ..s(tSchemaDef,tPathKey_"consumes",tConsumes,,"^")
            If tProduces'="" Do ..s(tSchemaDef,tPathKey_"produces",tProduces,,"^")
            Set tOutParObjCount=0
            Set (tParamDescription,tParamRequired)=""
            If value.%Get("customParams").%Get("params")'="" {
                Set tParamDescription = value.%Get("customParams").%Get("params").%Get("description")
                Set tParamRequired = value.%Get("customParams").%Get("params").%Get("required")
                If tParamRequired="" Set tParamRequired=1
            }
            Set tPar = value.%Get("formalSpec").%GetIterator()
            While tPar.%GetNext(.pkey,.pvalue) {
                Set tCustomDescription = ..g(value,"customParams.params."_pvalue.%Get("param")_".description")
                If pvalue.%Get("param")'="response",(pvalue.%Get("outputOnly")=1)||(pvalue.%Get("byRef")=1) Set tOutParObjCount=tOutParObjCount+1
                //Special type to get the whole http request
                If pvalue.%Get("paramType")="apiPub.service.message",..g(value,"param")'="response" Continue
                Set tIsArray=($Piece(pvalue.%Get("paramType"),"|",2)'="")
                If pvalue.%Get("inputType")'="",$Find("application/x-www-form-urlencoded multipart/form-data",pvalue.%Get("inputType"))>0 {
                    //for x-www-form-urlencoded and multipart/form-data inputType
                    Do ..s(tSchemaDef,tPathKey_"requestBody^content^"_pvalue.%Get("inputType")_"^schema^type","object",,"^")
                    Do ..s(tSchemaDef,tPathKey_"requestBody^content^"_pvalue.%Get("inputType")_"^schema^properties^"_pvalue.%Get("paramName")_"^type",pvalue.%Get("pmJDType"),,"^")
                    If pvalue.%Get("pmJDFormat")'="" Do ..s(tSchemaDef,tPathKey_"requestBody^content^"_pvalue.%Get("inputType")_"^schema^properties^"_pvalue.%Get("paramName")_"^format",pvalue.%Get("pmJDFormat"),,"^")
                    If tCustomDescription'="" Do ..s(tSchemaDef,tPathKey_"requestBody^content^"_pvalue.%Get("inputType")_"^schema^properties^"_pvalue.%Get("paramName")_"^description",tCustomDescription,,"^") 
                } ElseIf pvalue.%Get("inputType")'="",pvalue.%Get("inputType")'="header" {
                     //other input types  (entire body)
                    Do ..s(tSchemaDef,tPathKey_"requestBody^content^"_pvalue.%Get("inputType")_"^schema^type",pvalue.%Get("pmJDType"),,"^")
                    If pvalue.%Get("pmJDFormat")'="" Do ..s(tSchemaDef,tPathKey_"requestBody^content^"_pvalue.%Get("inputType")_"^schema^format",pvalue.%Get("pmJDFormat"),,"^")
                    If tCustomDescription'="" Do ..s(tSchemaDef,tPathKey_"requestBody^content^"_pvalue.%Get("inputType")_"^schema^description",tCustomDescription,,"^")
                } ElseIf pvalue.%Get("pmJDType")'="",'(pvalue.%Get("outputOnly")) {
                    // query and path params and header inputType
                    Set tInType="query"
                    If $Find(tPath,"{"_pvalue.%Get("paramName")_"}")>0 Set tInType="path"
                    If pvalue.%Get("inputType")'="" Set tInType = pvalue.%Get("inputType")
                    Set tParObj = {
                        "in":(tInType),
                        "name":(pvalue.%Get("paramName")),
                        "schema":{
                            "type":(pvalue.%Get("pmJDType"))
                        }
                    } 
                    If $Find("path",tInType)>0 Do tParObj.%Set("required",1,"boolean")
                    Set tParams = pvalue.%Get("params")
                    For i=1:1:$Length(tParams,"|") {
                        Set tAttName=$Piece($Piece(tParams,"|",i),"=",1)
                        Set tAttValue=$Piece($Piece(tParams,"|",i),"=",2)
                        If tAttName="MINVAL" Do tParObj.%Get("schema").%Set("minimum",tAttValue,pvalue.%Get("pmJType"))
                        If tAttName="MINVAL", tParams'["MAXVAL" Do tParObj.%Get("schema").%Set("exclusiveMaximum",1,"boolean")
                        If tAttName="MAXVAL" Do tParObj.%Get("schema").%Set("maximum",tAttValue,pvalue.%Get("pmJType"))
                        If tAttName="MAXVAL", tParams'["MINVAL" Do tParObj.%Get("schema").%Set("exclusiveMinimum",1,"boolean")
                        If tAttName="MINLEN" Do tParObj.%Get("schema").%Set("minLength",tAttValue,"number")
                        If tAttName="MAXLEN" Do tParObj.%Get("schema").%Set("maxLength",tAttValue,"number")
                    }
                    //set object param
                    If pvalue.%Get("pmJDFormat")'="" Do tParObj.%Get("schema").%Set("format",pvalue.%Get("pmJDFormat"))
                    If pvalue.%Get("paramDefault")'="",tParObj.%Get("required")'=1,pvalue.%Get("pmJDType")'="" {
                        Do tParObj.%Get("schema").%Set("default",pvalue.%Get("paramDefault"),pvalue.%Get("pmJDType"))
                    }
                    If (tIsArray) {
                        Do ..s(tParObj,"schema^type","array",,"^")
                        Do ..s(tParObj,"schema^items^type",pvalue.%Get("pmJDType"),,"^")
                        If pvalue.%Get("pmJDFormat")'="" Do ..s(tParObj,"schema^items^format",pvalue.%Get("pmJDFormat"),,"^")
                        Do ..s(tParObj,"style","form",,"^")
                        Do ..s(tParObj,"explode","false","boolean","^")
                    }
                    //custom params
                    If value.%Get("customParams").%Get("params")'="" {
                        Set tCustomParams = value.%Get("customParams").%Get("params").%Get(pvalue.%Get("param"))
                        If tCustomParams'="" {
                            Set tSC = ..JSONToFlatJSON(tCustomParams,.tCustomFlatParams,{"printResults":0})
                            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                            Set tIt = tCustomFlatParams.%GetIterator()
                            While tIt.%GetNext(.ckey,.cvalue) {
                                If $Find("inputType outputType",ckey)>0 Continue 
                                Do ..s(tParObj,ckey,cvalue,$Select((ckey="required")||($Find("true false",$ZConvert(cvalue,"L"))>0):"boolean",1:""),"^")
                                //change to array if string type
                                If tParObj.%Get("schema").%Get("type")="string",$Find(ckey,"schema^items^enum")>0 {
                                   Do tParObj.%Get("schema").%Set("type","array")
                                   Do tParObj.%Get("schema").%Get("items").%Set("type","string")
                                   Do tParObj.%Set("style","form")
                                   Do tParObj.%Set("explode","false","boolean")
                                }
                            }
                        }
                    }
                    Do ..s(tSchemaDef,tPathKey_"parameters[+]",tParObj,,"^")
                }
            }
            Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^description","successful operation",,"^")
            Set tOutBodyObjCount = value.%Get("byRefBodyParams").%Size()+value.%Get("outputBodyParams").%Size()
            Set tSingleOutputObj = (tOutBodyObjCount=1)&&(tOutParObjCount=0)
            If (tOutBodyObjCount+tOutParObjCount)>1 {
                Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^type","object",,"^")
                If (pIncludeXML) {
                    Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^type","object",,"^")
                    Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^xml^name","response",,"^")
                }
            }
            If pAuthMethod="bearer",value.%Get("protected")=1 {
                Do ..s(tSchemaDef,tPathKey_"security[0]^bearerAuth",[],,"^")
            } Else {
                Do ..s(tSchemaDef,tPathKey_"security[0]^basicAuth",[],,"^")
            }
            Set tPar = value.%Get("formalSpec").%GetIterator()
            While tPar.%GetNext(.pkey,.pvalue) {
                Set tIsArray=($Piece(pvalue.%Get("paramType"),"|",2)'="")
                If ((pvalue.%Get("outputOnly")=1)||(pvalue.%Get("byRef")=1)) {
                    Set tParamType = $Piece($Piece(pvalue.%Get("paramType"),"|",1),".",*)
                    If pvalue.%Get("complexType")=1,tOutBodyObjCount>0 {
                        If "DynamicObject DynamicArray"[tParamType {
                            Set tJSONSchema = pvalue.%Get("customSchema")
                            If tJSONSchema="" Set tJSONSchema = pvalue.%Get("customSchemaName")
                            Set tObjectName = pvalue.%Get("customSchemaName")
                            If tJSONSchema'="",'$IsObject(tJSONSchema) {
                                If mInfo.%Get("customSchemas").%Get(tObjectName)'="" {
                                    Set tJSONSchema=##class(%Library.DynamicObject).%New().%Set(tObjectName,mInfo.%Get("customSchemas").%Get(tObjectName))
                                }
                            }
                            If $IsObject(tJSONSchema),tJSONSchema.%Size()=1 {
                                Do pvalue.%Set("paramType",tObjectName)
                                Set tParamType = tObjectName
                                Set jsonResp=##class(%Library.DynamicObject).%New().%FromJSON(tJSONSchema.%ToJSON())
                                Do ..s(pvalue,"customObj",##class(%Library.DynamicObject).%New().%FromJSON(jsonResp.%ToJSON()),,pDelim)
                            } Else {
                                Set tParamType = $Select(tParamType="DynamicArray":"array", 1:"object")
                            }
                        } Else {
                            Set tSC = ..GetOpenAPISchema($Piece(pvalue.%Get("paramType"),"|",1),.jsonResp,{"printResults":0,"nestedMode":(pNestedMode)})
                            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                            If (tSC),jsonResp.%Size()=0 {
                                Set tParamType = $Select(tParamType="DynamicArray":"array", 1:"object")
                            }                            
                        }
                        If tParamType="object" {
                            If (tSingleOutputObj) {
                                Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^type","object",,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^type","object",,"^")
                            } Else {
                                Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^type","object",,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^type","object",,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^xml^name",pvalue.%Get("paramName"),,"^")
                            }
                        } ElseIf tParamType="array" {
                            Set tArrayObj = {"anyOf":[
                                    {"type":"object"},
                                    {"type":"string"},
                                    {"type":"number"},
                                    {"type":"boolean"}
                                ]}
                            If (tSingleOutputObj) {
                                Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^type","array",,"^")
                                Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^items",tArrayObj,,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^type","array",,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^items",tArrayObj,,"^")
                            } Else {
                                Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^type","array",,"^")
                                Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^items",tArrayObj,,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^type","array",,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^items",tArrayObj,,"^")
                            }
                        } Else {
                            Set tSchem = jsonResp.%GetIterator()
                            While tSchem.%GetNext(.skey,.svalue) {
                                //nestedMode use complete className to avoid name conflict
                                If (tParamType=skey)||($Piece(pvalue.%Get("paramType"),"|",1)=skey) {
                                    If (tSingleOutputObj) {
                                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                    } Else {
                                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^allOf^0^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^xml^name",pvalue.%Get("paramName"),,"^")
                                    }
                                }
                                If ..g(tSchemaDef,"components^schemas^"_skey,"^")="" Do ..s(tSchemaDef,"components^schemas^"_skey,svalue,,"^")
                                If (tParamType=skey),(tIsArray) {
                                    Do ..s(tSchemaDef,"components^schemas^arrayOf"_skey_"^type","array",,"^")
                                    Do ..s(tSchemaDef,"components^schemas^arrayOf"_skey_"^items^$ref","#/components/schemas/"_skey,,"^")
                                }
                            }
                        }
                    } ElseIf pvalue.%Get("pmJDType")'="",pvalue.%Get("pmJType")'="status",pvalue.%Get("outputType")="header" {
                        Set tParamDesc = ..g(value,"customParams^params^"_pvalue.%Get("param")_"^description",pDelim)
                        If tParamDesc'="" Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^headers^"_pvalue.%Get("paramName")_"^description",tParamDesc,,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^headers^"_pvalue.%Get("paramName")_"^schema^type",pvalue.%Get("pmJDType"),,"^")
                        If pvalue.%Get("pmJDFormat")'="" Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^headers^"_pvalue.%Get("paramName")_"^schema^format",pvalue.%Get("pmJDFormat"),,"^")
                    } ElseIf pvalue.%Get("pmJDType")'="",pvalue.%Get("pmJType")'="status",pvalue.%Get("outputType")'="" {
                        Set tParamDesc = ..g(value,"customParams^params^"_pvalue.%Get("param")_"^description",pDelim)
                        If tParamDesc'="" Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^description",tParamDesc,,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^"_pvalue.%Get("outputType")_"^schema^type",pvalue.%Get("pmJDType"),,"^")
                        If pvalue.%Get("pmJDFormat")'="" Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^"_pvalue.%Get("outputType")_"^schema^format",pvalue.%Get("pmJDFormat"),,"^")
                    } ElseIf pvalue.%Get("pmJDType")'="",pvalue.%Get("pmJType")'="status" {
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^type","object",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^type",$Select((tIsArray):"array",1:pvalue.%Get("pmJDType")),,"^")
                        If pvalue.%Get("pmJDFormat")'="",'tIsArray Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^format",pvalue.%Get("pmJDFormat"),,"^")
                        If (tIsArray) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^items^type",pvalue.%Get("pmJDType"),,"^")
                        If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^type",$Select((tIsArray):"array",1:pvalue.%Get("pmJDType")),,"^")
                        If (pIncludeXML),(tIsArray) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^items^type",pvalue.%Get("pmJDType"),,"^")
                        If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^xml^name","response",,"^")
                    } ElseIf pvalue.%Get("pmJDType")'="",pvalue.%Get("pmJType")="status" {
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^headers^iris-statuscode^description","1 For Success and 0 For Error",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^headers^iris-statuscode^schema^type","integer",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^headers^iris-statuscode^schema^format","int32",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^headers^iris-statusmessage^description","Display the error text for statuscode",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^headers^iris-statusmessage^schema^type","string",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^headers^iris-errorcode^description","Return an error status code with the error as specified by the internal errorcode",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^headers^iris-errorcode^schema^type","integer",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*"_value.%Get("successfulCode")_"^headers^iris-errorcode^schema^format","int32",,"^")

                        Do ..s(tSchemaDef,tPathKey_"responses^*500^headers^iris-statuscode^description","0 For Error",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*500^headers^iris-statuscode^schema^type","integer",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*500^headers^iris-statuscode^schema^format","int32",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*500^headers^iris-statusmessage^description","Display the error text for statuscode",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*500^headers^iris-statusmessage^schema^type","string",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*500^headers^iris-errorcode^description","Return an error status code with the error as specified by the internal errorcode",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*500^headers^iris-errorcode^schema^type","integer",,"^")
                        Do ..s(tSchemaDef,tPathKey_"responses^*500^headers^iris-errorcode^schema^format","int32",,"^")
                    }
                }
            }
            While ..i(value,"customParams.statusCodes",.pSkey,.pSvalue,.pSIt) {
                If pSvalue.%Get("code")'="" {
                    Do ..s(tSchemaDef,tPathKey_"responses^*"_pSvalue.%Get("code")_"^content^application/json^schema^$ref","#/components/schemas/responseStatus",,"^")
                    Do ..s(tSchemaDef,tPathKey_"responses^*"_pSvalue.%Get("code")_"^description",pSvalue.%Get("description"),,"^")
                }
            }
            Do ..s(tSchemaDef,tPathKey_"responses^*500^content^application/json^schema^$ref","#/components/schemas/responseStatus",,"^")
            Do ..s(tSchemaDef,tPathKey_"responses^*500^description","Internal Server Error",,"^")
            //Request
            If (value.%Get("hasComplexParams")) {
                Set tSingleInputObj = (tInBodyObjCount=1)

                If '(tSingleInputObj) {
                    Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^type","object",,"^")
                    If tParamDescription'="",'$IsObject(tParamDescription) {
                        Do ..s(tSchemaDef,tPathKey_"requestBody^description",tParamDescription,,"^")
                    }
                    If tParamRequired'="",'$IsObject(tParamRequired) {
                        Do ..s(tSchemaDef,tPathKey_"requestBody^required",tParamRequired,"boolean","^")
                    }
                    If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^type","object",,"^")
                    If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^xml^name",key_"Request",,"^")
                }
                Set tPar = value.%Get("formalSpec").%GetIterator()
                While tPar.%GetNext(.pkey,.pvalue) {
                    Set tCustomFlatParams = {}
                    If value.%Get("customParams").%Get("params")'="" {
                        Set tCustomParams = value.%Get("customParams").%Get("params").%Get(pvalue.%Get("param"))
                        If tCustomParams'="" {
                            Set tSC = ..JSONToFlatJSON(tCustomParams,.tCustomFlatParams,{"printResults":0})
                            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                        }
                    }
                    If pvalue.%Get("complexType")=1,pvalue.%Get("outputOnly")'=1 {
                        Set tParamType = $Piece($Piece(pvalue.%Get("paramType"),"|",1),".",*)
                        If pvalue.%Get("customObj")'="" {
                            Set jsonResp = ##class(%Library.DynamicObject).%New().%FromJSON(pvalue.%Get("customObj").%ToJSON())
                        } ElseIf "DynamicObject DynamicArray"[tParamType {
                            Set tJSONSchema = pvalue.%Get("customSchema")
                            If tJSONSchema="" Set tJSONSchema = pvalue.%Get("customSchemaName")
                            Set tObjectName = pvalue.%Get("customSchemaName")
                            If tJSONSchema'="",'$IsObject(tJSONSchema) {
                                If mInfo.%Get("customSchemas").%Get(tObjectName)'="" {
                                    Set tJSONSchema=##class(%Library.DynamicObject).%New().%Set(tObjectName,mInfo.%Get("customSchemas").%Get(tObjectName))
                                }
                            }
                            If $IsObject(tJSONSchema),tJSONSchema.%Size()=1 {
                                Do pvalue.%Set("paramType",tObjectName)
                                Set tParamType = tObjectName
                                Set jsonResp=##class(%Library.DynamicObject).%New().%FromJSON(tJSONSchema.%ToJSON())
                                Do ..s(pvalue,"customObj",##class(%Library.DynamicObject).%New().%FromJSON(jsonResp.%ToJSON()),,pDelim)
                            } Else {
                                Set tParamType = $Select(tParamType="DynamicArray":"array", 1:"object")
                            }
                        } ElseIf pvalue.%Get("customObj")="" {
                            Set tSC = ..GetOpenAPISchema($Piece(pvalue.%Get("paramType"),"|",1),.jsonResp,{"printResults":0,"nestedMode":(pNestedMode)})
                            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                            If (tSC),jsonResp.%Size()=0 {
                                Set tParamType = $Select(tParamType="DynamicArray":"array", 1:"object")
                            }                            
                        }
                        If tParamType="object" {
                            Do ..s(tSchemaDef,tPathKey_"requestBody^description","Body Request Content",,"^")
                            If tParamDescription'="",'$IsObject(tParamDescription) {
                                Do ..s(tSchemaDef,tPathKey_"requestBody^description",tParamDescription,,"^")
                            }
                            If tParamRequired'="",'$IsObject(tParamRequired) {
                                Do ..s(tSchemaDef,tPathKey_"requestBody^required",tParamRequired,"boolean","^")
                            }
                            If (tSingleInputObj) {
                                Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^type","object",,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^type","object",,"^")
                                If tCustomFlatParams.%Get("description")'="" Do ..s(tSchemaDef,tPathKey_"requestBody^description",tCustomFlatParams.%Get("description"),,"^")
                                If tCustomFlatParams.%Get("required")'="" Do ..s(tSchemaDef,tPathKey_"requestBody^required",tCustomFlatParams.%Get("required"),"boolean","^")
                            } Else {
                                Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^type","object",,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^type","object",,"^")
                                If tCustomFlatParams.%Get("description")'="" {
                                    Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^description",tCustomFlatParams.%Get("description"),,"^")
                                    If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^description",tCustomFlatParams.%Get("description"),,"^")
                                }
                                If tCustomFlatParams.%Get("required")'="" {
                                    Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^required^+",pvalue.%Get("paramName"),,"^")
                                    If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^required^+",pvalue.%Get("paramName"),,"^")
                                }
                            }
                        } ElseIf tParamType="array" {
                            //deprecated part (never used) (DynamicArray type must have a schema name)
                            Do ..s(tSchemaDef,tPathKey_"requestBody^description","Body Request Content",,"^")
                            If tCustomFlatParams.%Get("description")'="" Do ..s(tSchemaDef,tPathKey_"requestBody^description",tCustomFlatParams.%Get("description"),,"^")
                            Set tArrayObj = {"anyOf":[
                                    {"type":"object"},
                                    {"type":"string"},
                                    {"type":"number"},
                                    {"type":"boolean"}
                                ]}
                            If tParamDescription'="",'$IsObject(tParamDescription) {
                                Do ..s(tSchemaDef,tPathKey_"requestBody^description",tParamDescription,,"^")
                            }
                            If tParamRequired'="",'$IsObject(tParamRequired) {
                                Do ..s(tSchemaDef,tPathKey_"requestBody^required",tParamRequired,"boolean","^")
                            }
                            If (tSingleInputObj) {
                                Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^type","array",,"^")
                                Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^items",tArrayObj,,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^type","array",,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^items",tArrayObj,,"^")
                            } Else {
                                Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^type","array",,"^")
                                Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^items",tArrayObj,,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^type","array",,"^")
                                If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^items",tArrayObj,,"^")
                            }
                        } Else {
                            Set tSchem = jsonResp.%GetIterator()
                            While tSchem.%GetNext(.skey,.svalue) {
                                Set tIsArray=($Piece(pvalue.%Get("paramType"),"|",2)'="")      
                                //nestedMode use complete className to avoid name conflict
                                If (tParamType=skey)||($Piece(pvalue.%Get("paramType"),"|",1)=skey) {
                                    If tParamDescription'="",'$IsObject(tParamDescription) {
                                        Do ..s(tSchemaDef,tPathKey_"requestBody^description",tParamDescription,,"^")
                                    }
                                    If tParamRequired'="",'$IsObject(tParamRequired) {
                                        Do ..s(tSchemaDef,tPathKey_"requestBody^required",tParamRequired,"boolean","^")
                                    }
                                    If (tSingleInputObj) {
                                        Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        Do ..s(tSchemaDef,tPathKey_"requestBody^description","Body Request Content",,"^")
                                        If tCustomFlatParams.%Get("description")'="" Do ..s(tSchemaDef,tPathKey_"requestBody^description",tCustomFlatParams.%Get("description"),,"^")
                                        If tCustomFlatParams.%Get("required")'="" Do ..s(tSchemaDef,tPathKey_"requestBody^required",tCustomFlatParams.%Get("required"),"boolean","^")
                                    } Else {
                                        Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        If tCustomFlatParams.%Get("description")'="" {
                                            Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^description",tCustomFlatParams.%Get("description"),,"^")
                                            If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^description",tCustomFlatParams.%Get("description"),,"^")
                                        }
                                        If tCustomFlatParams.%Get("required")'="" {
                                            Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/json^schema^required^+",pvalue.%Get("paramName"),,"^")
                                            If (pIncludeXML) Do ..s(tSchemaDef,tPathKey_"requestBody^content^application/xml^schema^required^+",pvalue.%Get("paramName"),,"^")
                                        }
                                    }
                                }
                                If ..g(tSchemaDef,"components^schemas^"_skey,"^")="" Do ..s(tSchemaDef,"components^schemas^"_skey,svalue,,"^")
                                If (tParamType=skey),(tIsArray) {
                                    Do ..s(tSchemaDef,"components^schemas^arrayOf"_skey_"^type","array",,"^")
                                    Do ..s(tSchemaDef,"components^schemas^arrayOf"_skey_"^items^$ref","#/components/schemas/"_skey,,"^")
                                }
                            }
                        }
                    }
                }
            }
        }
        Do ..s(tSchemaDef,"components^schemas^responseStatus^type","object",,"^")
        If (pIncludeXML) Do ..s(tSchemaDef,"components^schemas^responseStatus^xml^name","responseStatus",,"^")
        Do ..s(tSchemaDef,"components^schemas^responseStatus^properties^statusCode^type","integer",,"^")
        Do ..s(tSchemaDef,"components^schemas^responseStatus^properties^message^type","string",,"^")
        Do ..s(tSchemaDef,"components^schemas^responseStatus^properties^errorCode^type","integer",,"^")
        Do ..s(tSchemaDef,"externalDocs^description","Find out more about Swagger",,"^")
        Do ..s(tSchemaDef,"externalDocs^url","http://swagger.io",,"^")
        If mInfo.%Get("customServers")'="" {
            Do ..s(tSchemaDef,"servers",mInfo.%Get("customServers"),,".")
        } Else {
            Do ..s(tSchemaDef,"servers[0]^url",pNS,,"^")
            Do ..s(tSchemaDef,"servers[0]^description","http server",,"^")
            Do ..s(tSchemaDef,"servers[1]^url",$Replace(pNS,"http",$Select($Find(pNS,"https")>0:"http",1:"https")),,"^")
            Do ..s(tSchemaDef,"servers[1]^description","https server",,"^")
        }
        If mInfo.%Get("customSecurity")'="" {
            Do ..s(tSchemaDef,"components^securitySchemes",mInfo.%Get("customSecurity"),,"^")
        } Else {
            Do ..s(tSchemaDef,"components^securitySchemes^basicAuth^type","http",,"^")
            Do ..s(tSchemaDef,"components^securitySchemes^basicAuth^scheme","basic",,"^")
            If pAuthMethod="bearer" {
                Do ..s(tSchemaDef,"components^securitySchemes^bearerAuth^type","http",,"^")
                Do ..s(tSchemaDef,"components^securitySchemes^bearerAuth^scheme","bearer",,"^")
            }
        }
        Set pJSON = tSchemaDef       
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

ClassMethod GetOpenAPISchema(pClassName As %String, Output pXSDInfo As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:0)
        Set pNestedMode = $Select(pParams.nestedMode'="":pParams.nestedMode,1:0)
        Set pAttributePrefix = $Select(pParams.attributePrefix'="":pParams.attributePrefix,1:"_")
        Set pCharsKey = $Select(pParams.charsKey'="":pParams.charsKey,1:"$value")

        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"","nestedParentKey":"", "parentType":"", "level":0, "circRefCtrl":{},"originalJSON":{},"mapTypes":{},"json":{},"requiredKeys":{}}
        Set pLevel = pInternal.level
        Set pJSON = pInternal.json
        Set pParentKey = pInternal.parentKey
        Set pNestedParentKey = pInternal.nestedParentKey
        Set pParentType = pInternal.parentType
        Set pCircRefCtrl = pInternal.circRefCtrl
        Set pOriginalJSON = pInternal.originalJSON
        Set pMapTypes = pInternal.mapTypes
        Set pRequiredKeys = pInternal.requiredKeys
		If pParentType="" {
            Set tSC = ##class(apiPub.core.irisMetadata).ClassNameToXSD(pClassName,.pJSON,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
			Set pXSDInfo = {}
            Set tMapTypes = ##class(apiPub.core.typeMapper).GetXSDMapTypes()
            If pJSON.%Size()>0{
                Set prop = pJSON.%GetIterator()
                While prop.%GetNext(.key,.value) {
                    If $IsObject(value),value.%Get("proc")="",key'["ArrayOf" {
                        Set tSC = ..GetOpenAPISchema(pClassName,.pXSDInfo,pParams,{"parentKey":(key),"nestedParentKey":(key),"parentType":(key),"level":(1),"circRefCtrl":(pCircRefCtrl),"originalJSON":(pJSON),"mapTypes":(tMapTypes),"json":(value),"requiredKeys":(pRequiredKeys)})
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                    }
                }
            }
            //nestedMode use complete className to avoid name conflict
            If pNestedMode=1{
                Set prop = pXSDInfo.%GetIterator()
                Do prop.%GetNext(.key,.value)
                Set pXSDInfo={}
                Do ..s(pXSDInfo,pClassName,value,,pDelim)
            }
            If pPrintResults  {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pXSDInfo.%ToJSON(),.jsonString)
                Write jsonString,!
            }
		} Else {
            Do pJSON.%Set("proc",1)
            //Treat Inheritance
            Set tBasedOn = pJSON.%Get("basedOn")
            Set tOParentKey = pParentKey
            If tBasedOn'="",$IsObject(pOriginalJSON.%Get(tBasedOn)) {
                Set tType = pOriginalJSON.%Get(tBasedOn).%Get("type")
                If tType="" {
                    If (pNestedMode) {
                        Set tSC = ..GetOpenAPISchema(pClassName,.pXSDInfo,pParams,{"parentKey":(pParentKey),"nestedParentKey":(pNestedParentKey), "parentType":(pParentType),"level":(pLevel),"circRefCtrl":(pCircRefCtrl),"originalJSON":(pOriginalJSON),"mapTypes":(pMapTypes),"json":(pOriginalJSON.%Get(pJSON.%Get("basedOn"))),"requiredKeys":(pRequiredKeys)})
                    } Else {
                        Set tSC = ..GetOpenAPISchema(pClassName,.pXSDInfo,pParams,{"parentKey":(tBasedOn),"nestedParentKey":(tBasedOn), "parentType":(tBasedOn),"level":(1),"circRefCtrl":(pCircRefCtrl),"originalJSON":(pOriginalJSON),"mapTypes":(pMapTypes),"json":(pOriginalJSON.%Get(tBasedOn)),"requiredKeys":(pRequiredKeys)})
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                        Do ..s(pXSDInfo,pParentKey_pDelim_"allOf"_pDelim_"0"_pDelim_"$ref","#/components/schemas/"_tBasedOn,,pDelim)  
                        Set pParentKey=pParentKey_pDelim_"allOf"_pDelim_"1"
                    }
                } Else {
                    Set tBasedOnType = $Piece(pMapTypes.%Get($ZConvert($Piece(tType,":",2),"L")),"|",2)
                    If tBasedOnType="" Set tBasedOnType="string"
                    Set tBasedOnFormat = $Piece(pMapTypes.%Get($ZConvert($Piece(tType,":",2),"L")),"|",3)
                    Do ..s(pXSDInfo,pParentKey_pDelim_"properties"_pDelim_pCharsKey_pDelim_"type",tBasedOnType,,pDelim)
                    If tBasedOnFormat'="" Do ..s(pXSDInfo,pParentKey_pDelim_"properties"_pDelim_pCharsKey_pDelim_"format",tBasedOnFormat,,pDelim)
                }
            }
            //Correct Auto-Reference Limitation
            Do pCircRefCtrl.%Set(pParentType_pDelim_pParentType,pNestedParentKey)
            Set tParentCircRefCtrl = ##class(%Library.DynamicObject).%New().%FromJSON(pCircRefCtrl.%ToJSON())
            If pJSON.%Get("type")="" {
                Do ..s(pXSDInfo,pParentKey_pDelim_"type","object",,pDelim)  
                Do ..s(pXSDInfo,pParentKey_pDelim_"xml"_pDelim_"name",$Piece(tOParentKey,pDelim,*),,pDelim)  
                Set pParentKey=pParentKey_pDelim_"properties"
                Set pNestedParentKey=pNestedParentKey_pDelim_"properties"
            } 
            Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                If $IsObject(value) {
                    Do value.%Set("proc",1)
                    If (value.%Get("attribute")) Set key = pAttributePrefix_key
                    Set tIsArrayType = value.%Get("maxOccurs")="unbounded"
                    Set tType = value.%Get("type")
                    Set tRequired = (+value.%Get("minOccurs")>0)
                    Set tObjType = pOriginalJSON.%Get(tType)
                    Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$Select(key'="":key, 1:"")
                    Set tNestedKey = $Select(pNestedParentKey'="":pNestedParentKey_pDelim, 1:"")_$Select(key'="":key, 1:"")
                    Set tNested = pNestedMode
                    If $IsObject(tObjType) {
                        Do tObjType.%Set("proc",1)
                        If 'tIsArrayType Set tIsArrayType = tObjType.%Get("maxOccurs")="unbounded"
                        Set tCircKey = tParentCircRefCtrl.%Get(pParentType_pDelim_$Select((tIsArrayType):"ArrOf",1:"")_tType)
                        If (tCircKey="")||(tNestedKey'[tCircKey),$IsObject(tObjType) Do pCircRefCtrl.%Set(pParentType_pDelim_$Select((tIsArrayType):"ArrOf",1:"")_tType,tNestedKey)
                        If (tRequired),pRequiredKeys.%Get($Piece(tKey,pDelim,1,*-2)_pDelim_"required[+]"_$Piece(tKey,pDelim,*))="" {
                            Do pRequiredKeys.%Set($Piece(tKey,pDelim,1,*-2)_pDelim_"required[+]"_$Piece(tKey,pDelim,*),1)
                            Do ..s(pXSDInfo,$Piece(tKey,pDelim,1,*-2)_pDelim_"required[+]",$Piece(tKey,pDelim,*),,pDelim)
                        }
                        If (tIsArrayType) {
                            Do ..s(pXSDInfo,tKey_pDelim_"type","array",,pDelim)  
                            Set tKey=tKey_pDelim_"items"
                            Set tNestedKey=tNestedKey_pDelim_"items"
                        }
                        If (tCircKey="")||(tNestedKey'[tCircKey) {
                            Do ..s(pXSDInfo,tKey,{},,pDelim)  
                            If $IsObject(tObjType),tObjType.%Get("type")="" {
                                If (tType["ArrayOf")||(tType["PairOf") Set tNested=1
                                If tNested=0 Do ..s(pXSDInfo,tKey_pDelim_"allOf[0]"_pDelim_"$ref","#/components/schemas/"_tType,,pDelim)
                                If value.%Get("documentation")'="" Do ..s(pXSDInfo,tKey_pDelim_"description",value.%Get("documentation"),,pDelim)
                                If value.%Get("example")'="" Do ..s(pXSDInfo,tKey_pDelim_"example",value.%Get("example"),,pDelim)
                                Set tSC = ..GetOpenAPISchema(pClassName,.pXSDInfo,pParams,{"parentKey":($Select((tNested=1):tKey,1:tType)),"nestedParentKey":(tNestedKey), "parentType":(tType),"level":(pLevel+1),"circRefCtrl":(pCircRefCtrl),"originalJSON":(pOriginalJSON),"mapTypes":(pMapTypes),"json":(tObjType),"requiredKeys":(pRequiredKeys)})
                                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                            } Else {
                                Set tJSONType = $Piece(pMapTypes.%Get($ZConvert(tType,"L")),"|",2)
                                If tJSONType="" Set tJSONType="string"
                                Set tJSONFormat = $Piece(pMapTypes.%Get($ZConvert(tType,"L")),"|",3)
                                Do ..s(pXSDInfo,tKey_pDelim_"type",tJSONType,,pDelim)
                                If tJSONFormat'="" Do ..s(pXSDInfo,tKey_pDelim_"format",tJSONFormat,,pDelim)
                                If tBasedOn'="" {
                                    Set tBasedOnType = $Piece(pMapTypes.%Get($ZConvert($Piece(tBasedOn,":",2),"L")),"|",2)
                                    Set tBasedOnFormat = $Piece(pMapTypes.%Get($ZConvert($Piece(tBasedOn,":",2),"L")),"|",3)
                                    If tBasedOnType'="" {
                                        Do ..s(pXSDInfo,$Piece(tKey,pDelim,1,*-1)_pDelim_pCharsKey_pDelim_"type",tBasedOnType,,pDelim)
                                        If tBasedOnFormat'="" Do ..s(pXSDInfo,$Piece(tKey,pDelim,1,*-1)_pDelim_pCharsKey_pDelim_"format",tBasedOnFormat,,pDelim)
                                    }
                                }
                                If value.%Get("enumeration")'="" {
                                    If "number integer"[tJSONType {
                                        Set tEnum = value.%Get("enumeration").%GetIterator()
                                        While (tEnum.%GetNext(.enk,.vk)) {
                                            Do ..s(pXSDInfo,tKey_pDelim_"enum"_pDelim_enk,+vk,"number",pDelim)
                                        }
                                    } Else {
                                        Do ..s(pXSDInfo,tKey_pDelim_"enum",value.%Get("enumeration"),,pDelim)
                                    }
                                }
                            } 
                            If value.%Get("documentation")'="" Do ..s(pXSDInfo,tKey_pDelim_"description",value.%Get("documentation"),,pDelim)
                            If value.%Get("example")'="" Do ..s(pXSDInfo,tKey_pDelim_"example",value.%Get("example"),,pDelim)
                        } Else {
                            If tNestedKey[tCircKey {
                                If ..g(pXSDInfo,tKey,pDelim)="" {
                                    Set tAutoRefKey = "#/components/schemas/"_$Replace(tCircKey,"^","/")
                                    Do ..s(pXSDInfo,tKey_pDelim_"$ref",tAutoRefKey,,pDelim)
                                }
                            }
                        }
                    } Else {
                        If (tRequired),pRequiredKeys.%Get($Piece(tKey,pDelim,1,*-2)_pDelim_"required[+]"_$Piece(tKey,pDelim,*))="" {
                            Do pRequiredKeys.%Set($Piece(tKey,pDelim,1,*-2)_pDelim_"required[+]"_$Piece(tKey,pDelim,*),1)
                            Do ..s(pXSDInfo,$Piece(tKey,pDelim,1,*-2)_pDelim_"required[+]",$Piece(tKey,pDelim,*),,pDelim)
                        }
                        If (tIsArrayType) {
                            Do ..s(pXSDInfo,tKey_pDelim_"type","array",,pDelim)  
                            Set tKey=tKey_pDelim_"items"
                            Set tNestedKey=tNestedKey_pDelim_"items"
                        }
                        Set tJSONType = $Piece(pMapTypes.%Get($ZConvert(value.%Get("type"),"L")),"|",2)
                        If tJSONType="" Set tJSONType="object"
                        Set tJSONFormat = $Piece(pMapTypes.%Get($ZConvert(value.%Get("type"),"L")),"|",3)
                        Do ..s(pXSDInfo,tKey_pDelim_"type",tJSONType,,pDelim)
                        If tJSONFormat'="" Do ..s(pXSDInfo,tKey_pDelim_"format",tJSONFormat,,pDelim)
                        If tBasedOn'="" {
                            Set tBasedOnType = $Piece(pMapTypes.%Get($ZConvert($Piece(tBasedOn,":",2),"L")),"|",2)
                            Set tBasedOnFormat = $Piece(pMapTypes.%Get($ZConvert($Piece(tBasedOn,":",2),"L")),"|",3)
                            If tBasedOnType'="" {
                                Do ..s(pXSDInfo,$Piece(tKey,pDelim,1,*-1)_pDelim_pCharsKey_pDelim_"type",tBasedOnType,,pDelim)
                                If tBasedOnFormat'="" Do ..s(pXSDInfo,$Piece(tKey,pDelim,1,*-1)_pDelim_pCharsKey_pDelim_"format",tBasedOnFormat,,pDelim)
                            }
                        }
                        If value.%Get("enumeration")'="" {
                            If "number integer"[tJSONType {
                                Set tEnum = value.%Get("enumeration").%GetIterator()
                                While (tEnum.%GetNext(.enk,.vk)) {
                                    Do ..s(pXSDInfo,tKey_pDelim_"enum"_pDelim_enk,+vk,"number",pDelim)
                                }
                            } Else {
                                Do ..s(pXSDInfo,tKey_pDelim_"enum",value.%Get("enumeration"),,pDelim)
                            }
                        }
                        Set tOType = $Select("string boolean date dateTime decimal"'[value.%Get("type"):"("_value.%Get("type")_") ",1:"")
                        if tOType="(long) " Set tOType=""
                        If (value.%Get("documentation")'="")||(tOType'="") Do ..s(pXSDInfo,tKey_pDelim_"description",tOType_value.%Get("documentation"),,pDelim)
                        If (value.%Get("example")'="") Do ..s(pXSDInfo,tKey_pDelim_"example",tOType_value.%Get("example"),,pDelim)
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

ClassMethod TemplateToOpenApiSchema(pJSON As %Library.DynamicObject, ByRef pObjectName As %String, Output pOpenApiJSON As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pNestedMode = $Select(pParams.nestedMode'="":pParams.nestedMode,1:0)
        Set pSchemaPrefix = ..JGet(pParams,"schemaPrefix")
        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"","parentNode":"","nestedJSON":{}}
        Set pParentKey = pInternal.parentKey
        Set pParentNode = pInternal.parentNode
		Set pNestedJSON = pInternal.nestedJSON
		If pParentKey="" {
			Set pOpenApiJSON = {}
            If pObjectName="",pJSON.%Size()=1 {
                Set prop = pJSON.%GetIterator()
                Do prop.%GetNext(.key,.value)
                Set pObjectName=key
                Set pJSON = value
            } 
            If pObjectName="" {
                Set tSC = $$$ERROR($$$GeneralError, "pObjectName must be informed when there is no main node")
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }
			Do ..TemplateToOpenApiSchema(pJSON,pObjectName,.pOpenApiJSON,pParams,{"parentKey":(pObjectName_"|"_$Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object")),"parentNode":(pSchemaPrefix_pObjectName),"nestedJSON":(pNestedJSON)})
            If (pNestedMode) Set pOpenApiJSON=pNestedJSON
            If pPrintResults {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pOpenApiJSON.%ToJSON(),.jsonString)
                Write jsonString,!
            }
		} Else {
            Set tParentObjName = $Piece($Piece(pParentKey,pDelim,*-1),"|",1)
            Set tObjName = $Piece($Piece(pParentKey,pDelim,*),"|",1)
            Set tObjType = $Piece($Piece(pParentKey,pDelim,*),"|",2)
            Set tUCObjName=pSchemaPrefix_$ZConvert($E(tObjName,1,1),"U")_$E(tObjName,2,*)
            Set tUCParentObjName=pSchemaPrefix_$ZConvert($E(tParentObjName,1,1),"U")_$E(tParentObjName,2,*)
            Do ..s(pOpenApiJSON,tUCObjName_pDelim_"type",tObjType,,pDelim)
            Do ..s(pNestedJSON,pParentNode_pDelim_"type",tObjType,,pDelim)
            Set tType=..g(pOpenApiJSON,tUCParentObjName_pDelim_"type",pDelim)
            If $Find(pParentKey,pDelim)>0{
                Set tArr = ..g(pOpenApiJSON,tUCParentObjName_pDelim_$Select(tType="object":"properties"_pDelim_tObjName,1:"items"_pDelim_"anyOf"),pDelim)
                If (tArr="")||(..find(tArr,"..g(value,""$ref"")=""#/components/schemas/"_tUCObjName_"""")=-1) {
                    Do ..s(pOpenApiJSON,tUCParentObjName_pDelim_$Select(tType="object":"properties"_pDelim_tObjName,1:"items"_pDelim_"anyOf"_pDelim_"+")_pDelim_"$ref","#/components/schemas/"_tUCObjName,,pDelim)
                }
            }
            Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                Set tk=key
                If tk=+tk Set tk=$Replace(tUCObjName,pSchemaPrefix,"")_"-Item"_$Select(key=0:"",1:key+1)
                Set tKey = $Select(pParentKey'="":pParentKey, 1:"")_pDelim_tk
                // For nested mode
                Set tNodeKey = $Select(pParentNode'="":pParentNode, 1:"")
                If tObjType'="array" {
                    Set tNodeKey=tNodeKey_pDelim_"properties"_pDelim_tk
                } Else {
                    Set tArr = ..g(pNestedJSON,$Select(pParentNode'="":pParentNode, 1:"")_pDelim_"items"_pDelim_"anyOf",pDelim)
                    Set tNodeKey=tNodeKey_pDelim_"items"_pDelim_"anyOf"_pDelim_$Select($IsObject(tArr):tArr.%Size(),1:key)
                }
                If $IsObject(value) {
                    Do ..TemplateToOpenApiSchema(value,pObjectName,.pOpenApiJSON,pParams,{"parentKey":(tKey_"|"_$Select($ClassName(value)="%Library.DynamicArray":"array",1:"object")),"parentNode":(tNodeKey),"nestedJSON":(pNestedJSON)})
				} Else {
                    Set tCType = pJSON.%GetTypeOf(key)
                    If key=+key {
                        Set tInclude=1
                        Set tExArr = ..g(pOpenApiJSON,tUCObjName_pDelim_"items"_pDelim_"anyOf",pDelim)
                        If $IsObject(tExArr) {
                            If ..find(tExArr,"..g(value,""type"")="""_tCType_"""")'=-1 Set tInclude=0
                        }
                        If (tInclude=1) {
                            Set tItem = {
                                "type":(tCType)
                            }
                            Do ..s(tItem,"example",value,tCType,pDelim)
                            Do ..s(pOpenApiJSON,tUCObjName_pDelim_"items"_pDelim_"anyOf"_pDelim_"+",tItem,,pDelim)
                            Do ..s(pNestedJSON,pParentNode_pDelim_"items"_pDelim_"anyOf"_pDelim_"+",tItem,,pDelim)
                        }
                    } Else {
                        Set tExType = ..g(pOpenApiJSON,tUCObjName_pDelim_"properties"_pDelim_key_pDelim_"type",pDelim)
                        If tExType="" Set tExType = ..g(pNestedJSON,pParentNode_pDelim_"properties"_pDelim_key_pDelim_"type",pDelim)
                        If tExType'="",tCType'=tExType Set tCType = "string"
                        Do ..s(pOpenApiJSON,tUCObjName_pDelim_"properties"_pDelim_key_pDelim_"type",tCType,,pDelim)
                        Do ..s(pNestedJSON,pParentNode_pDelim_"properties"_pDelim_key_pDelim_"type",tCType,,pDelim)
                        If tCType = "string",$Length(value)=10,$Extract($Translate(value,"1920","XXXX"),1,2)="XX",$Extract(value,5)="-",$Extract(value,8)="-" {
                            Do ..s(pOpenApiJSON,tUCObjName_pDelim_"properties"_pDelim_key_pDelim_"format","date",,pDelim)
                            Do ..s(pNestedJSON,pParentNode_pDelim_"properties"_pDelim_key_pDelim_"format","date",,pDelim)
                        } ElseIf $Extract($TR(value,"0123456789","XXXXXXXXXX"),1,17)="XXXX-XX-XXTXX:XX:" {
                            Do ..s(pOpenApiJSON,tUCObjName_pDelim_"properties"_pDelim_key_pDelim_"format","date-time",,pDelim)
                            Do ..s(pNestedJSON,pParentNode_pDelim_"properties"_pDelim_key_pDelim_"format","date-time",,pDelim)
                        }
                        Do ..s(pOpenApiJSON,tUCObjName_pDelim_"properties"_pDelim_key_pDelim_"example",value,tCType,pDelim)
                        Do ..s(pNestedJSON,pParentNode_pDelim_"properties"_pDelim_key_pDelim_"example",value,tCType,pDelim)
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

ClassMethod TemplateToOpenApiSchemaOld(pJSON As %Library.DynamicObject, ByRef pObjectName As %String, Output pOpenApiJSON As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"", "parentType":""}
        Set pParentKey = pInternal.parentKey
        Set pParentType = pInternal.parentType
		If pParentType="" {
			Set pOpenApiJSON = {}
            If pObjectName="",pJSON.%Size()=1 {
                Set prop = pJSON.%GetIterator()
                Do prop.%GetNext(.key,.value)
                Set pObjectName=key
                Set pJSON = value
            } 
            If pObjectName="" {
                Set tSC = $$$ERROR($$$GeneralError, "pObjectName must be informed when there is no main node")
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }
			Do ..TemplateToOpenApiSchemaOld(pJSON,pObjectName,.pOpenApiJSON,pParams,{"parentKey":(pObjectName), "parentType":($Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object"))})
            If pPrintResults {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pOpenApiJSON.%ToJSON(),.jsonString)
                Write jsonString,!
            }
		} Else {
            Do ..s(pOpenApiJSON,pParentKey_pDelim_"type",pParentType,,pDelim)
            Set pParentKey=pParentKey_pDelim_$Select(pParentType="object":"properties",1:"items")
            Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                Set tk = key  If pParentType="array",key=+key Set tk = ""
                Set tKey = $Select(pParentKey'="":pParentKey, 1:"")_$Select(tk'="":pDelim_tk, 1:"")
                If $IsObject(value),$Find($Piece(tKey,pDelim,*),"@")=0 {
                    Do ..TemplateToOpenApiSchemaOld(value,pObjectName,.pOpenApiJSON,pParams,{"parentKey":(tKey), "parentType":($Select($ClassName(value)="%Library.DynamicArray":"array",1:"object"))})
				} Else {
                    If $Find($Piece(tKey,pDelim,*),"@")=0 {
                        Set tCType = pJSON.%GetTypeOf(key)
                        Set tExType = ..g(pOpenApiJSON,tKey_pDelim_"type",pDelim)
                        If tExType'="",tCType'=tExType Set tCType = "string"
                        Do ..s(pOpenApiJSON,tKey_pDelim_"type",tCType,,pDelim)
                            If tCType = "string",$Length(value)=10,$Extract($Translate(value,"1920","XXXX"),1,2)="XX",$Extract(value,5)="-",$Extract(value,8)="-" {
                            Do ..s(pOpenApiJSON,tKey_pDelim_"format","date",,pDelim)
                        } ElseIf $Extract($TR(value,"0123456789","XXXXXXXXXX"),1,17)="XXXX-XX-XXTXX:XX:" {
                            Do ..s(pOpenApiJSON,tKey_pDelim_"format","date-time",,pDelim)
                        }
                        Do ..s(pOpenApiJSON,tKey_pDelim_"example",value,tCType,pDelim)
                    } Else {
                        Set tOrigProp = $Piece($Piece(tKey,pDelim,*),"@",1)
                        Set tSchemaProp = $Piece($Piece(tKey,pDelim,*),"@",2)
                        Set tKey = $Piece(tKey,pDelim,1,*-1)_pDelim_tOrigProp_pDelim_tSchemaProp
                        Do ..s(pOpenApiJSON,tKey,value,,pDelim)
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

ClassMethod OpenApiSchemaToTemplate(pObjName As %String, pJSON As %Library.DynamicObject, Output pSchema As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)

        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"", "datetime":($REPLACE($ZDATETIME($ZTIMESTAMP,3,1,3)," ","T")_"Z"),"parentType":"","originalJSON":(pJSON),"level":0,"parentIndex":""}
        Set pParentKey = pInternal.parentKey
        Set pDateTime = pInternal.datetime
        Set pParentIndex = pInternal.parentIndex
        Set pParentType = pInternal.parentType
        Set pLevel = pInternal.level
		If pParentType="" {
			Set pSchema = {}
            If pJSON.%Get(pObjName) = "" {
                Set tSC = $$$ERROR($$$GeneralError, "invalid schema")
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }        
			Set tSC = ..OpenApiSchemaToTemplate(pObjName,##class(%Library.DynamicObject).%New().%Set(pObjName,pJSON.%Get(pObjName)) ,.pSchema,pParams,{"datetime":(pDateTime),"parentKey":"", "parentType":"object","originalJSON":(pInternal.originalJSON),"level":1,"parentIndex":""})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            If pPrintResults {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pSchema.%ToJSON(),.jsonString)
                Write jsonString,!
            }
		} Else {
			Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$Select(key'="":key, 1:"")
                If key="items",$Piece(pParentKey,pDelim,*)'="properties" Set tKey=$Piece(tKey,pDelim,1,*-1)
                If ..g(value,"type")="array",key'=+key Set tKey = tKey_pDelim_"0"
				If $IsObject(value) {
                    Do ..OpenApiSchemaToTemplate(pObjName,value,.pSchema,pParams,{"datetime":(pDateTime),"parentKey":(tKey), "parentType":($Select($ClassName(value)="%Library.DynamicArray":"array",1:"object")),"originalJSON":(pInternal.originalJSON),"level":(pLevel+1),"parentIndex":(pParentIndex)})
    			} Else {
                    If $Piece(tKey,pDelim,*)="$ref","allOf oneOf anyOf"[$Piece(tKey,pDelim,*-2) {
                        Set tJSON = ..GetByLineKey(pInternal.originalJSON,$Piece(value,"#/components/schemas/",2),"/")
                        If tJSON'="",$IsObject(tJSON) {
                            Set tParentIndex = $Piece(tKey,pDelim,*-1)
                            Set tKey = $Piece(tKey,pDelim,1,*-3)
                            If ($Length(tKey,pDelim)<5)||($Piece(tKey,pDelim,1,*-2)'[$Piece(tKey,pDelim,*-1,*)) {
                                Set tKey = tKey_pDelim_tParentIndex
                                Do ..OpenApiSchemaToTemplate(pObjName,tJSON,.pSchema,pParams,{"datetime":(pDateTime), "parentKey":(tKey), "parentType":"object","originalJSON":(pInternal.originalJSON),"level":(pLevel+1),"parentIndex":(tParentIndex)})
                            } 
                        }
                    } Else {
					    If $Piece(tKey,pDelim,*)="$ref" {
                            Set tJSON = ..GetByLineKey(pInternal.originalJSON,$Piece(value,"#/components/schemas/",2),"/")
                            If tJSON'="",$IsObject(tJSON) {
                                Set tKey = $Piece(tKey,pDelim,1,*-1)
                                If ($Length(tKey,pDelim)<5)||($Piece(tKey,pDelim,1,*-2)'[$Piece(tKey,pDelim,*-1,*)) {
                                    Do ..OpenApiSchemaToTemplate(pObjName,tJSON,.pSchema,pParams,{"datetime":(pDateTime), "parentKey":(tKey), "parentType":"object","originalJSON":(pInternal.originalJSON),"level":(pLevel+1),"parentIndex":""})
                                }
                            }
                        } ElseIf ("type"[$Piece(tKey,pDelim,*)) {
                            Set (tValue,tType)=value
                            Set tFkey=$Piece(..ReplaceSch(tKey),pDelim,2,*)
                            Set tValue = {}
                            If tType="array" Set tValue = []
                            If tType="number" Set tValue = 0
                            If tType="integer" Set tValue = 0
                            If tType="boolean" Set tValue = "true"
                            If tType="string" Set tValue = "string"
                            //..g(pSchema,$Piece(tFkey,1,*-1),pDelim),!
                            If $IsObject(..g(pJSON,"enum")) Set tValue = ..g(pJSON,"enum"_pDelim_"0",pDelim)
                            If ..g(pJSON,"example")'="" Set tValue = ..g(pJSON,"example")
                            If ..g(pJSON,"format")'="",..g(pJSON,"format")="date" Set tValue = $E(pDateTime,1,10)
                            If ..g(pJSON,"format")'="",..g(pJSON,"format")="date-time" Set tValue = pDateTime
                            If tFkey'="" {
                                Do ..s(pSchema,tFkey,tValue,$Select("boolean number"[tType:tType,1:""),pDelim)
                            }
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

ClassMethod ReplaceSch(str)
{
    //Quit str
    Quit $Replace($Replace($Replace($Replace($Replace($Replace($Replace($Replace($Replace($Replace(str,"^properties^properties","^properties^##properties"),"^properties",""),"^oneOf","^anyOf"),"^anyOf",""),"^allOf",""),"^type^type","^type^##type"),"^type",""),"##",""),"^*^","^"),"^*","")
}

}

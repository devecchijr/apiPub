Class apiPub.core.publisher Extends apiPub.core.jsonBuilder
{

ClassMethod GetOASFromClass(pClassName As %String, Output pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject, pRequestURL As %String) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        If '$Data(pParams) Set pParams={}
        If '$Data(pRequestURL) Set pRequestURL=""
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^")
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pIncludeXML = $Select(pParams.includeXML'="":pParams.includeXML,1:0)
        Set pNestedMode = $Select(pParams.nestedMode'="":pParams.nestedMode,1:0)
        Set pClassMethodOnly = $Select(pParams.classMethodOnly'="":pParams.classMethodOnly,1:0)
        Set pMethodName = $Select(pParams.methodName'="":pParams.methodName,1:"")
        Set pBasePath = $Select(pParams.basePath'="":pParams.basePath,1:"")
        Set pJSON = {}
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||SERVICENAME")
        Set tTitle=pClassName_" API"
        If $IsObject(tMParam) Set tTitle = tMParam.Default
        Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId(pClassName_"||TITLE")
        If $IsObject(tMParam) Set tTitle = tMParam.Default
        Set pNS=$Piece(pRequestURL,"/",1,4)
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
        If tContactName'="" Do ..SetByLineKey(tSchemaDef,"info.contact.name",tContactName,,".")
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
        Do ..SetByLineKey(tSchemaDef,"openapi","3.0.0",,".")
        If mInfo.%Get("customInfo")'="" {
            Do ..SetByLineKey(tSchemaDef,"info",mInfo.%Get("customInfo"),,".")
        } Else {
            Do ..SetByLineKey(tSchemaDef,"info.description",pDescription,,".")
            Do ..SetByLineKey(tSchemaDef,"info.version",tVersion,,".")
            Do ..SetByLineKey(tSchemaDef,"info.title",tTitle,,".")
            Do ..SetByLineKey(tSchemaDef,"info.termsOfService",tTermsOfService,,".")
            Do ..SetByLineKey(tSchemaDef,"info.contact.email", tContactEmail,,".")
            Do ..SetByLineKey(tSchemaDef,"info.contact.url", tContactURL,,".")
            Do ..SetByLineKey(tSchemaDef,"info.license.name",tLicenseName,,".")
            Do ..SetByLineKey(tSchemaDef,"info.license.url",tLicenseURL,,".")
        }
        If mInfo.%Get("customTags")'="" {
            Do ..SetByLineKey(tSchemaDef,"tags",mInfo.%Get("customTags"),,".")
            Set pTagName=mInfo.%Get("customTags").%Get(0).%Get("name")
        } Else {
            Do tSchemaDef.%Set("tags",[])
        }
        Do tSchemaDef.%Set("paths",{})
        If mInfo.%Get("customSchemas")'="" {
            Do ..SetByLineKey(tSchemaDef,"components.schemas",mInfo.%Get("customSchemas"),,".")
        }
        Set tMet = mInfo.%Get("methods").%GetIterator()
        While tMet.%GetNext(.key,.value) {
            Set (tTagDescription,tTagDocsDescription,tTagDocsUrl)=""
            If (pClassMethodOnly),'(value.%Get("classMethod")) Continue
            Set tDescription = $Select(value.%Get("description")'="":value.%Get("description"),1:"")
            If value.%Get("customParams").%Get("description")'="" Set tDescription = value.%Get("customParams").%Get("description")
            Set tSummary = tDescription
            If value.%Get("customParams").%Get("summary")'="" Set tSummary = value.%Get("customParams").%Get("summary")
            Set tVerb=$ZConvert(value.%Get("customParams").%Get("verb"),"L")
            If tVerb="" Set tVerb=$Select((value.%Get("hasComplexParams")):"post",1:"get")
            Set tDeprecated=value.%Get("customParams").%Get("deprecated")
            If $ZConvert(tDeprecated,"L")="true" Set tDeprecated = 1
            If '(tDeprecated) Set tDeprecated = 0
            Set tInBodyObjCount = value.%Get("inputBodyParams").%Size()+value.%Get("byRefBodyParams").%Size()
            If value.%Get("customParams").%Get("path")'="" {
                Set tPath = $Replace("/"_$Select(pBasePath'="":pBasePath_"/",1:"")_value.%Get("customParams").%Get("path"),"//","/")
            } Else {
                //Set tPath = $Replace("/"_$Select(pBasePath'="":pBasePath_"/",1:"")_pClassName_"/"_key,"//","/")
                Set tPath = $Replace("/"_$Select(pBasePath'="":pBasePath_"/",1:"")_key,"//","/")
            }
            Set tOperationId = value.%Get("customParams").%Get("operationId")
            If tOperationId="" Set tOperationId=key
            Set tConsumes = value.%Get("customParams").%Get("consumes")
            //If tConsumes="" Set tConsumes=["application/json"]
            Set tProduces = value.%Get("customParams").%Get("produces")
           // If tProduces="" Set tConsumes=["application/json"]
            Set tTagName=pTagName
            Set tCustomTag = value.%Get("customParams").%Get("tag")
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
                Do ..SetByLineKey(tSchemaDef,"tags"_pDelim_tTagKey_pDelim_"name",tTagName,,pDelim)
            }
            If tTagDescription'="" Do ..SetByLineKey(tSchemaDef,"tags"_pDelim_tTagKey_pDelim_"description",tTagDescription,,pDelim)
            If tTagDocsDescription'="" Do ..SetByLineKey(tSchemaDef,"tags"_pDelim_tTagKey_pDelim_"externalDocs"_pDelim_"description",tTagDocsDescription,,pDelim)
            If tTagDocsUrl'="" Do ..SetByLineKey(tSchemaDef,"tags"_pDelim_tTagKey_pDelim_"externalDocs"_pDelim_"url",tTagDocsUrl,,pDelim)
            Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^tags[0]",tTagName,,"^")
            If tSummary'="" Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^summary",tSummary,,"^")
            If tDescription'="" Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^summary",tDescription,,"^")
            If (tDeprecated) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^deprecated",tDeprecated,"boolean","^")
            Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^operationId",tOperationId,,"^")
            If tConsumes'="" Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^consumes",tConsumes,,"^")
            If tProduces'="" Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^produces",tProduces,,"^")
            Set tOutParObjCount=0
            Set (tParamDescription,tParamRequired)=""
            If value.%Get("customParams").%Get("params")'="" {
                Set tParamDescription = value.%Get("customParams").%Get("params").%Get("description")
                Set tParamRequired = value.%Get("customParams").%Get("params").%Get("required")
                If tParamRequired="" Set tParamRequired=1
            }
            Set tPar = value.%Get("formalSpec").%GetIterator()
            While tPar.%GetNext(.pkey,.pvalue) {
                Set tIsArray=($Piece(pvalue.%Get("paramType"),"|",2)'="")
                //For different single input types
                If pvalue.%Get("input")'="",pvalue.%Get("input")'="header",value.%Get("formalSpec").%Size()-$Select(value.%Get("resultParam")'="":1,1:0)=1 {
                    //different types
                    If tParamDescription'="" Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^description",tParamDescription,,"^")
                    Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^requestBody^content^"_pvalue.%Get("input")_"^schema^type",pvalue.%Get("pmJDType"),,"^")
                } ElseIf pvalue.%Get("pmJDType")'="",'(pvalue.%Get("outputOnly")) {
                    If tParamDescription'="" Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^description",tParamDescription,,"^")
                    Set tInType="query"
                    If $Find(tPath,"{"_pvalue.%Get("paramName")_"}")>0 Set tInType="path"
                    If pvalue.%Get("input")'="" Set tInType = pvalue.%Get("input")
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
                    If pvalue.%Get("pmJDFormat")'="" Do tParObj.%Get("schema").%Set("format",pvalue.%Get("pmJDFormat"))
                    If (tIsArray) {
                        Do ..SetByLineKey(tParObj,"schema^type","array",,"^")
                        Do ..SetByLineKey(tParObj,"schema^items^type",pvalue.%Get("pmJDType"),,"^")
                        If pvalue.%Get("pmJDFormat")'="" Do ..SetByLineKey(tParObj,"schema^items^format",pvalue.%Get("pmJDFormat"),,"^")
                        Do ..SetByLineKey(tParObj,"style","form",,"^")
                        Do ..SetByLineKey(tParObj,"explode","false","boolean","^")
                    }
                    If value.%Get("customParams").%Get("params")'="" {
                        Set tCustomParams = value.%Get("customParams").%Get("params").%Get(pvalue.%Get("param"))
                        If tCustomParams'="" {
                            Set tSC = ..JSONToFlatJSON(tCustomParams,.tCustomFlatParams,{"printResults":0})
                            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                            Set tIt = tCustomFlatParams.%GetIterator()
                            While tIt.%GetNext(.ckey,.cvalue) {
                                If $Find("input output",ckey)>0 Continue 
                                Do ..SetByLineKey(tParObj,ckey,cvalue,$Select((ckey="required")||($Find("true false",$ZConvert(cvalue,"L"))>0):"boolean",1:""),"^")
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
                    Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^parameters[+]",tParObj,,"^")
                    If (pvalue.%Get("outputOnly")=1)||(pvalue.%Get("byRef")=1) Set tOutParObjCount=tOutParObjCount+1
                }
            }
            Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^description","successful operation",,"^")
            Set tOutBodyObjCount = value.%Get("byRefBodyParams").%Size()+value.%Get("outputBodyParams").%Size()
            Set tSingleOutputObj = (tOutBodyObjCount=1)&&(tOutParObjCount=0)
            If (tOutBodyObjCount+tOutParObjCount)>1 {
                Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^type","object",,"^")
                If (pIncludeXML) {
                    Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^type","object",,"^")
                    Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^xml^name","response",,"^")
                }
            }
            Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^security[0]^basicAuth",[],,"^")
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
                                    Set tJSONSchema={}.%Set(tObjectName,mInfo.%Get("customSchemas").%Get(tObjectName))
                                }
                            }
                            If $IsObject(tJSONSchema),tJSONSchema.%Size()=1 {
                                Do pvalue.%Set("paramType",tObjectName)
                                Set tParamType = tObjectName
                                Set jsonResp={}.%FromJSON(tJSONSchema.%ToJSON())
                                Do ..SetByLineKey(pvalue,"customObj",{}.%FromJSON(jsonResp.%ToJSON()),,pDelim)
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
                                Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^type","object",,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^type","object",,"^")
                            } Else {
                                Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^type","object",,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^type","object",,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^xml^name",pvalue.%Get("paramName"),,"^")
                            }
                        } ElseIf tParamType="array" {
                            Set tArrayObj = {"anyOf":[
                                    {"type":"object"},
                                    {"type":"string"},
                                    {"type":"number"},
                                    {"type":"boolean"}
                                ]}
                            If (tSingleOutputObj) {
                                Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^type","array",,"^")
                                Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^items",tArrayObj,,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^type","array",,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^items",tArrayObj,,"^")
                            } Else {
                                Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^type","array",,"^")
                                Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^items",tArrayObj,,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^type","array",,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^items",tArrayObj,,"^")
                            }
                        } Else {
                            Set tSchem = jsonResp.%GetIterator()
                            While tSchem.%GetNext(.skey,.svalue) {
                                If tParamType=skey {
                                    If (tSingleOutputObj) {
                                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                    } Else {
                                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^allOf^0^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^xml^name",pvalue.%Get("paramName"),,"^")
                                    }
                                }
                                If ..GetByLineKey(tSchemaDef,"components^schemas^"_skey,"^")="" Do ..SetByLineKey(tSchemaDef,"components^schemas^"_skey,svalue,,"^")
                                If (tParamType=skey),(tIsArray) {
                                    Do ..SetByLineKey(tSchemaDef,"components^schemas^arrayOf"_skey_"^type","array",,"^")
                                    Do ..SetByLineKey(tSchemaDef,"components^schemas^arrayOf"_skey_"^items^$ref","#/components/schemas/"_skey,,"^")
                                }
                            }
                        }
                    } ElseIf pvalue.%Get("pmJDType")'="",pvalue.%Get("pmJType")'="status",pvalue.%Get("output")="header" {
                        Set tParamDesc = ..GetByLineKey(value,"customParams^params^"_pvalue.%Get("param")_"^description",pDelim)
                        If tParamDesc'="" Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^headers^"_pvalue.%Get("paramName")_"^description",tParamDesc,,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^headers^"_pvalue.%Get("paramName")_"^schema^type",pvalue.%Get("pmJDType"),,"^")
                        If pvalue.%Get("pmJDFormat")'="" Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^headers^"_pvalue.%Get("paramName")_"^schema^format",pvalue.%Get("pmJDFormat"),,"^")
                    } ElseIf pvalue.%Get("pmJDType")'="",pvalue.%Get("pmJType")'="status",pvalue.%Get("output")'="" {
                        Set tParamDesc = ..GetByLineKey(value,"customParams^params^"_pvalue.%Get("param")_"^description",pDelim)
                        If tParamDesc'="" Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^description",tParamDesc,,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^"_pvalue.%Get("output")_"^schema^type",pvalue.%Get("pmJDType"),,"^")
                        If pvalue.%Get("pmJDFormat")'="" Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^"_pvalue.%Get("output")_"^schema^format",pvalue.%Get("pmJDFormat"),,"^")
                    } ElseIf pvalue.%Get("pmJDType")'="",pvalue.%Get("pmJType")'="status" {
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^type","object",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^type",$Select((tIsArray):"array",1:pvalue.%Get("pmJDType")),,"^")
                        If pvalue.%Get("pmJDFormat")'="",'tIsArray Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^format",pvalue.%Get("pmJDFormat"),,"^")
                        If (tIsArray) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^items^type",pvalue.%Get("pmJDType"),,"^")
                        If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^type",$Select((tIsArray):"array",1:pvalue.%Get("pmJDType")),,"^")
                        If (pIncludeXML),(tIsArray) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^items^type",pvalue.%Get("pmJDType"),,"^")
                        If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^content^application/xml^schema^xml^name","response",,"^")
                    } ElseIf pvalue.%Get("pmJDType")'="",pvalue.%Get("pmJType")="status" {
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^headers^iris-statuscode^description","1 For Success and 0 For Error",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^headers^iris-statuscode^schema^type","integer",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^headers^iris-statuscode^schema^format","int32",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^headers^iris-statusmessage^description","Display the error text for statuscode",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^headers^iris-statusmessage^schema^type","string",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^headers^iris-errorcode^description","Return an error status code with the error as specified by the internal errorcode",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^headers^iris-errorcode^schema^type","integer",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*"_value.%Get("successfulCode")_"^headers^iris-errorcode^schema^format","int32",,"^")

                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*500^headers^iris-statuscode^description","0 For Error",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*500^headers^iris-statuscode^schema^type","integer",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*500^headers^iris-statuscode^schema^format","int32",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*500^headers^iris-statusmessage^description","Display the error text for statuscode",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*500^headers^iris-statusmessage^schema^type","string",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*500^headers^iris-errorcode^description","Return an error status code with the error as specified by the internal errorcode",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*500^headers^iris-errorcode^schema^type","integer",,"^")
                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*500^headers^iris-errorcode^schema^format","int32",,"^")
                    }
                }
            }
            Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*400^content^application/json^schema^$ref","#/components/schemas/responseStatus",,"^")
            Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*400^description","Bad Request",,"^")
            Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*500^content^application/json^schema^$ref","#/components/schemas/responseStatus",,"^")
            Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^responses^*500^description","Internal Server Error",,"^")
            //Request
            If (value.%Get("hasComplexParams")) {
                Set tSingleInputObj = (tInBodyObjCount=1)
                If '(tSingleInputObj) {
                    Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^requestBody^$ref","#/components/requestBodies/"_key_"Request",,"^")
                    Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/json^schema^type","object",,"^")
                    If tParamDescription'="",'$IsObject(tParamDescription) {
                        Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^description",tParamDescription,,"^")
                    }
                    If tParamRequired'="",'$IsObject(tParamRequired) {
                        Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^required",tParamRequired,"boolean","^")
                    }
                    If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/xml^schema^type","object",,"^")
                    If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/xml^schema^xml^name",key_"Request",,"^")
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
                            Set jsonResp = {}.%FromJSON(pvalue.%Get("customObj").%ToJSON())
                        } ElseIf "DynamicObject DynamicArray"[tParamType {
                            Set tJSONSchema = pvalue.%Get("customSchema")
                            If tJSONSchema="" Set tJSONSchema = pvalue.%Get("customSchemaName")
                            Set tObjectName = pvalue.%Get("customSchemaName")
                            If tJSONSchema'="",'$IsObject(tJSONSchema) {
                                If mInfo.%Get("customSchemas").%Get(tObjectName)'="" {
                                    Set tJSONSchema={}.%Set(tObjectName,mInfo.%Get("customSchemas").%Get(tObjectName))
                                }
                            }
                            If $IsObject(tJSONSchema),tJSONSchema.%Size()=1 {
                                Do pvalue.%Set("paramType",tObjectName)
                                Set tParamType = tObjectName
                                Set jsonResp={}.%FromJSON(tJSONSchema.%ToJSON())
                                Do ..SetByLineKey(pvalue,"customObj",{}.%FromJSON(jsonResp.%ToJSON()),,pDelim)
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
                            Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^requestBody^$ref","#/components/requestBodies/"_key_"Request",,"^")
                            Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^description","Body Request Content",,"^")
                            If tParamDescription'="",'$IsObject(tParamDescription) {
                                Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^description",tParamDescription,,"^")
                            }
                            If tParamRequired'="",'$IsObject(tParamRequired) {
                                Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^required",tParamRequired,"boolean","^")
                            }
                            If tCustomFlatParams.%Get("description")'="" Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^description",tCustomFlatParams.%Get("description"),,"^")
                            If tCustomFlatParams.%Get("required")'="" Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^required",tCustomFlatParams.%Get("required"),"boolean","^")
                            If (tSingleOutputObj) {
                                Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/json^schema^type","object",,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/xml^schema^type","object",,"^")
                            } Else {
                                Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^type","object",,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^type","object",,"^")
                            }
                        } ElseIf tParamType="array" {
                            Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^requestBody^$ref","#/components/requestBodies/"_key_"Request",,"^")
                            Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^description","Body Request Content",,"^")
                            If tParamDescription'="",'$IsObject(tParamDescription) {
                                Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^description",tParamDescription,,"^")
                            }
                            If tParamRequired'="",'$IsObject(tParamRequired) {
                                Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^required",tParamRequired,"boolean","^")
                            }
                            If tCustomFlatParams.%Get("description")'="" Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^description",tCustomFlatParams.%Get("description"),,"^")
                            Set tArrayObj = {"anyOf":[
                                    {"type":"object"},
                                    {"type":"string"},
                                    {"type":"number"},
                                    {"type":"boolean"}
                                ]}
                            If (tSingleOutputObj) {
                                Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/json^schema^type","array",,"^")
                                Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/json^schema^items",tArrayObj,,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/xml^schema^type","array",,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/xml^schema^items",tArrayObj,,"^")
                            } Else {
                                Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^type","array",,"^")
                                Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^items",tArrayObj,,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^type","array",,"^")
                                If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^items",tArrayObj,,"^")
                            }
                        } Else {
                            Set tSchem = jsonResp.%GetIterator()
                            While tSchem.%GetNext(.skey,.svalue) {
                                Set tIsArray=($Piece(pvalue.%Get("paramType"),"|",2)'="")      
                                If tParamType=skey {
                                    If (tSingleInputObj) {
                                        Do ..SetByLineKey(tSchemaDef,"paths^"_tPath_"^"_tVerb_"^requestBody^$ref","#/components/requestBodies/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        If ..GetByLineKey(tSchemaDef,"components^requestBodies^"_$Select((tIsArray):"arrayOf",1:"")_skey)="" {
                                            Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_$Select((tIsArray):"arrayOf",1:"")_skey_"^content^application/json^schema^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                            If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_$Select((tIsArray):"arrayOf",1:"")_skey_"^content^application/xml^schema^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                            Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_$Select((tIsArray):"arrayOf",1:"")_skey_"^description","Body Request Content ("_$Select((tIsArray):"arrayOf",1:"")_skey_")",,"^")
                                            If tParamDescription'="",'$IsObject(tParamDescription) {
                                                Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_$Select((tIsArray):"arrayOf",1:"")_skey_"^description",tParamDescription,,"^")
                                            }
                                            If tParamRequired'="",'$IsObject(tParamRequired) {
                                                 Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_$Select((tIsArray):"arrayOf",1:"")_skey_"^required",tParamRequired,"boolean","^")
                                            }
                                            If tCustomFlatParams.%Get("description")'="" Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_$Select((tIsArray):"arrayOf",1:"")_skey_"^description",tCustomFlatParams.%Get("description"),,"^")
                                            If tCustomFlatParams.%Get("required")'="" Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_$Select((tIsArray):"arrayOf",1:"")_skey_"^required",tCustomFlatParams.%Get("required"),"boolean","^")
                                        }
                                    } Else {
                                        Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/json^schema^properties^"_pvalue.%Get("paramName")_"^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                        If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"components^requestBodies^"_key_"Request^content^application/xml^schema^properties^"_pvalue.%Get("paramName")_"^$ref","#/components/schemas/"_$Select((tIsArray):"arrayOf",1:"")_skey,,"^")
                                    }
                                }
                                If ..GetByLineKey(tSchemaDef,"components^schemas^"_skey,"^")="" Do ..SetByLineKey(tSchemaDef,"components^schemas^"_skey,svalue,,"^")
                                If (tParamType=skey),(tIsArray) {
                                    Do ..SetByLineKey(tSchemaDef,"components^schemas^arrayOf"_skey_"^type","array",,"^")
                                    Do ..SetByLineKey(tSchemaDef,"components^schemas^arrayOf"_skey_"^items^$ref","#/components/schemas/"_skey,,"^")
                                }
                            }
                        }
                    }
                }
            }
        }
        Do ..SetByLineKey(tSchemaDef,"components^schemas^responseStatus^type","object",,"^")
        If (pIncludeXML) Do ..SetByLineKey(tSchemaDef,"components^schemas^responseStatus^xml^name","responseStatus",,"^")
        Do ..SetByLineKey(tSchemaDef,"components^schemas^responseStatus^properties^statusCode^type","string",,"^")
        Do ..SetByLineKey(tSchemaDef,"components^schemas^responseStatus^properties^message^type","string",,"^")
        Do ..SetByLineKey(tSchemaDef,"components^schemas^responseStatus^properties^errorCode^type","string",,"^")
        Do ..SetByLineKey(tSchemaDef,"externalDocs^description","Find out more about Swagger",,"^")
        Do ..SetByLineKey(tSchemaDef,"externalDocs^url","http://swagger.io",,"^")
        If mInfo.%Get("customServers")'="" {
            Do ..SetByLineKey(tSchemaDef,"servers",mInfo.%Get("customServers"),,".")
        } Else {
            Do ..SetByLineKey(tSchemaDef,"servers[0]^url",pNS,,"^")
            Do ..SetByLineKey(tSchemaDef,"servers[1]^url",$Replace(pNS,"http",$Select($Find(pNS,"https")>0:"http",1:"https")),,"^")
        }
        If mInfo.%Get("customSecurity")'="" {
            Do ..SetByLineKey(tSchemaDef,"components^securitySchemes",mInfo.%Get("customSecurity"),,"^")
        } Else {
            Do ..SetByLineKey(tSchemaDef,"components^securitySchemes^basicAuth^type","http",,"^")
            Do ..SetByLineKey(tSchemaDef,"components^securitySchemes^basicAuth^scheme","basic",,"^")
        }
        Do ..SetByLineKey(tSchemaDef,"components^responses^UnauthorizedError^description","Authentication information is missing or invalid",,"^")
        Set pJSON = tSchemaDef       
        If pPrintResults {
            Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
            Do tFormatter.FormatToString(pJSON.%ToJSON(),.jsonString)
            Write jsonString
        }
    }
    Catch(e) {
        w $System.Status.GetOneErrorText(e.AsStatus()),!
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
        Set pCharsKey = $Select(pParams.charskey'="":pParams.charskey,1:"value")

        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"","nestedParentKey":"", "parentType":"", "level":0, "circRefCtrl":{},"originalJSON":{},"mapTypes":{},"json":{}}
        Set pLevel = pInternal.level
        Set pJSON = pInternal.json
        Set pParentKey = pInternal.parentKey
        Set pNestedParentKey = pInternal.nestedParentKey
        Set pParentType = pInternal.parentType
        Set pCircRefCtrl = pInternal.circRefCtrl
        Set pOriginalJSON = pInternal.originalJSON
        Set pMapTypes = pInternal.mapTypes
		If pParentType="" {
            Set tSC = ##class(apiPub.core.irisMetadata).ClassNameToXSD(pClassName,.pJSON,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
			Set pXSDInfo = {}
            Set tMapTypes = ##class(apiPub.core.typeMapper).GetXSDMapTypes()
            If pJSON.%Size()>0{
                Set prop = pJSON.%GetIterator()
                While prop.%GetNext(.key,.value) {
                    If $IsObject(value),value.%Get("proc")="",key'["ArrayOf" {
                        Set tSC = ..GetOpenAPISchema(pClassName,.pXSDInfo,pParams,{"parentKey":(key),"nestedParentKey":(key),"parentType":(key),"level":(1),"circRefCtrl":(pCircRefCtrl),"originalJSON":(pJSON),"mapTypes":(tMapTypes),"json":(value)})
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                    }
                }
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
                        Set tSC = ..GetOpenAPISchema(pClassName,.pXSDInfo,pParams,{"parentKey":(pParentKey),"nestedParentKey":(pNestedParentKey), "parentType":(pParentType),"level":(pLevel),"circRefCtrl":(pCircRefCtrl),"originalJSON":(pOriginalJSON),"mapTypes":(pMapTypes),"json":(pOriginalJSON.%Get(pJSON.%Get("basedOn")))})
                    } Else {
                        Set tSC = ..GetOpenAPISchema(pClassName,.pXSDInfo,pParams,{"parentKey":(tBasedOn),"nestedParentKey":(tBasedOn), "parentType":(tBasedOn),"level":(1),"circRefCtrl":(pCircRefCtrl),"originalJSON":(pOriginalJSON),"mapTypes":(pMapTypes),"json":(pOriginalJSON.%Get(tBasedOn))})
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                        Do ..SetByLineKey(pXSDInfo,pParentKey_pDelim_"allOf"_pDelim_"0"_pDelim_"$ref","#/components/schemas/"_tBasedOn,,pDelim)  
                        Set pParentKey=pParentKey_pDelim_"allOf"_pDelim_"1"
                    }
                } Else {
                    Set tBasedOnType = $Piece(pMapTypes.%Get($ZConvert($Piece(tType,":",2),"L")),"|",2)
                    If tBasedOnType="" Set tBasedOnType="string"
                    Set tBasedOnFormat = $Piece(pMapTypes.%Get($ZConvert($Piece(tType,":",2),"L")),"|",3)
                    Do ..SetByLineKey(pXSDInfo,pParentKey_pDelim_"properties"_pDelim_pCharsKey_pDelim_"type",tBasedOnType,,pDelim)
                    If tBasedOnFormat'="" Do ..SetByLineKey(pXSDInfo,pParentKey_pDelim_"properties"_pDelim_pCharsKey_pDelim_"format",tBasedOnFormat,,pDelim)
                }
            }
            //Correct Auto-Reference Limitation
            Do pCircRefCtrl.%Set(pParentType_pDelim_pParentType,pNestedParentKey)
            Set tParentCircRefCtrl = {}.%FromJSON(pCircRefCtrl.%ToJSON())
            If pJSON.%Get("type")="" {
                Do ..SetByLineKey(pXSDInfo,pParentKey_pDelim_"type","object",,pDelim)  
                Do ..SetByLineKey(pXSDInfo,pParentKey_pDelim_"xml"_pDelim_"name",$Piece(tOParentKey,pDelim,*),,pDelim)  
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
                    Set tRequired = (value.%Get("minOccurs")="")
                    Set tObjType = pOriginalJSON.%Get(tType)
                    Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$Select(key'="":key, 1:"")
                    Set tNestedKey = $Select(pNestedParentKey'="":pNestedParentKey_pDelim, 1:"")_$Select(key'="":key, 1:"")
                    Set tNested = pNestedMode
                    If $IsObject(tObjType) {
                        Do tObjType.%Set("proc",1)
                        If 'tIsArrayType Set tIsArrayType = tObjType.%Get("maxOccurs")="unbounded"
                        Set tCircKey = tParentCircRefCtrl.%Get(pParentType_pDelim_$Select((tIsArrayType):"ArrOf",1:"")_tType)
                        If (tCircKey="")||(tNestedKey'[tCircKey),$IsObject(tObjType) Do pCircRefCtrl.%Set(pParentType_pDelim_$Select((tIsArrayType):"ArrOf",1:"")_tType,tNestedKey)
                        If (tRequired) Do ..SetByLineKey(pXSDInfo,$Piece(tKey,pDelim,1,*-2)_pDelim_"required[+]",$Piece(tKey,pDelim,*),,pDelim)
                        If (tIsArrayType) {
                            Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"type","array",,pDelim)  
                            Set tKey=tKey_pDelim_"items"
                            Set tNestedKey=tNestedKey_pDelim_"items"
                        }
                        If (tCircKey="")||(tNestedKey'[tCircKey) {
                            Do ..SetByLineKey(pXSDInfo,tKey,{},,pDelim)  
                            If $IsObject(tObjType),tObjType.%Get("type")="" {
                                If (tType["ArrayOf")||(tType["PairOf") Set tNested=1
                                If tNested=0 Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"allOf[0]"_pDelim_"$ref","#/components/schemas/"_tType,,pDelim)
                                If value.%Get("documentation")'="" Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"description",value.%Get("documentation"),,pDelim)
                                If value.%Get("example")'="" Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"example",value.%Get("example"),,pDelim)
                                Set tSC = ..GetOpenAPISchema(pClassName,.pXSDInfo,pParams,{"parentKey":($Select((tNested=1):tKey,1:tType)),"nestedParentKey":(tNestedKey), "parentType":(tType),"level":(pLevel+1),"circRefCtrl":(pCircRefCtrl),"originalJSON":(pOriginalJSON),"mapTypes":(pMapTypes),"json":(tObjType)})
                                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                            } Else {
                                Set tJSONType = $Piece(pMapTypes.%Get($ZConvert(tType,"L")),"|",2)
                                If tJSONType="" Set tJSONType="string"
                                Set tJSONFormat = $Piece(pMapTypes.%Get($ZConvert(tType,"L")),"|",3)
                                Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"type",tJSONType,,pDelim)
                                If tJSONFormat'="" Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"format",tJSONFormat,,pDelim)
                                If tBasedOn'="" {
                                    Set tBasedOnType = $Piece(pMapTypes.%Get($ZConvert($Piece(tBasedOn,":",2),"L")),"|",2)
                                    Set tBasedOnFormat = $Piece(pMapTypes.%Get($ZConvert($Piece(tBasedOn,":",2),"L")),"|",3)
                                    If tBasedOnType'="" {
                                        Do ..SetByLineKey(pXSDInfo,$Piece(tKey,pDelim,1,*-1)_pDelim_pCharsKey_pDelim_"type",tBasedOnType,,pDelim)
                                        If tBasedOnFormat'="" Do ..SetByLineKey(pXSDInfo,$Piece(tKey,pDelim,1,*-1)_pDelim_pCharsKey_pDelim_"format",tBasedOnFormat,,pDelim)
                                    }
                                }
                                If value.%Get("enumeration")'="" {
                                    If "number integer"[tJSONType {
                                        Set tEnum = value.%Get("enumeration").%GetIterator()
                                        While (tEnum.%GetNext(.enk,.vk)) {
                                            Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"enum"_pDelim_enk,+vk,"number",pDelim)
                                        }
                                    } Else {
                                        Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"enum",value.%Get("enumeration"),,pDelim)
                                    }
                                }
                            } 
                            If value.%Get("documentation")'="" Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"description",value.%Get("documentation"),,pDelim)
                            If value.%Get("example")'="" Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"example",value.%Get("example"),,pDelim)
                        } Else {
                            If tNestedKey[tCircKey {
                                If ..GetByLineKey(pXSDInfo,tKey,pDelim)="" {
                                    Set tAutoRefKey = "#/components/schemas/"_$Replace(tCircKey,"^","/")
                                    Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"$ref",tAutoRefKey,,pDelim)
                                }
                            }
                        }
                    } Else {
                        If (tRequired) Do ..SetByLineKey(pXSDInfo,$Piece(tKey,pDelim,1,*-2)_pDelim_"required[+]",$Piece(tKey,pDelim,*),,pDelim)
                        If (tIsArrayType) {
                            Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"type","array",,pDelim)  
                            Set tKey=tKey_pDelim_"items"
                            Set tNestedKey=tNestedKey_pDelim_"items"
                        }
                        Set tJSONType = $Piece(pMapTypes.%Get($ZConvert(value.%Get("type"),"L")),"|",2)
                        If tJSONType="" Set tJSONType="object"
                        Set tJSONFormat = $Piece(pMapTypes.%Get($ZConvert(value.%Get("type"),"L")),"|",3)
                        Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"type",tJSONType,,pDelim)
                        If tJSONFormat'="" Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"format",tJSONFormat,,pDelim)
                        If tBasedOn'="" {
                            Set tBasedOnType = $Piece(pMapTypes.%Get($ZConvert($Piece(tBasedOn,":",2),"L")),"|",2)
                            Set tBasedOnFormat = $Piece(pMapTypes.%Get($ZConvert($Piece(tBasedOn,":",2),"L")),"|",3)
                            If tBasedOnType'="" {
                                Do ..SetByLineKey(pXSDInfo,$Piece(tKey,pDelim,1,*-1)_pDelim_pCharsKey_pDelim_"type",tBasedOnType,,pDelim)
                                If tBasedOnFormat'="" Do ..SetByLineKey(pXSDInfo,$Piece(tKey,pDelim,1,*-1)_pDelim_pCharsKey_pDelim_"format",tBasedOnFormat,,pDelim)
                            }
                        }
                        If value.%Get("enumeration")'="" {
                            If "number integer"[tJSONType {
                                Set tEnum = value.%Get("enumeration").%GetIterator()
                                While (tEnum.%GetNext(.enk,.vk)) {
                                    Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"enum"_pDelim_enk,+vk,"number",pDelim)
                                }
                            } Else {
                                Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"enum",value.%Get("enumeration"),,pDelim)
                            }
                        }
                        Set tOType = $Select("string boolean date dateTime decimal"'[value.%Get("type"):"("_value.%Get("type")_") ",1:"")
                        if tOType="(long) " Set tOType=""
                        If (value.%Get("documentation")'="")||(tOType'="") Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"description",tOType_value.%Get("documentation"),,pDelim)
                        If (value.%Get("example")'="") Do ..SetByLineKey(pXSDInfo,tKey_pDelim_"example",tOType_value.%Get("example"),,pDelim)
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
			Do ..TemplateToOpenApiSchema(pJSON,pObjectName,.pOpenApiJSON,pParams,{"parentKey":(pObjectName), "parentType":($Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object"))})
            If pPrintResults {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pOpenApiJSON.%ToJSON(),.jsonString)
                Write jsonString,!
            }
		} Else {
            Do ..SetByLineKey(pOpenApiJSON,pParentKey_pDelim_"type",pParentType,,pDelim)
            Set pParentKey=pParentKey_pDelim_$Select(pParentType="object":"properties",1:"items")
            Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                Set tk = key  If pParentType="array",key=+key Set tk = ""
                Set tKey = $Select(pParentKey'="":pParentKey, 1:"")_$Select(tk'="":pDelim_tk, 1:"")
                If $IsObject(value),$Find($Piece(tKey,pDelim,*),"@")=0 {
                    Do ..TemplateToOpenApiSchema(value,pObjectName,.pOpenApiJSON,pParams,{"parentKey":(tKey), "parentType":($Select($ClassName(value)="%Library.DynamicArray":"array",1:"object"))})
				} Else {
                    If $Find($Piece(tKey,pDelim,*),"@")=0 {
                        Set tCType = pJSON.%GetTypeOf(key)
                        Set tExType = ..GetByLineKey(pOpenApiJSON,tKey_pDelim_"type",pDelim)
                        If tExType'="",tCType'=tExType Set tCType = "string"
                        Do ..SetByLineKey(pOpenApiJSON,tKey_pDelim_"type",tCType,,pDelim)
                        Do ..SetByLineKey(pOpenApiJSON,tKey_pDelim_"example",value,tCType,pDelim)
                    } Else {
                        Set tOrigProp = $Piece($Piece(tKey,pDelim,*),"@",1)
                        Set tSchemaProp = $Piece($Piece(tKey,pDelim,*),"@",2)
                        Set tKey = $Piece(tKey,pDelim,1,*-1)_pDelim_tOrigProp_pDelim_tSchemaProp
                        Do ..SetByLineKey(pOpenApiJSON,tKey,value,,pDelim)
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

}

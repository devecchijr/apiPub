Class apiPub.core.introspector Extends apiPub.core.jsonBuilder
{

/// w ##class(apiPub.core.introspector).getMethodsSpecFromFile("/irisdev/app/tmpFiles/devecchijr7-Pet-1.0.0-swagger.json")
ClassMethod getMethodsSpecFromFile(pFileName As %String) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set stream=##class(%FileCharacterStream).%New()
        Set tSC = stream.LinkToFile(pFileName)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        Set tJSON = ##Class(%Library.DynamicObject).%FromJSON(stream.Read())
        If tJSON.%Size()>0 {
            Set tSC = ..getMethodsSpec(tJSON,.tSpec,{"printResults":1})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        }
	}
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod getApiClassFromOAS(OAS As %DynamicObject, APIClass As %DynamicObject, ByRef XData As %DynamicObject, Output apiDescription As %String, responseLog As %Stream.GlobalCharacter) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        If (OAS.%Size()=0)||(..g(OAS,"openapi")="") {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "<400> invalid OAS content"))
        }
        Set tSC = ..getMethodsSpec(OAS,.tSpec,{"printResults":0})
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        While ..i(tSpec,"methodSpec",.idx,.val,.it) {
            Set tApipubNotation = {}
            If ..g(val,"summary")'="" Do ..s(tApipubNotation,"description",..treatDescription(..g(val,"summary")))
            If ..g(val,"tag")'="" Do ..s(tApipubNotation,"tag",..g(val,"tag"))
            If ..g(val,"path")'="",'("/"_idx=..g(val,"path")) Do ..s(tApipubNotation,"path",..g(val,"path"))
            Do ..s(tApipubNotation,"verb",..g(val,"verb"))
            If ..g(tApipubNotation,"verb")="post",..g(val,"payload")'="" Do ..r(tApipubNotation,"verb")
            If ..g(tApipubNotation,"verb")="get",..g(val,"payload")="" Do ..r(tApipubNotation,"verb")
            If ..g(val,"description")'="" Do ..s(tApipubNotation,"params.description",..treatDescription(..g(val,"description")),,"^")
            Set tMethod = {
                    "_name":(idx),
                    "ClassMethod":1,
                    "WebMethod":1
            }
            Set tInputParams = ""
            If (..g(val,"params")'=""||..g(val,"payload")'=""){
                Set tInputParams = ..getInputParams(..g(val,"params"),..g(val,"payload"),tApipubNotation)
                Do ..s(tMethod,"FormalSpec",tInputParams)
            }
            Set tResponse = ..getResponse(..g(val,"response"),tApipubNotation,.tInputParams)
            If tInputParams'="" Do ..s(tMethod,"FormalSpec",tInputParams)
            Do  Do ..s(tMethod,"ReturnType",tResponse)
            Set tb = $Char(9)
            Set cr = $Char(10)
            Set tImplCode=tb_"//your code here"
            If tResponse="%Status" {
                Set crt = cr_tb
                Set tImplCode = tb_"Set tSC = $System.Status.OK()"_crt_"Try {"_crt_tb_"//your code here"_crt_"}"_crt_"Catch(e) {"_crt_tb_"Set tSC = e.AsStatus()"_crt_"}"_crt_"Quit tSC"
            }
            Do ..s(tMethod,"Implementation",tImplCode)
            If ..g(val,"successfulCode")'="",..g(val,"successfulCode")'="200" Do ..s(tApipubNotation,"successfulCode",..g(val,"successfulCode"))
            If ..g(val,"exceptionCodes")'="" {
                Set tCodes=[]
                While ..i(val,"exceptionCodes",.exIdx,.exVal,.exIt) {
                    Do tCodes.%Push({"code":(exIdx),"description":(..g(exVal,"description"))})
                }
                If tCodes.%Size()>0 Do ..s(tApipubNotation,"statusCodes",tCodes)
            }
            Do ..s(tMethod,"Description",..getApiPubNotation(tApipubNotation))
            Do responseLog.WriteLine("Method """_idx_""" created")
            Do ..s(APIClass,"Method.+",tMethod)
        }

        Set apiDescription="{apiClassName}"
        If ..g(tSpec,"XData")'="" {
            Set XData = ..g(tSpec,"XData")
            If ..g(XData,"info.title")'="" Set apiDescription=..g(XData,"info.title")
            If apiDescription="",..g(XData,"info.description")'="" Set apiDescription=..g(XData,"info.description")
        }
	}
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod getMethodsSpec(pJSON As %Library.DynamicObject, Output pSpec As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)

        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"", "parentType":"","originalJSON":(pJSON),"level":0}
        Set pParentKey = pInternal.parentKey
        Set pParentType = pInternal.parentType
        Set pLevel = pInternal.level
		If pParentType="" {
            Set pSpec={}
			Set tSC = ..getMethodsSpec(pJSON ,.pSpec, pParams,{"parentKey":"", "parentType":($Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object")),"originalJSON":(pInternal.originalJSON),"level":1})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            If pPrintResults {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pSpec.%ToJSON(),.jsonString)
                Write jsonString,!
            }
		} Else {
			Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
				Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$Select(key'="":key, 1:"")
				If $IsObject(value) {
                    If ..g(value,"operationId")'="" {
                        Set tMethod = {}
                        Do ..s(tMethod,"path",$Piece(tKey,pDelim,*-1))
                        Do ..s(tMethod,"verb",$Piece(tKey,pDelim,*))
                        If ..g(value,"summary")'="" Do ..s(tMethod,"summary",..g(value,"summary"))
                        If ..g(value,"description")'="" Do ..s(tMethod,"description",..g(value,"description"))
                        If ..g(value,"tags")'="" Do ..s(tMethod,"tag",..g(value,"tags.0"))
                        While ..i(value,"parameters",.pIdx,.pVal,.pIt) {
                            Set tName = ..g(pVal,"name")
                            Do ..s(tMethod,"params."_tName,pVal)
                            Do ..r(tMethod,"params."_tName_".name")
                        }
                        While ..i(value,"requestBody",.rIdx,.rVal,.rIt) {
                            Set (tReqObj,tParamName)=""
                            If rIdx="$ref" {
                                Set tPath = $E($Translate(rVal,"/#",pDelim),2,*)
                                Set tParamName = $Piece(tPath,pDelim,*)
                                Set tRef = ..g(pInternal.originalJSON,tPath,pDelim)
                                If $IsObject(tRef) {
                                    If ..g(tMethod,"description")="",..g(tRef,"description")'="" Do ..s(tMethod,"description",..g(tRef,"description")) 
                                    Set rVal = ..g(tRef,"content")
                                }
                            } 
                            Set tSchPath=..g(rVal,"application/json"_pDelim_"schema"_pDelim_"$ref",pDelim)
                            If tSchPath'="" {
                                Set tPath = $E($Translate(tSchPath,"/#",pDelim),2,*)
                                Set tParamName = $Piece(tPath,pDelim,*)
                                Set tRef = ..g(pInternal.originalJSON,tPath,pDelim)
                                If $IsObject(tRef) {
                                    Set tReqObj={}
                                    Do ..s(tReqObj,"application/json"_pDelim_"schemaRef",tParamName,,pDelim)
                                    Do ..s(tReqObj,"application/json"_pDelim_"schemaRefType",..g(tRef,"type"),,pDelim)
                                } 
                            } ElseIf ..g(rVal,"application/json"_pDelim_"schema",pDelim)'="" {
                                Set tReqObj = {}
                                Set tSchema = ..g(rVal,"application/json"_pDelim_"schema",pDelim).%ToJSON()
                                Set tSchema = $Replace($Replace($TR(tSchema," :{}"_$Char(13,10)_$Char(9),""),"""type""",""),"""","")
                                If ((tSchema="object")||(tSchema="array")) {
                                    Do ..s(tReqObj,"application/json"_pDelim_"genericType",tSchema,,pDelim)
                                } ElseIf tSchema="array,itemsanyOf[object,string,number,boolean]" {
                                    Do ..s(tReqObj,"application/json"_pDelim_"genericType","array",,pDelim)
                                } Else {
                                    Do ..s(tReqObj,"application/json"_pDelim_"schemaRef",..g(value,"operationId")_"_request",,pDelim)
                                    Do ..s(pSpec,"XData"_pDelim_"schemas"_pDelim_..g(value,"operationId")_"_request",..g(rVal,"application/json"_pDelim_"schema",pDelim),,pDelim)
                                    Do ..s(tReqObj,"application/json"_pDelim_"schemaRefType",..g(rVal,"application/json"_pDelim_"schema"_pDelim_"type",pDelim),,pDelim)
                                }
                            } Else {
                                Set tReqObj = rVal
                            }
                            If $IsObject(tReqObj) {
                                While ..i(tReqObj,,.cparIdx,.cparVal,.cparIt) {
                                    Do ..s(tMethod,"payload."_cparIdx,cparVal)
                                }
                            }
                        }
                        While ..i(value,"responses",.rIdx,.rVal,.rIt) {
                            Set tRespCode=+rIdx
                            If tRespCode<300{
                                Set tContent = ..g(rVal,"content")
                                If ..g(rVal,"headers")'="" {
                                    While ..i(..g(rVal,"headers"),,.crespIdx,.crespVal,.crespIt) {
                                        Do ..s(tMethod,"response.headers."_crespIdx,crespVal)
                                    }
                                }
                                If tContent'="" {
                                    Set (tRespObj,tSchemaName)=""
                                    Set tSchPath=..g(tContent,"application/json"_pDelim_"schema"_pDelim_"$ref",pDelim)
                                    If tSchPath'="" {
                                        Set tPath = $E($Translate(tSchPath,"/#",pDelim),2,*)
                                        Set tSchemaName = $Piece(tPath,pDelim,*)
                                        Set tRef = ..g(pInternal.originalJSON,tPath,pDelim)
                                        If $IsObject(tRef) {
                                            Set tRespObj={}
                                            Do ..s(tRespObj,"application/json"_pDelim_"schemaRef",tSchemaName,,pDelim)
                                            Do ..s(tRespObj,"application/json"_pDelim_"schemaRefType",..g(tRef,"type"),,pDelim)
                                        }
                                    } ElseIf ..g(tContent,"application/json"_pDelim_"schema",pDelim)'="" {
                                        Set tRespObj = {}
                                        Set tSchema = ..g(tContent,"application/json"_pDelim_"schema",pDelim).%ToJSON()
                                        Set tSchema = $Replace($Replace($TR(tSchema," :{}"_$Char(13,10)_$Char(9),""),"""type""",""),"""","")
                                        If ((tSchema="object")||(tSchema="array")) {
                                            Do ..s(tRespObj,"application/json"_pDelim_"genericType",tSchema,,pDelim)
                                        } ElseIf tSchema="array,itemsanyOf[object,string,number,boolean]" {
                                            Do ..s(tRespObj,"application/json"_pDelim_"genericType","array",,pDelim)
                                        } Else {
                                            Do ..s(tRespObj,"application/json"_pDelim_"schemaRef",..g(value,"operationId")_"_response",,pDelim)
                                            Do ..s(pSpec,"XData"_pDelim_"schemas"_pDelim_..g(value,"operationId")_"_response",..g(tContent,"application/json"_pDelim_"schema",pDelim),,pDelim)
                                            Do ..s(tRespObj,"application/json"_pDelim_"schemaRefType",..g(tContent,"application/json"_pDelim_"schema"_pDelim_"type",pDelim),,pDelim)
                                        }
                                    } Else {
                                        Set tRespObj = tContent 
                                    }
                                    If $IsObject(tRespObj) {
                                        While ..i(tRespObj,,.crespIdx,.crespVal,.crespIt) {
                                            Do ..s(tMethod,"response."_crespIdx,crespVal)
                                        }
                                    }
                                }
                                Do ..s(tMethod,"successfulCode",tRespCode,"string")
                            } ElseIf rIdx'=500 {
                                If tMethod.%Get("exceptionCodes")="" Do tMethod.%Set("exceptionCodes",{})
                                Do tMethod.%Get("exceptionCodes").%Set(rIdx,rVal)
                            }
                        }
                        Set tKey="methodSpec"_pDelim_..g(value,"operationId")
                        Do ..s(pSpec,"methodSpec."_..g(value,"operationId"),tMethod)
                    }
                    Do ..getMethodsSpec(value,.pSpec,pParams,{"parentKey":(tKey), "parentType":($Select($ClassName(value)="%Library.DynamicArray":"array",1:"object")),"originalJSON":(pInternal.originalJSON),"level":(pLevel+1)})
    			} Else {
                    If $Find(tKey,"components"_pDelim_"schemas")>0 Do ..s(pSpec,"XData"_pDelim_$Replace(tKey,"components"_pDelim,""),value,,pDelim)
                    If $Piece(tKey,pDelim,1)="info" Do ..s(pSpec,"XData"_pDelim_tKey,value,,pDelim)
                    If $Piece(tKey,pDelim,1)="tags" Do ..s(pSpec,"XData"_pDelim_tKey,value,,pDelim)
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

ClassMethod getInputParams(paramsSpec As %DynamicObject, payload As %DynamicObject, ByRef apiPubNotation As %DynamicObject) As %String
{
    Set tTypes = {
        "string|":"%String",
        "number|":"%Numeric",
        "boolean|":"%Boolean",
        "string|date":"%Date",
        "string|date-time":"%DateTime",
        "integer|":"%Integer",
        "integer|int64":"%BigInt",
        "integer|int32":"%Integer"
    }
    Set tRet = ""
    While (..i(paramsSpec,,.idx,.val,.it)) {
        Set tParamName = $Tr(idx,"!@#$%ˆ&*()_-","")
        If idx'=tParamName Do ..s(apiPubNotation,"params."_tParamName_".name",idx,,"^")
        If ..g(val,"required")'="" Do ..s(apiPubNotation,"params."_tParamName_".required",..g(val,"required"),,"^") 
        If ..g(val,"description")'="" Do ..s(apiPubNotation,"params."_tParamName_".description",..treatDescription(..g(val,"description")),,"^") 
        Set tType = ..g(tTypes,..g(val,"schema.type")_"|"_..g(val,"schema.format"))
        If tType="" Set tType="%String"
        If ..g(val,"in")="header" {
            Do ..s(apiPubNotation,"params."_tParamName_".inputType","header",,"^")
        }
        If ..g(val,"schema.type")="array" {
            If ..g(val,"schema.items.enum")'="" Do ..s(apiPubNotation,"params."_tParamName_".schema.items.enum",..g(val,"schema.items.enum"),,"^")
            If ..g(val,"schema.items.default")'="" Do ..s(apiPubNotation,"params."_tParamName_".schema.items.default",..g(val,"schema.items.default"),,"^")
        }
        Set tRet=tRet_$Select(tRet'="":",",1:"")_tParamName_":"_tType
    }
    While (..i(payload,,.idx,.val,.it)) {
        Set tType="%DynamicObject"
        If ..g(val,"schemaRefType")="array" Set tType="%DynamicArray"
        If ..g(val,"description")'="" Do ..s(apiPubNotation,"params.payload.description",..treatDescription(..g(val,"description")),,"^") 
        If ..g(val,"required")'="" Do ..s(apiPubNotation,"params.payload.required",..g(val,"required"),,"^") 
        If idx="application/json",..g(val,"schemaRef")'="" {
            Do ..s(apiPubNotation,"params.payload.schema",..g(val,"schemaRef"),,"^")
            Do ..s(apiPubNotation,"params.payload.parse","true",,"^")
            Set tRet=tRet_$Select(tRet'="":",",1:"")_"payload"_":"_tType
        } ElseIf idx="application/json",..g(val,"genericType")="array" {
            Set tType="%DynamicArray"
            Set tRet=tRet_$Select(tRet'="":",",1:"")_"payload"_":"_tType
        } ElseIf idx="application/json" {
            Set tRet=tRet_$Select(tRet'="":",",1:"")_"payload"_":"_tType
        } ElseIf idx="application/x-www-form-urlencoded" {
            While (..i(val,"schema.properties",.encIdx,.encVal,.encIt)) {
                Set tParamName = $Tr(encIdx,"!@#$%ˆ&*()_-","")
                If encIdx'=tParamName Do ..s(apiPubNotation,"params."_tParamName_".name",encIdx,,"^")
                If ..g(encVal,"description")'="" Do ..s(apiPubNotation,"params."_tParamName_".description",..treatDescription(..g(encVal,"description")),,"^") 
                Set tType = ..g(tTypes,..g(encVal,"type")_"|"_..g(encVal,"format"))
                If tType="" Set tType="%String"
                Do ..s(apiPubNotation,"params."_tParamName_".inputType",idx,,"^") 
                Set tRet=tRet_$Select(tRet'="":",",1:"")_tParamName_":"_tType
            }
        } ElseIf ..g(val,"schema.type")="string",..g(val,"schema.format")="" {
            Do ..s(apiPubNotation,"params.payload.inputType",idx,,"^")
            Set tType="%Stream.GlobalCharacter"
            Set tRet=tRet_$Select(tRet'="":",",1:"")_"payload"_":"_tType
        } ElseIf ..g(val,"schema.type")="string",..g(val,"schema.format")="binary" {
            Do ..s(apiPubNotation,"params.payload.inputType",idx,,"^")
            Set tType="%Stream.GlobalBinary"
            Set tRet=tRet_$Select(tRet'="":",",1:"")_"payload"_":"_tType
        }
    }
    Quit tRet
}

ClassMethod getResponse(responseSpec As %DynamicObject, ByRef apiPubNotation As %DynamicObject, ByRef outputParams As %String) As %String
{
    Set tTypes = {
        "string|":"%String",
        "number|":"%Numeric",
        "boolean|":"%Boolean",
        "string|date":"%Date",
        "string|date-time":"%DateTime",
        "integer|":"%Integer",
        "integer|int64":"%BigInt",
        "integer|int32":"%Integer"
    }
    Set tRet = ""
    While (..i(responseSpec,,.idx,.val,.it)) {
        Set tType="%DynamicObject"
        If ..g(val,"schemaRefType")="array" Set tType="%DynamicArray"
        If ..g(val,"description")'="" Do ..s(apiPubNotation,"response.description",..treatDescription(..g(val,"description")),,"^") 
        If idx="application/json",..g(val,"schemaRef")'="" {
            If ..g(val,"schemaRefType")'="array",..g(val,"schemaRefType")'="object" {
                Do ..s(apiPubNotation,"response.outputType","text/plain",,"^")
                Set tType=..g(tTypes,..g(val,"schemaRefType")_"|")
            }
            Do ..s(apiPubNotation,"response.schema",..g(val,"schemaRef"),,"^")
            Set tRet=tRet_$Select(tRet'="":",",1:"")_tType
        } ElseIf idx="application/json",..g(val,"genericType")="array" {
            Set tType="%DynamicArray"
            Set tRet=tRet_$Select(tRet'="":",",1:"")_tType
        } ElseIf idx="application/json" {
            Set tRet=tRet_$Select(tRet'="":",",1:"")_tType
        } ElseIf idx="headers" {
            While (..i(val,,.hIdx,.hVal,.hIt)) {
                Set tParamName = $Tr(hIdx,"!@#$%ˆ&*()_-","")
                If hIdx'=tParamName Do ..s(apiPubNotation,"params."_tParamName_".name",hIdx,,"^")
                If ..g(hVal,"description")'="" Do ..s(apiPubNotation,"params."_tParamName_".description",..treatDescription(..g(hVal,"description")),,"^") 
                Set tType = ..g(tTypes,..g(hVal,"schema.type")_"|"_..g(hVal,"schema.format"))
                If tType="" Set tType="%String"
                Do ..s(apiPubNotation,"params."_tParamName_".outputType",idx,,"^")
                Set outputParams=outputParams_$Select(outputParams'="":",",1:"")_"*"_tParamName_":"_tType
            }
        } ElseIf ..g(val,"schema.type")="string",..g(val,"schema.format")="" {
            Do ..s(apiPubNotation,"response.outputType",idx,,"^")
            Set tType="%Stream.GlobalCharacter"
            Set tRet=tRet_$Select(tRet'="":",",1:"")_tType
        } ElseIf ..g(val,"schema.type")="string",..g(val,"schema.format")="binary" {
            Do ..s(apiPubNotation,"response.outputType",idx,,"^")
            Set tType="%Stream.GlobalBinary"
            Set tRet=tRet_$Select(tRet'="":",",1:"")_tType
        }
    }
    If tRet="" Set tRet = "%Status"
    Quit tRet
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

ClassMethod treatDescription(desc) As %String
{
    Quit $Replace($Replace($Replace($Replace($Replace($Replace(desc,"=","@equals"),$Char(10),""),$Char(13),"")," \",""),"\",""),"@equals","\=")
}

}

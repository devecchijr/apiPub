Class apiPub.core.service Extends (%CSP.REST, %Projection.AbstractProjection, apiPub.core.jsonBuilder)
{

Parameter CHARSET As %String = "UTF-8";

Parameter CONTENTTYPEJSON As %String = "application/json";

Parameter HandleCorsRequest = 1;

Parameter Cors = 1;

Parameter ReservedInboundParams As %String = "CachePassWord,CacheUserName,IRISUsername,IRISPassword,";

Parameter ReservedOutboundParams As %String = "CachePassWord,CacheUserName,IRISUsername,IRISPassword,TargetBaseURL";

Parameter DefaultForEmptyContentType As %String;

Parameter BeautifyJsonBodyResponse As %Boolean = 1;

Parameter BeautifyJsonBodyRequest As %Boolean = 1;

Parameter DispatchClass As %String;

Parameter OASPath As %String = "Get:/oas";

/// Allow API Calling
Parameter OnlyOAS As %Boolean = 0;

/// Use TracerBSName for monitoring
Parameter Traceable As %Boolean = 0;

Parameter TracerBSName = "apiPub.tracer.bs";

Parameter SSL As %String = "DEFAULT";

Parameter HTTPS As %Boolean = 0;

Parameter CallerInfo = "Rest Client";

Parameter TargetBaseURL;

Parameter APIDomain = "apiPub";

ClassMethod ServiceRouter(pRequest As apiPub.service.message, Output pResponse As apiPub.service.message) As %Status
{
    Set tSC = $$$OK 
    Try {
        If pRequest.APIOperationId="GetOAS",pRequest.DispatchClass'="" Return ##class(apiPub.core.service).GetOAS(pRequest,.pResponse)
		If pRequest.DispatchClass'="",pRequest.DispatchMethod'="" Return ##class(apiPub.core.service).CallAPI(pRequest,.pResponse)
		Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Invalid API Mapper"))
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
    Quit tSC
}

ClassMethod CallAPI(pRequest As apiPub.service.message, Output pResponse As apiPub.service.message) As %Status
{
    Set tSC = $$$OK 
    Try {
		If (..#OnlyOAS) {
			If pRequest.Body.SizeGet()=0 Set tSC = $$$ERROR($$$GeneralError, "Only Documentation (OAS)")
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
		}
        Set tBodyRequest = {}
        If "Post Put"[pRequest.HttpVerb,$ZConvert(pRequest.ContentType,"L")["json" {
			If pRequest.Body.SizeGet()=0 Set tSC = $$$ERROR($$$GeneralError, "Body Could Not be Empty")
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tBodyRequest = {}.%FromJSON(pRequest.Body.Read())
            Set pResponse.ContentType =  "application/json"
        } ElseIf "Post Put"[pRequest.HttpVerb,$ZConvert(pRequest.ContentType,"L")["xml" {
            If pRequest.Body.SizeGet()=0 Set tSC = $$$ERROR($$$GeneralError, "Body Could Not be Empty")
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tBodyRequest = pRequest.Body.Read()
            Set pResponse.ContentType =  "application/xml"
        } ElseIf "Post Put"[pRequest.HttpVerb {
            //Set tSC = $$$ERROR($$$GeneralError, "Invalid Content Type")
            Set tBodyRequest = {}
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        }
        Set tSC = ..GetRestParams(pRequest.Params,.tParams,.tMethodParams)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
		Set tParams.printResults=0
		Set innerStat = {}
		Set pSuccessfulCode=""
		Set tSC = ##class(apiPub.core.dispatcher).JSONCall(pRequest.DispatchClass_"||"_pRequest.DispatchMethod,,pRequest.HttpVerb,tBodyRequest,tMethodParams,.jsonResult,tParams,.innerStat,.pInnerStat,.pSuccessfulCode)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		If innerStat.%Size()>0{
            Set pResponse.Headers={
                "iris-StatusCode":(innerStat.%Get("statusCode")),
                "iris-StatusMessage":(innerStat.%Get("message")),
                "iris-ErrorCode":(innerStat.%Get("errorCode"))
            }.%ToJSON()
        }
        If $Data(jsonResult),$IsObject(jsonResult) {
			If jsonResult.%Size()>0||(($ClassName(jsonResult)="%Library.DynamicArray")&&$IsObject(jsonResult)) Do pResponse.Body.Write(jsonResult.%ToJSON())
			Set pResponse.ContentType = "application/json"
        } ElseIf $Data(xmlResult),$IsObject(xmlResult) {
			If xmlResult.%Size()>0 Do pResponse.Body.Write(xmlResult.Read())
			Set pResponse.ContentType = "application/xml"
		}
        Set pResponse.ResponseStatusCode = pSuccessfulCode
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
    Quit tSC
}

ClassMethod GetOAS(pRequest As apiPub.service.message, Output pResponse As apiPub.service.message) As %Status
{
    Set tSC = $$$OK 
    Try {
        If pRequest.Params="" Set pRequest.Params="{}"
        //Separate internal behavioral params from other params
        Set tSC = ..GetRestParams(pRequest.Params,.tParams,.tBusParams)
        Set tBasePath = tBusParams.%Get("basePath")
        Set tParams.basePath = tBasePath
        Set tParams.printResults = 0
        Set tSC = ##class(apiPub.core.publisher).GetOASFromClass(pRequest.DispatchClass,.tJsonResponse,tParams,pRequest.RequestURL)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        Do pResponse.Body.Write(tJsonResponse.%ToJSON())
        Set pResponse.ContentType =  "application/json"
        Set pResponse.ResponseStatusCode = 200
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
    Quit tSC
}

ClassMethod HttpCall(pURLPaths...) As %Status
{
	Try 
	{
		Set tRequestParams = {
        	"targetBaseURL":(..#TargetBaseURL)
			,"apiDomain":(..#APIDomain)
			,"callerInfo":(..#CallerInfo)
			,"reservedInboundParams":(..#ReservedInboundParams)
			,"beautifyJsonBodyRequest":(..#BeautifyJsonBodyRequest)
		}
		Set tSC = ..HttpRequestToMsgRequest(%request,tRequestParams,.tRequest, pURLPaths...)
		If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		If (..#Traceable) {
			Set tSC = ..CallBS(..#TracerBSName,tRequest,.tResponse)
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		} Else {
			Set tResponse = ##class(apiPub.service.message).%New()
			Set tSC = ..DirectMethodCall(tRequest,.tResponse)
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		}
		Set tResponseParams = {
			"defaultForEmptyContentType":(..#DefaultForEmptyContentType)
			,"beautifyJsonBodyResponse":(..#BeautifyJsonBodyResponse)
		}
		Set tSC = ..TreatMsgResponse(tRequest,.tResponse,tResponseParams)
		If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		Set tSC = ..MsgResponseToHttpResponse(tResponse)
		If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
	}
	Catch(e) {
		Do ..ErrorHandler(e, .tSC)
	}
	Quit tSC
}

ClassMethod DirectMethodCall(pRequest As apiPub.service.message, Output pResponse As apiPub.service.message) As %Status
{
    Set tSC = $$$OK 
    Try {
        Set tSC = ..ServiceRouter(pRequest,.pResponse)
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
    Quit tSC
}

ClassMethod ProxyHttpCall(pRequest As apiPub.service.message, Output pResponse As apiPub.service.message) As %Status
{
    Set tSC = $$$OK 
    Try {
		Set tRequestParams = {
        	"targetBaseURL":(..#TargetBaseURL)
			,"https":(..#HTTPS)
			,"ssl":(..#SSL)
			,"reservedOutboundParams":(..#ReservedOutboundParams)
		}
        Set tSC = ..MsgRequestToHttpRequest(pRequest,tRequestParams,.tHttpRequest,.tURL)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        Set tSC = $Method(tHttpRequest,pRequest.HttpVerb,tURL)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        Set tSC = ..HttpResponseToMsgResponse(tURL,tHttpRequest,pRequest,.pResponse)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
    Quit tSC
}

// Separate Behaviour params (starts with _) from Method/Request params

ClassMethod GetRestParams(pRestParams As %String, Output pParams As %Library.DynamicObject, Output pRequestParams As %Library.DynamicObject) As %Status
{
    Set tSC = $$$OK 
    Try {
        If '$Data(pRequestParams) Set pRequestParams = {}
        If '$Data(pParams) Set pParams = {}
        If pRestParams="" Set pRestParams="{}"
        Set tIter = {}.%FromJSON(pRestParams).%GetIterator()
        While tIter.%GetNext(.key,.value) {
            If $ZConvert(value,"L")="true" Set value = 1
            If $ZConvert(value,"L")="false" Set value = 0
            If $Extract(key,1,1)="_" {
                Do pParams.%Set($Extract(key,2,*),value)
            } Else {
                Do pRequestParams.%Set(key,value)
            }
        }
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
    Quit tSC
}

ClassMethod TreatMsgResponse(pRequest As apiPub.service.message, ByRef pResponse As apiPub.service.message, pParams As %Library.DynamicObject) As %Status
{
    Set tSC = $$$OK 
    Try {
        If '$Data(pParams) Set pParams={}
        Set pDefaultForEmptyContentType = $Select(pParams.defaultForEmptyContentType'="":pParams.defaultForEmptyContentType,1:"")
        Set pBeautifyJsonBodyResponse = $Select(pParams.beautifyJsonBodyResponse'="":pParams.beautifyJsonBodyResponse,1:0)
		If pResponse.ResponseReasonPhrase="" {
        	Set pResponse.ResponseReasonPhrase = ..GetResponseReasonPhrase(pResponse.ResponseStatusCode)
        }
        Set tFormatter = ##class(%JSON.Formatter).%New()
        If pResponse.ContentType="" Set pResponse.ContentType = pDefaultForEmptyContentType
        If $IsObject(pResponse.Body),pResponse.Body.SizeGet()>0{
            If (pBeautifyJsonBodyResponse),pResponse.ContentType'="",$Find($ZConvert(pResponse.ContentType,"L"),"json")>0,$Find(pResponse.Body.Read(),"{")>0 {
                Set pBodyResponse = ##class(%DynamicObject).%FromJSON(pResponse.Body)
                Set tSC = tFormatter.FormatToStream(pBodyResponse,pResponse.Body)
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            }
        }
        If $Data(pRequest),pRequest'="" {
            Set pResponse.APIPath = pRequest.APIPath
            Set pResponse.HttpVerb = pRequest.HttpVerb
            Set pResponse.CallerInfo = pRequest.CallerInfo
            Set pResponse.APIOperationId = pRequest.APIOperationId
            Set pResponse.APIDomain = pRequest.APIDomain
        }
	}
    Catch(e) {
		Set tSC = e.AsStatus()
    }
	Quit tSC
}

ClassMethod HttpResponseToMsgResponse(pURL As %String, pHttpRequest As %Net.HttpRequest, pMessageRequest As apiPub.service.message, Output pMessageResponse As apiPub.service.message, Output pBodyResponse As %Library.DynamicObject, Output pHeadersResponse As %Library.DynamicObject) As %Status
{
    Set tSC = $$$OK 
    Try {
        Set pResponse = pHttpRequest.HttpResponse
        Set pMessageResponse = ##class(apiPub.service.message).%New()
        Set pBodyResponse = {}
        Set tFormatter = ##class(%JSON.Formatter).%New()
        If $IsObject(pResponse.Data),pResponse.Data.SizeGet()>0{
			Do pResponse.Data.Rewind()
			While (pResponse.Data.AtEnd=0) {
				Do pMessageResponse.Body.Write(pResponse.Data.Read())
			}
        }
        Set tHeaders = {}
        Set tIdx = pResponse.GetNextHeader("")
        While tIdx'="" {
            Set tValue = pResponse.GetHeader(tIdx)
            If tValue'="" Do tHeaders.%Set(tIdx,tValue)
            Set tIdx = pResponse.GetNextHeader(tIdx)
        }
        If tHeaders.%Size()>0 {
            Set tHeaderStr = ""
            Set tSC = tFormatter.FormatToString(tHeaders.%ToJSON(),.tHeaderStr) 
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            Set pMessageResponse.Headers = tHeaderStr
            Set pHeadersResponse = tHeaders
        }
		Set tParams={}
		Set tIdx = pHttpRequest.NextParam("")
		While tIdx'="" {
            Set tValue = $Get(pHttpRequest.GetParam(tIdx))
            If tValue'="" Do tParams.%Set(tIdx,tValue)
			Set tIdx = pHttpRequest.NextParam(tIdx)
		}
        If tParams.%Size()>0 {
            Set tParamsStr = ""
            Set tSC = tFormatter.FormatToString(tParams.%ToJSON(),.tParamsStr) 
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            Set pMessageResponse.Params = tParamsStr
        }
        Set pMessageResponse.RequestURL = pURL
        Set pMessageResponse.ResponseStatusCode = pResponse.StatusCode
        Set pMessageResponse.ResponseStatusLine = pResponse.StatusLine
        Set pMessageResponse.ResponseReasonPhrase = pResponse.ReasonPhrase
		Set pMessageResponse.ContentType = pResponse.ContentType
        Set pMessageResponse.ContentInfo = pResponse.ContentInfo
        Set pMessageResponse.ContentLength = pResponse.ContentLength
        Set pMessageResponse.ContentBoundary = pResponse.ContentBoundary
   }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
	Quit tSC
}

ClassMethod MsgResponseToHttpResponse(pResponse As apiPub.service.message) As %Status
{
	Set tSC = $$$OK
	Try
	{
		kill %objlasterror
		If pResponse.CharSet'="" Set %response.CharSet = pResponse.CharSet
		Set %response.ContentType = pResponse.ContentType
		Set %response.Status = pResponse.ResponseStatusCode
		If pResponse.Headers'="" {
			Set tJSONHeader = {}.%FromJSON(pResponse.Headers)
			Set tProp = tJSONHeader.%GetIterator()
			While (tProp.%GetNext(.key,.value)) {
		   		Do %response.SetHeader(key,value)
			}
		}
        If $IsObject(pResponse.Body),pResponse.Body.SizeGet()>0{
			Do pResponse.Body.Rewind()
			While (pResponse.Body.AtEnd=0) {
				Write pResponse.Body.Read()
			}
		}
	}
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod ErrorHandler(pStatusException As %Exception.StatusException, Output pSC As %Status)
{
	Set %response.ContentType = ..#CONTENTTYPEJSON
	Set tMessage = $Select($$$ISERR(pStatusException.AsStatus()):$System.Status.GetOneErrorText(pStatusException.AsStatus()),1:"OK")
	Set tErrorCode = +$System.Status.GetErrorCodes(pStatusException.AsStatus())
	If $Find($zConvert(tMessage,"L"),"<400>")>0 {
		Set %response.Status = ..#HTTP400BADREQUEST
	} ElseIf $Find($zConvert(tMessage,"L"),"<405>")>0 {
		Set %response.Status = ..#HTTP405METHODNOTALLOWED
	} Else {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
	}
	Set tErrorTrap={
			"statusCode":($$$ISOK(pStatusException.AsStatus())),
			"message":(tMessage),
			"errorCode":(tErrorCode)
	}
	Write tErrorTrap.%ToJSON()
	Set pSC = $$$OK
}

ClassMethod GetResponseReasonPhrase(statusCode As %Integer) As %String
{
        If statusCode = 200 Quit "OK"
        If statusCode = 201 Quit "Created"
        If statusCode = 202 Quit "Accepted"
        If statusCode = 204 Quit "No Content"
        If statusCode = 304 Quit "Not Modified"
        If statusCode = 400 Quit "Bad Request"
        If statusCode = 401 Quit "Unauthorized"
        If statusCode = 403 Quit "Forbidden"
        If statusCode = 404 Quit "Not Found"
        If statusCode = 405 Quit "Method Not Allowed"
        If statusCode = 406 Quit "Not Acceptable"
        If statusCode = 409 Quit "Conflict"
        If statusCode = 415 Quit "Unsupported Media Type"
        If statusCode = 422 Quit "Unprocessable Entity"
        If statusCode = 423 Quit "Locked"
        If statusCode = 500 Quit "Internal Server Error"
        Quit ""
}

ClassMethod GetRouterMap() As %Library.DynamicObject
{
	Quit {
		"paths":
		{
		}
	}
}

ClassMethod GetPathInfoOld(pHttpVerb As %String, pOrigPath As %String, pAPIMap As %Library.DynamicObject, Output pAPIInfo As %Library.DynamicObject, Output pPath As %String, Output pParamName As %String, Output pValue As %String) As %Status
{
	Set tSC = $$$OK
	Try
	{
		Set pValue = ""
		Set pPath = pOrigPath
		Set pParamName = ""
		Set pHttpVerb = $ZConvert(pHttpVerb,"S")
		Set pAPIOperationId = pHttpVerb_" "_pOrigPath
		Set tPath = pHttpVerb_":"_pOrigPath
		Set tAPIMap = pAPIMap
		Set prop = tAPIMap.%Get("paths").%GetIterator()
		If tAPIMap.%Get("paths").%Get(tPath)'="" {
			Set pAPIInfo = tAPIMap.%Get("paths").%Get(tPath)
			Return tSC
		}
		If tAPIMap.%Get("paths").%Get("*:"_pOrigPath)'="" {
			Set pAPIInfo = tAPIMap.%Get("paths").%Get("*:"_pOrigPath)
			Return tSC
		}
		Set prop = tAPIMap.%Get("paths").%GetIterator()
		While (prop.%GetNext(.key,.value)) {
			Set tPath = pHttpVerb_":"_pOrigPath
			Set tKey = $ZConvert($Piece(key,":",1),"S")_":"_$Piece(key,":",2,*)
			If $Piece(tKey,":",1)="*" Set $Piece(tKey,":",1)=pHttpVerb
			If $Length(tKey,"/")=$Length(tPath,"/"),$Piece(tPath,":/",1) = $Piece(tKey,":/",1),tKey["{" {
				Set tSec = 0
				While $Find(tKey,"{")>0 {
					Set tPieceRef = $Length($Piece(tKey,"{",1),"/")
					Set tVarKey = $Piece(tKey,"/",tPieceRef)
					Set tVarPath = $Piece(tPath,"/",tPieceRef)
					If tVarPath'="?" {
						Set pValue = pValue_$Select(pValue'="":"|"_tVarPath,1:tVarPath)
						Set pParamName = pParamName_$Select(pParamName'="":"|"_tVarKey,1:tVarKey) 
						Set pParamName=$Translate(pParamName,"{}","")
					}
					Set $Piece(tKey,"/",tPieceRef) = "?"
					Set $Piece(tPath,"/",tPieceRef) = "?"
                    If tPath=tKey {
						Set pPath = "/"_$Piece(key,":/",2)
						Set pAPIInfo = value
						Return tSC
					}
				}
				Set (pValue,pParamName) = ""
			}
		}
		Set tSC = $$$ERROR($$$GeneralError, "API Not Mapped "_pHttpVerb_":"_pOrigPath)
	}
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod GetPathInfo(pHttpVerb As %String, pOrigPath As %String, pAPIMap As %Library.DynamicObject, Output pAPIInfo As %Library.DynamicObject) As %Status
{
	Set tSC = $$$OK
	Try
	{
		If '$Data(pAPIMap) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "url map not informed"))
		If pAPIMap.%Get("paths")="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "url map not informed"))
		Set tSC = ..GetIdxPath(pAPIMap,.idxmap)
		If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		Set pHttpVerb = $ZConvert(pHttpVerb,"S")
		Set tPath = pHttpVerb_":"_pOrigPath
		Set tPoint = idxmap
		Set tParams = {}
		For i=1:1:$Length(tPath,"/") {
			Set tParValue = ""
			Set tPc = $Replace($Piece(tPath,"/",i),":","")
			If i=1 Set tPc = $ZConvert(tPc,"S")
			Set tF = tPoint.%Get(tPc)
			If tF="" {
				Set tF = tPoint.%Get("@P")
				If tF="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "path "_tPath_" not mapped"))
				Do tParams.%Set(tPoint.%Get("@parName"),tPc)
			}
			Set tPoint=tF
		}
		Set pAPIInfo = {}
		If '$IsObject(tPoint) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "path "_tPath_" not mapped"))
		Set prop = tPoint.%GetIterator()
		While (prop.%GetNext(.key,.value)) {
			If '$IsObject(value),key'="@parName" {
				Do pAPIInfo.%Set($Tr(key,"@",""),value)			
			}
		}
		Do pAPIInfo.%Set("urlParams",tParams)	
	}
	Catch(e)
	{
		w $System.Status.GetOneErrorText(e.AsStatus()),!
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod GetIdxPath(pAPIMap As %Library.DynamicObject, Output pIndexedMap As %Library.DynamicObject) As %Status
{
	Set tSC = $$$OK
	Try
	{
		Set pIndexedMap = {}
		Set prop = pAPIMap.%Get("paths").%GetIterator()
		While (prop.%GetNext(.key,.value)) {
			Set tKey = ""
			For i=1:1:$Length(key,"/") {
				Set tParName = ""
				Set tPc = $Replace($Piece(key,"/",i),":","")
				If i=1 Set tPc = $ZConvert(tPc,"S")
				If $Find(tPc,"{")>0,$Find(tPc,"}")>0 {
					Set tParName = $Replace($Replace(tPc,"{",""),"}","")
					If tParName'="" Do ..SetByLineKey(pIndexedMap,tKey_"^@parName",tParName,,"^")
					Set tPc = "@P"
				}
				Set tKey = tKey_$Select(i=1:"",1:"^")_tPc
			}
			If $IsObject(value) {
				Do ..SetByLineKey(pIndexedMap,tKey,value,,"^")
			} Else {
				Do ..SetByLineKey(pIndexedMap,tKey,{"@operationId":(value)},,"^")
			}
			Do ..SetByLineKey(pIndexedMap,tKey_"^@path",key,,"^")
			If tParName'="" Do ..SetByLineKey(pIndexedMap,tKey_"^@parName",tParName,,"^")
		}
	}
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod HttpRequestToMsgRequest(pRequest As %CSP.Request, pParams As %Library.DynamicObject, Output pRestRequest As apiPub.service.message, pURLPaths...) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pAPIDomain = $Select(pParams.apiDomain'="":pParams.apiDomain,1:"")
        Set pTargetBaseURL = $Select(pParams.targetBaseURL'="":pParams.targetBaseURL,1:"")
        Set pCallerInfo = $Select(pParams.callerInfo'="":pParams.callerInfo,1:"")
        Set pBeautifyJsonBodyRequest = $Select(pParams.beautifyJsonBodyRequest'="":pParams.beautifyJsonBodyRequest,1:0)
        Set pReservedInboundParams = $Select(pParams.reservedInboundParams'="":pParams.reservedInboundParams,1:"")
		If pAPIDomain = "" {
			Set tSC = $$$ERROR($$$GeneralError, "param apiDomain is Required")
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		}
		#Dim pRequest As %CSP.Request
		Set pRestRequest = ##Class(apiPub.service.message).%New()
		Set tFormatter = ##class(%JSON.Formatter).%New()
		Set tParams={}
		Set tIdx = pRequest.Next("")
		While tIdx'="" {
            Set tValue = $Get(pRequest.Data(tIdx,1))
            If tValue'="" Do tParams.%Set(tIdx,tValue)
			Set tIdx = pRequest.Next(tIdx)
		}
		Set tHeaders = {}
		Set tIdx = pRequest.NextCgiEnv("")
		While tIdx'="" {
            Set tValue = pRequest.CgiEnvs(tIdx)
            If tValue'="" Do tHeaders.%Set(tIdx,tValue)
			Set tIdx = pRequest.NextCgiEnv(tIdx)
		}
		If tHeaders.%Size()>0 {
			Set tStrHeaders = ""
			Set tSC = tFormatter.FormatToString(tHeaders.%ToJSON(),.tStrHeaders) 
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			Set pRestRequest.Headers = tStrHeaders
		}
		Set tCookies = {}
		Set tIdx = pRequest.NextCookie("")
		While tIdx'="" {
            Set tValue = pRequest.GetCookie(tIdx)
            If tValue'="" Do tCookies.%Set(tIdx,tValue)
			Set tIdx = pRequest.NextCookie(tIdx)
		}
		If tCookies.%Size()>0 {
			Set tStrCookies=""
			Set tSC = tFormatter.FormatToString(tCookies.%ToJSON(),.tStrCookies) 
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			Set pRestRequest.Cookies = tStrCookies 
		}
		Set tMimeData = {}
		Set tIdx = pRequest.NextMimeData("")
		While tIdx'="" {
            Set tValue = pRequest.GetMimeData(tIdx)
			If $Find($ClassName(tValue),"Stream")>0 {
				Do tValue.Rewind()
				Do tMimeData.%Set(tIdx,tValue.Read())
			} Else {
            	If tValue'="" Do tMimeData.%Set(tIdx,tValue)
			}
			Set tIdx = pRequest.NextMimeData(tIdx)
		}
		If tMimeData.%Size()>0 {
			Set tStrMimeData = ""
			Set tSC = tFormatter.FormatToString(tMimeData.%ToJSON(),.tStrMimeData) 
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			Set pRestRequest.MimeData = tStrMimeData
		}
		Set pRestRequest.HttpVerb = $ZConvert(tHeaders."REQUEST_METHOD","S")
		Set pRestRequest.ContentType = tHeaders."CONTENT_TYPE"
		Set pRestRequest.RequestURL = tHeaders."REQUEST_SCHEME"_"://"_tHeaders."HTTP_HOST"_tHeaders."REQUEST_URI"
		If $IsObject(pRequest.Content),pRequest.Content.SizeGet()>0{
			If (pBeautifyJsonBodyRequest),$Find($ZConvert(pRestRequest.ContentType,"L"),"json") {
				Set tSC = tFormatter.FormatToStream(pRequest.Content,pRestRequest.Body) 
				If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			} Else {
				Do pRequest.Content.Rewind()
				While (pRequest.Content.AtEnd=0) {
					Do pRestRequest.Body.Write(pRequest.Content.Read())
				}
			}
		}
		Set pRestRequest.APIDomain = pAPIDomain
		If pCallerInfo '= "" Set pRestRequest.CallerInfo = pCallerInfo
		If tHeaders."HTTP_USER_AGENT"'="" Set pRestRequest.CallerInfo = pRestRequest.CallerInfo_$Select(pCallerInfo'="":" (",1:"")_tHeaders."HTTP_USER_AGENT"_$Select(pCallerInfo'="":")",1:"")
		Set tOriginalPath = ""
		If $Data(pURLPaths) {
			For i=1:1:pURLPaths {
				Set tOriginalPath=tOriginalPath_"/"_pURLPaths(i)
			}
		}
		Set tAPIMap={}
		If ..#DispatchClass'="" {
			Set tSC = ##class(apiPub.core.irisMetadata).GetCacheCustomPaths(..#DispatchClass,.tAPIMap)
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		}
		If ..#OASPath'="",..#DispatchClass'="" Do tAPIMap.%Get("paths").%Set(..#OASPath,{"operationId":"GetOAS","className":(..#DispatchClass)})
		Set tLocalAPIMap = ..GetRouterMap()
		Set tM = tLocalAPIMap.%Get("paths").%GetIterator()
		While tM.%GetNext(.mkey,.mvalue) {
			Do tAPIMap.%Get("paths").%Set(mkey,mvalue)
		}
		If tAPIMap.%Get("paths")="" Do tAPIMap.%Set("paths",{})
		Set tSC = ..GetPathInfo(pRestRequest.HttpVerb,tOriginalPath,tAPIMap,.tAPIInfo)
       	If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		If $IsObject(tAPIInfo) {
			If tAPIInfo.%Get("className")'="" Set pRestRequest.DispatchClass = tAPIInfo.%Get("className")
			If tAPIInfo.%Get("methodName")'="" Set pRestRequest.DispatchMethod = tAPIInfo.%Get("methodName")
			If tAPIInfo.%Get("urlParams").%Get("className")'="" Set pRestRequest.DispatchClass = tAPIInfo.%Get("urlParams").%Get("className")
			If tAPIInfo.%Get("urlParams").%Get("methodName")'="" Set pRestRequest.DispatchMethod = tAPIInfo.%Get("urlParams").%Get("methodName")
			Set pRestRequest.APIOperationId = tAPIInfo.%Get("operationId")
			Set pRestRequest.APIPath = tAPIInfo.%Get("path")
		}
		Set tURLParams = tAPIInfo.%Get("urlParams").%GetIterator()
		While tURLParams.%GetNext(.ukey,.uvalue) {
			Do tParams.%Set(ukey,uvalue)
		}
		If pTargetBaseURL'="" Set pRestRequest.TargetBaseURL = pTargetBaseURL 
		For i=1:1:$Length(pReservedInboundParams,",") {
			Set tParName = $Piece(pReservedInboundParams,",",i)
			If tParName'="",tParams.%Get(tParName)'="" Do tParams.%Remove(tParName)
		}
		If tParams.%Size()>0 {
			Set tStrParams = ""
			Set tSC = tFormatter.FormatToString(tParams.%ToJSON(),.tStrParams) 
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			Set pRestRequest.Params = tStrParams
		}
	}
	Catch(e)
	{
        Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod MsgRequestToHttpRequest(pMessageRequest As apiPub.service.message, pParams As %Library.DynamicObject, Output pHttpRequest As %Net.HttpRequest, Output tURL As %String, pGetToken As %Boolean = 0) As %Status
{
    Set tSC = $$$OK 
    Try {
        If '$Data(pParams) Set pParams={}
        Set pTargetBaseURL = $Select(pParams.targetBaseURL'="":pParams.targetBaseURL,1:"")
        Set pHTTPS = $Select(pParams.https'="":pParams.https,1:0)
        Set pSSL = $Select(pParams.ssl'="":pParams.ssl,1:"")
        Set pReservedOutboundParams = $Select(pParams.reservedOutboundParams'="":pParams.reservedOutboundParams,1:"")

        Set tURL = ""
        Set pHttpRequest = ##class(%Net.HttpRequest).%New()
        Set pHttpRequest.Server = pTargetBaseURL
        Set pHttpRequest.Https = pHTTPS
        Set pHttpRequest.SSLConfiguration = pSSL
        Set tJSONHeaders = {}.%FromJSON(pMessageRequest.Headers)
        Set tProp = tJSONHeaders.%GetIterator()
        While (tProp.%GetNext(.key,.value)) {
            Do pHttpRequest.SetHeader(key,value)
        }
        Set tAPIPath = pMessageRequest.APIPath
		Set tJSONParams = {}
        If $Length(pMessageRequest.Params)>0 Set tJSONParams = {}.%FromJSON(pMessageRequest.Params)
        Set tProp = tJSONParams.%GetIterator()
        While (tProp.%GetNext(.key,.value)) {
            If $Find(pReservedOutboundParams,key)=0 {
                If $Find(tAPIPath,"{"_key_"}")>0 {
                    Set tAPIPath = $Replace(tAPIPath,"{"_key_"}",value)
                } Else {
                    Do pHttpRequest.SetParam(key,value)
                }
            }
        }
        Do pHttpRequest.EntityBody.Write(pMessageRequest.Body.Read())
        Set tTargetBaseURL = pMessageRequest.TargetBaseURL
        If tTargetBaseURL="" Set tTargetBaseURL = pTargetBaseURL
        Set tURL = $Select($Extract(tTargetBaseURL,*)="/":$Extract(tTargetBaseURL,1,*-1),1:tTargetBaseURL)_tAPIPath
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
	Quit tSC
}

ClassMethod CallBS(pBSName As %String = "apiPub.tracer.bs", pRequest As apiPub.service.message, Output pOutput As apiPub.service.message) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set tSC = ##Class(Ens.Director).CreateBusinessService(pBSName,.tBS)
		If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		Set tSC = tBS.ProcessInput(pRequest,.tResponse)
		If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		Set pOutput = tResponse
	}
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/" Method="GET" Call="HttpCall"/>
<Route Url="/:path" Method="GET" Call="HttpCall"/>
<Route Url="/:path/:path" Method="GET" Call="HttpCall"/>
<Route Url="/:path/:path/:path" Method="GET" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path" Method="GET" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path" Method="GET" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path" Method="GET" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path" Method="GET" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path" Method="GET" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/:path" Method="GET" Call="HttpCall"/>
<Route Url="/" Method="POST" Call="HttpCall"/>
<Route Url="/:path" Method="POST" Call="HttpCall"/>
<Route Url="/:path/:path" Method="POST" Call="HttpCall"/>
<Route Url="/:path/:path/:path" Method="POST" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path" Method="POST" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path" Method="POST" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path" Method="POST" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path" Method="POST" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path" Method="POST" Call="HttpCall"/>
<Route Url="/" Method="PUT" Call="HttpCall"/>
<Route Url="/:path" Method="PUT" Call="HttpCall"/>
<Route Url="/:path/:path" Method="PUT" Call="HttpCall"/>
<Route Url="/:path/:path/:path" Method="PUT" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path" Method="PUT" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path" Method="PUT" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path" Method="PUT" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path" Method="PUT" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path" Method="PUT" Call="HttpCall"/>
<Route Url="/" Method="DELETE" Call="HttpCall"/>
<Route Url="/:path" Method="DELETE" Call="HttpCall"/>
<Route Url="/:path/:path" Method="DELETE" Call="HttpCall"/>
<Route Url="/:path/:path/:path" Method="DELETE" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path" Method="DELETE" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path" Method="DELETE" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path" Method="DELETE" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path" Method="DELETE" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path" Method="DELETE" Call="HttpCall"/>
<Route Url="/" Method="PATCH" Call="HttpCall"/>
<Route Url="/:path" Method="PATCH" Call="HttpCall"/>
<Route Url="/:path/:path" Method="PATCH" Call="HttpCall"/>
<Route Url="/:path/:path/:path" Method="PATCH" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path" Method="PATCH" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path" Method="PATCH" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path" Method="PATCH" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path" Method="PATCH" Call="HttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path" Method="PATCH" Call="HttpCall"/>
</Routes>
}

}

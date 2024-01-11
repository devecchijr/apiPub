Class apiPub.core.service Extends (%CSP.REST, %Projection.AbstractProjection, apiPub.core.jsonBuilder)
{

Parameter CONTENTTYPEJSON = "application/json";

Parameter HandleCorsRequest = 1;

Parameter Cors = 1;

Parameter ReservedInboundParams = "CachePassWord,CacheUserName,IRISUsername,IRISPassword,";

Parameter ReservedOutboundParams = "CachePassWord,CacheUserName,IRISUsername,IRISPassword,TargetBaseURL";

Parameter DefaultForEmptyContentType;

Parameter BeautifyJsonBodyResponse = 1;

Parameter BeautifyJsonBodyRequest = 1;

Parameter DispatchClass;

Parameter DispatchBaseURL;

/// If OASNestedMode=1 publisher avoid name conflict for OAS Schemas (Complex Requests and Responses)
Parameter OASNestedMode = 0;

Parameter OASPath = "Get:/oas";

/// Allow API Calling
Parameter OnlyOAS = 0;

/// Use TracerBSName for monitoring
Parameter Traceable = 1;

Parameter TracerBSName = "apiPub.tracer.bs";

/// When the class is also a Business Service 
Parameter DispatchBSName;

Parameter SSL = "DEFAULT";

Parameter HTTPS = 0;

Parameter CallerInfo = "Rest Client";

Parameter TargetBaseURL;

Parameter APIDomain = "apiPub";

/// 1 for basic or 2 for bearer token
Parameter AuthMethod = 1;

/// If AuthMethod = 2, default (validateAuthorization) method validates using this Oauth Client Id
/// You can overload this method also
Parameter OAuthClient;

/// Show bearer token if traceable = 1 and AuthMethod = 2
Parameter DecodeBearerToken = 0;

/// Middleware Request Handler
ClassMethod RequestHandler(pRequest As apiPub.service.message, pStatus As %Status) As %Status
{
	Quit pStatus
}

/// Middleware Response Handler
ClassMethod ResponseHandler(pRequest As apiPub.service.message, pResponse As apiPub.service.message, pStatus As %Status, pError As %DynamicObject) As %Status
{
	Quit pStatus
}

ClassMethod ServiceRouter(pRequest As apiPub.service.message, Output pResponse As apiPub.service.message) As %Status
{
    Set tSC = $$$OK 
    Try {
        If pRequest.APIOperationId="getOAS",pRequest.DispatchClass'="" Return ..GetOAS(pRequest,.pResponse)
		If pRequest.DispatchClass'="",pRequest.DispatchMethod'="" {
			//bearer token validation
			If ..#AuthMethod=2,pRequest.ProtectedRoute=1 {
				Set tSC = ..validateAuthorization(pRequest)
			}
			Set tSC = ..RequestHandler(pRequest, tSC)
			If 'tSC Return tSC
			Set tSC =..Dispatch(pRequest,.pResponse)
			If 'tSC Return tSC
			Set tSC = ..ResponseHandler(pRequest, pResponse, tSC)
			Return tSC
		}
		Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "path not found"))
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
    Quit tSC
}

ClassMethod Dispatch(pRequest As apiPub.service.message, Output pResponse As apiPub.service.message) As %Status
{
    Set tSC = $$$OK 
    Try {
		If (..#OnlyOAS) {
			Set tSC = $$$ERROR($$$GeneralError, "Only Documentation (OAS)")
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
		}
		Set tSC = ##class(apiPub.core.dispatcher).Dispatch(pRequest,.pResponse)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
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
        Set tSC = ..GetRequestParams(pRequest.Params,.tBusParams,.tParams)
        Set tBasePath = tBusParams.%Get("basePath")
        Set tParams.basePath = tBasePath
        Set tParams.printResults = 0
		If ..#OASNestedMode=1 Set tParams.nestedMode=1
		If ..#AuthMethod=2 Set tParams.authMethod = "bearer"
		If ..#DispatchBaseURL'="" {
			Set tRequestURL =$Replace(..#DispatchBaseURL,"{namespace}",$namespace)
			If $Find(tRequestURL,"http")=0 Set tRequestURL = $Piece(pRequest.RequestURL,"/",1,3)_$Replace("/"_$Replace(..#DispatchBaseURL,"{namespace}",$namespace),"//","/")
		} Else {
			Set tRequestURL = $Piece(pRequest.RequestURL,$Piece(..#OASPath,":",2),1)
			If tRequestURL="" Set tRequestURL = $Piece(pRequest.RequestURL,"/",1,*-1)
		}
        Set tSC = ##class(apiPub.core.publisher).GetOASFromClass(pRequest.DispatchClass,.tJsonResponse,tParams,tRequestURL)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		Do tJsonResponse.%ToJSON(pResponse.Body)
        Set pResponse.ContentType =  "application/json"
        Set pResponse.ResponseStatusCode = 200
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
    Quit tSC
}

ClassMethod Call(pRequest As apiPub.service.message, Output pResponse As apiPub.service.message, pMethodName As %String = "OnProcessInput") As %Status
{
	Try 
	{
		If ((..#Traceable)||(pRequest.Trace=1)) {
			Set tSC = ..CallBS(..#TracerBSName,pRequest,.pResponse,pMethodName)
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        } Else {
            Set tSC = ..ToHttpCall(pRequest,,.pResponse)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        }
		Set tResponseParams = {
			"defaultForEmptyContentType":(..#DefaultForEmptyContentType)
			,"beautifyJsonBodyResponse":(..#BeautifyJsonBodyResponse)
		}
		Set tSC = ..TreatMsgResponse(pRequest,.pResponse,tResponseParams)
		If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
	}
	Catch(e) {
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod FromHttpCall(pURLPaths...) As %Status
{
	Set (tRequest,tResponse)=""
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
		If ((..#Traceable)||(tRequest.Trace=1)) {
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
		Do ..ErrorHandler(tRequest, tResponse, e, .tSC, .tError)
		If $IsObject(tRequest),$IsObject(tResponse) Set tSC = ..ResponseHandler(tRequest, tResponse, tSC, tError)
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

ClassMethod ToHttpCall(pRequest As apiPub.service.message, pRequestParams As %Library.DynamicObject, Output pResponse As apiPub.service.message, pTimeout As %Integer) As %Status
{
    Set tSC = $$$OK 
    Try {
		If '$Data(pRequestParams) {
			Set pRequestParams = {
				"targetBaseURL":(..#TargetBaseURL)
				,"https":(..#HTTPS)
				,"ssl":(..#SSL)
				,"reservedOutboundParams":(..#ReservedOutboundParams)
			}
		}
        Set tSC = ..MsgRequestToHttpRequest(pRequest,pRequestParams,.tHttpRequest,.tURL)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		If $Data(pTimeout) Set tHttpRequest.Timeout = pTimeout
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
        If pResponse.ContentType="" Set pResponse.ContentType = pDefaultForEmptyContentType
        If ((..#Traceable)||pRequest.Trace=1),$IsObject(pResponse.Body),pResponse.Body.SizeGet()>0{
			If ($IsObject(##class(%Dictionary.ClassDefinition).%OpenId("%JSON.Formatter"))),(pBeautifyJsonBodyResponse),$Find($ZConvert(pResponse.ContentType,"L"),"json")>0 {
        		Set tFormatter = ##class(%JSON.Formatter).%New()
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
			If ((..#Traceable)||pMessageRequest.Trace=1),($IsObject(##class(%Dictionary.ClassDefinition).%OpenId("%JSON.Formatter"))) {
        		Set tFormatter = ##class(%JSON.Formatter).%New()
				Set tSC = tFormatter.FormatToString(tHeaders.%ToJSON(),.tHeaderStr) 
				If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			} Else {
				Set tHeaderStr = tHeaders.%ToJSON()			
			}
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
			If ((..#Traceable)||pMessageRequest.Trace=1),($IsObject(##class(%Dictionary.ClassDefinition).%OpenId("%JSON.Formatter"))) {
        		Set tFormatter = ##class(%JSON.Formatter).%New()
				Set tSC = tFormatter.FormatToString(tParams.%ToJSON(),.tParamsStr) 
				If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
				Set pMessageResponse.Params = tParamsStr
			} Else {
				Set pMessageResponse.Params = tParams.%ToJSON()			
			}
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

/// overload this method to validade the bearer token (ex: Oath 2.0)
/// validade all apis with a bearer token (ApiPub) if protected param not 0
ClassMethod validateAuthorization(pRequest As apiPub.service.message) As apiPub.service.message
{
	Set tBearer = $Piece(pRequest.GetHeaders("HTTP_AUTHORIZATION")," ",2,*)
	If ..#OAuthClient'="",'(##class(%SYS.OAuth2.Validation).ValidateJWT(..#OAuthClient, tBearer, "", "", .tJsonObj,.tSecurityParams, .tValidateStatus)) {
        Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"<401> invalid Auth token"))
    }
    Quit pRequest
}

/// allow overload
ClassMethod ErrorHandler(pRequest As apiPub.service.message, pResponse As apiPub.service.message, pStatusException As %Exception.StatusException, Output pSC As %Status, Output pError As %DynamicObject)
{
	Set %response.ContentType = ..#CONTENTTYPEJSON
	Set tMessage = $Select($$$ISERR(pStatusException.AsStatus()):$System.Status.GetOneErrorText(pStatusException.AsStatus()),1:"OK")
	Set tErrorC = 500
	Set tErrorCode = +$System.Status.GetErrorCodes(pStatusException.AsStatus())
	If $Find("6237 6251 6254 6255",tErrorCode) > 0 {
		Set tMessage = $Replace(tMessage,"XML","JSON")
	}
	If tErrorCode>=6200,tErrorCode<=6400 {
		Set tErrorC=400
	}
	Set tErrorL = $Locate(tMessage,"<[0-9]{3}>")
	If tErrorL>0 {
		Set tErrorC = $Extract(tMessage,tErrorL+1,tErrorL+3)
		Set tMessage = $Replace(tMessage,"<"_tErrorC_">","")
	}
	If $Find(tMessage,":")>0 Set tMessage = $Piece(tMessage,":",2,*)
	While $Find(tMessage,"  ")>0 {
		Set tMessage = $Replace(tMessage,"  "," ")
	}
	If $Extract(tMessage,1,1)=" " Set tMessage = $Extract(tMessage,2,*)
	Set pError={
			"statusCode":($$$ISOK(pStatusException.AsStatus())),
			"message":(tMessage),
			"errorCode":(tErrorCode)
	}
	Set %response.Status = tErrorC_" "_$E(tMessage,1,46)
	Do %response.SetHeader("iris-statuscode",$$$ISOK(pStatusException.AsStatus()))
	Do %response.SetHeader("iris-statusmessage",tMessage)
	Do %response.SetHeader("iris-errorcode",tErrorCode)
	Write pError.%ToJSON()
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
		"paths":{
		}
	}
}

ClassMethod GetPathInfo(pHttpVerb As %String, pOrigPath As %String, pIdxMap As %Library.DynamicObject, Output pAPIInfo As %Library.DynamicObject) As %Status
{
	Set tSC = $$$OK
	Try
	{
		Set pHttpVerb = $ZConvert(pHttpVerb,"S")
		Set tPath = pHttpVerb_":"_pOrigPath
		Set tPoint = pIdxMap
		Set tParams = {}
		Set tFSlash=0
		For i=1:1:$Length(tPath,"/") {
			Set tParValue = ""
			Set tPc = $Replace($Piece(tPath,"/",i),":","")
			If i=1 Set tPc = $ZConvert(tPc,"S")
			Set tF = tPoint.%Get(tPc)
			If tF="" {
				Set tF = tPoint.%Get("@P")
				If tF="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "path "_tPath_" not found"))
				Do tParams.%Set(tPoint.%Get("@parName"),tPc)
			}
			Set tPoint=tF
		}
		Set pAPIInfo = {}
		If '$IsObject(tPoint) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "path "_tPath_" not found"))
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
		Set pRestRequest = ##Class(apiPub.service.message).%New()
		Set tParams={}
		//Deprecated Set tIdx = pRequest.Next("")
		Set tIdx=$Order(pRequest.Data(""))		
		While tIdx'="" {
            Set tValue = $Get(pRequest.Data(tIdx,1))
            If tValue'="" Do tParams.%Set(tIdx,$Select((..#CHARSET'="")&&($ZCVT(..#CHARSET,"U")'="UTF-8"):tValue, 1:$ZCVT(tValue,"O","UTF8")))
			//Deprecated Set tIdx = pRequest.Next(tIdx)
			Set tIdx=$Order(pRequest.Data(tIdx))		
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
			If ((..#Traceable)||pRestRequest.Trace=1),($IsObject(##class(%Dictionary.ClassDefinition).%OpenId("%JSON.Formatter"))) {
        		Set tFormatter = ##class(%JSON.Formatter).%New()
				Set tSC = tFormatter.FormatToString(tHeaders.%ToJSON(),.tStrHeaders) 
				If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			} Else {
				Set tStrHeaders = tHeaders.%ToJSON()
			}
			Set pRestRequest.Headers = tStrHeaders
			If ..#DecodeBearerToken=1,((..#Traceable)||pRestRequest.Trace=1),..#AuthMethod=2,$zConvert($Piece(pRestRequest.GetHeaders("HTTP_AUTHORIZATION")," ",1),"L")="bearer" {
    			Set token = $Piece(pRestRequest.GetHeaders("HTTP_AUTHORIZATION")," ",2,*)
				Try {
					Set b64header = $Piece(token,".",1)
					Set tAuthHeader = {}.%FromJSON($$$BASE64URLDECODE(b64header))
					Set b64body = $Piece(token,".",2)
					Set tAuthPayload = {}.%FromJSON($$$BASE64URLDECODE(b64body))
					If ($IsObject(##class(%Dictionary.ClassDefinition).%OpenId("%JSON.Formatter"))) {
						Set tFormatter = ##class(%JSON.Formatter).%New()
						Do tFormatter.FormatToString(tAuthHeader.%ToJSON(),.tStrAuthHeader) 
						Do tFormatter.FormatToString(tAuthPayload.%ToJSON(),.tStrAuthPayload) 
					} Else {
						Set tStrAuthHeader = tAuthHeader.%ToJSON()
						Set tStrAuthPayload = tAuthPayload.%ToJSON()
					}
					Set pRestRequest.AuthHeader=tStrAuthHeader
					Set pRestRequest.AuthBody=tStrAuthPayload
				}
				Catch nex {
				}
			}
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
			If ((..#Traceable)||pRestRequest.Trace=1),($IsObject(##class(%Dictionary.ClassDefinition).%OpenId("%JSON.Formatter"))) {
        		Set tFormatter = ##class(%JSON.Formatter).%New()
				Set tSC = tFormatter.FormatToString(tCookies.%ToJSON(),.tStrCookies) 
				If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			} Else {
				Set tStrCookies = tCookies.%ToJSON()
			}
			Set pRestRequest.Cookies = tStrCookies 
		}
		Set tIdx = pRequest.NextMimeData("")
		While tIdx'="" {
			Set tStream = $Classmethod("%Stream.GlobalBinary","%New")
			Do tStream.CopyFrom(pRequest.GetMimeData(tIdx))
			Do pRestRequest.SetMimeData(tIdx, tStream)
			Set tIdx = pRequest.NextMimeData(tIdx)
		}
		Set pRestRequest.ServiceClass = $This
		Set pRestRequest.HttpVerb = $ZConvert(tHeaders."REQUEST_METHOD","S")
		Set pRestRequest.ContentType = tHeaders."CONTENT_TYPE"
		Set pRestRequest.RequestURL = tHeaders."REQUEST_SCHEME"_"://"_tHeaders."HTTP_HOST"_tHeaders."REQUEST_URI"
		Set pRestRequest.CharSet = ..#CHARSET
		If $IsObject(pRequest.Content),pRequest.Content.SizeGet()>0{
			If ((..#Traceable)||pRestRequest.Trace=1),($IsObject(##class(%Dictionary.ClassDefinition).%OpenId("%JSON.Formatter"))),(pBeautifyJsonBodyRequest),$Find($ZConvert(pRestRequest.ContentType,"L"),"json") {
				Set tSC = tFormatter.FormatToStream(pRequest.Content,pRestRequest.Body) 
				If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			} Else {
				Do pRestRequest.Body.CopyFrom(pRequest.Content)
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
		//Get Indexed route map from dispatch class
		Set tIdxMap={}
		If ..#DispatchClass'="" {
			If '$IsObject(##class(%Dictionary.ClassDefinition).%OpenId(..#DispatchClass)) {
				Set tSC = $$$ERROR($$$GeneralError, ..#DispatchClass_" is not a valid class")
				If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			}
			Set tSC = ##class(apiPub.core.irisMetadata).GetCachedCustomPaths(..#DispatchClass,.tIdxMap)
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		}
		//Add Documentation Path
		If ..#OASPath'="",..#DispatchClass'="" {
			Set tOASAPIMap = {"paths":{}}
			Do tOASAPIMap.%Get("paths").%Set(..#OASPath,{"operationId":"getOAS","className":(..#DispatchClass)})
			Set tSC = ..GetIdxPath(tOASAPIMap,.tOASIdxMap)
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			Set tSC = ..JSONAppend(tOASIdxMap,.tIdxMap)
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		}
		//Add Local Path Route
		Set tLocalAPIMap = ..GetRouterMap()
		If tLocalAPIMap.%Get("paths").%Size()>0 {
			Set tSC = ..GetIdxPath(tLocalAPIMap,.tLocalIdxMap)
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			Set tSC = ..JSONAppend(tLocalIdxMap,.tIdxMap)
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		}
		Set tSC = ..GetPathInfo(pRestRequest.HttpVerb,tOriginalPath,tIdxMap,.tAPIInfo)
       	If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
		If $IsObject(tAPIInfo) {
			If tAPIInfo.%Get("className")'="" Set pRestRequest.DispatchClass = tAPIInfo.%Get("className")
			If tAPIInfo.%Get("methodName")'="" Set pRestRequest.DispatchMethod = tAPIInfo.%Get("methodName")
			If tAPIInfo.%Get("urlParams").%Get("className")'="" Set pRestRequest.DispatchClass = tAPIInfo.%Get("urlParams").%Get("className")
			If tAPIInfo.%Get("urlParams").%Get("methodName")'="" Set pRestRequest.DispatchMethod = tAPIInfo.%Get("urlParams").%Get("methodName")
			Set pRestRequest.APIOperationId = tAPIInfo.%Get("operationId")
			Set pRestRequest.ProtectedRoute = tAPIInfo.%Get("protected")
			Set pRestRequest.Trace = tAPIInfo.%Get("trace")
			If pRestRequest.APIOperationId="" Set pRestRequest.APIOperationId = pRestRequest.DispatchMethod
			If pRestRequest.DispatchClass="" Set pRestRequest.DispatchClass = ..#DispatchClass
			Set pRestRequest.APIPath = tAPIInfo.%Get("path")
		}
		Set tURLParams = tAPIInfo.%Get("urlParams").%GetIterator()
		While tURLParams.%GetNext(.ukey,.uvalue) {
			Do tParams.%Set(ukey,$ZCONVERT(uvalue,"O","UTF8"))
		}
		If pTargetBaseURL'="" Set pRestRequest.TargetBaseURL = pTargetBaseURL 
		For i=1:1:$Length(pReservedInboundParams,",") {
			Set tParName = $Piece(pReservedInboundParams,",",i)
			If tParName'="",tParams.%Get(tParName)'="" Do tParams.%Remove(tParName)
		}
		If tParams.%Size()>0 {
			Set tStrParams = ""
			If ((..#Traceable)||pRestRequest.Trace=1),($IsObject(##class(%Dictionary.ClassDefinition).%OpenId("%JSON.Formatter"))) {
				Set tSC = tFormatter.FormatToString(tParams.%ToJSON(),.tStrParams) 
				If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			} Else {
				Set tStrParams = tParams.%ToJSON()
			}
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
        Set pHeaders = $Select(pParams.headers'="":pParams.headers,1:"")
        Set tURL = ""
        Set pHttpRequest = ##class(%Net.HttpRequest).%New()
        Set pHttpRequest.Https = pHTTPS
        Set pHttpRequest.SSLConfiguration = pSSL
		Set tJSONHeaders = {}
        If $Length(pMessageRequest.Headers)>0 Set tJSONHeaders = {}.%FromJSON(pMessageRequest.Headers)
		If pMessageRequest.ContentType'="" {
            Do ..s(tJSONHeaders,"Content-Type",pMessageRequest.ContentType)
		}
        Set tProp = tJSONHeaders.%GetIterator()
        While (tProp.%GetNext(.key,.value)) {
            Do pHttpRequest.SetHeader(key,$Select($IsObject(value):value.%ToJSON(),1:value))
        }
		For i=1:1:$Length(pHeaders,",") {
			Set hKey = $Piece($Piece(pHeaders,",",i),":",1)
			Set hValue = $Piece($Piece(pHeaders,",",i),":",2)
			If hKey'="",hValue'="" Do pHttpRequest.SetHeader(hKey,hValue)
		}
		If $Find("get:put:post:patch:delete:",$Piece($ZCONVERT(pMessageRequest.APIPath,"L"),":",1))>0 {
			Set pMessageRequest.APIPath = $Piece(pMessageRequest.APIPath,":",2,*)
		}
        Set tAPIPath = pMessageRequest.APIPath
		Set tJSONParams = {}
        If $Length(pMessageRequest.Params)>0 Set tJSONParams = {}.%FromJSON(pMessageRequest.Params)
        Set tProp = tJSONParams.%GetIterator()
        While (tProp.%GetNext(.key,.value)) {
            If $Find(pReservedOutboundParams,key)=0 {
                If $Find(tAPIPath,"{"_key_"}")>0 {
                    Set tAPIPath = $Replace(tAPIPath,"{"_key_"}",$ZCONVERT($ZCONVERT(value,"O","UTF8"),"O","URL"))
                } Else {
					If $Find($ZCONVERT(pMessageRequest.ContentType,"L"),"form-urlencoded")=0 {
                    	Do pHttpRequest.SetParam(key,$Select($IsObject(value):value.%ToJSON(),1:value))
					} Else {
						Do pHttpRequest.InsertFormData(key,$Select($IsObject(value):value.%ToJSON(),1:value))
					}
                }
            }
        }
		Do pMessageRequest.Body.Rewind()
		While (pMessageRequest.Body.AtEnd=0) {
			Do pHttpRequest.EntityBody.Write(pMessageRequest.Body.Read())
		}
		If pTargetBaseURL="" Set pTargetBaseURL = pMessageRequest.TargetBaseURL
        Set pHttpRequest.Server = $Select($Find(pTargetBaseURL,":")>0:$Piece(pTargetBaseURL,":",*-1),1:pTargetBaseURL)
		If $Find(pTargetBaseURL,":")>0 Set pHttpRequest.Port = $Piece(pTargetBaseURL,":",*)
        Set tURL = tAPIPath
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
	Quit tSC
}

ClassMethod CallBS(pBSName As %String = "apiPub.tracer.bs", pRequest As apiPub.service.message, Output pOutput As apiPub.service.message, pMethodName As %String = "ProcessInput") As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set tSC = ##Class(Ens.Director).CreateBusinessService(pBSName,.tBS)
		If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		Set tSC = $Method(tBS,pMethodName,pRequest,.pResponse)
		If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		Set pOutput = pResponse
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
<Route Url="/" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/:path" Method="GET" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/:path/" Method="GET" Call="FromHttpCall"/>
<Route Url="/" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/:path" Method="POST" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/:path/" Method="POST" Call="FromHttpCall"/>
<Route Url="/" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/:path" Method="PUT" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/:path/" Method="PUT" Call="FromHttpCall"/>
<Route Url="/" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/:path" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/:path/" Method="DELETE" Call="FromHttpCall"/>
<Route Url="/" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/:path" Method="PATCH" Call="FromHttpCall"/>
<Route Url="/:path/:path/:path/:path/:path/:path/:path/:path/:path/" Method="PATCH" Call="FromHttpCall"/>
</Routes>
}

}

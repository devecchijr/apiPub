Class apiPub.core.dispatcher Extends apiPub.core.jsonBuilder
{

ClassMethod Dispatch(pRequest As apiPub.service.message, Output pResponse As apiPub.service.message) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        //Parse Request *************************************************************************
        Set pInputBody = {}
        Set tSC = ..GetRequestParams(pRequest.Params,.tInputParams,.tParams)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tSC = ..GetRequestParams(pRequest.Headers,.tInputHeaders)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tMethodKey = pRequest.DispatchClass_"||"_pRequest.DispatchMethod
        Set tVerb = pRequest.HttpVerb
        //End Of Parse *************************************************************************
        Set tSuccessfulCode=""
        Set tResult = {}
        Set tHeadersResponse = {}
        Set pDelim = $Select(tParams.keyDelimiter'="":tParams.keyDelimiter,1:"^")
        Set pPrintResults = $Select(tParams.printResults'="":tParams.printResults,1:0)
        Set tSC = ##class(apiPub.core.irisMetadata).GetMethodInfo(tMethodKey,.minfo,{"printResults":0,"showClassSchemas":1})
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        If minfo.%Size()=0 Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"invalid method call ("_tMethodKey_")"))
        Set tVerb=$ZConvert(minfo.%Get("customParams").%Get("verb"),"L")
        Set tPreValidationMethod=minfo.%Get("customParams").%Get("preValidationMethod")
        If tPreValidationMethod="",minfo.%Get("authorizationMethod")'="" Set tPreValidationMethod = minfo.%Get("authorizationMethod")
        Set tSchemas=minfo.%Get("schemas")
        If tSchemas = "" Set tSchemas = {}
        If tVerb="" Set tVerb=$Select((minfo.%Get("hasComplexParams")):"post",1:"get")
        If tVerb'=$ZConvert(tVerb,"L") {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"<Method not Alowed> invalid http verb"))
        }
        Set tServiceObj=""
        If minfo.%Get("classMethod")=0 {
            Set tSC = ##class(apiPub.core.irisMetadata).GetClassDefInfo($Piece(tMethodKey,"||",1),,,.tIsBS,)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tBusinessServiceName=""
            If pRequest.ServiceClass '="" Set tBusinessServiceName = $Parameter(pRequest.ServiceClass,"DispatchBSName") 
            If tBusinessServiceName="" {
                Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId($Piece(tMethodKey,"||",1)_"||BSNAME")
                If $IsObject(tMParam) Set tBusinessServiceName = tMParam.Default
            }
            If (tIsBS)||(tBusinessServiceName'="") {
                If tBusinessServiceName="" Set tBusinessServiceName=$Piece(tMethodKey,"||",1)
                Set tSC = ##Class(Ens.Director).CreateBusinessService(tBusinessServiceName,.tServiceObj)
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            } Else {
                Set tServiceObj=$ClassMethod($Piece(tMethodKey,"||",1),"%New")
            }
        }
        //Verify if there is a pre validation method for calling
        If tPreValidationMethod'="" {
            Set tSC = ##class(apiPub.core.irisMetadata).GetMethodInfo(pRequest.DispatchClass_"||"_tPreValidationMethod,.mPVinfo,{"printResults":0,"showClassSchemas":1})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            If mPVinfo.%Get("classMethod")="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,tPreValidationMethod_" is not a valid method"))
            If ..GetByLineKey(mPVinfo,"formalSpec[0].paramType")'="apiPub.service.message" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"input parameter of "_tPreValidationMethod_" method must be apiPub.service.message"))
            If (..GetByLineKey(mPVinfo,"outputBodyParams").SizeGet()'=1)||(..GetByLineKey(mPVinfo,"formalSpec["_..GetByLineKey(mPVinfo,"outputBodyParams.0")_"].paramType")'="apiPub.service.message") Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"output parameter of "_tPreValidationMethod_" method must be apiPub.service.message"))
            If mPVinfo.%Get("classMethod")=0 {
                Set tPVCmd = "(pHttpReq,tObj) Quit $Method(tObj,"""_tPreValidationMethod_""",pHttpReq)"
                Set pRequest = $xecute(tPVCmd,pRequest,tServiceObj)
            } Else {
                Set tPVCmd = "(pHttpReq) Quit $ClassMethod("""_$Piece(tMethodKey,"||",1)_""","""_tPreValidationMethod_""",pHttpReq)"
                Set pRequest = $xecute(tPVCmd,pRequest)
            }
        }
        If $Find("post put",$ZConvert(pRequest.HttpVerb,"L"))>0,$ZConvert(pRequest.ContentType,"L")["json" {
			If pRequest.Body.SizeGet()=0 Set tSC = $$$ERROR($$$GeneralError, "Body Could Not be Empty")
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set pInputBody = {}.%FromJSON(pRequest.Body.Read())
        }
        Set tClStr = ""
        Set tSuccessfulCode = minfo.%Get("successfulCode")
        Set tSingleReqBody = minfo.%Get("inputBodyParams").%Size()+minfo.%Get("byRefBodyParams").%Size()=1
        If (tSingleReqBody) {
            Set tFS = minfo.%Get($Select(minfo.%Get("inputBodyParams").%Size()>0:"inputBodyParams",1:"byRefBodyParams")).%GetIterator()
            While (tFS.%GetNext(.key,.value)) {
                Set pWrappedBody = {}.%Set(minfo.%Get("formalSpec").%Get(value).%Get("paramName"),pInputBody)
                Set pInputBody = {}.%FromJSON(pWrappedBody.%ToJSON())
                K pWrappedBody
            }
        }
        Set tOutputParams=0
        If minfo.%Get("formalSpec") {
            Set tFS = minfo.formalSpec.%GetIterator()
            While (tFS.%GetNext(.key,.value)) {
                Set tPName = value.%Get("paramName")
                Xecute ("Kill tmpZ"_$Tr(tPName,"!@#$%^&*()_- ",""))
                If minfo.%Get("resultParam")=key Continue
                Set tPType = value.%Get("pmJType")
                Set tValue=""
                If value.%Get("inputType")="header" {
                    Set tValue = tInputHeaders.%Get(tPName)
                    If tValue="" Set tValue = tInputHeaders.%Get("HTTP_"_$Tr($ZConvert(tPName,"U"),"-","_"))
                } ElseIf $Find("multipart/form-data application/x-www-form-urlencoded",value.%Get("inputType"))>0 {
                    If value.%Get("iConvFunction")="stream",value.%Get("pmJDFormat")="binary" {
                        Set tStreamobj = $ClassMethod(value.%Get("paramType"),"%New")
                        Do tStreamobj.CopyFrom(pRequest.GetMimeData(tPName))
                        Set tValue = tStreamobj
                    } Else {
                        Set tValue = tInputParams.%Get(tPName)
                    }
                } ElseIf value.%Get("inputType")'="" {
                    Set tStreamobj = $ClassMethod(value.%Get("paramType"),"%New")
                    Do tStreamobj.CopyFrom(pRequest.Body)
                    Set tValue = tStreamobj
                } Else {
                    Set tValue = tInputParams.%Get(tPName)
                }
                If value.%Get("pmJType")'="",(value.%Get("outputOnly")=1)||(value.%Get("byRef")=1) Set tOutputParams=tOutputParams+1
                If (tPType'="") //Primitive Values
                    ||((value.%Get("complexType")=1)&&(pInputBody.%Get(tPName)'="")) //Complex Values
                    ||((value.%Get("outputOnly")=1)||(value.%Get("byRef")=1)) //Output Values
                    ||(value.%Get("paramType")="apiPub.service.message") //Special type
                    { 
                    Set tClStr = tClStr_","_$Select((value.%Get("outputOnly")=1)||(value.%Get("byRef")=1):".",1:"")_"tmpZ"_$Tr(tPName,"!@#$%^&*()_- ","")
                    Set tIsList=$Piece(value.%Get("paramType"),"|",2)
                    Set tSchema = value.%Get("customSchema")
                    // Incorporate customSchema with pre-existent schemas
                    If tSchema'="",$IsObject(tSchema) {
                        Set tSc = tSchema.%GetIterator()
                        While (tSc.%GetNext(.sSkey,.sSvalue)) {
                            Do tSchemas.%Set(sSkey,sSvalue)
                        }
                        Set tSchema=""
                    }
                    If tSchema="" Set tSchema = tSchemas
                    Set tSchemaName = value.%Get("customSchemaName")
                    Set tParse = value.%Get("parse")
                    //complex input types
                    If '(value.%Get("outputOnly")) //must be an input parameter
                    &&(
                        ((value.%Get("complexType")=1)&&(pInputBody.%Get(tPName)'="")) //complex body object
                        ||(value.%Get("paramType")="apiPub.service.message") //special type to get the whole http request content
                    ) {
                        Set tParamType = $Piece(value.%Get("paramType"),"|",1)
                        Set reqObj=""
                        Set jsonReqObj = pInputBody.%Get(tPName)
                        If (tParamType = "%Library.DynamicObject")||(tParamType = "%Library.DynamicArray") {
                            Set reqObj={}.%FromJSON(jsonReqObj.%ToJSON())
                            If tSchemaName'="",tParse'=0 {
                                Set tSC = ##class(apiPub.core.parser).Parse(tSchemaName,reqObj,tSchema,.tParseResult,.tParseText,{"printResults":0})
                                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                If tParseText'="1" {
                                    Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"<400> Bad Request - "_tParseText))
                                }
                            }
                        } Else {
                            If tIsList'="" {
                                Set tList = $ClassMethod(tIsList,"%New")
                                Set tLit = jsonReqObj.%GetIterator()
                                While tLit.%GetNext(.lkey,.lvalue) {
                                    If '$IsObject(lvalue) Continue
                                    Set tSC = ##Class(apiPub.core.converter).JSONToObj(lvalue,$Piece(value.%Get("paramType"),"|",1),.reqObj)
                                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                    If tIsList["List" Do tList.InsertAt(reqObj,lkey+1)
                                    If tIsList["Array" Do tList.SetAt(reqObj,lkey+1)
                                }
                                Set reqObj=tList
                            } Else {
                                If tParamType="apiPub.service.message" { //special type
                                    Set reqObj=pRequest
                                } Else { //body object
                                    Set tSC = ##Class(apiPub.core.converter).JSONToObj(jsonReqObj,$Piece(value.%Get("paramType"),"|",1),.reqObj)
                                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                }
                                Kill jsonReqObj
                            }
                        }
                        Set tCmd = "(req) Set tmpZ"_$Tr(tPName,"!@#$%^&*()_- ","")_"=req"
                        Xecute (tCmd,reqObj)
                    } Else { //simple or native types
                        If '(value.%Get("outputOnly")),tValue'="" {
                            If tIsList'="" {
                                Set tList = $ClassMethod(tIsList,"%New")
                                For i=1:1:$Length(tValue,",") {
                                    If tIsList="%Library.DynamicArray" Do tList.%Set(i-1,$Piece(tValue,",",i))
                                    If tIsList["List" Do tList.InsertAt($Piece(tValue,",",i),i)
                                    If tIsList["Array",tIsList'="%Library.DynamicArray" Do tList.SetAt($Piece(tValue,",",i),i)
                                }
                                Set tValue=tList
                            } Else {
                                //Stream to String
                                If $IsObject(tValue),tValue.%IsA("%Stream.Object") {
                                    If value.%Get("iConvFunction")="stream" {
                                        Set tStream = $ClassMethod(value.%Get("paramType"),"%New")
                                        Do tStream.CopyFrom(tValue)
                                        Set tValue=tStream
                                    } ElseIf tValue.SizeGet()>0,value.%Get("pmJDType")="string" {
                                        Set tStrContent = ""
                                        Do tValue.Rewind()
                                        While (tValue.AtEnd=0) {
                                            Set tStrContent = tStrContent_tValue.Read()
                                        }
                                        Set tValue=tStrContent
                                    }
                                } ElseIf value.%Get("iConvFunction")="stream" {
                                    Set tStream = $ClassMethod(value.%Get("paramType"),"%New")
                                    Do tStream.Write(tValue)
                                    Set tValue=tStream
                                } ElseIf value.%Get("iConvFunction")'="" {
                                    If $ClassMethod($Piece(value.%Get("paramType"),"|",1),"IsValid",tValue)'=1 {
                                        For i=1:1:$Length(value.%Get("iConvFunction"),",") {
                                            Set cVal = $ClassMethod($Piece(value.%Get("paramType"),"|",1),value.%Get("iConvFunction"),tValue)
                                            If $ClassMethod($Piece(value.%Get("paramType"),"|",1),"IsValid",cVal)=1 Set tValue = cVal  Quit
                                        }
                                    }
                                    If $ClassMethod($Piece(value.%Get("paramType"),"|",1),"IsValid",tValue)'=1 {
                                        Set tSC = $$$ERROR($$$GeneralError, "invalid parameter value ("_tPName_")")
                                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                                    }
                                }
                            }
                        }
                        Set tCmd = "(var) Set tmpZ"_$Tr(tPName,"!@#$%^&*()_- ","")_"=var"
                        Xecute (tCmd,tValue)
                    }
                } Else {
                    Set tClStr = tClStr_","
                }
            }
        }
        Set (tRetPName,tRetType)=""
        If minfo.%Get("resultParam")'="" {
            Set tRetPName=$Piece(minfo.%Get("formalSpec").%Get(minfo.%Get("resultParam")).%Get("paramName"),"|",1)
            Set tRetType=$Piece(minfo.%Get("formalSpec").%Get(minfo.%Get("resultParam")).%Get("paramType"),"|",1)
        }
        If tServiceObj="" Set tClStr = "$ClassMethod("""_$Piece(tMethodKey,"||",1)_""","""_$Piece(tMethodKey,"||",2)_""""_tClStr_")"
        If $IsObject(tServiceObj) Set tClStr = "$Method(tObj,"""_$Piece(tMethodKey,"||",2)_""""_tClStr_")"
        Xecute "Kill tmpZ"_$Tr(tRetPName,"!@#$%^&*()_- ","")
        Try {
            If tRetType'="" {
                Set tClStr = "(tObj) Set tmpZ"_$Tr(tRetPName,"!@#$%^&*()_- ","")_" = "_tClStr
                Xecute (tClStr,tServiceObj)
            } Else {
                Set tClStr = "(tObj) Do "_tClStr
                Xecute (tClStr,tServiceObj)
            }
        } Catch(e) {
            If 'e.AsStatus() { Throw ##Class(%Exception.StatusException).CreateFromStatus(e.AsStatus())}
        }
        Set tSingleRespBody = tOutputParams+minfo.%Get("byRefBodyParams").%Size()+minfo.%Get("outputBodyParams").%Size()=1
        If minfo.%Get("formalSpec") {
            Set tFS = minfo.formalSpec.%GetIterator()
            While (tFS.%GetNext(.key,.value)) {
                Set tPName = value.%Get("paramName")
                Set tPType = value.%Get("pmJType")
                Set tParamType = $Piece(value.%Get("paramType"),"|",1)
                Set tList=$Piece(value.%Get("paramType"),"|",2)
                If tPType'=""||value.%Get("complexType")=1,(value.%Get("outputOnly")=1||value.%Get("byRef")=1) {
                    Set tVal=""
                    Set tCmd = "(out) Set out=$Get(tmpZ"_$Tr(tPName,"!@#$%^&*()_- ","")_","""")"
                    Xecute (tCmd,.tVal)
                    If tPType="status" {
                        Set pInnerStatus = tVal
                        If value.%Get("outputType")="body" {
                            Do tResult.%Set("iris-StatusCode",$$$ISOK(tVal))
                            Do tResult.%Set("iris-StatusMessage",$Select($$$ISERR(tVal):$System.Status.GetOneErrorText(tVal),1:"OK"))
                            If '(tVal) Do tResult.%Set("iris-ErrorCode",$System.Status.GetErrorCodes(tVal))
                        } Else {
                            Do tHeadersResponse.%Set("iris-StatusCode",$$$ISOK(tVal))
                            Do tHeadersResponse.%Set("iris-StatusMessage",$Select($$$ISERR(tVal):$System.Status.GetOneErrorText(tVal),1:"OK"))
                            If '(tVal) Do tHeadersResponse.%Set("iris-ErrorCode",$System.Status.GetErrorCodes(tVal))
                        }
                        //To be Implemented Silent Mode
                        If '$$$ISOK(tVal) Throw ##Class(%Exception.StatusException).CreateFromStatus(tVal)
                    } ElseIf value.%Get("complexType")=1 {
                        If tVal'="" {
                            If (tParamType = "%Library.DynamicObject")||(tParamType = "%Library.DynamicArray") {
                                If tSingleRespBody=1 {
                                    Set tResult = tVal
                                } Else {
                                    Do tResult.%Set(tPName,tVal)
                                }
                            } Else {
                                If tList'="" {
                                    Set tJSONList = []
                                    Set tSC = ##Class(apiPub.core.converter).ObjArrayToJSONArray(tVal,.tJSONList,{"printResults":0})                      
                                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                    If tSingleRespBody=1 {
                                        Set tResult = tJSONList
                                    } Else {
                                        Do tResult.%Set(tPName,tJSONList)
                                    }
                                } Else {
                                    Set tSC = ##Class(apiPub.core.converter).ObjToJSON(tVal,.tJsonObj,{"printResults":0})
                                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                    If tSingleRespBody=1 {
                                        Set tResult = tJsonObj
                                    } Else {
                                        Do tResult.%Set(tPName,tJsonObj)
                                    }
                                }
                            }
                        }
                    } Else { //Primitive values
                        If tList'="" {
                            Set pJSONList = []
                            For i=1: 1: tVal.Count() {
                                Set tItVal=tVal.GetAt(i)
                                If value.%Get("oConvFunction")'="",tItVal'="" {
                                    Set tItVal = $ClassMethod($Piece(value.%Get("paramType"),"|",1),value.%Get("oConvFunction"),tItVal)
                                } 
                                Do pJSONList.%Push(tItVal)
                            }
                            Set tVal=pJSONList
                            Do tResult.%Set(tPName,tVal)
                        } Else {
                            //Not alocate specific values for different output type
                            If value.%Get("outputType")'="",value.%Get("outputType")'="header" {
                                Set tResult = tVal
                                Set pResponse.ContentType = value.%Get("outputType")  
                            } Else {
                                If value.%Get("oConvFunction")="stream",tVal'="",value.%Get("pmJDType")="string" {
                                    // alocate stream response on json property
                                    If tVal.SizeGet()>0 {
                                        Set tStrContent = ""
                                        Do tVal.Rewind()
                                        While (tVal.AtEnd=0) {
                                            Set tStrContent = tStrContent_tVal.Read()
                                        }
                                        Set tVal=tStrContent
                                    }
                                } ElseIf value.%Get("oConvFunction")'="",tVal'="" {
                                    Set tVal = $ClassMethod(value.%Get("paramType"),value.%Get("oConvFunction"),tVal)
                                }
                                If value.%Get("outputType")="header" {
                                    Do tHeadersResponse.%Set(tPName,tVal,$Select(tVal'="":tPType,1:""))
                                } Else {
                                    Do tResult.%Set(tPName,tVal,$Select(tVal'="":tPType,1:""))
                                }
                            }
                        } 
                    }
                }
            }
        }
        //Parse Response **********************************
		If tHeadersResponse.%Size()>0{
            Set pResponse.Headers=tHeadersResponse.%ToJSON()
        }
        If $Data(tResult),$IsObject(tResult),tResult.%IsA("%Library.DynamicAbstractObject") {
			If tResult.%Size()>0||(($ClassName(tResult)="%Library.DynamicArray")&&$IsObject(tResult)) Do pResponse.Body.Write(tResult.%ToJSON())
			Set pResponse.ContentType = "application/json"
		} ElseIf $Data(tResult),$IsObject(tResult),tResult.%IsA("%Stream.Object") {
            Do pResponse.Body.CopyFrom(tResult)
		} ElseIf $Data(tResult),'$IsObject(tResult) {
			Do pResponse.Body.Write(tResult)
        }
        If minfo.%Get("responseCharset")'="" Set pResponse.CharSet = minfo.%Get("responseCharset")
        Set pResponse.ResponseStatusCode = tSuccessfulCode
        //*************************************************
        If pPrintResults {
            If $IsObject(tResult) {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(tResult.%ToJSON(),.jsonString)
                Write jsonString
            } Else {
                Write tResult
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

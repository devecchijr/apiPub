Class apiPub.core.dispatcher Extends apiPub.core.jsonBuilder
{

// Road Map

ClassMethod XMLCall(pMethodKey As %String, ByRef pInstance As %XML.Adaptor, pInputBody As %AbstractStream, pInputParams As %Library.DynamicObject, Output pResult As %AbstractStream, pParams As %Library.DynamicObject, Output pHeadersResponse As %Library.DynamicObject, Output pInnerStatus As %Status, Output pSuccessfulCode) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        Set pHeadersResponse = {}
        Set pResult = ##class(%Library.GlobalCharacterStream).%New()
    }
    Catch(e) {
        Set tSC = e.AsStatus()
    }
    Quit tSC
}

ClassMethod JSONCall(pMethodKey As %String, ByRef pInstance As %RegisteredObject, pVerb As %String = "get", pInputBody As %Library.DynamicObject, pInputParams As %Library.DynamicObject, pInputHeaders As %Library.DynamicObject, Output pResult As %Library.DynamicObject, pParams As %Library.DynamicObject, Output pHeadersResponse As %Library.DynamicObject, Output pInnerStatus As %Status, Output pSuccessfulCode) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        If '$Data(pParams) Set pParams={}
        If '$Data(pInputBody) Set pInputBody={}
        Set pSuccessfulCode=""
        Set pResult = {}
        Set pHeadersResponse = {}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^")
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set tSC = ##class(apiPub.core.irisMetadata).GetMethodInfo(pMethodKey,.minfo,{"printResults":0,"showClassSchemas":1})
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        If minfo.%Size()=0 Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"invalid method call ("_pMethodKey_")"))
        Set tVerb=$ZConvert(minfo.%Get("customParams").%Get("verb"),"L")
        Set tSchemas=minfo.%Get("schemas")
        If tSchemas = "" Set tSchemas = {}
        If tVerb="" Set tVerb=$Select((minfo.%Get("hasComplexParams")):"post",1:"get")
        If tVerb'=$ZConvert(pVerb,"L") {
            Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"<Method not Alowed> invalid http verb"))
        }
        Set tServiceObj=""
        If minfo.%Get("classMethod")=0 {
            If '$Data(pInstance) {
                Set tSC = ##class(apiPub.core.irisMetadata).GetClassDefInfo($Piece(pMethodKey,"||",1),,,.tIsBS,)
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                Set tBusinessServiceName=minfo.%Get("customParams").%Get("bsName")
                If tBusinessServiceName="" {
                    Set tMParam=##class(%Dictionary.ParameterDefinition).%OpenId($Piece(pMethodKey,"||",1)_"||BSNAME")
                    If $IsObject(tMParam) Set tBusinessServiceName = tMParam.Default
                }
                If (tIsBS)||(tBusinessServiceName'="") {
                    If tBusinessServiceName="" Set tBusinessServiceName=$Piece(pMethodKey,"||",1)
                    Set tSC = ##Class(Ens.Director).CreateBusinessService(tBusinessServiceName,.tServiceObj)
                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                } Else {
                    Set tServiceObj=$ClassMethod($Piece(pMethodKey,"||",1),"%New")
                }
            } Else {
                If $IsObject(pInstance) Set tServiceObj=pInstance
            }
        }
        Set tClStr = ""
        Set pSuccessfulCode = minfo.%Get("successfulCode")
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
                If value.%Get("input")="header" {
                    Set tValue = pInputHeaders.%Get(tPName)
                    If tValue="" Set tValue = pInputHeaders.%Get("HTTP_"_$Tr($ZConvert(tPName,"U"),"-","_"))
                } Else {
                    Set tValue = pInputParams.%Get(tPName)
                }
                If value.%Get("pmJType")'="",(value.%Get("outputOnly")=1)||(value.%Get("byRef")=1) Set tOutputParams=tOutputParams+1
                If (tPType'="")//Primitive Values
                    ||((value.%Get("complexType")=1)&&(pInputBody.%Get(tPName)'="")) //Complex Values
                    ||((value.%Get("outputOnly")=1)||(value.%Get("byRef")=1)) { //Output Values
                    Set tClStr = tClStr_","_$Select((value.%Get("outputOnly")=1)||(value.%Get("byRef")=1):".",1:"")_"tmpZ"_$Tr(tPName,"!@#$%^&*()_- ","")
                    Set tIsList=$Piece(value.%Get("paramType"),"|",2)
                    Set tSchema = value.%Get("customSchema")
                    If tSchema="" Set tSchema = tSchemas
                    Set tSchemaName = value.%Get("customSchemaName")
                    If '(value.%Get("outputOnly")),value.%Get("complexType")=1,pInputBody.%Get(tPName)'="" {
                        Set tParamType = $Piece(value.%Get("paramType"),"|",1)
                        Set reqObj=""
                        Set jsonReqObj = pInputBody.%Get(tPName)
                        If (tParamType = "%Library.DynamicObject")||(tParamType = "%Library.DynamicArray") {
                            Set reqObj={}.%FromJSON(jsonReqObj.%ToJSON())
                            If tSchemaName'="" {
                                Set tSC = ##class(apiPub.core.parser).Parse(tSchemaName,reqObj,tSchema,.tParseResult,.tParseText,{"printResults":0})
                                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                If tParseText'="1" {
                                    Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"<Bad Request> "_tParseText))
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
                                Set tSC = ##Class(apiPub.core.converter).JSONToObj(jsonReqObj,$Piece(value.%Get("paramType"),"|",1),.reqObj)
                                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                Kill jsonReqObj
                            }
                        }
                        Set tCmd = "(req) Set tmpZ"_$Tr(tPName,"!@#$%^&*()_- ","")_"=req"
                        Xecute (tCmd,reqObj)
                    } Else {
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
                                If value.%Get("iConvFunction")'="" {
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
        If tServiceObj="" Set tClStr = "$ClassMethod("""_$Piece(pMethodKey,"||",1)_""","""_$Piece(pMethodKey,"||",2)_""""_tClStr_")"
        If $IsObject(tServiceObj) Set tClStr = "$Method(tObj,"""_$Piece(pMethodKey,"||",2)_""""_tClStr_")"
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
                        If value.%Get("output")="body" {
                            Do pResult.%Set("iris-StatusCode",$$$ISOK(tVal))
                            Do pResult.%Set("iris-StatusMessage",$Select($$$ISERR(tVal):$System.Status.GetOneErrorText(tVal),1:"OK"))
                            If '(tVal) Do pResult.%Set("iris-ErrorCode",$System.Status.GetErrorCodes(tVal))
                        } Else {
                            Do pHeadersResponse.%Set("iris-StatusCode",$$$ISOK(tVal))
                            Do pHeadersResponse.%Set("iris-StatusMessage",$Select($$$ISERR(tVal):$System.Status.GetOneErrorText(tVal),1:"OK"))
                            If '(tVal) Do pHeadersResponse.%Set("iris-ErrorCode",$System.Status.GetErrorCodes(tVal))
                        }
                        //To be Implemented Silent Mode
                        If '$$$ISOK(tVal) Throw ##Class(%Exception.StatusException).CreateFromStatus(tVal)
                    } ElseIf value.%Get("complexType")=1 {
                        If tVal'="" {
                            If (tParamType = "%Library.DynamicObject")||(tParamType = "%Library.DynamicArray") {
                                If tSingleRespBody=1 {
                                    Set pResult = tVal
                                } Else {
                                    Do pResult.%Set(tPName,tVal)
                                }
                            } Else {
                                If tList'="" {
                                    Set tJSONList = []
                                    Set tSC = ##Class(apiPub.core.converter).ObjArrayToJSONArray(tVal,.tJSONList,{"printResults":0})                      
                                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                    If tSingleRespBody=1 {
                                        Set pResult = tJSONList
                                    } Else {
                                        Do pResult.%Set(tPName,tJSONList)
                                    }
                                } Else {
                                    Set tSC = ##Class(apiPub.core.converter).ObjToJSON(tVal,.tJsonObj,{"printResults":0})
                                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                                    If tSingleRespBody=1 {
                                        Set pResult = tJsonObj
                                    } Else {
                                        Do pResult.%Set(tPName,tJsonObj)
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
                            Do pResult.%Set(tPName,tVal)
                        } Else {
                            If value.%Get("oConvFunction")'="",tVal'="" {
                                Set tVal = $ClassMethod(value.%Get("paramType"),value.%Get("oConvFunction"),tVal)
                            }
                            If value.%Get("output")="header" {
                                Do pHeadersResponse.%Set(tPName,tVal,$Select(tVal'="":tPType,1:""))
                            } Else {
                                Do pResult.%Set(tPName,tVal,$Select(tVal'="":tPType,1:""))
                            }
                        } 
                    }
                }
            }
        }
        If pPrintResults {
            Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
            Do tFormatter.FormatToString(pResult.%ToJSON(),.jsonString)
            Write jsonString
        }
    }
    Catch(e) {
        //w $System.Status.GetOneErrorText(e.AsStatus()),!
        Set tSC = e.AsStatus()
    }
    Quit tSC
}

}

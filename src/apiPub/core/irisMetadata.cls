Class apiPub.core.irisMetadata Extends apiPub.core.jsonBuilder
{

ClassMethod GetMethodsInfo(pClassName As %String, pMethodName As %String, ByRef pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        If '$Data(pParams) Set pParams={}
        If '$Data(pInternal) {
            k pJSON,methodInfo
            Set pInternal={"level":0,"origClass":(pClassName)}
        }
        If '$Data(pJSON) Set pJSON={"methods":{},"customSchemas":{}}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^")
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pOrigClass = pInternal.%Get("origClass")
        set tCD=##class(%Dictionary.ClassDefinition).%OpenId(pClassName)
        If $IsObject(tCD) {
            If tCD.Super'="" {
                For sup=1:1:$l(tCD.Super,",") {  Continue:$p(tCD.Super,",",sup)=""
                    Set tSC = ..GetMethodsInfo($Piece(tCD.Super,",",sup),pMethodName,.pJSON,pParams,{"level":(pInternal.level+1),"origClass":(pOrigClass)})
                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                }
            }
            // description of methods
            If (tCD.Methods.Count()>0) {
                Set xdataID=pClassName_"||apiPub"
                Set tCompiledXdata=##class(%Dictionary.CompiledXData).%OpenId(xdataID)
                If $IsObject(tCompiledXdata),$IsObject(tCompiledXdata.Data) {
                    Set tXDataJSON = ##class(%Library.DynamicObject).%New().%FromJSON(tCompiledXdata.Data)
                    If $IsObject(tXDataJSON),tXDataJSON.%Get("schemas")'="" {
                        Set tProp = tXDataJSON.%Get("schemas").%GetIterator()
                        While tProp.%GetNext(.key,.value) {
                            Do ..s(pJSON,"customSchemas"_pDelim_key,value,,pDelim)
                        }
                    }
                    If $IsObject(tXDataJSON),tXDataJSON.%Get("info")'="" {
                        Set tProp = tXDataJSON.%Get("info").%GetIterator()
                        While tProp.%GetNext(.key,.value) {
                            Do ..s(pJSON,"customInfo"_pDelim_key,value,,pDelim)
                        }
                    }
                    If $IsObject(tXDataJSON),tXDataJSON.%Get("tags")'="" {
                        Set tProp = tXDataJSON.%Get("tags").%GetIterator()
                        While tProp.%GetNext(.key,.value) {
                            Do ..s(pJSON,"customTags"_pDelim_key,value,,pDelim)
                        }
                    }
                    If $IsObject(tXDataJSON),tXDataJSON.%Get("securitySchemes")'="" {
                        Set tProp = tXDataJSON.%Get("securitySchemes").%GetIterator()
                        While tProp.%GetNext(.key,.value) {
                            Do ..s(pJSON,"customSecurity"_pDelim_key,value,,pDelim)
                        }
                    }
                    If $IsObject(tXDataJSON),tXDataJSON.%Get("servers")'="" {
                        Set tProp = tXDataJSON.%Get("servers").%GetIterator()
                        While tProp.%GetNext(.key,.value) {
                            Do ..s(pJSON,"customServers"_pDelim_key,value,,pDelim)
                        }
                    }
                }
                Do ..s(pJSON,"description",tCD.Description,,pDelim)
                Set key=""
                Set tMD=tCD.Methods.GetNext(.key)
                While(key'="") {
                    If pMethodName'="",pMethodName'=tMD.Name {
                        Set tMD=tCD.Methods.GetNext(.key)
                        Continue
                    }
                    If (tMD.WebMethod),'(tMD.Internal),'(tMD.Private),..g(pJSON,"methods"_pDelim_tMD.Name,pDelim)="" {
                        Set tSC = ..GetMethodInfo(pClassName_"||"_tMD.Name,.methodInfo,{"printResults":0})
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                        Do ..s(pJSON,"methods"_pDelim_tMD.Name,##class(%Library.DynamicObject).%New().%FromJSON(methodInfo.%ToJSON()),,pDelim)
                    }
                    Set tMD=tCD.Methods.GetNext(.key)
                } 
            }
        }
        If pInternal.level=0,pPrintResults {
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

ClassMethod GetMethodParams(pTag As %String, pMethodCom As %String, Output pOutputParams As %Library.DynamicObject, Output pOutputCom As %String) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        Set pOutputParams = {}
        Set pOutputCom=pMethodCom
        While $Find(pOutputCom,pTag)>0,$Find(pOutputCom,"[")>0,$Find(pOutputCom,"]")>0 {
            Set tComm = $Piece(pOutputCom,pTag,2)
            Set tAttBlock = $Piece($Piece(tComm,"[",2,*),"]",1,*-1)
            Set pOutputCom = $Replace($Piece(pOutputCom,"[",1),pTag,"")_$Piece(pOutputCom,tAttBlock_"]",2,*)
            If $Find(tAttBlock,"{")>0,$Find(tAttBlock,"}")>0,$Find(tAttBlock,"=")=0 {
                Set pOutputParams = ##class(%Library.DynamicObject).%New().%FromJSON(tAttBlock)
                Quit
            } ElseIf ($Find(tAttBlock,"=")>0) {
                Set tCmd = "(tVal) Set tVal ="_$Replace($Replace($Replace($Piece($Replace(tAttBlock,"\=","\*"),"=",2),"\*","="),$Char(10),""),$Char(13),"")
                Set tVal = ""
                Try {
                    Xecute (tCmd,.tVal)
                } Catch(e) { 
                    Set tSC = $$$ERROR($$$GeneralError, "invalid "_pTag_" param ["_tAttBlock_"]")
                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                }
                Set tKey=$Tr($Piece(tAttBlock,"=",1),"""","")
                If tKey="path",$E(tVal,1)'="/" Set tVal="/"_tVal
                Do ..s(pOutputParams,tKey,tVal,,".")
            }
        }
        Set pOutputCom = $Replace($Replace(pOutputCom,$Char(10),""),$Char(13),"")
    }
    Catch(e) {
        Set tSC = e.AsStatus()
    }
    Quit tSC
}

ClassMethod GetCustomPaths(pClassName As %String, Output pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        If '$Data(pParams) Set pParams={}
        If '$Data(pInternal) Set pInternal={"level":0,"origClass":(pClassName)}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^")
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pOrigClass = pInternal.%Get("origClass")
        Set tCD=##class(%Dictionary.ClassDefinition).%OpenId(pClassName)
        If pInternal.level=0 {
            Set pJSON={"paths":{}}
        }
        If $IsObject(tCD) {
            If tCD.Super'="" {
                For sup=1:1:$l(tCD.Super,",") {  Continue:$p(tCD.Super,",",sup)=""
                    Set tSC = ..GetCustomPaths($Piece(tCD.Super,",",sup),.pJSON,pParams,{"level":(pInternal.level+1),"origClass":(pOrigClass)})
                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                }
            }
            If (tCD.Methods.Count()>0) {
                Set key=""
                Set tMD=tCD.Methods.GetNext(.key)
                While(key'="") {
                    If (tMD.WebMethod),'(tMD.Internal),'(tMD.Private) {
                        Set tSC = ..GetMethodInfo(pClassName_"||"_tMD.Name,.mInfo,{"printResults":0})
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                        Set tVerb=mInfo.%Get("verb")
                        Set tProtected=mInfo.%Get("protected")
                        Set tTrace=mInfo.%Get("trace")
                        Set tOperationId = mInfo.%Get("customParams").%Get("operationId")
                        Set tPath = tVerb_":/"_tMD.Name
                        If mInfo.%Get("customParams").%Get("path")'="" Set tPath = tVerb_":"_mInfo.%Get("customParams").%Get("path")
                        If pJSON.%Get("paths").%Get(tPath)'="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "duplicated Path on Class "_pClassName))
                        //build non required paths
                        If mInfo.%Get("customParams").%Get("params")'="" {
                            Set tAuxPath = tPath
                            Set prop = mInfo.%Get("customParams").%Get("params").%GetIterator()
		                    While (prop.%GetNext(.cpkey,.cpvalue)) { 
                                If ..JGet(cpvalue,"required")=0 {
                                    Set tAuxPath=$Replace(tAuxPath,"/{"_cpkey_"}","")
                                    Set tAuxPath=$Length(tAuxPath,"/")_"##"_$Piece(tAuxPath,":",1)_":"_$Piece(tAuxPath,":",2,*)
                                    If ..g(pJSON,"paths"_"^"_tAuxPath_"^methodName","^")'="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "duplicated Path on Method "_tMD.Name))
                                    Do pJSON.%Get("paths").%Set(tAuxPath,{"methodName":(tMD.Name)})
                                    If tOperationId'="" Do pJSON.%Get("paths").%Get(tAuxPath).%Set("operationId",tOperationId)
                                    If tProtected'="" Do pJSON.%Get("paths").%Get(tAuxPath).%Set("protected",tProtected)
                                    If tTrace'="" Do pJSON.%Get("paths").%Get(tAuxPath).%Set("trace",tTrace)
                                }
                            }
                        }
                        Set tPath = $Length(tPath,"/")_"##"_$Piece(tPath,":",1)_":"_$Piece(tPath,":",2,*)
                        If ..g(pJSON,"paths"_"^"_tPath_"^methodName","^")'="" Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "duplicated Path on Method "_tMD.Name))
                        Do pJSON.%Get("paths").%Set(tPath,{"methodName":(tMD.Name)})
                        If tOperationId'="" Do pJSON.%Get("paths").%Get(tPath).%Set("operationId",tOperationId)
                        If tProtected'="" Do pJSON.%Get("paths").%Get(tPath).%Set("protected",tProtected)
                        If tTrace'="" Do pJSON.%Get("paths").%Get(tPath).%Set("trace",tTrace)
                    }
                    Set tMD=tCD.Methods.GetNext(.key)
                } 
            }
        }
        If pInternal.level=0 {
            If (pPrintResults) {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pJSON.%ToJSON(),.jsonString)
                Write jsonString
            }
			Set tSC = ..GetIdxPath(pJSON,.tIdxJSON)
			If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            Set pJSON = tIdxJSON
            If (pPrintResults) {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pJSON.%ToJSON(),.jsonString)
                Write jsonString
            }
        }
    }
    Catch(e) {
        Set tSC = e.AsStatus()
    }
    Quit tSC
}

ClassMethod GetSubclassesOf(superclassName As %String, subClasses As %DynamicArray) As %Status
{
    If '$Data(subClasses) Set subClasses = []
	Set tSC = $System.Status.OK()
	Try {
        Set level=[]
        Set tSql = "SELECT distinct ID "_
            "FROM %Dictionary.ClassDefinition where Super = '"_superclassName_"' or Super like '%,"_superclassName_"' or Super like '"_superclassName_",%'"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set tSC = tStatement.%Prepare(tSql)
        If tSC'=1 {write "%Prepare failed:" Do $System.Status.DisplayError(tSC) quit}
        Set tRS = tStatement.%Execute()
        If tRS.%SQLCODE=0 {
            While tRS.%Next() {
                Do level.%Push(tRS.%GetData(1))
            }
        }
        Set levelIt = level.%GetIterator()
        While levelIt.%GetNext(.key,.classname) {
            Do subClasses.%Push(classname)
            Do ..GetSubclassesOf(classname,subClasses)
        }
    }
	Catch(e) {
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod GetMethodInfo(pMethodKey As %String, Output pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject, pLevel, Output pSchemas As %Library.DynamicObject) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        If '$Data(pParams) Set pParams={}
        If '$Data(pLevel) {
            Set pLevel=0
            Set pJSON={}
            Set pSchemas={}
        }
        If pLevel'=+pLevel Set pLevel=0
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^")
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pResponseObjName = $Select(pParams.responseObjName'="":pParams.responseObjName,1:"response")
        Set pSuccessfulCode = $Select(pParams.successfulCode'="":pParams.successfulCode,1:"200")
        Set (tCachedSpec,tTimeChanged)=""
        Set tCachedData=0
        If pLevel=0 {
            //Verify cached spec data
            Set tSC = ..GetClassDefInfo($Piece(pMethodKey,"||",1),.tTimeChanged)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tCachedSpec=##class(apiPub.service.cache).CacheIdxOpen(pMethodKey_"||sp")
            If '$IsObject(tCachedSpec) {
                Set tCachedSpec = ##class(apiPub.service.cache).%New()
                Set tCachedSpec.Key = pMethodKey_"||sp"
            } Else {
                If tCachedSpec.DateTimeCtl=tTimeChanged Set tCachedData=1
            }
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tCachedSchemas=##class(apiPub.service.cache).CacheIdxOpen($Piece(pMethodKey,"||",1)_"||sch")
            If '$IsObject(tCachedSchemas) {
                Set tCachedSchemas = ##class(apiPub.service.cache).%New()
                Set tCachedSchemas.Key = $Piece(pMethodKey,"||",1)_"||sch"
                Set tCachedData=0
            } Else {
                If tCachedSchemas.DateTimeCtl'=tTimeChanged Set tCachedData=0
            }
        } 
        //If not cached yet
        If (tTimeChanged="")||(tCachedData=0) {
            Set tCD=##class(%Dictionary.ClassDefinition).%OpenId($Piece(pMethodKey,"||",1))
            If $IsObject(tCD) {
                Set tMD = ##class(%Dictionary.CompiledMethod).%OpenId(pMethodKey)
                If $IsObject(tMD) {
                    Set primitiveTypes = ##Class(apiPub.core.typeMapper).GetParamTypes()
                    Set tSC=..GetMethodParams("@apiPub",tMD.Description,.tApiPubParams,.tMethodDesc)
                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                    Set tMD.Description=tMethodDesc
                    Set xdataID=$Piece(pMethodKey,"||",1)_"||apiPub"
                    Set tCompiledXdata=##class(%Dictionary.CompiledXData).%OpenId(xdataID)
                    Set tXDataJSON={"schemas":{}}
                    If $IsObject(tCompiledXdata),$IsObject(tCompiledXdata.Data) {
                        Set tXDataJSON = ##class(%Library.DynamicObject).%New().%FromJSON(tCompiledXdata.Data)
                        //review this block after (how to get date from xdata)
                        If tXDataJSON.%Get($Piece(pMethodKey,"||",2))'="" {
                            Set tProp = tXDataJSON.%Get($Piece(pMethodKey,"||",2)).%GetIterator()
                            While tProp.%GetNext(.key,.value) {
                                Do tApiPubParams.%Set(key,value)  
                            }
                        }
                        While ..i(tXDataJSON,"schemas",.tScIdx,.tScVal,.tScIt) {
                            If ..g(pSchemas,tScIdx,"^")="" {
                                Do ..s(pSchemas,tScIdx,tScVal,,"^")
                            }
                        }
                    }
                    Do ..s(pJSON,"description",tMD.Description,,pDelim)
                    Do ..s(pJSON,"classMethod",tMD.ClassMethod,,pDelim)
                    If tMD.SoapMessageName'="" Do ..s(pJSON,"soapMessageName",tMD.SoapMessageName,,pDelim)
                    If tMD.SoapNameSpace'="" Do ..s(pJSON,"soapNameSpace",tMD.SoapNameSpace,,pDelim)
                    If tMD.SoapRequestMessage'= "" Do ..s(pJSON,"soapRequestMessage",tMD.SoapRequestMessage,,pDelim)
                    Set tProtected = 1
                    If (..g(tApiPubParams,"protected")=0) Set tProtected = 0
                    If (..g(tApiPubParams,"public")=1) Set tProtected = 0
                    Do ..s(pJSON,"protected",tProtected,,pDelim)
                    Do ..s(pJSON,"trace",(..g(tApiPubParams,"trace")=1),,pDelim)
                    Do ..s(pJSON,"formalSpec",[],,pDelim)
                    Do ..s(pJSON,"inputBodyParams",[],,pDelim)
                    Do ..s(pJSON,"byRefBodyParams",[],,pDelim)
                    Do ..s(pJSON,"outputBodyParams",[],,pDelim)
                    Do ..s(pJSON,"customParams",{},,pDelim)
                    Set tResponseDescription=""
                    Set tComplexSchema=0
                    Set (tResponseContentType,tResponseCharSet) = ""
                    If tApiPubParams.%Size()>0 {
                        Do ..s(pJSON,"customParams",tApiPubParams,,pDelim)
                        If ..g(tApiPubParams,"response.name",".")'="" Set pResponseObjName = ..g(tApiPubParams,"response.name",".")
                        If ..g(tApiPubParams,"response.outputType",".")'="" Set tResponseContentType = ..g(tApiPubParams,"response.outputType",".")
                        If ..g(tApiPubParams,"response.contentType",".")'="" Set tResponseContentType = ..g(tApiPubParams,"response.contentType",".")
                        If ..g(tApiPubParams,"response.charset",".")'="" Set tResponseCharSet = ..g(tApiPubParams,"response.charset",".")
                        If tResponseCharSet="",..g(tApiPubParams,"charset",".")'="" Set tResponseCharSet = ..g(tApiPubParams,"charset",".")
                        If ..g(tApiPubParams,"successfulCode",".")'="" Set pSuccessfulCode = ..g(tApiPubParams,"successfulCode",".")
                    }
                    Do ..s(pJSON,"successfulCode",pSuccessfulCode,,pDelim)
                    Set (tBinaryStreamParams,tCharStreamParams)=""
                    For i=1:1:$ListLength(tMD.FormalSpecParsed) {
                        Set (tParamName,tParamDesc,tParamType,tParamInOut,tParamDefault,tParamAtts)=""
                        Set tSerParam=$ListGet(tMD.FormalSpecParsed,i)
                        For si=1:1:$ListLength(tSerParam) {
                            If si=1 Set tParamName = $ListGet(tSerParam,si)
                            If si=2 Set tParamType = $ListGet(tSerParam,si)
                            If si=3 Set tParamInOut = $ListGet(tSerParam,si)
                            If si=4 Set tParamDefault = $ListGet(tSerParam,si)
                            If si>4 Set tParamAtts = tParamAtts_$ListGet(tSerParam,si)_$Select((si#2):"=",1:"|")
                        }
                        Set tParamAtts=$Extract(tParamAtts,1,*-1)
                        Set tPMType = primitiveTypes.%Get($S($Length(tParamType,".")>1:"%",1:"")_$ZConvert($Piece(tParamType,".",*),"L"))
                        Set tXmlAdaptor=0
                        If tPMType="" {
                            Set tSC = ..GetClassDefInfo(tParamType,,.tXmlAdaptor)
                            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                        }
                        Set tParam = tParamName
                        Set (tParamOutput,tParamInput)=""
                        If tApiPubParams.%Size()>0 {
                            If ..g(tApiPubParams,"params."_tParam_".name",".")'="" Set tParamName = ..g(tApiPubParams,"params."_tParam_".name",".")
                            If ..g(tApiPubParams,"params."_tParam_".outputType",".")'="" Set tParamOutput = ..g(tApiPubParams,"params."_tParam_".outputType",".")
                            If ..g(tApiPubParams,"params."_tParam_".inputType",".")'="" Set tParamInput = ..g(tApiPubParams,"params."_tParam_".inputType",".")
                        }
                        // if type=stream and inputType not defined, then set a defaut
                        If tParamInput="",$Piece(tPMType,"|",4)="stream",tParamName'="response" {
                            If "%Stream.GlobalBinary %Stream.FileBinary"[tParamType Set tBinaryStreamParams=tBinaryStreamParams_$Select(tBinaryStreamParams'="":",",1:"")_..g(pJSON,"formalSpec").%Size()                     
                            If "%Stream.GlobalCharacter %Stream.FileCharacter"[tParamType Set tCharStreamParams=tCharStreamParams_$Select(tCharStreamParams'="":",",1:"")_..g(pJSON,"formalSpec").%Size()                     
                        }
                        Set tParamObj = {
                            "param":(tParam),
                            "paramName":(tParamName),
                            "paramType":(tParamType),
                            "pmJType":($Piece(tPMType,"|",1)),
                            "pmJDType":($Piece(tPMType,"|",2)),
                            "pmJDFormat":($Piece(tPMType,"|",3)),
                            "iConvFunction":($Piece(tPMType,"|",4)),
                            "oConvFunction":($Piece(tPMType,"|",5)),
                            "complexType":((tXmlAdaptor=1)&&(tParamType'="apiPub.service.message")),
                            "outputOnly":(tParamInOut="*"),
                            "byRef":(tParamInOut="&"),
                            "params":(tParamAtts),
                            "outputType":(tParamOutput),
                            "inputType":(tParamInput)
                        }
                        If tParamDefault'="","string boolean number"[$Piece(tPMType,"|",2) {
                            Do tParamObj.%Set("paramDefault",$Replace(tParamDefault,"""",""),$Piece(tPMType,"|",2))
                        }
                        If tParamInput'="",tParamInput'="header" Do pJSON.%Set("requestContentType",tParamInput)
                        If tParamOutput'="",tParamOutput'="header" Do pJSON.%Set("responseContentType",tParamOutput)
                        If (tParamType="%Library.DynamicObject")||(tParamType="%Library.DynamicArray") Do tParamObj.%Set("complexType",1)
                        Set tElType = $Tr($Piece($Piece(tParamAtts,"ELEMENTTYPE=",2),",",1),"""","")
                        If tApiPubParams.%Get("params")'="" {
                            Set tSchema = ..g(tApiPubParams,"params."_tParam_".schema",".")
                            Set tParse = ..g(tApiPubParams,"params."_tParam_".parse",".")
                            If $ZConvert(tParse,"L")="false" Set tParse = 0
                            If tSchema'="" Set tComplexSchema=1
                            If $IsObject(tSchema),tSchema.%Get("items")'="" Set tComplexSchema=0
                            If (tParamObj.%Get("complexType")) {
                                If $IsObject(tXDataJSON),'$IsObject(tSchema),tXDataJSON.%Get("schemas")'="" {
                                    If tXDataJSON.%Get("schemas").%Get(tSchema)'="" {
                                        Do tParamObj.%Set("customSchemaName",tSchema)
                                        Do tParamObj.%Set("parse",tParse)
                                    }
                                } ElseIf $IsObject(tSchema),tSchema.%Size()=1 {
                                    Do tParamObj.%Set("customSchema",##class(%Library.DynamicObject).%New().%FromJSON(tSchema.%ToJSON()))
                                    Set prop = tSchema.%GetIterator()
                                    Do prop.%GetNext(.tKey,.tValue)
                                    Do tParamObj.%Set("customSchemaName",tKey)
                                    Do tParamObj.%Set("parse",tParse)
                                }
                                If tParamObj.%Get("customSchemaName")="",tParamType="%Library.DynamicArray",("*&"'[tParamInOut)||(tParamInOut="") {
                                    Do tParamObj.%Set("complexType",0)
                                    Set tElType="%String"
                                }                            
                            }
                        }
                        If tElType'="",tXmlAdaptor=0 {
                            Set tPMType = primitiveTypes.%Get($S($Length(tElType,".")>1:"%",1:"")_$ZConvert($Piece(tElType,".",*),"L"))
                            Do tParamObj.%Set("paramType",tElType_"|"_tParamType)
                            Do tParamObj.%Set("pmJType",$Piece(tPMType,"|",1))
                            Do tParamObj.%Set("pmJDType",$Piece(tPMType,"|",2))
                            Do tParamObj.%Set("pmJDFormat",$Piece(tPMType,"|",3))
                            Do tParamObj.%Set("iConvFunction",$Piece(tPMType,"|",4))
                            Do tParamObj.%Set("oConvFunction",$Piece(tPMType,"|",5))
                            Set tClassDef=##class(%Dictionary.ClassDefinition).%OpenId(tElType)
                            If $IsObject(tClassDef) {
                                Set tSC = ..GetClassDefInfo(tElType,,.tXmlAdaptor)
                                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                                Do tParamObj.%Set("complexType",(tXmlAdaptor=1))
                            }
                        }
                        If (tParamObj.%Get("complexType")),(tParamInOut="*") Do ..s(pJSON,"outputBodyParams[+]",i-1,,pDelim)
                        If (tParamObj.%Get("complexType")),(tParamInOut="&") Do ..s(pJSON,"byRefBodyParams[+]",i-1,,pDelim)
                        If (tParamObj.%Get("complexType")),(tParamInOut="") Do ..s(pJSON,"inputBodyParams[+]",i-1,,pDelim)
                        Do ..s(pJSON,"formalSpec[+]",tParamObj,,pDelim)
                    }
                    //set defaulf values for not defined inputtypes
                    If tCharStreamParams'="" {
                        For i=1:1:$L(tCharStreamParams,",") {
                            Do ..s(pJSON,"formalSpec."_$Piece(tCharStreamParams,",",i)_".inputType",$Select($L(tCharStreamParams,",")=1:"text/html",1:"multipart/form-data"))
                            Do ..s(pJSON,"customParams.params."_..g(pJSON,"formalSpec."_$Piece(tCharStreamParams,",",i)_".param")_".inputType",$Select($L(tCharStreamParams,",")=1:"text/html",1:"multipart/form-data"))
                            Do pJSON.%Set("requestContentType",$Select($L(tCharStreamParams,",")=1:"text/html",1:"multipart/form-data"))
                        }
                    }
                    If tBinaryStreamParams'="" {
                        // different types in the same method
                        If tCharStreamParams'="" Set tBinaryStreamParams=tBinaryStreamParams_","_tCharStreamParams
                        For i=1:1:$L(tBinaryStreamParams,",") {
                            Do ..s(pJSON,"formalSpec."_$Piece(tBinaryStreamParams,",",i)_".inputType","multipart/form-data")
                            Do ..s(pJSON,"customParams.params."_..g(pJSON,"formalSpec."_$Piece(tBinaryStreamParams,",",i)_".param")_".inputType","multipart/form-data")
                            Do pJSON.%Set("requestContentType","multipart/form-data")
                        }
                    }
                    If tMD.ReturnType'="" {
                        Set tType = tMD.ReturnType
                        Set tPMType = primitiveTypes.%Get($S($Length(tType,".")>1:"%",1:"")_$ZConvert($Piece(tType,".",*),"L"))
                        Set tPMClass = tType
                        If $Length(tType,".")=1,$Extract(tType,1,1)="%" Set tPMClass = "%Library."_$Tr($Extract($Piece(tType,".",*),1,*),"%","")
                        If tPMType="",$Length(tType,".")=1,$Extract(tType,1,1)'="%" Set tPMClass = $Piece(tCD.Name,".",1,*-1)_"."_$Tr($Extract($Piece(tType,".",*),1,*),"%","")
                        Set tParams = tMD.ReturnTypeParams
                        Set tXmlAdaptor = 0
                        Set tClassDef=""
                        If tPMType="" Set tClassDef=##class(%Dictionary.ClassDefinition).%OpenId(tPMClass)
                        If $IsObject(tClassDef) {
                            Set tSC = ..GetClassDefInfo(tPMClass,,.tXmlAdaptor)
                            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                        }
                        Set tElType = $Tr($Piece($Piece(tParams,"ELEMENTTYPE=",2),",",1),"""","")
                        If tElType'="",tXmlAdaptor=0 {
                            Set tPMType = primitiveTypes.%Get($S($Length(tElType,".")>1:"%",1:"")_$ZConvert($Piece(tElType,".",*),"L"))
                            Set tPMClass=tElType_"|"_tPMClass
                            Set tClassDef=##class(%Dictionary.ClassDefinition).%OpenId(tElType)
                            If $IsObject(tClassDef) {
                                Set tSC = ..GetClassDefInfo(tElType,,.tXmlAdaptor)
                                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                            }
                        }
                        Set tRetParamObj = {
                            "param":("response"),
                            "paramName":(pResponseObjName),
                            "paramType":(tPMClass),
                            "pmJType":($Piece(tPMType,"|",1)),
                            "pmJDType":($Piece(tPMType,"|",2)),
                            "pmJDFormat":($Piece(tPMType,"|",3)),
                            "iConvFunction":($Piece(tPMType,"|",4)),
                            "oConvFunction":($Piece(tPMType,"|",5)),
                            "complexType":(tXmlAdaptor=1),
                            "outputOnly":1,
                            "byRef":0,
                            "params":(tParams),
                            "outputType":(tResponseContentType)
                        }
                        If tResponseContentType'="",tResponseContentType'="header" Do pJSON.%Set("responseContentType",tResponseContentType)
                        If (tPMClass="%Library.DynamicObject")||(tPMClass="%Library.DynamicArray") Do tRetParamObj.%Set("complexType",1)
                        Do ..s(pJSON,"formalSpec[+]",tRetParamObj,,pDelim)
                        Do ..s(pJSON,"resultParam",pJSON.%Get("formalSpec").%Size()-1,,pDelim)
                        If (tRetParamObj.%Get("complexType")) Do ..s(pJSON,"outputBodyParams[+]",pJSON.%Get("formalSpec").%Size()-1,,pDelim)                    
                        Set tIt = pJSON.%Get("formalSpec").%GetIterator()
                        While tIt.%GetNext(.key,.value) {
                            If key'=pJSON.%Get("resultParam"),(value.%Get("outputOnly")),(value.%Get("complexType")) {
                                If ..find(..g(pJSON,"outputBodyParams"),"value="_key)=-1 Do ..s(pJSON,"outputBodyParams[+]",key,,pDelim)
                            }
                        }
                        If tApiPubParams.%Get("response")'="" {
                            Set tSchema = ..g(tApiPubParams,"response.schema",".")
                            If (tRetParamObj.%Get("complexType")) {
                                If '$IsObject(tSchema),tXDataJSON.%Get("schemas")'="" {
                                    If tXDataJSON.%Get("schemas").%Get(tSchema)'="" {
                                        Do tRetParamObj.%Set("customSchemaName",tSchema)
                                    }
                                } ElseIf $IsObject(tSchema),tSchema.%Size()=1 {
                                    Do tRetParamObj.%Set("customSchema",##class(%Library.DynamicObject).%New().%FromJSON(tSchema.%ToJSON()))
                                    Set prop = tSchema.%GetIterator()
                                    Do prop.%GetNext(.tKey,.tValue)
                                    Do tRetParamObj.%Set("customSchemaName",tKey)
                                }
                            }
                        }
                    } Else {
                        Do ..s(pJSON,"resultParam","",,pDelim)
                    }
                    If tResponseCharSet'="" Do ..s(pJSON,"responseCharset",tResponseCharSet,,pDelim)                 
                } Else {
                    If tCD.Super'="" {
                        For sup=1:1:$l(tCD.Super,",") {  Continue:$p(tCD.Super,",",sup)=""
                            Set tSC = ..GetMethodInfo($Piece(tCD.Super,",",sup)_"||"_$Piece(pMethodKey,"||",2),.pJSON,pParams,pLevel+1,.pSchemas)
                            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                        }
                    }
                }
            }
            If pLevel=0,pJSON.%Size()>0 {
                Do pJSON.%Set("hasComplexParams",0)
                If (pJSON.%Get("inputBodyParams").%Size()>0)||(pJSON.%Get("byRefBodyParams").%Size()>0) {
                    Do pJSON.%Set("hasComplexParams",1)
                }
                Set tVerb=$ZConvert(pJSON.%Get("customParams").%Get("verb"),"S")
                If tVerb="" Set tVerb=$Select((pJSON.%Get("hasComplexParams"))||(pJSON.%Get("requestContentType")'=""):"Post",1:"Get")
                Do pJSON.%Set("verb",tVerb)

                // Save Cached data
                Set tCachedSpec.DateTimeCtl=tTimeChanged
                Do pJSON.%ToJSON(tCachedSpec.Content)
                Set tSC = tCachedSpec.%Save()
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}

                // Save Cached schemas
                Set tCachedSchemas.DateTimeCtl=tTimeChanged
                Do pSchemas.%ToJSON(tCachedSchemas.Content)
                Set tSC = tCachedSchemas.%Save()
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }
        } Else {
            //Get cached data
            Set pJSON = ##class(%Library.DynamicObject).%New().%FromJSON(tCachedSpec.Content)
            Set pSchemas = ##class(%Library.DynamicObject).%New().%FromJSON(tCachedSchemas.Content)
        }
        If pLevel=0,pJSON.%Size()>0,pPrintResults {
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

ClassMethod IsSubClassOf(aClassName As %String = "", superClass As %String = "") As %Boolean
{
    Set classDefinition=##class(%Dictionary.ClassDefinition).%OpenId(aClassName)
    If ($isobject(classDefinition)) {
        If classDefinition.Super'="" {
            If classDefinition.Super[superClass Return 1
            for sup=1:1:$l(classDefinition.Super,",") {  continue:$p(classDefinition.Super,",",sup)=""
                Set tSuper = $p(classDefinition.Super,",",sup)
                If $Find(tSuper,"%")=0,$Length(tSuper,".")=1,$Length(aClassName,".")>1 {
                    Set tSuper = $Piece(aClassName,".",1,*-1)_"."_tSuper
                }
                If ..IsSubClassOf(tSuper, superClass) Return 1
            }
        }
    }
    Quit 0
}

ClassMethod GetClassDefInfo(aClassName As %String = "", ByRef timeChanged, Output isXMLAdaptor, Output isBusinessService, level = 0) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        If level=0 {
            Set (isXMLAdaptor,isBusinessService)=0
        }
        set classDefinition=##class(%Dictionary.ClassDefinition).%OpenId(aClassName)
        if ($isobject(classDefinition)) {
            If '$Data(timeChanged) Set timeChanged = +$TR($ZDatetime(classDefinition.TimeChanged,8,9)," :","")
            If +$TR($ZDatetime(classDefinition.TimeChanged,8,9)," :","")>timeChanged Set timeChanged=+$TR($ZDatetime(classDefinition.TimeChanged,8,9)," :","")
            if classDefinition.Super'="" {
                If isXMLAdaptor=0,classDefinition.Super["XML.Adaptor" Set isXMLAdaptor=1
                If isBusinessService=0,classDefinition.Super["Ens.BusinessService" Set isBusinessService=1
                for sup=1:1:$l(classDefinition.Super,",") {  continue:$p(classDefinition.Super,",",sup)=""
                    Set tSuper = $p(classDefinition.Super,",",sup)
                    If $Find(tSuper,"%")=0,$Length(tSuper,".")=1,$Length(aClassName,".")>1 {
                        Set tSuper = $Piece(aClassName,".",1,*-1)_"."_tSuper
                    }
                    Set tSC = ..GetClassDefInfo(tSuper,.timeChanged,.isXMLAdaptor,.isBusinessService,level+1)
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

ClassMethod NodesFromXSD(pClassName As %String, Output pXSDInfo As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
    Set tSC = $System.Status.OK()
    Try
    {
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^")
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:0)
        Set pCharsKey = $Select(pParams.charsKey'="":pParams.charsKey,1:"$value")
        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"", "parentType":"", "level":0, "circRefCtrl":{},"originalJSON":{},"mapTypes":{},"json":{}}
        Set pLevel = pInternal.level
        Set pJSON = pInternal.json
        Set pParentKey = pInternal.parentKey
        Set pParentType = pInternal.parentType
        Set pCircRefCtrl = pInternal.circRefCtrl
        Set pOriginalJSON = pInternal.originalJSON
        Set pMapTypes = pInternal.mapTypes
        If pParentType="" {
            Set tSC = ..ClassNameToXSD(pClassName,.pJSON,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set pXSDInfo = {"types":{},"list":{},"circularRef":{}}
            Set tMapTypes = ##class(apiPub.core.typeMapper).GetXSDMapTypes()
            If pJSON.%Size()>0{
                Set prop = pJSON.%GetIterator()
                While prop.%GetNext(.key,.value) {
                    If $IsObject(value),value.%Get("proc")="",key'["ArrayOf" {
                        Do ..NodesFromXSD(pClassName,.pXSDInfo,pParams,{"parentKey":(key),"parentType":(key),"level":(1),"circRefCtrl":(pCircRefCtrl),"originalJSON":(pJSON),"mapTypes":(tMapTypes),"json":(value)})
                    }
               }
            }
            If pPrintResults  {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pXSDInfo.%ToJSON(),.jsonString)
                Write jsonString,!
            }
        } Else {
            //Treat Inheritance
            If pJSON.%Get("basedOn")'="",$IsObject(pOriginalJSON.%Get(pJSON.%Get("basedOn"))) {
                Set tSC = ..NodesFromXSD(pClassName,.pXSDInfo,pParams,{"parentKey":(pParentKey),"parentType":(pParentType),"level":(pLevel),"circRefCtrl":(pCircRefCtrl),"originalJSON":(pOriginalJSON),"mapTypes":(pMapTypes),"json":(pOriginalJSON.%Get(pJSON.%Get("basedOn")))})
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }
            //Correct Auto-Reference Limitation
            Do pCircRefCtrl.%Set(pParentType_pDelim_pParentType,pParentKey)
            Set tParentCircRefCtrl = ##class(%Library.DynamicObject).%New().%FromJSON(pCircRefCtrl.%ToJSON())
            Set prop = pJSON.%GetIterator()
            While prop.%GetNext(.key,.value) {
                If $IsObject(value) {
                    //Set As Processed Obj
                    Do value.%Set("proc",1)
                    Set tType = value.%Get("type")
                    Set tObjType = pOriginalJSON.%Get(tType)
                    Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$Select(key'="":key, 1:"")
                    Set tIsArrayType = value.%Get("maxOccurs")="unbounded"
                    If $IsObject(tObjType) {
                        //Set As Processed Obj
                        Do tObjType.%Set("proc",1)
                        If 'tIsArrayType Set tIsArrayType = tObjType.%Get("maxOccurs")="unbounded"
                        //Check If Its An Object Array (wrapped object)
                        Set tCircKey = tParentCircRefCtrl.%Get(pParentType_pDelim_$Select((tIsArrayType):"ArrOf",1:"")_tType)
                        If (tCircKey="")||(tKey'[tCircKey),$IsObject(tObjType) Do pCircRefCtrl.%Set(pParentType_pDelim_$Select((tIsArrayType):"ArrOf",1:"")_tType,tKey)
                        If (tIsArrayType) Do ..s(pXSDInfo,"list."_tKey,1,,".")  
                        If (tCircKey="")||(tKey'[tCircKey) {
                            If $IsObject(tObjType),tObjType.%Get("type")="" {
                                Do ..NodesFromXSD(pClassName,.pXSDInfo,pParams,{"parentKey":(tKey), "parentType":(tType),"level":(pLevel+1),"circRefCtrl":(pCircRefCtrl),"originalJSON":(pOriginalJSON),"mapTypes":(pMapTypes),"json":(tObjType)})
                            } Else {
                                Set tJSONType = $Piece(pMapTypes.%Get($ZConvert(value.%Get("type"),"L")),"|",1)
                                If tJSONType="" Set tJSONType="string"
                                If "boolean number"[tJSONType Do ..s(pXSDInfo,"types."_tKey,tJSONType,,".")  
                            }
                        } Else {
                            If tKey[tCircKey Do ..s(pXSDInfo,"circularRef."_tKey,tCircKey,,".")
                        }
                    } Else {
                        If (tIsArrayType) Do ..s(pXSDInfo,"list."_tKey,1,,".")  
                        Set tJSONType = $Piece(pMapTypes.%Get($ZConvert(value.%Get("type"),"L")),"|",1)
                        If tJSONType="" Set tJSONType="string"
                        If "boolean number"[tJSONType Do ..s(pXSDInfo,"types."_tKey,tJSONType,,".")  
                    }
                } Else {
                    // treat baseOn types
                    // $TR(pCharsKey,"$#@","") to avoid conflict with classes that has value property
                    Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$TR(pCharsKey,"$#@","")
                    Set tJSONType = $Piece(pMapTypes.%Get($ZConvert($Piece(value,":",2),"L")),"|",1)
                    If tJSONType="" Set tJSONType="string"
                    If "boolean number"[tJSONType {
                        Do ..s(pXSDInfo,"types."_tKey,tJSONType,,".")  
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

ClassMethod GetCachedCustomPaths(pClassName As %String, Output pJSON As %Library.DynamicObject) As %Status
{
    Set tSC = $System.Status.OK()
    Try {
        //Get Last Class Modification Date
        Set tSC = ..GetClassDefInfo(pClassName,.tTimeChanged)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tCachedRoutes=##class(apiPub.service.cache).CacheIdxOpen(pClassName_"||rt")
        If '$IsObject(tCachedRoutes) {
            Set tCachedRoutes=##class(apiPub.service.cache).%New()
            Set tCachedRoutes.Key = pClassName_"||rt"
        }
        If (tCachedRoutes.DateTimeCtl="")||(tCachedRoutes.DateTimeCtl'=tTimeChanged) {
            Set tSC = ..GetCustomPaths(pClassName,.pJSON,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tCachedRoutes.DateTimeCtl=tTimeChanged
            Do pJSON.%ToJSON(tCachedRoutes.Content)
            Set tSC = tCachedRoutes.%Save()
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        } Else {
            Set pJSON = ##class(%Library.DynamicObject).%New().%FromJSON(tCachedRoutes.Content)
        }
    }
    Catch(e) {
        Set tSC = e.AsStatus()
    }
    Quit tSC
}

ClassMethod ClassNameToXSDInfo(pClassName As %String, Output pXSDInfo As %Library.DynamicObject, pParams As %Library.DynamicObject) As %Status
{
    Set tSC = $System.Status.OK()
    Try
	{
        If '$Data(pParams) Set pParams={}
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pUseCacheDefinition = $Select(pParams.useCacheDefinition'="":pParams.useCacheDefinition,1:1)
        //Get Last Class Modification Date
        Set tSC = ..GetClassDefInfo(pClassName,.tTimeChanged)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        //Cached XSD Definitions 
        Set tCachedXsd=##class(apiPub.service.cache).CacheIdxOpen(pClassName_"||nd")
        If '$IsObject(tCachedXsd) {
            Set tCachedXsd=##class(apiPub.service.cache).%New()
            Set tCachedXsd.Key = pClassName_"||nd"
        }
        If (tCachedXsd.DateTimeCtl="")||(tCachedXsd.DateTimeCtl'=tTimeChanged) {
            Set tSC = ..NodesFromXSD(pClassName,.pXSDInfo,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tCachedXsd.DateTimeCtl=tTimeChanged
            Do pXSDInfo.%ToJSON(tCachedXsd.Content)
            Set tSC = tCachedXsd.%Save()
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        } Else {
            Set pXSDInfo = ##class(%Library.DynamicObject).%New().%FromJSON(tCachedXsd.Content)
        }
        If pPrintResults {
            Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
            Do tFormatter.FormatToString(pXSDInfo.%ToJSON(),.jsonString)
            Write jsonString,!
        }
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod ClassNameToXSD(pClassName As %String, Output pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject) As %Status
{
    Set tSC = $System.Status.OK()
    Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pPrintSchema = $Select(pParams.printSchema'="":pParams.printSchema,1:0)
        Set tSw=##class(%XML.Schema).%New()
        Set tSC=tSw.AddSchemaType(pClassName)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tSchema=tSw.GetSchema("")
        Set tWt=##class(%XML.Writer).%New()
        Set tWt.Indent=1
        Do tWt.OutputToStream(.tXSD)
        Do tWt.DocumentNode(tSchema)
        If pPrintSchema {
            If $IsObject(tXSD),tXSD.SizeGet()>0{
                Do tXSD.Rewind()
                While (tXSD.AtEnd=0) {
                    Write (tXSD.Read())
                }
            }
        }   
        Set tSC = ..XSDToJSON(tXSD,.pJSON,pParams)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod XSDToJSON(pXmlStream As %AbstractStream, Output pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject, ByRef pNode As %XML.Node) As %Status
{
    Set tSC = $System.Status.OK()
    Try
    {
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^")
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"","extensionMap":[],"level":-1,"xmlJSON":{}}
        Set pParentKey = pInternal.parentKey
        Set pExtensionMap = pInternal.extensionMap
        Set pLevel = pInternal.level
        Set pBuild = pInternal.build
        Set pXMLJSON = pInternal.xmlJSON
        If pLevel=-1 {
            Set pInternal.level = 0
            Set tSC = ##class(%XML.Document).GetDocumentFromStream(pXmlStream,.pXMLDoc)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

            Set pInternal={"parentKey":"","extensionMap":[],"level":0,"xmlJSON":{}}
            Set pNode = pXMLDoc.GetDocumentElement()
            Set tSC = ..XSDToJSON(pXmlStream,.pJSON,pParams,pInternal,pNode)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

            Set pJSON = pInternal.xmlJSON
            If (pPrintResults) {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pJSON.%ToJSON(),.jsonString)
                Write jsonString
            }
        } Else {
            Set tIdx=""
            Set key = pNode.NodeData
            Do {
                If pNode.NodeType = 0 {
                    Set key = pNode.QName
                    Set tText=""
                    Set status = pNode.GetText(.tText)
                    If 'status Set tText = ""
                    Set tAttCount=pNode.GetNumberAttributes()
                    Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$Select((key'=""):key, 1:"")
                    Set tLineKey = $Replace($Replace($Replace($Replace($Replace($Replace($Replace($Replace($Replace(tKey,"^element",""),"^attribute",""),"^sequence",""),"^complexContent",""),"^simpleContent",""),"^extension",""),"^annotation",""),"^simpleType",""),"^restriction","")
                    If key="documentation" {
                        If $Length(tLineKey,pDelim)>2 {
                            If $Find(tText,"@apiPub")>0 {
                                Set tSC=..GetMethodParams("@apiPub",tText,.tApiPubParams,.tMethodDesc)
                                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                                Set tText=tMethodDesc
                                Set tCPar = tApiPubParams.%GetIterator()
                                While tCPar.%GetNext(.cpkey,.cpvalue) {
                                    Do ..s(pInternal.xmlJSON,$Piece(tLineKey,pDelim,1,*-1)_pDelim_cpkey,cpvalue,,pDelim)
                                }
                            }
                            Set tSC = ..s(pInternal.xmlJSON,tLineKey,tText,,pDelim)
                        }
                    }
                    If tAttCount>0 {
                        Set tMetaKey = ""
                        Set tAtt=pNode.FirstAttributeName()
                        While tAtt'="" {
                            Set tValue = pNode.GetAttributeValue(tAtt)
                            If pLevel = 1,tAtt="name" {
                                Set tKey = tValue
                            }
                            If key="extension",tAtt="base" {
                                Set tSC = ..s(pInternal.xmlJSON,tLineKey_pDelim_"basedOn",tValue,,pDelim)
                            }
                            If key="restriction",tAtt="base" {
                                Set tSC = ..s(pInternal.xmlJSON,tLineKey_pDelim_"type",$Piece(tValue,":",*),,pDelim)
                                Set tSC = ..s(pInternal.xmlJSON,tLineKey_pDelim_"restriction",1,,pDelim)
                            }
                            If "maxLength minLength"[key,tAtt="value" {
                                If $Length(tLineKey,pDelim)>1 {
                                    Set tSC = ..s(pInternal.xmlJSON,tLineKey,tValue,,pDelim)
                                }
                            }
                            If key="enumeration",tAtt="value" {
                                If $Length(tLineKey,pDelim)>1 {
                                    Set tSC = ..s(pInternal.xmlJSON,tLineKey_pDelim_"+",tValue,,pDelim)
                                }
                            }
                            If pLevel > 1,tAtt="name" {
                                Set tMetaKey = $Replace($Replace($Replace($Replace($Replace($Replace(tKey,"^element",""),"^attribute",""),"^sequence",""),"^complexContent",""),"^simpleContent",""),"^extension","")_pDelim_tValue
                                Set tKey = tKey_pDelim_tValue
                            }
                            Set tAtt=pNode.NextAttributeName(tAtt)
                        }
                        Set tAtt=pNode.FirstAttributeName()
                        While tAtt'="" {
                            If tAtt'="name" {
                                Set tValue = pNode.GetAttributeValue(tAtt)
                                If tMetaKey'="" {
                                    Set tSC = ..s(pInternal.xmlJSON,tMetaKey_pDelim_tAtt,$Piece(tValue,":",*),,pDelim)
                                    If tAtt = "type",$find(tValue,":")>0 {
                                        If tKey["^attribute^" Set tSC = ..s(pInternal.xmlJSON,tMetaKey_pDelim_"attribute",1,"boolean",pDelim)
                                        Set tSC = ..s(pInternal.xmlJSON,tMetaKey_pDelim_"namespace",$Piece(tValue,":",1),,pDelim)
                                    }
                                }    
                            }
                            Set tAtt=pNode.NextAttributeName(tAtt)
                        }
                    }  
                    If pNode.HasChildNodes() {
                        Set tNodeId = pNode.NodeId
                        Do pNode.MoveToFirstChild(1)
                        If pNode.NodeId'=tNodeId {
                            Do ..XSDToJSON(pXmlStream,.pJSON,pParams,{"parentKey":(tKey),"extensionMap":(pExtensionMap),"level":(pLevel+1),"xmlJSON":(pInternal.xmlJSON)}, pNode)
                            Do pNode.MoveToParent(1)
                        }
                    }
                }
            } While (pNode.MoveToNextSibling(1))
        }
    }
    Catch(e)
    {
        Set tSC = e.AsStatus()
    }
    Quit tSC
}

}

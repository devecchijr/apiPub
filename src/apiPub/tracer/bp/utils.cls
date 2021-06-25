Class apiPub.tracer.bp.utils Extends apiPub.core.jsonBuilder
{

// Utility methods to use inside bpl for json manipulation 

Method Get(pObj As %Library.DynamicObject, pKey As %String, pDelim As %String = ".") As %Library.DynamicObject
{
    Quit ..GetByLineKey(pObj, pKey, pDelim)
}

Method Set(pObj As %Library.DynamicObject, pKey As %String, pValue As %Library.DynamicObject, pType As %String = "", pDelim As %String = ".", pInferBoolean As %Boolean = 1) As %Status
{
    Quit ..SetByLineKey(pObj, pKey, pValue, pType)
}

Method GetNextJSONObj(pJSON As %Library.DynamicObject, pKey As %String, ByRef pCtrlObj As %Library.DynamicObject, ByRef pOutputObj As %Library.DynamicObject, pDelim As %String = ".") As %Boolean
{
        If '$Data(pCtrlObj) Set pCtrlObj = {}
        If '$Data(pOutputObj) Set pOutputObj = {}
        If (..Get(pCtrlObj,pKey_pDelim_"index")="")||(..Get(pCtrlObj,pKey_pDelim_"index")<0) {
            Do ..Set(pCtrlObj,pKey_pDelim_"index",0)
        } Else {
            Do ..Set(pCtrlObj,pKey_pDelim_"index",..Get(pCtrlObj,pKey_pDelim_"index")+1)
        } 
        If pKey="" {
            Set tArray=pJSON
        } Else {
            Set tArray = ..Get(pJSON, pKey, pDelim)
        }
        Set tQuit = 0
        If $CLASSNAME(tArray)'="%Library.DynamicArray" {
            Set tQuit = 1
        } ElseIf (..Get(pCtrlObj,pKey_pDelim_"index")+1)>tArray.%Size()
        { 
            Set tQuit = 1
        } 
        Set tRef=..Get(tArray,..Get(pCtrlObj,pKey_pDelim_"index"))        
        If (tQuit)||'$Data(tRef) {
            Set pOutputObj={}
            Do ..Set(pCtrlObj,pKey_pDelim_"index",-1)
            Do ..Set(pCtrlObj,pKey_pDelim_"obj",{})
            Quit 0
        }
        Set tRef=..Get(tArray,..Get(pCtrlObj,pKey_pDelim_"index"))
        Do ..Set(pCtrlObj,pKey_pDelim_"obj",tRef)
        While (pOutputObj.%Size()>0) {
            Set prop = pOutputObj.%GetIterator()
            Do prop.%GetNext(.key,.value)
            Do pOutputObj.%Remove(key)
        }
        Set prop = tRef.%GetIterator()
        While (prop.%GetNext(.key,.value)) {
            Do pOutputObj.%Set(key,value)
        }
        Quit 1
}

/// Automate BPL Generation based on JSON complex object
/// example: Do ##class(apiPub.tracer.bp.utils).GetBPLFromJSONObj(##class(JSON.Utils).GetSDA(),"GetSDA","Custom.MyBPLClass")
ClassMethod GetBPLFromJSONObj(pJSON As %Library.DynamicObject, pOperationId As %String = "OperationId", pBPLClassName As %String = "apiPub.tracer.bp") As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
            Set tSC = ..GetJSONStruct(pJSON,.tStruct,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            Set fExport = {
                "Export^_generator":($Select(##class(%SYSTEM.Version).GetISCProduct()=3:"IRIS",1:"CACHE")),
                "Export^_version":"26",
                "Export^_zv":($zv),
                "Export^_ts":($zdt($zts, 3,,3)),
                "Export^Class^_name":(pBPLClassName),
                "Export^Class^Description":("automatically generated "_($zdt($zts, 3,,3))),
                "Export^Class^Super":"Ens.BusinessProcessBPL,apiPub.tracer.bp.utils",
                "Export^Class^TimeChanged":($zts),
                "Export^Class^TimeCreated":($zts),
                "Export^Class^Storage^_name":"Default",
                "Export^Class^Storage^Type":"%Storage.Persistent",
                "Export^Class^Storage^Type":"%Storage.Persistent",
                "Export^Class^XData^_name":"BPL",
                "Export^Class^XData^Description":"BPL Definition",
                "Export^Class^XData^XMLNamespace":"http://www.intersystems.com/bpl"
            }
            Set tEncTracing=""
            Set tPropName=""
            Set tSetCtxObj = {}
            //Set header
            Set fbpl = {
            "process^_language": "objectscript",
            "process^_request": "apiPub.service.message",
            "process^_response": "apiPub.service.message"
            }
            Do ..SetByLineKey(fbpl,"process^context^property__0^_instantiate","1")
            Do ..SetByLineKey(fbpl,"process^context^property__0^_name","root")
            Do ..SetByLineKey(fbpl,"process^context^property__0^_type","%Library.DynamicObject")
            Do ..SetByLineKey(fbpl,"process^context^property__1^_instantiate","0")
            Do ..SetByLineKey(fbpl,"process^context^property__1^_name","subject")
            Do ..SetByLineKey(fbpl,"process^context^property__1^_type","%String")
            Do ..SetByLineKey(fbpl,"process^context^property__1^parameters^parameter^_name","MAXLEN")
            Do ..SetByLineKey(fbpl,"process^context^property__1^parameters^parameter^_value","200")
            Do ..SetByLineKey(fbpl,"process^context^property__2^_instantiate","1")
            Do ..SetByLineKey(fbpl,"process^context^property__2^_name","iteratorCtrl")
            Do ..SetByLineKey(fbpl,"process^context^property__2^_type","%Library.DynamicObject")
            Do ..SetByLineKey(fbpl,"process^context^property__3^_instantiate","0")
            Do ..SetByLineKey(fbpl,"process^context^property__3^_name","tSC")
            Do ..SetByLineKey(fbpl,"process^context^property__3^_type","%Status")
            Do ..SetByLineKey(fbpl,"process^context^property__4^_instantiate","1")
            Do ..SetByLineKey(fbpl,"process^context^property__4^_name","calc")
            Do ..SetByLineKey(fbpl,"process^context^property__4^_type","%Library.DynamicObject")
            Do ..SetByLineKey(fbpl,"process^context^property__5^_instantiate","0")
            Do ..SetByLineKey(fbpl,"process^context^property__5^_name","messageName")
            Do ..SetByLineKey(fbpl,"process^context^property__5^_type","%String")
            Do ..SetByLineKey(fbpl,"process^context^property__6^_instantiate","0")
            Do ..SetByLineKey(fbpl,"process^context^property__6^_name","sourceName")
            Do ..SetByLineKey(fbpl,"process^context^property__6^_type","%String")
            Set tContCP=7
			Set prop = tStruct.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                Set tObjName=$ZConvert(..GetByLineKey(value,"objName"),"L")
                If (..GetByLineKey(value,"itType")="begIt")||(..GetByLineKey(value,"itType")="value") {
                    If ..GetByLineKey(value,"itType")="begIt" {
                        If ..GetByLineKey(fbpl,"process^context^property__"_tContCP_"^_name")="",$Get(tPropName(tObjName))'=1 {
                            Set tPropName(tObjName)=1
                            Do ..SetByLineKey(fbpl,"process^context^property__"_tContCP_"^_instantiate","1")
                            Do ..SetByLineKey(fbpl,"process^context^property__"_tContCP_"^_name",tObjName)
                            Do ..SetByLineKey(fbpl,"process^context^property__"_tContCP_"^_type","%Library.DynamicObject")
                        }
                        Set tContCP=tContCP+1
                    }
                }
            }
            Do ..SetByLineKey(fbpl,"process^sequence^call^_async","0")
            Do ..SetByLineKey(fbpl,"process^sequence^call^_name", "call apiPub.tracer.bo")
            Do ..SetByLineKey(fbpl,"process^sequence^call^_target", "apiPub.tracer.bo")
            Do ..SetByLineKey(fbpl,"process^sequence^call^request^_type", "apiPub.service.message")
            Do ..SetByLineKey(fbpl,"process^sequence^call^request^assign^_action", "set")
            Do ..SetByLineKey(fbpl,"process^sequence^call^request^assign^_property", "callrequest")
            Do ..SetByLineKey(fbpl,"process^sequence^call^request^assign^_value", "request")
            Do ..SetByLineKey(fbpl,"process^sequence^call^response^_type", "apiPub.service.message")
            Do ..SetByLineKey(fbpl,"process^sequence^call^response^assign^_action", "set")
            Do ..SetByLineKey(fbpl,"process^sequence^call^response^assign^_property", "response")
            Do ..SetByLineKey(fbpl,"process^sequence^call^response^assign^_value", "callresponse")
            Do ..SetByLineKey(fbpl,"process^sequence^if^_condition", "($ZConvert(response.ContentType,""L"")[""json"")&&(response.Body.SizeGet()>0)")
            Do ..SetByLineKey(fbpl,"process^sequence^if^_name", "ContentType=""json""")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^assign^_action","set")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^assign^_name","root=response.Body")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^assign^_property", "context.root")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^assign^_value","{}.%FromJSON(response.Body)")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^_condition","response.APIOperationId="""_pOperationId_"""")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^_name", pOperationId_" API")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^_name",pOperationId)
            
            Do ..SetByLineKey(fExport,"Export^Class^Parameter^_name","SETTINGS")
            Do ..SetByLineKey(fExport,"Export^Class^Parameter^Type","%String")
            Do ..SetByLineKey(fExport,"Export^Class^Property__0^_name","preProcessBusinessRule")
            Do ..SetByLineKey(fExport,"Export^Class^Property__0^Type","%String")
            Do ..SetByLineKey(fExport,"Export^Class^Property__1^_name","rootTracing")
            Do ..SetByLineKey(fExport,"Export^Class^Property__1^Type","%Boolean")
            Do ..SetByLineKey(fExport,"Export^Class^Parameter^Default","rootTracing:Basic,")
            Set tParent="process^sequence^if^true^if^true^sequence"
            Set tValue="""root""_$Char(10)_""------------------------------------------------------------------------------------------------""_$Char(10)"
            Set iprop = tStruct.%GetIterator()
            While (iprop.%GetNext(.ikey,.ivalue)) {
                If ..GetByLineKey(ivalue,"itType")="value",..GetByLineKey(ivalue,"objName")="Root" {
                    Set tObjName=$ZConvert(..GetByLineKey(ivalue,"objName"),"L")
                    If ..GetByLineKey(ivalue,"key")'="" {
                        Set tValue=tValue_$Select(tValue'="":"_",1:"")_""""_..GetByLineKey(ivalue,"key")_": """
                        Set tValue=tValue_"_process.Get(context."_tObjName_","""_..GetByLineKey(ivalue,"key")_""")_$char(10)"
                    }
                }
            }
            If $LENGTH(tValue)>0 {
                Do ..SetByLineKey(fbpl,tParent_"^if^_condition","(process.rootTracing)") 
                Do ..SetByLineKey(fbpl,tParent_"^if^_name","trace is on?") 
                Do ..SetByLineKey(fbpl,tParent_"^if^annotation","check if rootTracing parameter is on")
                Do ..SetByLineKey(fbpl,tParent_"^if^true^trace^_name","trace root")
                Do ..SetByLineKey(fbpl,tParent_"^if^true^trace^annotation","trace all root properties")
                Do ..SetByLineKey(fbpl,tParent_"^if^true^trace^_value",tValue)
            }
            Set tParams=..GetByLineKey(fExport,"Export^Class^Parameter^Default")
            Do ..SetByLineKey(fExport,"Export^Class^Parameter^Default",tParams_"preProcessBusinessRule:Basic:ruleSelector,")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^_condition","process.preProcessBusinessRule'=""""")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^_name","rule defined?")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^annotation","rule defined for pre processing?")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^true^assign^_name","set subject")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^true^assign^_property","context.subject")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^true^assign^_value","""preProcessing""")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^true^assign^_action","set")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^true^assign^annotation","subject = ""preProcessing""")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^true^rule^_name","rule for pre processing")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^true^rule^_rule","@process.preProcessBusinessRule")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^true^rule^_ruleContext","context")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__1^true^rule^annotation","call rule for pre processing with all of the context properties")
            k tContSeq
            k tVerifProp
            Set tContProp=3
            Set tLine=tParent
			Set prop = tStruct.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                If ..GetByLineKey(value,"itType")="begIt" {
                    Set tLine = tParent
                    If '$Data(tContSeq(..GetByLineKey(value,"level"))) {
                        Set tContSeq(..GetByLineKey(value,"level"))=1
                    } Else {
                        Set tContSeq(..GetByLineKey(value,"level"))=tContSeq(..GetByLineKey(value,"level"))+1
                    }
                    For i=1:1:..GetByLineKey(value,"level") {
                         Set tLine=tLine_"^while__"_tContSeq(i)
                    }
                    Set tObjName=$ZConvert(..GetByLineKey(value,"objName"),"L")
                    Set tParentObjName=$ZConvert(..GetByLineKey(value,"parentObjName"),"L")
                    If '$Data(tVerifProp(tObjName)) {
                        Set tVerifProp(tObjName)=1
                        Do ..SetByLineKey(fExport,"Export^Class^Property__1"_tContProp_"^_name",tObjName_"BusinessRule")
                        Do ..SetByLineKey(fExport,"Export^Class^Property__1"_tContProp_"^Type","%String")
                        Do ..SetByLineKey(fExport,"Export^Class^Property__2"_tContProp_"^_name",tObjName_"Tracing")
                        Do ..SetByLineKey(fExport,"Export^Class^Property__2"_tContProp_"^Type","%Boolean")
                    }
                    Set tContProp=tContProp+1
                    Set tParams=..GetByLineKey(fExport,"Export^Class^Parameter^Default")
                    Do ..SetByLineKey(fExport,"Export^Class^Parameter^Default",tParams_tObjName_"BusinessRule:Basic:ruleSelector,"_tObjName_"Tracing:Basic,")
                    Do ..SetByLineKey(fbpl,tLine_"^_name","ForEach("_tObjName_")")
                    Do ..SetByLineKey(fbpl,tLine_"^annotation","iterate through "_tObjName_" array")
                    Do ..SetByLineKey(fbpl,tLine_"^_condition","process.GetNextJSONObj(context."_tParentObjName_","""_..GetByLineKey(value,"key")_""",context.iteratorCtrl,context."_tObjName_")")
                    Set tValue=""
                    Set tValue=""""_tObjName_"[""_process.Get(context.iteratorCtrl,"""_..GetByLineKey(value,"key")_".index"")_""]""_$Char(10)_""------------------------------------------------------------------------------------------------""_$Char(10)"
                    Set iprop = tStruct.%GetIterator()
                    Set tEncNumberExists=0
                    Set tSeqContext=2
                    While (iprop.%GetNext(.ikey,.ivalue)) {
                        Set tiObjName=$ZConvert(..GetByLineKey(ivalue,"objName"),"L")
                        If ..GetByLineKey(ivalue,"itType")="value",..GetByLineKey(value,"uKey")=$Piece(..GetByLineKey(ivalue,"uKey"),".@"_..GetByLineKey(ivalue,"objName")_"@",1) {
                           If ..GetByLineKey(ivalue,"key")'="" {
                                If (..GetByLineKey(ivalue,"key")["EncounterNumber") Set tEncNumberExists=1
                                Set tValue=tValue_$Select(tValue'="":"_",1:"")_""""_..GetByLineKey(ivalue,"key")_": """
                                Set tValue=tValue_"_process.Get(context."_tiObjName_","""_..GetByLineKey(ivalue,"key")_""")_$char(10)"
                           }
                        }
                    }
                    If tObjName="encounter" Set tEncTracing = tValue
                    If $LENGTH(tValue)>0 {
                        If (tEncNumberExists),tObjName'="encounter" {
                            Set tValue = tValue_"_$char(10)_"_$Replace(tEncTracing,"[""_context.encounter.index_""]","")
                        }
                        Do ..SetByLineKey(fbpl,tLine_"^if__0^_condition","(process."_tObjName_"Tracing)")
                        Do ..SetByLineKey(fbpl,tLine_"^if__0^annotation","check if "_tObjName_"Tracing parameter is on")
                        Do ..SetByLineKey(fbpl,tLine_"^if__0^_name","trace is on?")
                        Do ..SetByLineKey(fbpl,tLine_"^if__0^true^trace^_name",tObjName)
                        Do ..SetByLineKey(fbpl,tLine_"^if__0^true^trace^_value","""trace "_tObjName_"""")
                        Do ..SetByLineKey(fbpl,tLine_"^if__0^true^trace^_value",tValue)
                        Do ..SetByLineKey(fbpl,tLine_"^if__0^true^trace^annotation","trace all "_tObjName_" properties if necessary")
                    }
                    Do ..SetByLineKey(fbpl,tLine_"^if__1^_condition","process."_tObjName_"BusinessRule'=""""")
                    Do ..SetByLineKey(fbpl,tLine_"^if__1^_name","rule defined?")
                    Do ..SetByLineKey(fbpl,tLine_"^if__1^true^assign^_name","set subject")
                    Do ..SetByLineKey(fbpl,tLine_"^if__1^true^assign^_property","context.subject")
                    Do ..SetByLineKey(fbpl,tLine_"^if__1^true^assign^_value",""""_tObjName_"""")
                    Do ..SetByLineKey(fbpl,tLine_"^if__1^true^assign^_action","set")
                    Do ..SetByLineKey(fbpl,tLine_"^if__1^true^assign^annotation","subject = """_tObjName_"""")
                    Do ..SetByLineKey(fbpl,tLine_"^if__1^true^rule^_name","rule for "_tObjName)
                    Do ..SetByLineKey(fbpl,tLine_"^if__1^true^rule^_rule","@process."_tObjName_"BusinessRule")
                    Do ..SetByLineKey(fbpl,tLine_"^if__1^true^rule^_ruleContext","context")
                    Do ..SetByLineKey(fbpl,tLine_"^if__1^true^rule^annotation","call rule for "_tObjName_" with all of the context properties")
                }
            }
            Do ..SetByLineKey(fExport,"Export^Class^Property__1"_(tContProp+1)_"^_name","postProcessBusinessRule")
            Do ..SetByLineKey(fExport,"Export^Class^Property__1"_(tContProp+1)_"^Type","%String")
            Set tParams=..GetByLineKey(fExport,"Export^Class^Parameter^Default")
            Do ..SetByLineKey(fExport,"Export^Class^Parameter^Default",tParams_"postProcessBusinessRule:Basic:ruleSelector,")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^_condition","process.postProcessBusinessRule'=""""")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^_name","rule defined?")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^annotation","rule defined for post post processing?")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^true^assign^_name","set subject")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^true^assign^_property","context.subject")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^true^assign^_value","""postProcessing""")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^true^assign^_action","set")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^true^assign^annotation","subject = ""postProcessing""")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^true^rule^_name","rule for postProcess")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^true^rule^_rule","@process.postProcessBusinessRule")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^true^rule^_ruleContext","context")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^if__2^true^rule^annotation","call rule for post processing with all of the context properties")
            Set tCode = " Set tFormatter=##class(%JSON.Formatter).%New()"_$char(10)_
            " Do tFormatter.FormatToStream(context.root,response.Body)"
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^code^_name","format response")
            Do ..SetByLineKey(fbpl,"process^sequence^if^true^if^true^sequence^code^value",tCode)
            //Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
            //Do tFormatter.FormatToString(fbpl.%ToJSON(),.jsonString)
            //Write jsonString
            Set tSC = ##class(apiPub.core.converter).JSONFromFlatJSON(fbpl,.bpl,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tSC = ##class(apiPub.core.converter).JSONToXML(bpl,.tXml,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tStrContent=""
            Do tXml.Rewind()
            While (tXml.AtEnd=0) {
                Set tStrContent = tStrContent_tXml.Read()
            }
            Do ..SetByLineKey(fExport,"Export^Class^XData^Data",tStrContent)
            Set tSC = ##class(apiPub.core.converter).JSONFromFlatJSON(fExport,.export,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tSC = ##class(apiPub.core.converter).JSONToXML(export,.tXml,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tFileName="bplExport"_$TR($zts,".,","")_".xml"  
            Set tSC = ..SaveStreamToFile(tXml,tFileName)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tSC = $System.OBJ.Load(tFileName,"ck")
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Do ##class(%File).Delete(tFileName, .scRet)
	}
	Catch(e)
	{
		Write $System.Status.DisplayError(e.AsStatus())
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

/// Get the structure metadata based on a json instance 
ClassMethod GetJSONStruct(pJSON As %Library.DynamicObject, Output pOutput As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pKeyDelimiter = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:".") 
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)

        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"", "oParentKey":"","parentName":"","parentType":"","arrayLevel":1,"parentIdx":"","ctr":{}}
        Set pParentKey = pInternal.parentKey
        Set pOParentKey = pInternal.oParentKey
        Set pParentType = pInternal.parentType
        Set pParentName = pInternal.parentName
        Set pArrayLevel = pInternal.arrayLevel
        Set pParentIdx = pInternal.parentIdx
        Set pCtr = pInternal.ctr
		If pParentType="" {
			Set pOutput = []
            If $CLASSNAME(pJSON)="%Library.DynamicArray" {
                Do pOutput.%Push({"uKey":"array","parentObjName":"Root","objName":"Array","key":"","level":1,"itType":"begIt"})
			    Do ..GetJSONStruct(pJSON,.pOutput,pParams,{"parentKey":"array","oParentKey":"array","parentName":"@array@","parentType":($Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object")),"arrayLevel":(2),"parentIdx":(pParentIdx),"ctr":(pCtr)})
            } Else {
			    Do ..GetJSONStruct(pJSON,.pOutput,pParams,{"parentKey":"","oParentKey":"","parentName":"","parentType":($Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object")),"arrayLevel":(pArrayLevel),"parentIdx":(pParentIdx),"ctr":(pCtr)})
            }
            If $CLASSNAME(pJSON)="%Library.DynamicArray" {
                Do pOutput.%Push({"uKey":"array","parentObjName":"Root","objName":"Array","key":"","level":1,"itType":"finIt"})
            }
            If pPrintResults {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pOutput.%ToJSON(),.jsonString)
                Write jsonString
            }

		} Else {
			Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                Set vKey = key
                Set oKey = key
                If pParentType="array" {
                    Set oKey="@"_$ZConvert($Piece(pOParentKey,pKeyDelimiter,*),"W")_"@"
                    Set vKey="@"_$ZConvert($Piece(pParentKey,pKeyDelimiter,*),"W")_pParentIdx_"@"
                }
				Set tKey = $Select(pParentKey'="":pParentKey_pKeyDelimiter, 1:"")_$Select(vKey'="":vKey, 1:"")
				Set tOKey = $Select(pOParentKey'="":pOParentKey_pKeyDelimiter, 1:"")_$Select(oKey'="":oKey, 1:"")
                Set tIdx = $Length(pParentKey,pKeyDelimiter_vKey_pKeyDelimiter)
                If tIdx=1 Set tIdx=""
                Set tPrint=0
                If $IsObject(value) {
                    If $CLASSNAME(value)="%Library.DynamicArray" {
                        If pCtr.%Get(tOKey)=""{
                            Set pParentName=$Piece(tKey,"@",*-1)
                            Set pParentIdx = tIdx
                            Set tNodeName = "@"_$ZConvert(vKey,"W")_tIdx_"@"
                            Set tParentName = "@"_$Select(pParentName'="":pParentName,1:"Root")_"@"
                            Set tLine = tKey
                            If $Find(tKey,tParentName)>0 {
                                Set tLine = $Piece(tKey,tParentName_pKeyDelimiter,2)
                            }
                            If $Find(tKey,"@@")=0 Do pOutput.%Push({"uKey":(tKey),"parentObjName":($Translate(tParentName,"@_","")),"objName":($Translate(tNodeName,"@_","")),"key":(tLine),"level":(pArrayLevel),"itType":"begIt"})
                            Set tPrint = 1
                        }
					    Do pCtr.%Set(tOKey,"@array:"_pArrayLevel_vKey)
                    }
                    Do ..GetJSONStruct(value,.pOutput,pParams,{"parentKey":(tKey), "oParentKey":(tOKey),"parentName":(pParentName),"parentType":($Select($ClassName(value)="%Library.DynamicArray":"array",1:"object")),"arrayLevel":(pArrayLevel+$Select($CLASSNAME(value)="%Library.DynamicArray":1,1:0)),"parentIdx":(pParentIdx),"ctr":(pCtr)})
                    If tPrint=1 {
                        If $Find(tKey,"@@")=0 Do pOutput.%Push({"uKey":(tKey),"parentObjName":($Translate(tParentName,"@_","")),"objName":($Translate(tNodeName,"@_","")),"key":(tLine),"level":(pArrayLevel),"itType":"finIt"})
                    }
				} Else {
                    If pCtr.%Get(tOKey)=""{
                        Set tParentName = "@"_$Select(pParentName'="":pParentName,1:"Root")_"@"
                        Set tLine = tKey
                        Set tParent = "Root"
                        If $Find(tKey,"@")>0 {
                            Set tLine = $Piece(tKey,"@"_pKeyDelimiter,*)
                            Set tParent = "@"_$Piece($Piece(tKey,"@"_pKeyDelimiter,*-1),"@",*)_"@"
                        }
                        If $Find(tLine,"@")>0 {
                            If $Find(tKey,"@@")=0 Do pOutput.%Push({"uKey":(tKey),"objName":($Piece(tLine,"@",*-1)),"key":"","level":(pArrayLevel),"itType":"value","type":(pJSON.%GetTypeOf(key))})
                        } Else {
                            If $Find(tKey,"@@")=0 Do pOutput.%Push({"uKey":(tKey),"objName":($Translate(tParent,"@_","")),"key":(tLine),"level":(pArrayLevel),"itType":"value","type":(pJSON.%GetTypeOf(key))})
                        }
                    } 
					Do pCtr.%Set(tOKey,value,pJSON.%GetTypeOf(key))
	 			}
			}
		}
	}
	Catch(e)
	{
		Write $System.Status.DisplayError(e.AsStatus())
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

}

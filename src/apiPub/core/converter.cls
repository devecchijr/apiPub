Class apiPub.core.converter Extends apiPub.core.jsonBuilder
{

ClassMethod JSONToObj(pJSON As %Library.DynamicObject, pClassName As %String, Output pObj) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        //Verify if object needs to be wrapped 
        Set jkey=""
        Set tIt = pJSON.%GetIterator()
        Do tIt.%GetNext(.jkey,.jvalue)
        If jkey'=$Piece(pClassName,".",*) {
            Set tAuxJSON = {}
            Do tAuxJSON.%Set($Piece(pClassName,".",*),pJSON)
            Set pJSON=tAuxJSON
        }    
        Set tSC = ..JSONToXML(pJSON,.tXml,{"printResults":0})
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tSC = ..XMLToObj(tXml,pClassName,.pObj)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Kill tXml
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod XMLToObj(pXmlStream As %AbstractStream, pClassName As %String, Output pObj) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set tClassDefinition=##class(%Dictionary.ClassDefinition).%OpenId(pClassName)
        If ('$Isobject(tClassDefinition)) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid Class Name ("_pClassName_")")
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        }
        Set tReader = ##class(%XML.Reader).%New()
        Set tSC = tReader.OpenStream(pXmlStream)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tReader.CheckRequired = 1
        // Associate a class name with the XML element name
        Do tReader.Correlate($Piece(pClassName,".",*),pClassName)
        // Read object from xml file
        Do tReader.Next(.pObj,.tSC)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        If '$Data(pObj)||'($IsObject(pObj)) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid Inputed Object")
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        }
        Do tReader.Close()
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod ObjToJSON(pObj As %RegisteredObject, Output pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject) As %Status
{
    Set tSC = $System.Status.OK()
    Try
	{
        If '$Data(pParams) Set pParams={}
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pUseCacheDefinition = $Select(pParams.useCacheDefinition'="":pParams.useCacheDefinition,1:1)
        Set pCharset = $Select(pParams.charset'="":pParams.charset,1:"UTF-8")
        Set pUnwappObject = $Select(pParams.unwappObject'="":pParams.unwappObject,1:1)
        If '$Data(pObj)||'($IsObject(pObj)) {
            Set tSC = $$$ERROR($$$GeneralError, "Invalid Object")
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        }
        Set tClassName = pObj.%PackageName()_"."_pObj.%ClassName()
        Set tSC = ##class(apiPub.core.irisMetadata).ClassNameToXSDInfo(tClassName,.tXsdInfo,{"printResults":0})
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tWt=##class(%XML.Writer).%New()
        Set tWt.Indent=1
        Set tWt.Charset=pCharset
        Do tWt.OutputToStream(.tXML)
        Do tWt.RootObject(pObj)
        Set pParams.noNamedRoot = "@null"
        Set pParams.noNamedElement = "@null"
        Set tSC = ..XMLToJSON(tXML,tXsdInfo,.tJson,pParams,)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        //Unwapp
        If (pUnwappObject),tJson.%Size()=1 { 
            Set tIt = tJson.%GetIterator()
            Do tIt.%GetNext(.key,.obj)
            If '$IsObject(obj) Set obj = {}
            Set pJSON=obj
        } Else {
            Set pJSON=tJson
        }
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod JSONToXML(pJSON As %Library.DynamicObject, Output pXmlStream As %AbstractStream, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject, ByRef pWriter As %XML.Writer) As %Status
{
	Try
	{
        Set tSC = $System.Status.OK()

        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pRootName = $Select(pParams.noNamedRoot'="":pParams.noNamedRoot,1:"Root")
        Set pNoNamedArray = $Select(pParams.noNamedElement'="":pParams.noNamedElement,1:"Element")
        Set pAttPrefix = $Select(pParams.attributePrefix'="":pParams.attributePrefix,1:"_")
        Set pCharset = $Select(pParams.charset'="":pParams.charset,1:"UTF-8")
        Set pCharsKey = $Select(pParams.charsKey'="":pParams.charsKey,1:"$value")
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pGhostDelim = $Select(pParams.ghostDelim'="":pParams.ghostDelim,1:"__")

        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"", "parentType":"", "level":0, "rootDefined":""}
        Set pLevel = pInternal.level
        Set pRootDefined = pInternal.rootDefined
        Set pParentKey = pInternal.parentKey
        Set pParentType = pInternal.parentType

		If pParentType="" {
            Set pRootDefined=0
			Set pJSON = ##class(%Library.DynamicObject).%New().%FromJSON(pJSON.%ToJSON())
            Set pWriter=##class(%XML.Writer).%New()
            Set pWriter.Charset=pCharset
            Set pWriter.Indent=1
            Set tSC = pWriter.OutputToStream(.pXmlStream)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tSC=pWriter.StartDocument()
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Set tRootNeeded=0
            If $ClassName(pJSON)="%Library.DynamicArray" {
                Set tRootNeeded = 1
            }
            If $ClassName(pJSON)="%Library.DynamicObject" {
                Set tRootName=""
                Set prop = pJSON.%GetIterator()
                While (prop.%GetNext(.key,.value)) {
                    If tRootName'="" Set tRootNeeded=1  Quit
                    If '$IsObject(value) Set tRootNeeded=1  Quit
					If $ClassName(value)'="%Library.DynamicObject" Set tRootNeeded=1  Quit
                    Set tRootName=key
                }
            }
            If $ClassName(pJSON)="%Library.DynamicArray" {
                Set tKey=pNoNamedArray
            }
            If tRootNeeded=1 {
                Set pRootDefined = 1
                Set tSC=pWriter.RootElement(pRootName)
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }
			Do ..JSONToXML(pJSON,.pXmlStream,pParams,{"parentKey":(pNoNamedArray), "parentType":($Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object")), "level":(pLevel), "rootDefined":(pRootDefined)},pWriter)
            If tRootNeeded=1 {
                Set tSC=pWriter.EndRootElement()
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }
            Set tSC=pWriter.EndDocument()
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            If pPrintResults {
                Write !
                While 'pXmlStream.AtEnd {
                    Write pXmlStream.Read(),!
                }
            }
		} Else {
            //First Attributes
            Set tRootDefined = pRootDefined
			Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                If '$IsObject(value) {
                    If (pAttPrefix="")||($Extract(key,1,1)=pAttPrefix) {
                        Set tSC=pWriter.WriteAttribute($Extract(key,$Select(pAttPrefix="":1,1:2),*),value)
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                    }
                }
            }
			Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                Set tParentElName = $Piece($Select(pParentKey="":"Root",1:pParentKey),pDelim,*)
                If tParentElName=+tParentElName Set tParentElName = pNoNamedArray
				Set tElName = $Select(key=+key:tParentElName,1:key)
                If $Find(tElName,pGhostDelim)>0 Set tElName=$Piece(tElName,pGhostDelim,1)
                Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$Select(key'="":key, 1:"")
                If $IsObject(value) {
                    If ($ClassName(value)="%Library.DynamicObject")||(pParentType="array"){
                        If tRootDefined=0 {
                            Set pRootDefined=1
                            Set tSC=pWriter.RootElement(tElName)
                        } Else {
                            Set tSC=pWriter.Element(tElName)
                        }
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                    }
                    Do ..JSONToXML(value,.pXmlStream,pParams,{"parentKey":(tKey), "parentType":($Select($ClassName(value)="%Library.DynamicArray":"array",1:"object")), "level":(pLevel+1), "rootDefined":(pRootDefined)},pWriter)
                    If ($ClassName(value)="%Library.DynamicObject")||(pParentType="array"){
                        If tRootDefined=0 {
                            Set tSC=pWriter.EndRootElement()
                        } Else {
                            Set tSC=pWriter.EndElement()
                        }
                        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                    }
                } Else {
                    If pAttPrefix'="",$Extract(key,1,1)'=pAttPrefix {
                        If key=pCharsKey {
							//Treat Special Characters CDATA
                            If value'=$Char(10),($Find(value, $Char(10))>0)||($Find(value, $Char(13))>0)||($Find(value,$Char(92))>0)||($Find(value,$Char(60))>0)||($Find(value,$Char(62))>0) {
                                Set tSC=pWriter.WriteCData(value)
                            } Else {
                                Set tSC=pWriter.WriteChars(value)
                            }
                            //Set tSC=pWriter.WriteChars(value)
							If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                        } Else {
                            Set tSC=pWriter.Element(tElName)
                            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
							//Treat Special Characters As CDATA
                            If value'=$Char(10),($Find(value, $Char(10))>0)||($Find(value, $Char(13))>0)||($Find(value,$Char(92))>0)||($Find(value,$Char(60))>0)||($Find(value,$Char(62))>0) {
                                Set tSC=pWriter.WriteCData(value)
                            } Else {
                                Set tSC=pWriter.WriteChars(value)
                            }
                            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                            Set tSC=pWriter.EndElement()
                            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
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

ClassMethod XMLObjToJSON(pXmlStream As %AbstractStream, pClassName As %String, Output pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject) As %Status
{
    Set tSC = $System.Status.OK()
    Try
	{
        Do ..s(pParams,"printResults",0)
        Set tSC = ##class(apiPub.core.irisMetadata).ClassNameToXSDInfo(pClassName,.tXSDInfo,{"printResults":0})
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}

        Set tSC = ##class(apiPub.core.converter).XMLToJSON(pXmlStream,tXSDInfo,.pJSON,pParams)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod XMLToJSON(pXmlStream As %AbstractStream, pXSDInfo As %Library.DynamicObject, Output pJSON As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject, ByRef pNode As %XML.Node) As %Status
{
    Set tSC = $System.Status.OK()
    Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        If '$Data(pXSDInfo) Set pXSDInfo={"list":{},"types":{},"circularRef":{}}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pAttributePrefix = $Select(pParams.attributePrefix'="":pParams.attributePrefix,1:"_")
        Set pInferTypes = $Select(pParams.inferTypes'="":pParams.inferTypes,1:0)
        Set pWithNSPrefix = $Select(pParams.withNSPrefix'="":pParams.withNSPrefix,1:1)
        Set pShowAttQName = $Select(pParams.showAttQName'="":pParams.showAttQName,1:1)
        Set pCharsKey = $Select(pParams.charsKey'="":pParams.charsKey,1:"$value")
        Set pRootName = $Select(pParams.noNamedRoot'="":pParams.noNamedRoot,1:"Root")
        Set pNoNamedArray = $Select(pParams.noNamedElement'="":pParams.noNamedElement,1:"Element")
        Set pListOfArrays = $Select(pParams.listOfArrays'="":pParams.listOfArrays,1:[])
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pObjIsArray = $Select(pParams.objIsArray'="":pParams.objIsArray,1:0)
        //Avoid problems with xml element order (usefull for repetitive xml nodes) 
        Set pKeepElemOrder = $Select(pParams.keepElemOrder'="":pParams.keepElemOrder,1:0)
        Set pGhostDelim = $Select(pParams.ghostDelim'="":pParams.ghostDelim,1:"__")
        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"","parentName":"","parentSName":"","level":-1,"arrayCtrlIdx":{},"arrayCtrlName":{}, "xmlJSON":{}, "build":0}
        Set pParentKey = pInternal.parentKey
        Set pParentName = pInternal.parentName
        Set pParentSName = pInternal.parentSName
        Set pLevel = pInternal.level
        Set pBuild = pInternal.build
        Set pXMLJSON = pInternal.xmlJSON
		If pLevel=-1 {
            Set pInternal.level = 0
            Set tSC = ##class(%XML.Document).GetDocumentFromStream(pXmlStream,.pXMLDoc)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            //Force Node to be An Array
            If $IsObject(pListOfArrays) {
                Set prop = pListOfArrays.%GetIterator()
                While (prop.%GetNext(.key,.value)) {
                    Do pInternal.arrayCtrlName.%Set(value,0)
                }        
            }
            //CountNodes
            Set pNode = pXMLDoc.GetDocumentElement()
			Set tSC = ..XMLToJSON(pXmlStream,pXSDInfo,.pJSON,pParams,pInternal,pNode)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            
            Set pInternal={"parentNameKey":"","parentKey":"","level":0,"arrayCtrlIdx":(pInternal.arrayCtrlIdx),"arrayCtrlName":(pInternal.arrayCtrlName),"xmlJSON":{}, "build":1}
            Set pNode = pXMLDoc.GetDocumentElement()
			Set tSC = ..XMLToJSON(pXmlStream,pXSDInfo,.pJSON,pParams,pInternal,pNode)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            Set pJSON = pInternal.xmlJSON
            If (pPrintResults) {
                Write !,"JSON",!
                Write "============",!
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pJSON.%ToJSON(),.jsonString)
                Write jsonString
            }
		} Else {
            Set tIdx=""
            Set key = pNode.NodeData
            Do {
                If pNode.NodeType = 0 {
                    If pWithNSPrefix Set key = pNode.QName
                    Set tText=""
                    Set status = pNode.GetText(.tText)
                    If 'status Set tText = ""
                    Set tAttCount=pNode.GetNumberAttributes()

                    Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$Select((key'=pRootName)&&(key'=""):key, 1:"")
                    Set tName = $Select(pParentName'="":pParentName_pDelim, 1:"")_$Select((key'=pRootName)&&(key'=""):key, 1:"")
                    Set tSName = $Select(pParentSName'="":pParentSName_pDelim, 1:"")_$Select((key'=pRootName)&&(key'=""):key, 1:"")
                    If pXSDInfo.%Get("circularRef").%Get(tSName)'="" Set tSName = pXSDInfo.%Get("circularRef").%Get(tSName)
                    If (tKey'=""),'pBuild {
                        Set tIdx=pInternal.%Get("arrayCtrlIdx").%Get(tKey)
                        If tIdx="" {Set tIdx = 0} Else {Set tIdx = tIdx+1}
                        Do pInternal.%Get("arrayCtrlIdx").%Set(tKey,tIdx)
                        If tIdx>0||(pObjIsArray)||(pXSDInfo.%Get("list").%Get(tSName)=1) {
                            Do pInternal.%Get("arrayCtrlName").%Set(tKey,0)                            
                            If (pKeepElemOrder) {
                              Set tKey=tKey_pGhostDelim_tIdx
                            } Else {
                              Set tKey=tKey_pDelim_tIdx
                            }
                            Do pInternal.%Get("arrayCtrlName").%Set(tName,0)
                        }
                    }
                    If (tKey'="")&&(pBuild) {
                        Set tIdx=pInternal.%Get("arrayCtrlName").%Get($Replace(tKey,"^0",""))
                        If tIdx'="" {
                            Do pInternal.%Get("arrayCtrlName").%Set($Replace(tKey,"^0",""),tIdx+1)
                            If (pKeepElemOrder) {
                              Set tKey=tKey_pGhostDelim_tIdx
                            } Else {
                              Set tKey=tKey_pDelim_tIdx
                            }
                        } ElseIf pInternal.%Get("arrayCtrlName").%Get(tName)'="" {
                            Set tKey=tKey_pDelim_"0"
                        }
                    }
                    If pBuild {
                        If (tText'="")||((tAttCount=0)&&(pNode.HasChildNodes()=0)) {
                            Set tType = "string"
                            If pInferTypes {
                                If ($zConvert(tText,"L")="true")||($zConvert(tText,"L")="false") {
                                    Set tText=$Select($zConvert(tText,"L")="true":1,1:0)
                                }
                                Set tType = ..GetJSONType(tText)
                            } Else {
                                If pXSDInfo.%Get("types").%Get(tSName)'="" {
                                    Set tType = pXSDInfo.%Get("types").%Get(tSName)
                                }
                            }
                            Set tEPath=$Replace(tKey,pRootName_pDelim,"")
                            Set tEPath=$Replace(tEPath,pNoNamedArray_pDelim,"")
                            If tType="boolean" Set tText=$Replace($Replace($ZConvert(tText,"L"),"true",1),"false",0)
                            If (tAttCount>0) {
                                /// $TR(pCharsKey,"$#@","") to avoid conflict with classes that has value property
                                If pXSDInfo.%Get("types").%Get(tSName_pDelim_$TR(pCharsKey,"$#@",""))'="",tType="string" {
                                    Set tType = pXSDInfo.%Get("types").%Get(tSName_pDelim_$TR(pCharsKey,"$#@",""))
                                    If tType="boolean" Set tText=$Replace($Replace($ZConvert(tText,"L"),"true",1),"false",0)
                                }
                                Do ..SetByLineKey(pXMLJSON,tEPath_pDelim_pCharsKey,tText,tType,pDelim,pInferTypes)
                            } Else {
                                Do ..SetByLineKey(pXMLJSON,tEPath,tText,tType,pDelim,pInferTypes)
                            }
                        }
                        If tAttCount>0 {
                            Set tAtt=pNode.FirstAttributeName()
                            While tAtt'="",((pNode.GetAttributeQName("type")="")||(pShowAttQName)) {
                                Set tEPath=$Replace(tKey,pRootName_pDelim,"")
                                Set tEPath=$Replace(tEPath,pNoNamedArray_pDelim,"")
                                Set tVKey = tAtt
                                If pWithNSPrefix Set tVKey=pNode.GetAttributeQName(tAtt)
                                Set tValue = pNode.GetAttributeValue(tAtt)
                                Set tType = "string"
                                If pInferTypes {
                                    Set tType = ..GetJSONType(tValue)
                                    If ($zConvert(tValue,"L")="true")||($zConvert(tValue,"L")="false") {
                                        Set tValue=$Select($zConvert(tValue,"L")="true":1,1:0)
                                    }
                                } Else {
                                    If pXSDInfo.%Get("types").%Get(tSName)'="" {
                                        Set tType = pXSDInfo.%Get("types").%Get(tSName)
                                    }
                                    If tVKey'="",pXSDInfo.%Get("types").%Get(tSName_pDelim_tVKey)'="",tType="string" {
                                        Set tType = pXSDInfo.%Get("types").%Get(tSName_pDelim_tVKey)
                                    }
                                    If tType="boolean" Set tValue=$Replace($Replace($ZConvert(tValue,"L"),"true",1),"false",0)
                                }
                                Do ..SetByLineKey(pXMLJSON,tEPath_pDelim_pAttributePrefix_tVKey,tValue,tType,pDelim,pInferTypes)
                                Set tAtt=pNode.NextAttributeName(tAtt)
                            } 
                        }   
                    }
                    If pNode.HasChildNodes() {
                        Set tNodeId = pNode.NodeId
                        //Treat inheritance (names)
                        Set tSName=$Select(pNode.GetAttributeQName("type")="xsi:type":pNode.GetAttributeValue("type"),1:tSName)
                        Do pNode.MoveToFirstChild(1)
                        If pNode.NodeId'=tNodeId {
                            Do ..XMLToJSON(pXmlStream,pXSDInfo,.pJSON,pParams,{"parentKey":(tKey),"parentName":(tName),"parentSName":(tSName),"level":(pLevel+1), "arrayCtrlIdx":(pInternal.arrayCtrlIdx),"arrayCtrlName":(pInternal.arrayCtrlName),"xmlJSON":(pInternal.xmlJSON), "build":(pBuild)}, pNode)
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

ClassMethod ObjArrayToJSONArray(pObjArray As %Collection.AbstractIterator, Output pJSONArray As %Library.DynamicObject, pParams As %Library.DynamicObject) As %Status
{
    Set tSC = $System.Status.OK()
    Try
	{
        Set tAdaptType = $Select(pParams.adaptType'="":pParams.adaptType,1:"XML")
        Set tClassName=""
        Set pJSONArray = []
        Set tXsdInfo={}
        For i=1: 1: pObjArray.Count() {
            If tAdaptType = "XML" {
                If (pObjArray.GetAt(i).%PackageName()_"."_pObjArray.GetAt(i).%ClassName())'=tClassName {
                    Set tClassName=pObjArray.GetAt(i).%PackageName()_"."_pObjArray.GetAt(i).%ClassName()
                    Set tSC = ##class(apiPub.core.irisMetadata).ClassNameToXSDInfo(tClassName,.tXsdInfo,{"printResults":0})
                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                }
                Set tWt=##class(%XML.Writer).%New()
                Set tWt.Indent=1
                Do tWt.OutputToStream(.tXML)
                Do tWt.RootObject(pObjArray.GetAt(i))
                Set pParams.noNamedRoot = "@null"
                Set pParams.noNamedElement = "@null"
                Set tSC = ..XMLToJSON(tXML,tXsdInfo,.tJsonObj,pParams,)
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                If tJsonObj.%Size()=1 {
                    Set tIt = tJsonObj.%GetIterator()
                    Do tIt.%GetNext(.jkey,.jvalue)
                }
                Do pJSONArray.%Push(##class(%Library.DynamicObject).%New().%FromJSON(jvalue.%ToJSON()))
            } Else {
                Set tSC = pObjArray.GetAt(i).%JSONExportToStream(.tStream)
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
                Do pJSONArray.%Push({}.%FromJSON(tStream))
            }
        }
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod JSONArrayToObjArray(pJSONArray As %Library.DynamicArray, pClassName As %String, Output pObjArray As %ArrayOfObjects) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
	    Set pObjArray = ##class(%ArrayOfObjects).%New()
        Set it = pJSONArray.%GetIterator()
        While it.%GetNext(.key,.value) {
            Set tSC = ..JSONToObj(value,pClassName,.pObj)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Do pObjArray.SetAt(pObj,key+1)
        }
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod JSONArrayToObjList(pJSONArray As %Library.DynamicArray, pClassName As %String, Output pObjArray As %ListOfObjects) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
	    Set pObjList = ##class(%ListOfObjects).%New()
        Set it = pJSONArray.%GetIterator()
        While it.%GetNext(.key,.value) {
            Set tSC = ..JSONToObj(value,pClassName,.pObj)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            Do pObjList.Insert(pObj)
        }
    }
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

}

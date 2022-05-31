Class apiPub.core.jsonBuilder Extends %RegisteredObject
{

ClassMethod JSet(ByRef pJSON As %Library.DynamicObject, pKey As %String, pValue As %Library.DynamicObject, pType As %String = "", pDelim As %String = ".", pInferBoolean As %Boolean = 1) As %Status [ SqlProc ]
{
    Quit ..SetByLineKey(pJSON, pKey, pValue, pType, pDelim, pInferBoolean)
}

ClassMethod JGet(pJSON As %Library.DynamicObject, pKey As %String, pDelim As %String = ".") As %Library.DynamicObject [ SqlProc ]
{
    Quit ..GetByLineKey(pJSON, pKey, pDelim)
}

ClassMethod JRem(pJSON As %Library.DynamicObject, pKey As %String, pDelim As %String = ".") As %Library.DynamicObject
{
    Quit ..RemoveByLineKey(pJSON, pKey, pDelim)
}

ClassMethod SetByLineKey(ByRef pJSON As %Library.DynamicObject, pKey As %String, pValue As %Library.DynamicObject, pType As %String, pDelim As %String = ".", pInferBoolean As %Boolean = 1) As %Status [ SqlProc ]
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set pKey = $Tr(pKey,"[]",pDelim)
        If $Piece(pKey,pDelim,1)="+" Set $Piece(pKey,pDelim,1) = $Select('$Data(pJSON):0,1:pJSON.%Size())
        If '$Data(pJSON),$Piece(pKey,pDelim,1)=+$Piece(pKey,pDelim,1) Set pJSON=[]
        If '$Data(pJSON) Set pJSON={}  
        Set tRef=pJSON
        For i=1:1:$Length(pKey,pDelim) {
            If $Piece(pKey,pDelim,i+1)="+",tRef.%Get($Piece(pKey,pDelim,i))="" Set $Piece(pKey,pDelim,i+1)=0
            If ($ClassName(tRef)="%Library.DynamicArray")&&($Piece(pKey,pDelim,i)="+") Set $Piece(pKey,pDelim,i)=tRef.%Size()
            Set tPiece = $Tr($Piece(pKey,pDelim,i),"*","")
            Set tNextPiece = $Piece(pKey,pDelim,i+1)
            If i=$Length(pKey,pDelim) {
                If pInferBoolean,($zConvert(pValue,"L")="true")||($zConvert(pValue,"L")="false") {
                    Set pValue=$Select($zConvert(pValue,"L")="true":1,1:0)
                    Set pType = "boolean"
                }
                If $Get(pType,"")'="" {
                    Do tRef.%Set(tPiece,pValue,pType)
                } Else {
                    Do tRef.%Set(tPiece,pValue)
                }
            } Else {
                If tRef.%Get(tPiece)="" Do tRef.%Set(tPiece,$Select(tNextPiece=+tNextPiece:[],1:{}))
                Set tRef = tRef.%Get(tPiece)
            }
        }
    }
	Catch(e)
	{
        Set tSC = e.AsStatus()
	}
    Quit tSC
}

ClassMethod GetByLineKey(pJSON As %Library.DynamicObject, pKey As %String, pDelim As %String = ".") As %Library.DynamicObject
{
    Set tRef=""
    Try
	{
        Set pKey = $Tr(pKey,"[]",pDelim)
        Set tRef=pJSON
        If pKey="" Quit
        For i=1:1:$Length(pKey,pDelim) {
            If $ClassName(tRef)'["%Library.Dynamic" Set tRef = ""  Quit
            If $ClassName(tRef)="%Library.DynamicArray",$Piece(pKey,pDelim,i)'=+$Piece(pKey,pDelim,i) Set tRef = ""  Quit
            Set tRef=tRef.%Get($Piece(pKey,pDelim,i))
            If tRef="" Quit
        }
    }
	Catch(e)
	{
        Set tSC = e.AsStatus()
	}
    Quit tRef
}

ClassMethod RemoveByLineKey(pJSON As %Library.DynamicObject, pKey As %String, pDelim As %String = ".") As %Library.DynamicObject
{
    Set tRef=""
    Try
	{
        Set pKey = $Tr(pKey,"[]",pDelim)
        Set tRef=pJSON
        If pKey="" Quit
        For i=1:1:$Length(pKey,pDelim) {
            If $ClassName(tRef)'["%Library.Dynamic" Quit
            If $ClassName(tRef)="%Library.DynamicArray",$Piece(pKey,pDelim,i)'=+$Piece(pKey,pDelim,i) Quit
            If i=$Length(pKey,pDelim) {
                If tRef.%Get($Piece(pKey,pDelim,i))'="" Do tRef.%Remove($Piece(pKey,pDelim,i))
            } Else {
                Set tRef=tRef.%Get($Piece(pKey,pDelim,i))
            }
            If tRef="" Quit
        }
    }
	Catch(e)
	{
        Set tSC = e.AsStatus()
	}
    Quit pJSON
}

ClassMethod GetJSONType(pString As %RawString) As %String
{
    If $Length(pString)>100 Quit "string"
    If ..RegexValidation(pString,"true|false") Quit "boolean"
    If ..RegexValidation(pString,"^[0-9][A-Za-z0-9.,-]*$") Quit "number"
    Quit "string"
}

ClassMethod RegexValidation(pString As %String, pRegex As %String) As %Boolean
{
	Set matcher=##class(%Regex.Matcher).%New(pRegex)
	Do matcher.TextSet(pString)
	Quit matcher.Locate()
}

ClassMethod JSONToFlatJSON(pJSON As %Library.DynamicObject, Output pFlatJSON As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
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
			Set pFlatJSON = {}
			Do ..JSONToFlatJSON(pJSON,.pFlatJSON,pParams,{"parentKey":"", "parentType":($Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object"))})
            If pPrintResults {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pFlatJSON.%ToJSON(),.jsonString)
                Write jsonString,!
            }
		} Else {
			Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
				Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$Select(key'="":key, 1:"")
				If $IsObject(value) {
                    Do ..JSONToFlatJSON(value,.pFlatJSON,pParams,{"parentKey":(tKey), "parentType":($Select($ClassName(value)="%Library.DynamicArray":"array",1:"object"))})
				} Else {
					Do pFlatJSON.%Set(tKey,value,pJSON.%GetTypeOf(key))
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

ClassMethod JSONFromFlatJSON(pFlatJSON As %Library.DynamicObject, Output pDeepJSON As %Library.DynamicObject, pParams As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1) 

        Set pDeepJSON = {}
		Set prop = pFlatJSON.%GetIterator()
		Set tRef=""
		While (prop.%GetNext(.key,.value)) {
			If tRef="",$Piece(key,pDelim,1)=+$Piece(key,pDelim,1) Set pDeepJSON=[]
			Set tRef=pDeepJSON
			For i=1:1:$Length(key,pDelim) {
				Set tPiece = $Piece(key,pDelim,i)
				Set tNextPiece = $Piece(key,pDelim,i+1)
				If i=$Length(key,pDelim) {
					Do tRef.%Set(tPiece,value,pFlatJSON.%GetTypeOf(key))
				} Else {
					If tRef.%Get(tPiece)="" Do tRef.%Set(tPiece,$Select(tNextPiece=+tNextPiece:[],1:{}))  
					Set tRef = tRef.%Get(tPiece)
				}
			}
		}
        If pPrintResults {
            Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
            Do tFormatter.FormatToString(pDeepJSON.%ToJSON(),.jsonString)
            Write jsonString,!
        }
	}
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod JSONAppend(pJSON As %Library.DynamicObject, ByRef pExistingJSON As %Library.DynamicObject) As %Status
{
	Set tSC = $$$OK
	Try
	{
        Set tSC = ..JSONToFlatJSON(pJSON,.tFJSON,{"printResults":0})
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        Set tM = tFJSON.%GetIterator()
        While tM.%GetNext(.mkey,.mvalue) {
            Do ..SetByLineKey(pExistingJSON,mkey,mvalue,,"^")
        }
	}
	Catch(e)
	{
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
            Set attKey=$Select($E($Piece(key,"##",*),*)="/":$E($Piece(key,"##",*),1,*-1),1:$Piece(key,"##",*))
            Set tKey = ""
			For i=1:1:$Length(attKey,"/") {
				Set tParName = ""
				Set tPc = $Replace($Piece(attKey,"/",i),":","")
				If i=1 Set tPc = $ZConvert(tPc,"S")
				If $Find(tPc,"{")>0,$Find(tPc,"}")>0 {
					Set tParName = $Replace($Replace(tPc,"{",""),"}","")
					If tParName'="" Do ..SetByLineKey(pIndexedMap,tKey_"^@parName",tParName,,"^")
					Set tPc = "@P"
				}
				Set tKey = tKey_$Select(i=1:"",1:"^")_tPc
			}
			If $IsObject(value) {
                Do ..JSONToFlatJSON(value,.fobj,{"printResults":0})
                Set fprop = fobj.%GetIterator()
                While (fprop.%GetNext(.fkey,.fvalue)) {
				    Do ..SetByLineKey(pIndexedMap,tKey_"^"_fkey,fvalue,,"^")
                }
			} Else {
				Do ..SetByLineKey(pIndexedMap,tKey,{"@operationId":(value)},,"^")
			}
			Do ..SetByLineKey(pIndexedMap,tKey_"^@path",attKey,,"^")
			If tParName'="" Do ..SetByLineKey(pIndexedMap,tKey_"^@parName",tParName,,"^")
		}
	}
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
 	Quit tSC
}

// Separate Behaviour params (starts with _) from Method/Request params

ClassMethod GetRequestParams(pReqParams As %String, Output pParams As %Library.DynamicObject, Output pBehavParams As %Library.DynamicObject) As %Status
{
    Set tSC = $$$OK 
    Try {
        If '$Data(pParams) Set pParams = {}
        If '$Data(pBehavParams) Set pBehavParams = {}
        If pReqParams="" Set pReqParams="{}"
        Set tIter = {}.%FromJSON(pReqParams).%GetIterator()
        While tIter.%GetNext(.key,.value) {
            If $ZConvert(value,"L")="true" Set value = 1
            If $ZConvert(value,"L")="false" Set value = 0
            If $Extract(key,1,1)="_" {
                Do pBehavParams.%Set($Extract(key,2,*),value)
            } Else {
                Do pParams.%Set(key,value)
            }
        }
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
    Quit tSC
}

// Print Identation

ClassMethod Ident(pLevel) As %String
{
    Set tRet = ""
    For i=1:1:pLevel Set tRet = tRet_$char(9)
    Quit tRet
}

// Get an array size for iteration loop

ClassMethod GetSizeByLineKey(pJSON As %Library.DynamicObject, pKey As %String, pDelim As %String = ".") As %Library.DynamicObject
{
    Set tRef=..GetByLineKey(pJSON, pKey, pDelim)
    If $ClassName(tRef)'="%Library.DynamicArray" Set tRef=[] 
    Quit tRef.%Size()
}

ClassMethod SaveStreamToFile(pStream As %AbstractStream, pFileName As %String) As %Status
{
    Set tSC = $System.Status.OK()
    Try
	{
        Set tFileStream=##class(%Stream.FileCharacter).%New()
        Set tSC=tFileStream.LinkToFile(pFileName)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Set tSC = tFileStream.CopyFrom(pStream)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        Set tSC = tFileStream.%Save()
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
    }
    Catch(e)
	{
		Write $System.Status.DisplayError(e.AsStatus())
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod findElement(arr As %Library.DynamicArray, value As %String) As %Numeric
{
    Set l = $listfromstring($e(arr.%ToJSON(),2,*-1),",")
    Quit $listfind(l,value)
}

}

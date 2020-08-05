Class apiPub.core.jsonBuilder Extends %RegisteredObject
{

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
	Set matcher.Text = pString
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

}

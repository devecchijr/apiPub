Class apiPub.core.parser Extends apiPub.core.jsonBuilder
{

/// Parse json payload object using openapi 3.0 schema
ClassMethod Parse(pObjName As %String, pJSON As %Library.DynamicObject, pSchema As %Library.DynamicObject, Output pResult As %Library.DynamicObject, Output pInLineResult As %String, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pCachedKey = $Select(pParams.cachedKey'="":pParams.cachedKey,1:1)

        //Internal Params
        If '$Data(pInternal) Set pInternal={"oPKey":"","pKey":"" ,"pType":"","originalJSON":(pJSON),"level":0}
        Set pKey = pInternal.pKey
        Set pOPKey = pInternal.oPKey
        Set pParentType = pInternal.pType
        Set pLevel = pInternal.level
		If pParentType="" {
			Set pResult = {"valid":1,"invalidItems":[]}
            Set tSC = ..GetFlatSchema(pObjName,pSchema,.tFlatSchema,{"printResults":0,"cachedKey":(pCachedKey)})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            Set tSchemaVal=tFlatSchema.%Get(pObjName)
            If $Find(tSchemaVal,"*object")=0,$Find(tSchemaVal,"*array")=0 Do ..Parse(pObjName,pJSON,tFlatSchema,.pResult,.pInLineResult,pParams,{"oPKey":(pObjName),"pKey":(pObjName), "pType":($Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object")),"originalJSON":(pInternal.originalJSON),"level":1})
            Set tInLineText = ""
            Set tIP = pResult."invalidItems".%GetIterator()
            While (tIP.%GetNext(.pskey,.psvalue)) {
                Set tInLineText=$Select(tInLineText'="":tInLineText_"; ",1:tInLineText)_psvalue
            }
            If tInLineText="" Set tInLineText="1"
            Set pInLineResult = tInLineText
            If pPrintResults {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pResult.%ToJSON(),.jsonString)
                Write jsonString,!
            }
		} Else {
            If pSchema.%Get("required").%Get(pKey)'="" {
                Set tReq = pSchema.%Get("required").%Get(pKey).%GetIterator()
                While (tReq.%GetNext(.rkey,.rvalue)) {
                    If 'pJSON.%IsDefined(rkey) {
                        Do pResult.%Set("valid",0)
                        Do pResult.%Get("invalidItems").%Push("Path "_$Replace($Replace(pOPKey,"^","."),".[","[")_"."_rkey_" is required")
                    }
                }
            }
			Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
				Set tKey = $Select(pKey'="":pKey_pDelim, 1:"")_$Select(key'="":$Select((pParentType="array")&&(key=+key):"0",1:key), 1:"")
				Set tOKey = $Select(pOPKey'="":pOPKey_pDelim, 1:"")_$Select(key'="":$Select((pParentType="array")&&(key=+key):"["_key_"]",1:key), 1:"")
                Set tSchemaVal = pSchema.%Get(tKey)
				If $IsObject(value) {
                    If $Piece(tSchemaVal,pDelim,1)="circRef" Set tKey=$Piece(tSchemaVal,pDelim,2,*)
                    If tSchemaVal'="" {
                        If (pResult.%Get("valid")),$Find(tSchemaVal,"*object")=0,$Find(tSchemaVal,"*array")=0 Do ..Parse(pObjName,value,pSchema,.pResult,.pInLineResult,pParams,{"oPKey":(tOKey),"pKey":(tKey), "pType":($Select($ClassName(value)="%Library.DynamicArray":"array",1:"object")),"originalJSON":(pInternal.originalJSON),"level":(pLevel+1)})
                    }
	 			} Else {
                    If tSchemaVal'="" {
                        If pSchema.%Get(tKey_pDelim_"enum")'="",$Length(pSchema.%Get(tKey),"^")=0 {
                            Set tList=$Listfromstring(pSchema.%Get(tKey_pDelim_"enum"),"^")
                            If $Listfind(tList,value)=0 {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid enumerator value ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        }
                        If pSchema.%Get(tKey_pDelim_"format")="date-time",$Length(pSchema.%Get(tKey),"^")=0 {
                            If '(##class(%Library.TimeStamp).IsValid(##class(%Library.TimeStamp).XSDToLogical(value))) {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid date-time format ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf pSchema.%Get(tKey_pDelim_"format")="date",$Length(pSchema.%Get(tKey),"^")=0 {
                            If '(##class(%Library.Date).IsValid(##class(%Library.Date).XSDToLogical(value))) {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid date format ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf pSchema.%Get(tKey_pDelim_"format")="int32",$Length(pSchema.%Get(tKey),"^")=0 {
                            If '(##class(%Library.SmallInt).IsValid(value)) {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid int32 format ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf pSchema.%Get(tKey_pDelim_"format")="int64",$Length(pSchema.%Get(tKey),"^")=0 {
                            If '(##class(%Library.BigInt).IsValid(value)) {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid int64 format ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf pSchema.%Get(tKey)="integer" {
                            If '(##class(%Library.BigInt).IsValid(value)) {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid integer type ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf (pSchema.%Get(tKey)="boolean") {
                            If '(pJSON.%GetTypeOf(key)="boolean") {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid boolean type ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf pSchema.%Get(tKey)="number" {
                            If '(pJSON.%GetTypeOf(key)="number") {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid numeric type ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf pSchema.%Get(tKey)="string" {
                            If '(pJSON.%GetTypeOf(key)="string") {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid string type ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf ((pSchema.%Get(tKey)="object")||($Piece(pSchema.%Get(tKey),pDelim,1)="circRef")) {
                            Do pResult.%Set("valid",0)
                            Do pResult.%Get("invalidItems").%Push("Invalid object type ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                        } ElseIf (pSchema.%Get(tKey)["^") {
                            If pJSON.%GetTypeOf(key)="boolean",'(pSchema.%Get(tKey)["boolean") {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Boolean type not allowed ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                            If pJSON.%GetTypeOf(key)="string",'(pSchema.%Get(tKey)["string") {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("String type not allowed ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                            If pJSON.%GetTypeOf(key)="number",'(pSchema.%Get(tKey)["number") {
                                If '((##class(%Library.Integer).IsValid(value))&&(pSchema.%Get(tKey)["integer")) {
                                    Do pResult.%Set("valid",0)
                                    Do pResult.%Get("invalidItems").%Push("Number type not allowed ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                                } 
                            }
                        }
                    }
                } 
                If tSchemaVal="" {
                    Set tMessage = $Replace($Replace(tOKey,"^","."),".[","[")
                    Do pResult.%Set("valid",0)
                    Do pResult.%Get("invalidItems").%Push("Invalid Property "_tMessage)
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

/// Verify circular reference
ClassMethod NotCircRef(pKey As %String, pValue As %String, ByRef pSchema As %DynamicObject, ByRef pCircRef As %DynamicObject, pDelim As %String) As %Boolean
{
        Set tFkey=..ReplaceSch(pKey)
        Set tObjRef=$Tr($Piece(pValue,"#/components/schemas/",2),"/",pDelim)
        Set pRefKey=""
        For i = 1:1:$L(tObjRef,pDelim) {
            Set tPieceKey = $Piece(tObjRef,pDelim,i)
            If tPieceKey="items",$Piece(pRefKey,pDelim,*)'="properties" Set tPieceKey="0"
            Set pRefKey = $Select(pRefKey'="":pRefKey_pDelim, 1:"")_$Select(tPieceKey'="":tPieceKey, 1:"")
        }
        Set tCircRef=..g(pCircRef,pRefKey)
        Set tLoopKey=""
        While (..i(tCircRef,"",.lidx,.lval,.lit)) {
            If ($E(tFkey,1,$L(lidx)+1)=(lidx_pDelim)) Set tLoopKey=lidx
        }
        If tLoopKey'="" {
            Do pSchema.%Set(tFkey,"circRef"_pDelim_..ReplaceSch(tLoopKey))            
        } Else {
            Do ..s(pCircRef,pRefKey_"."_tFkey,1)
        }
        Quit (tLoopKey="")
}

ClassMethod GetFlatSchema(pObjName As %String, pJSON As %Library.DynamicObject, Output pSchema As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)
        Set pCachedKey = $Select(pParams.cachedKey'="":pParams.cachedKey,1:"")
        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"", "circRef":{}, "parentType":"","originalJSON":(pJSON),"level":0}
        Set pParentKey = pInternal.parentKey
        Set pCircRef = pInternal.circRef
        Set pParentType = pInternal.parentType
        Set pLevel = pInternal.level
		If pParentType="" {
			Set pSchema = {"required":{}}
            If pJSON.%Get(pObjName) = "" {
                Set tSC = $$$ERROR($$$GeneralError, "invalid schema")
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }
            Set tCached=0      
            If pCachedKey'="" {
                //Get Last Class Modification Date
                Set tSC = ##class(apiPub.core.irisMetadata).GetClassDefInfo($Piece(pCachedKey,"||",1),.tTimeChanged)
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                Set tParseStruc=##class(apiPub.service.cache).CacheIdxOpen(pCachedKey_"||ps")
                If '$IsObject(tParseStruc) {
                    Set tParseStruc=##class(apiPub.service.cache).%New()
                    Set tParseStruc.Key = pCachedKey_"||ps"
                } Else {
                    If tParseStruc.DateTimeCtl=tTimeChanged Set tCached = 1
                }
            }
            If '(tCached) {
                Set tSC = ..GetFlatSchema(pObjName,##class(%Library.DynamicObject).%New().%Set(pObjName,pJSON.%Get(pObjName)) ,.pSchema,pParams,{"parentKey":"","circRef":{},"parentType":($Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object")),"originalJSON":(pInternal.originalJSON),"level":1})
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                If pCachedKey'="" {
                    Set tParseStruc.DateTimeCtl=tTimeChanged
                    Do pSchema.%ToJSON(tParseStruc.Content)
                    Set tSC = tParseStruc.%Save()
                    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
                }
            } Else {
                Set pSchema = ##class(%Library.DynamicObject).%New().%FromJSON(tParseStruc.Content)
            }
            If pPrintResults {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pSchema.%ToJSON(),.jsonString)
                Write jsonString,!
            }
		} Else {
			Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                If pParentKey="" {
                    Set pCircRef = {}
                }
                If pParentType="array",key=+key Set key="*"
                If key="items",$Piece(pParentKey,pDelim,*)'="properties" Set key="0"
				Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$Select(key'="":key, 1:"")
				If $IsObject(value) {
                    Do ..GetFlatSchema(pObjName,value,.pSchema,pParams,{"parentKey":(tKey),"circRef":(pCircRef),"parentType":($Select($ClassName(value)="%Library.DynamicArray":"array",1:"object")),"originalJSON":(pInternal.originalJSON),"level":(pLevel+1)})
    			} Else {
                    If $Piece(tKey,pDelim,*)="$ref","allOf oneOf anyOf"[$Piece(tKey,pDelim,*-2) {
                        Set tJSON = ..GetByLineKey(pInternal.originalJSON,$Piece(value,"#/components/schemas/",2),"/")
                        If tJSON'="",$IsObject(tJSON) {
                            Set tKey = $Piece(tKey,pDelim,1,*-3)
                            If (..NotCircRef(tKey,value,pSchema,pCircRef,pDelim)) {
                                Do ..GetFlatSchema(pObjName,tJSON,.pSchema,pParams,{"parentKey":(tKey),"circRef":(pCircRef),"parentType":"object","originalJSON":(pInternal.originalJSON),"level":(pLevel+1)})
                            } 
                        }
                    } Else {
					    If $Piece(tKey,pDelim,*)="$ref" {
                            Set tJSON = ..GetByLineKey(pInternal.originalJSON,$Piece(value,"#/components/schemas/",2),"/")
                            If tJSON'="",$IsObject(tJSON) {
                                Set tKey = $Piece(tKey,pDelim,1,*-1)
                                If (..NotCircRef(tKey,value,pSchema,pCircRef,pDelim)) {
                                    Do ..GetFlatSchema(pObjName,tJSON,.pSchema,pParams,{"parentKey":(tKey),"circRef":(pCircRef),"parentType":"object","originalJSON":(pInternal.originalJSON),"level":(pLevel+1)})
                                } 
                            }
                        } ElseIf ("format type"[$Piece(tKey,pDelim,*))||($Piece(tKey,pDelim,*-1)="enum")||($Piece(tKey,pDelim,*-1)="required") {
                            Set tFkey=..ReplaceSch(tKey)
                            If $Piece(tKey,pDelim,*-1)="required" {
                               If (("allOf oneOf anyOf"'[$Piece(tKey,pDelim,*-3))||($Piece(tKey,pDelim,*-3)="")) Do ..SetByLineKey(pSchema,"required."_tFkey_"."_value,1,,".")
                            } Else {
                                Set tParent = $Piece(tFkey,pDelim,1,*-1)
                                If $Extract(pSchema.%Get(tParent),1,1)="*" Do pSchema.%Set(tParent,$Extract(pSchema.%Get(tParent),2,*))
                                Set tExValue = pSchema.%Get(tFkey)
                                If tExValue="" {
                                    Do pSchema.%Set(tFkey,$Select("object array"[value:"*",1:"")_value)
                                } Else {
                                    If tExValue'[value Do pSchema.%Set(tFkey,tExValue_"^"_value)
                                }
                            }
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

ClassMethod ReplaceSch(str)
{
    Quit $Replace($Replace($Replace($Replace($Replace($Replace($Replace($Replace($Replace($Replace($Replace($Replace(str,"^properties^properties","^properties^##properties"),"^properties",""),"^oneOf","^anyOf"),"^anyOf",""),"^allOf",""),"^type^type","^type^##type"),"^type",""),"^required^required","^required^##required"),"^required",""),"##",""),"^*^","^"),"^*","")
}

}

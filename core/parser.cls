Class apiPub.core.parser Extends apiPub.core.jsonBuilder
{

ClassMethod Parse(pObjName As %String, pJSON As %Library.DynamicObject, pSchema As %Library.DynamicObject, Output pResult As %Library.DynamicObject, Output pInLineResult As %String, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)

        //Internal Params
        If '$Data(pInternal) Set pInternal={"oPKey":"","pKey":"" ,"pType":"","originalJSON":(pJSON),"level":0}
        Set pKey = pInternal.pKey
        Set pOPKey = pInternal.oPKey
        Set pParentType = pInternal.pType
        Set pLevel = pInternal.level
		If pParentType="" {
			Set pResult = {"valid":1,"invalidItems":[]}
            Set tSC = ..GetFlatSchema(pObjName,pSchema,.tFlatSchema,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
			Do ..Parse(pObjName,pJSON,tFlatSchema,.pResult,.pInLineResult,pParams,{"oPKey":(pObjName),"pKey":(pObjName), "pType":($Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object")),"originalJSON":(pInternal.originalJSON),"level":1})
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
                    If pJSON.%Get(rkey)="" {
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
                        If (pResult.%Get("valid")),$Find(tSchemaVal,"*object")=0 Do ..Parse(pObjName,value,pSchema,.pResult,.pInLineResult,pParams,{"oPKey":(tOKey),"pKey":(tKey), "pType":($Select($ClassName(value)="%Library.DynamicArray":"array",1:"object")),"originalJSON":(pInternal.originalJSON),"level":(pLevel+1)})
                    }
	 			} Else {
                    If tSchemaVal'="" {
                        If pSchema.%Get(tKey_pDelim_"enum")'="" {
                            Set tList=$Listfromstring(pSchema.%Get(tKey_pDelim_"enum"),"^")
                            If $Listfind(tList,value)=0 {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid enumerator value ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        }
                        If pSchema.%Get(tKey_pDelim_"format")="date-time" {
                            If '(##class(%Library.TimeStamp).IsValid(##class(%Library.TimeStamp).XSDToLogical(value))) {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid date-time format ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf pSchema.%Get(tKey_pDelim_"format")="date" {
                            If '(##class(%Library.Date).IsValid(##class(%Library.Date).XSDToLogical(value))) {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid date format ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf pSchema.%Get(tKey_pDelim_"format")="int32" {
                            If '(##class(%Library.SmallInt).IsValid(value)) {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid int32 format ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf pSchema.%Get(tKey_pDelim_"format")="int64" {
                            If '(##class(%Library.BigInt).IsValid(value)) {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid int64 format ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf pSchema.%Get(tKey)="integer" {
                            If '(##class(%Library.BigInt).IsValid(value)) {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid integer type ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        } ElseIf pSchema.%Get(tKey)="number" {
                            If '(##class(%Library.Numeric).IsValid(value)) {
                                Do pResult.%Set("valid",0)
                                Do pResult.%Get("invalidItems").%Push("Invalid numeric type ("_value_") on: "_$Replace($Replace(tOKey,"^","."),".[","[")_" path")
                            }
                        }
                    }
                }
                If tSchemaVal="" {
                    Do pResult.%Set("valid",0)
                    Do pResult.%Get("invalidItems").%Push("Invalid path: "_$Replace($Replace(tOKey,"^","."),".[","["))
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

ClassMethod GetFlatSchema(pObjName As %String, pJSON As %Library.DynamicObject, Output pSchema As %Library.DynamicObject, pParams As %Library.DynamicObject, pInternal As %Library.DynamicObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
        //If not Defined The Params Set the Default Values
        If '$Data(pParams) Set pParams={}
        Set pDelim = $Select(pParams.keyDelimiter'="":pParams.keyDelimiter,1:"^") 
        Set pPrintResults = $Select(pParams.printResults'="":pParams.printResults,1:1)

        //Internal Params
        If '$Data(pInternal) Set pInternal={"parentKey":"", "parentType":"","originalJSON":(pJSON),"level":0}
        Set pParentKey = pInternal.parentKey
        Set pParentType = pInternal.parentType
        Set pLevel = pInternal.level
		If pParentType="" {
			Set pSchema = {"required":{}}
            If pJSON.%Get(pObjName) = "" {
                Set tSC = $$$ERROR($$$GeneralError, "invalid schema")
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            }        
			Set tSC = ..GetFlatSchema(pObjName,{}.%Set(pObjName,pJSON.%Get(pObjName)) ,.pSchema,pParams,{"parentKey":"", "parentType":($Select($ClassName(pJSON)="%Library.DynamicArray":"array",1:"object")),"originalJSON":(pInternal.originalJSON),"level":1})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
            If pPrintResults {
                Set tFormatter = ##class(%JSON.Formatter).%New(),jsonString=""
                Do tFormatter.FormatToString(pSchema.%ToJSON(),.jsonString)
                Write jsonString,!
            }
		} Else {
			Set prop = pJSON.%GetIterator()
			While (prop.%GetNext(.key,.value)) {
                If pParentType="array",key=+key Set key="*"
                If key="items" Set key="0"
				Set tKey = $Select(pParentKey'="":pParentKey_pDelim, 1:"")_$Select(key'="":key, 1:"")
				If $IsObject(value) {
                    Do ..GetFlatSchema(pObjName,value,.pSchema,pParams,{"parentKey":(tKey), "parentType":($Select($ClassName(value)="%Library.DynamicArray":"array",1:"object")),"originalJSON":(pInternal.originalJSON),"level":(pLevel+1)})
    			} Else {
                    If $Piece(tKey,pDelim,*)="$ref","allOf anyOf"[$Piece(tKey,pDelim,*-2) {
                        Set tJSON = ..GetByLineKey(pInternal.originalJSON,$Piece(value,"#/components/schemas/",2),"/")
                        If tJSON'="",$IsObject(tJSON) {
                            Set tKey = $Piece(tKey,pDelim,1,*-3)
                            If ($Length(tKey,pDelim)<5)||($Piece(tKey,pDelim,1,*-2)'[$Piece(tKey,pDelim,*-1,*)) {
                                Do ..GetFlatSchema(pObjName,tJSON,.pSchema,pParams,{"parentKey":(tKey), "parentType":"object","originalJSON":(pInternal.originalJSON),"level":(pLevel+1)})
                            } Else {
                                Set tFind = $Find(tKey,$Piece(tKey,pDelim,*-1,*))
                                Set tFValue = $Replace($Replace($Replace($Replace($Replace($Replace($Extract(tKey,1,tFind-1),"^properties",""),"^anyOf",""),"^allOf",""),"^type",""),"^*^","^"),"^*","")
                                Set tFkey=$Replace($Replace($Replace($Replace($Replace($Replace(tKey,"^properties",""),"^anyOf",""),"^allOf",""),"^type",""),"^*^","^"),"^*","")
                                Do pSchema.%Set(tFkey,"circRef"_pDelim_tFValue)
                            }
                        }
                    } Else {
					    If $Piece(tKey,pDelim,*)="$ref" {
                            Set tJSON = ..GetByLineKey(pInternal.originalJSON,$Piece(value,"#/components/schemas/",2),"/")
                            If tJSON'="",$IsObject(tJSON) {
                                Set tKey = $Piece(tKey,pDelim,1,*-1)
                                If ($Length(tKey,pDelim)<5)||($Piece(tKey,pDelim,1,*-2)'[$Piece(tKey,pDelim,*-1,*)) {
                                    Do ..GetFlatSchema(pObjName,tJSON,.pSchema,pParams,{"parentKey":(tKey), "parentType":"object","originalJSON":(pInternal.originalJSON),"level":(pLevel+1)})
                                } Else {
                                    Set tFind = $Find(tKey,$Piece(tKey,pDelim,*-1,*))
                                    Set tFValue = $Replace($Replace($Replace($Replace($Replace($Replace($Extract(tKey,1,tFind-1),"^properties",""),"^anyOf",""),"^allOf",""),"^type",""),"^*^","^"),"^*","")
                                    Set tFkey=$Replace($Replace($Replace($Replace($Replace($Replace(tKey,"^properties",""),"^anyOf",""),"^allOf",""),"^type",""),"^*^","^"),"^*","")
                                    Do pSchema.%Set(tFkey,"circRef"_pDelim_tFValue)
                                }
                            }
                        } ElseIf ("format type"[$Piece(tKey,pDelim,*))||($Piece(tKey,pDelim,*-1)="enum")||($Piece(tKey,pDelim,*-1)="required") {
                            Set tFkey=$Replace($Replace($Replace($Replace($Replace($Replace($Replace(tKey,"^properties",""),"^anyOf",""),"^allOf",""),"^type",""),"^*^","^"),"^*",""),"^required","")
                            If $Piece(tKey,pDelim,*-1)="required" { 
                               Do ..SetByLineKey(pSchema,"required."_tFkey_"."_value,1,,".")  
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

}

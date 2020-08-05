Class apiPub.core.parser Extends apiPub.core.jsonBuilder
{

// Do ##class(apiPub.core.parser).Test()

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

ClassMethod Test() As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set tSchemas = {
            "Order": {
                "type": "object",
                "properties": {
                "id": {
                    "type": "integer",
                    "format": "int64"
                },
                "petId": {
                    "type": "integer",
                    "format": "int64"
                },
                "quantity": {
                    "type": "integer",
                    "format": "int32"
                },
                "shipDate": {
                    "type": "string",
                    "format": "date-time"
                },
                "status": {
                    "type": "string",
                    "description": "Order Status",
                    "enum": [
                    "placed",
                    "approved",
                    "delivered"
                    ]
                },
                "complete": {
                    "type": "boolean",
                    "default": false
                }
                },
                "xml": {
                "name": "Order"
                }
            },
            "Category": {
                "type": "object",
                "properties": {
                "id": {
                    "type": "integer",
                    "format": "int64"
                },
                "name": {
                    "type": "string"
                }
                },
                "xml": {
                "name": "Category"
                }
            },
            "User": {
                "type": "object",
                "properties": {
                "id": {
                    "type": "integer",
                    "format": "int64"
                },
                "username": {
                    "type": "string"
                },
                "firstName": {
                    "type": "string"
                },
                "lastName": {
                    "type": "string"
                },
                "email": {
                    "type": "string"
                },
                "password": {
                    "type": "string"
                },
                "phone": {
                    "type": "string"
                },
                "userStatus": {
                    "type": "integer",
                    "format": "int32",
                    "description": "User Status"
                }
                },
                "xml": {
                "name": "User"
                }
            },
            "Address2": {
                "type": "object",
                "properties": {
                    "Rua": {
                        "type": "string",
                        "example": "Rua Cravinhos"
                    },
                    "Apartamento": {
                        "type": "boolean",
                        "example": true
                    },
                    "Habitantes": {
                        "type": "integer",
                        "example": 12
                    },
                    "telefones": {
                        "type": "array",
                        "items": {
                            "type": "object",
                            "properties": {
                                "tipo": {
                                    "type": "string",
                                    "example": "comercial",
                                    "enum": ["comercial", "residencial"],
                                    "description": "type of address"
                                },
                                "ddd": {
                                    "type": "integer",
                                    "example": 11,
                                    "format": "int64"
                                },
                                "numero": {
                                    "type": "number",
                                    "example": 40392764
                                }
                            }
                        }
                    },
                    "outroArray": {
                        "type": "array",
                        "items": {
                            "type": "string",
                            "example": "abc"
                        }
                    }
                }
            },
            "MyObj": {
                    "type": "object",
                    "properties": {
                        "MyProp": {
                            "type": "string",
                            "example": "abc"
                        }
                    }
                },
                "superArray": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "complexObj": {
                                "type": "object",
                                "properties": {
                                    "VerdadeiroOuFalso": {
                                        "type": "boolean",
                                        "example": true
                                    }
                                }
                            }
                        }
                    }
                },
                "PetOrder": {
                    "type": "object",
                    "properties": {
                        "id": {
                            "type": "integer",
                            "format": "int64"
                        },
                        "petId": {
                            "type": "integer",
                            "format": "int64"
                        },
                        "quantity": {
                            "type": "integer",
                            "format": "int32"
                        },
                        "shipDate": {
                            "type": "string",
                            "format": "date-time"
                        },
                        "status": {
                            "type": "string",
                            "description": "Order Status",
                            "enum": ["placed", "approved", "delivered"]
                        },
                        "complete": {
                            "type": "boolean",
                            "default": false
                        },
                        "myObj": {
                            "$ref": "#/components/schemas/MyObj"
                        },
                        "myObj2": {
                            "$ref": "#/components/schemas/MyObj2"
                        }
                    },
                    "required":["id"],
                    "xml": {
                        "name": "Order"
                    }
                },
                "MyObj2": {
                    "type": "object",
                    "properties": {
                        "MyProp": {
                            "type": "string",
                            "example": "abc"
                        }
                    }
                },
                "Root": {
                    "type": "object",
                    "xml": {
                        "name": "Root"
                    },
                    "properties": {
                        "Customers": {
                            "type": "object",
                            "xml": {
                                "name": "Customers"
                            },
                            "properties": {
                                "Customer": {
                                    "type": "array",
                                    "items": {
                                        "allOf": [{
                                            "$ref": "#/components/schemas/Customer"
                                        }]
                                    }
                                }
                            }
                        },
                        "Orders": {
                            "type": "object",
                            "xml": {
                                "name": "Orders"
                            },
                            "properties": {
                                "Order": {
                                    "type": "array",
                                    "items": {
                                        "allOf": [{
                                            "$ref": "#/components/schemas/Order"
                                        }]
                                    }
                                }
                            }
                        }
                    }
                },
                "Customer": {
                    "type": "object",
                    "xml": {
                        "name": "Customer"
                    },
                    "properties": {
                        "CompanyName": {
                            "type": "string"
                        },
                        "ContactName": {
                            "type": "string"
                        },
                        "ContactTitle": {
                            "type": "string"
                        },
                        "Phone": {
                            "type": "string"
                        },
                        "Fax": {
                            "type": "string"
                        },
                        "FullAddress": {
                            "allOf": [{
                                "$ref": "#/components/schemas/FullAddress"
                            }]
                        },
                        "_CustomerID": {
                            "type": "string"
                        }
                    }
                },
                "FullAddress": {
                    "type": "object",
                    "xml": {
                        "name": "FullAddress"
                    },
                    "properties": {
                        "Address": {
                            "type": "string"
                        },
                        "City": {
                            "type": "string"
                        },
                        "Region": {
                            "type": "string"
                        },
                        "PostalCode": {
                            "type": "string"
                        },
                        "Country": {
                            "type": "string"
                        }
                    }
                },
                "Order": {
                    "type": "object",
                    "xml": {
                        "name": "Order"
                    },
                    "properties": {
                        "CustomerID": {
                            "type": "string"
                        },
                        "EmployeeID": {
                            "type": "string"
                        },
                        "OrderDate": {
                            "type": "string"
                        },
                        "RequiredDate": {
                            "type": "string"
                        },
                        "ShipInfo": {
                            "allOf": [{
                                "$ref": "#/components/schemas/ShipInfo"
                            }]
                        }
                    }
                },
                "ShipInfo": {
                    "type": "object",
                    "xml": {
                        "name": "ShipInfo"
                    },
                    "properties": {
                        "ShipVia": {
                            "type": "integer",
                            "format": "int64",
                            "description": "(long) "
                        },
                        "Freight": {
                            "type": "number"
                        },
                        "ShipName": {
                            "type": "string"
                        },
                        "ShipAddress": {
                            "type": "string"
                        },
                        "ShipCity": {
                            "type": "string"
                        },
                        "ShipRegion": {
                            "type": "string"
                        },
                        "ShipPostalCode": {
                            "type": "string"
                        },
                        "ShipCountry": {
                            "type": "string"
                        },
                        "ShippedDate": {
                            "type": "string",
                            "format": "date-time"
                        }
                    }
                },
                "Base": {
                    "type": "object",
                    "xml": {
                        "name": "Base"
                    },
                    "properties": {
                        "AutoRef": {
                            "$ref": "#/components/schemas/Base"
                        },
                        "Numeric": {
                            "type": "number"
                        },
                        "Numeric3": {
                            "type": "number"
                        },
                        "xpto": {
                            "type": "integer",
                            "format": "int64",
                            "description": "(long) "
                        },
                        "xpto2": {
                            "type": "integer",
                            "format": "int64",
                            "description": "(long) "
                        }
                    }
                },
                "SubBase": {
                    "allOf": [{
                        "$ref": "#/components/schemas/Base"
                    }, {
                        "type": "object",
                        "xml": {
                            "name": "SubBase"
                        },
                        "properties": {
                            "PropSubBase": {
                                "type": "string"
                            },
                            "AnotherProp": {
                                "type": "string"
                            }
                        }
                    }]
                },
                "Teste": {
                    "allOf": [{
                        "$ref": "#/components/schemas/SubBase"
                    }, {
                        "type": "object",
                        "xml": {
                            "name": "Teste"
                        },
                        "properties": {
                            "HSCoreVersion": {
                                "type": "string"
                            },
                            "HSMinVersionError": {
                                "type": "boolean",
                                "description": "Can be set by the web client when attempting to invoke a service on a gateway running on a version that's too old"
                            },
                            "AuthBy": {
                                "type": "string",
                                "description": "Who authorized this request"
                            },
                            "AuthType": {
                                "type": "string",
                                "description": "What type of authorization request Verbal, Written etc."
                            },
                            "BTGReason": {
                                "type": "string",
                                "description": "What is the reason for issuing a break the glass"
                            },
                            "BreakTheGlass": {
                                "type": "boolean",
                                "description": "Enabling this may be in violation of federal law ... check with your lawyers"
                            },
                            "Consent": {
                                "type": "string",
                                "description": "Consent information"
                            },
                            "ClinicalTypes": {
                                "type": "string",
                                "description": "Clinical types"
                            },
                            "RequestingUser": {
                                "type": "string",
                                "description": "The requesting user"
                            },
                            "RequestingUserRoles": {
                                "type": "string",
                                "description": "The roles for the requesting user"
                            },
                            "RequestingForProxyUserID": {
                                "type": "string",
                                "description": "If this is for a proxy, the $username of the proxied user"
                            },
                            "RequestingForProxyID": {
                                "type": "string",
                                "description": "If this is for a proxy, the internal ID of the proxied user"
                            },
                            "Signature": {
                                "type": "string",
                                "description": "Signature for this request"
                            },
                            "RequestId": {
                                "type": "string",
                                "description": "Request Audit ID *** Must always be set and passed around ***"
                            },
                            "RequestingGateway": {
                                "type": "string",
                                "description": "An identifier for the access gateway that initiated the request"
                            },
                            "Type": {
                                "type": "string",
                                "description": "Type for increasing the specificity of a request"
                            },
                            "AdditionalInfo": {
                                "description": "Additional request information",
                                "type": "object",
                                "xml": {
                                    "name": "AdditionalInfo"
                                },
                                "properties": {
                                    "AdditionalInfoItem": {
                                        "type": "array",
                                        "items": {
                                            "properties": {
                                                "value": {
                                                    "type": "string"
                                                },
                                                "_AdditionalInfoKey": {
                                                    "type": "string"
                                                }
                                            },
                                            "type": "object",
                                            "xml": {
                                                "name": "items"
                                            }
                                        }
                                    }
                                }
                            },
                            "SAMLData": {
                                "allOf": [{
                                    "$ref": "#/components/schemas/SAMLData"
                                }],
                                "description": "Contains SAML user / rhio / token"
                            },
                            "CustomAuditInfo": {
                                "description": "Data passed in here will be copied to CustomPairs when audited",
                                "type": "object",
                                "xml": {
                                    "name": "CustomAuditInfo"
                                },
                                "properties": {
                                    "CustomAuditInfoItem": {
                                        "type": "array",
                                        "items": {
                                            "type": "object",
                                            "xml": {
                                                "name": "items"
                                            },
                                            "properties": {
                                                "_CustomAuditInfoKey": {
                                                    "type": "string"
                                                },
                                                "value": {
                                                    "type": "string"
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            "prop": {
                                "type": "string"
                            },
                            "prop2": {
                                "type": "string"
                            }
                        }
                    }]
                },
                "SAMLData": {
                    "type": "object",
                    "xml": {
                        "name": "SAMLData"
                    },
                    "properties": {
                        "UserName": {
                            "type": "string"
                        },
                        "HSRoles": {
                            "type": "string",
                            "description": "Comma delimited string of roles"
                        },
                        "Organization": {
                            "type": "string",
                            "description": "The name of the organization"
                        },
                        "OrganizationOID": {
                            "type": "string",
                            "description": "OID from SAML assertion"
                        },
                        "RHIO": {
                            "type": "string",
                            "description": "OIDMap entry for User's RHIO"
                        },
                        "NPI": {
                            "type": "string",
                            "description": "National Provider Identifier"
                        },
                        "BreakTheGlass": {
                            "type": "boolean"
                        },
                        "PurposeOfUse": {
                            "type": "object",
                            "description": "(PurposeOfUse) "
                        },
                        "Token": {
                            "type": "string"
                        },
                        "LoginDomain": {
                            "type": "string"
                        },
                        "SAMLInfo": {
                            "description": "Anything stored in the SAMLInfo array will be passed from message to message",
                            "type": "object",
                            "xml": {
                                "name": "SAMLInfo"
                            },
                            "properties": {
                                "SAMLInfoItem": {
                                    "type": "array",
                                    "items": {
                                        "type": "object",
                                        "xml": {
                                            "name": "items"
                                        },
                                        "properties": {
                                            "_SAMLInfoKey": {
                                                "type": "string"
                                            },
                                            "value": {
                                                "type": "string"
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        "IDType": {
                            "type": "string",
                            "enum": ["HPII", "PortalUserIdentifier", "LocalSystemIdentifier"],
                            "description": "Australian specific properties"
                        },
                        "UseRoleForAudit": {
                            "type": "boolean",
                            "description": "Australian specific properties"
                        },
                        "IHINumber": {
                            "type": "string",
                            "description": "Australian specific properties"
                        },
                        "ClientSystemType": {
                            "type": "string",
                            "enum": ["CIS", "CSP", "CRP", "HI", "Medicare", "CPP", "CCP", "Other"],
                            "description": "Australian specific properties"
                        },
                        "OrganizationID": {
                            "type": "string",
                            "description": "Australian specific properties\nUS spelling which matches Organization inherited from HS.IHE.XUA.SAMLData (HPI-O)"
                        },
                        "Issuer": {
                            "type": "string",
                            "description": "Content of Issuer element in SAML Assertion"
                        },
                        "SubjectSPProvidedID": {
                            "type": "string",
                            "description": "SPProvidedID attribute of Subject element in SAML Assertion, if it exists"
                        },
                        "Subject": {
                            "type": "string",
                            "description": "Content of Subject element in SAML Assertion"
                        }
                    }
                },
                "Data": {
                    "type": "object",
                    "xml": {
                        "name": "Data"
                    },
                    "properties": {
                        "UserName": {
                            "type": "string"
                        },
                        "HSRoles": {
                            "type": "string",
                            "description": "Comma delimited string of roles"
                        },
                        "Organization": {
                            "type": "string",
                            "description": "The name of the organization"
                        },
                        "OrganizationOID": {
                            "type": "string",
                            "description": "OID from SAML assertion"
                        },
                        "RHIO": {
                            "type": "string",
                            "description": "OIDMap entry for User's RHIO"
                        },
                        "NPI": {
                            "type": "string",
                            "description": "National Provider Identifier"
                        },
                        "BreakTheGlass": {
                            "type": "boolean"
                        },
                        "PurposeOfUse": {
                            "type": "object",
                            "description": "(PurposeOfUse) "
                        },
                        "Token": {
                            "type": "string"
                        },
                        "LoginDomain": {
                            "type": "string"
                        },
                        "SAMLInfo": {
                            "description": "Anything stored in the SAMLInfo array will be passed from message to message",
                            "type": "object",
                            "xml": {
                                "name": "SAMLInfo"
                            },
                            "properties": {
                                "SAMLInfoItem": {
                                    "type": "array",
                                    "items": {
                                        "type": "object",
                                        "xml": {
                                            "name": "items"
                                        },
                                        "properties": {
                                            "_SAMLInfoKey": {
                                                "type": "string"
                                            },
                                            "value": {
                                                "type": "string"
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        "UseRoleForAudit": {
                            "type": "boolean",
                            "description": "Australian specific properties"
                        },
                        "IHINumber": {
                            "type": "string",
                            "description": "Australian specific properties"
                        },
                        "OrganizationID": {
                            "type": "string",
                            "description": "Australian specific properties\nUS spelling which matches Organization inherited from HS.IHE.XUA.SAMLData (HPI-O)"
                        },
                        "Issuer": {
                            "type": "string",
                            "description": "Content of Issuer element in SAML Assertion"
                        },
                        "SubjectSPProvidedID": {
                            "type": "string",
                            "description": "SPProvidedID attribute of Subject element in SAML Assertion, if it exists"
                        },
                        "Subject": {
                            "type": "string",
                            "description": "Content of Subject element in SAML Assertion"
                        },
                        "IDType": {
                            "type": "string",
                            "enum": ["HPII", "PortalUserIdentifier", "LocalSystemIdentifier"]
                        },
                        "ClientSystemType": {
                            "type": "string",
                            "enum": ["CIS", "CSP", "CRP", "HI", "Medicare", "CPP", "CCP", "Other"]
                        },
                        "Role": {
                            "type": "string",
                            "description": "Deprecated us HSRoles from SAMLData"
                        }
                    }
                },
                "AllDT": {
                    "type": "object",
                    "xml": {
                        "name": "AllDT"
                    },
                    "properties": {
                        "DT1": {
                            "type": "string"
                        },
                        "P01": {
                            "type": "integer",
                            "format": "int64",
                            "description": "(long) "
                        },
                        "P02": {
                            "type": "string",
                            "format": "binary",
                            "description": "(base64Binary) "
                        },
                        "P03": {
                            "type": "boolean"
                        },
                        "P04": {
                            "type": "string"
                        },
                        "P05": {
                            "type": "integer",
                            "format": "int64",
                            "description": "(long) "
                        },
                        "P06": {
                            "type": "number"
                        },
                        "P07": {
                            "type": "string",
                            "format": "date"
                        },
                        "P08": {
                            "type": "string",
                            "format": "date-time"
                        },
                        "P09": {
                            "type": "number"
                        },
                        "P10": {
                            "type": "number",
                            "description": "(double) "
                        },
                        "P11": {
                            "type": "string"
                        },
                        "P12": {
                            "type": "string"
                        },
                        "P13": {
                            "type": "integer",
                            "format": "int64",
                            "description": "(long) "
                        },
                        "P14": {
                            "type": "string"
                        },
                        "P15": {
                            "type": "string"
                        },
                        "P16": {
                            "type": "string"
                        },
                        "P17": {
                            "type": "number"
                        },
                        "P19": {
                            "type": "integer",
                            "description": "(short) "
                        },
                        "P20": {
                            "type": "string",
                            "format": "binary",
                            "description": "(base64Binary) "
                        },
                        "P21": {
                            "type": "string"
                        },
                        "P22": {
                            "type": "integer",
                            "description": "(time) "
                        },
                        "P23": {
                            "type": "string",
                            "format": "date-time"
                        },
                        "P24": {
                            "type": "integer",
                            "description": "(byte) "
                        },
                        "S01": {
                            "type": "string"
                        },
                        "S02": {
                            "type": "string",
                            "format": "binary",
                            "description": "(base64Binary) "
                        },
                        "S03": {
                            "type": "string"
                        },
                        "S04": {
                            "type": "string",
                            "format": "binary",
                            "description": "(base64Binary) "
                        },
                        "L01": {
                            "type": "object",
                            "xml": {
                                "name": "L01"
                            },
                            "properties": {
                                "L01Item": {
                                    "type": "array",
                                    "items": {
                                        "type": "string"
                                    }
                                }
                            }
                        },
                        "L02": {
                            "type": "object",
                            "xml": {
                                "name": "L02"
                            },
                            "properties": {
                                "A6": {
                                    "type": "array",
                                    "items": {
                                        "allOf": [{
                                            "$ref": "#/components/schemas/A6"
                                        }]
                                    }
                                }
                            }
                        },
                        "AR01": {
                            "type": "object",
                            "xml": {
                                "name": "AR01"
                            },
                            "properties": {
                                "AR01Item": {
                                    "type": "array",
                                    "items": {
                                        "type": "object",
                                        "xml": {
                                            "name": "items"
                                        },
                                        "properties": {
                                            "_AR01Key": {
                                                "type": "string"
                                            },
                                            "value": {
                                                "type": "string"
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        "AR02": {
                            "type": "object",
                            "xml": {
                                "name": "AR02"
                            },
                            "properties": {
                                "A6": {
                                    "type": "array",
                                    "items": {
                                        "allOf": [{
                                            "$ref": "#/components/schemas/A6"
                                        }, {
                                            "type": "object",
                                            "xml": {
                                                "name": "items"
                                            },
                                            "properties": {
                                                "_AR02Key": {
                                                    "type": "string"
                                                }
                                            }
                                        }]
                                    }
                                }
                            }
                        },
                        "AR03": {
                            "type": "object",
                            "xml": {
                                "name": "AR03"
                            },
                            "properties": {
                                "AR03Item": {
                                    "type": "array",
                                    "items": {
                                        "type": "object",
                                        "xml": {
                                            "name": "items"
                                        },
                                        "properties": {
                                            "_AR03Key": {
                                                "type": "string"
                                            },
                                            "value": {
                                                "type": "integer",
                                                "format": "int64"
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        "A01": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A1"
                            }]
                        },
                        "A07": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A7"
                            }]
                        },
                        "A08": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A8"
                            }]
                        },
                        "A09": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A9"
                            }]
                        },
                        "A10": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A10"
                            }]
                        },
                        "A11": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A11"
                            }]
                        }
                    }
                },
                "A6": {
                    "type": "object",
                    "xml": {
                        "name": "A6"
                    },
                    "properties": {
                        "P6S90": {
                            "type": "string"
                        },
                        "P6S1": {
                            "type": "string",
                            "enum": ["A", "B", "C", "D", "E", "F"]
                        },
                        "P6I1": {
                            "type": "integer",
                            "format": "int64",
                            "description": "(long) "
                        }
                    },
                    "required": [
                        "P6S90"
                    ]
                },
                "A1": {
                    "type": "object",
                    "xml": {
                        "name": "A1"
                    },
                    "properties": {
                        "P1S40": {
                            "type": "string"
                        },
                        "P4S1": {
                            "type": "string",
                            "enum": ["A", "B", "C", "D", "E", "F"]
                        },
                        "A2": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A2"
                            }]
                        }
                    }
                },
                "A2": {
                    "type": "object",
                    "xml": {
                        "name": "A2"
                    },
                    "properties": {
                        "P2S50": {
                            "type": "string"
                        },
                        "P2S1": {
                            "type": "integer",
                            "format": "int64",
                            "enum": [3, 4, 5, 6, 7, 8],
                            "description": "(long) "
                        },
                        "A3": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A3"
                            }]
                        }
                    }
                },
                "A3": {
                    "type": "object",
                    "xml": {
                        "name": "A3"
                    },
                    "properties": {
                        "P3S60": {
                            "type": "string"
                        },
                        "P3S1": {
                            "type": "string",
                            "enum": ["A", "B", "C", "D", "E", "F"]
                        },
                        "A4": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A4"
                            }]
                        }
                    }
                },
                "A4": {
                    "type": "object",
                    "xml": {
                        "name": "A4"
                    },
                    "properties": {
                        "P4S70": {
                            "type": "string"
                        },
                        "P4S1": {
                            "type": "string",
                            "enum": ["A", "B", "C", "D", "E", "F"]
                        },
                        "A5": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A5"
                            }]
                        }
                    }
                },
                "A5": {
                    "type": "object",
                    "xml": {
                        "name": "A5"
                    },
                    "properties": {
                        "P5S80": {
                            "type": "string"
                        },
                        "P5S1": {
                            "type": "integer",
                            "format": "int64",
                            "enum": [1, 2, 3, 4, 5, 6],
                            "description": "(long) "
                        },
                        "A6": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A6"
                            }]
                        }
                    }
                },
                "A7": {
                    "type": "object",
                    "xml": {
                        "name": "A7"
                    },
                    "properties": {
                        "L7S1": {
                            "type": "object",
                            "xml": {
                                "name": "L7S1"
                            },
                            "properties": {
                                "L7S1Item": {
                                    "type": "array",
                                    "items": {
                                        "type": "string"
                                    }
                                }
                            }
                        },
                        "P7S1": {
                            "type": "string",
                            "format": "date"
                        }
                    }
                },
                "A8": {
                    "type": "object",
                    "xml": {
                        "name": "A8"
                    },
                    "properties": {
                        "A8S1": {
                            "type": "object",
                            "xml": {
                                "name": "A8S1"
                            },
                            "properties": {
                                "A8S1Item": {
                                    "type": "array",
                                    "items": {
                                        "type": "object",
                                        "xml": {
                                            "name": "items"
                                        },
                                        "properties": {
                                            "_A8S1Key": {
                                                "type": "string"
                                            },
                                            "value": {
                                                "type": "string"
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        "P8S1": {
                            "type": "string",
                            "format": "date-time"
                        }
                    }
                },
                "A9": {
                    "type": "object",
                    "xml": {
                        "name": "A9"
                    },
                    "properties": {
                        "L9S1": {
                            "type": "object",
                            "xml": {
                                "name": "L9S1"
                            },
                            "properties": {
                                "A6": {
                                    "type": "array",
                                    "items": {
                                        "allOf": [{
                                            "$ref": "#/components/schemas/A6"
                                        }]
                                    }
                                }
                            }
                        },
                        "P9S1": {
                            "type": "string",
                            "format": "date"
                        }
                    }
                },
                "A10": {
                    "type": "object",
                    "xml": {
                        "name": "A10"
                    },
                    "properties": {
                        "A10S1": {
                            "type": "object",
                            "xml": {
                                "name": "A10S1"
                            },
                            "properties": {
                                "A6": {
                                    "type": "array",
                                    "items": {
                                        "allOf": [{
                                            "$ref": "#/components/schemas/A6"
                                        }, {
                                            "type": "object",
                                            "xml": {
                                                "name": "items"
                                            },
                                            "properties": {
                                                "_A10S1Key": {
                                                    "type": "string"
                                                }
                                            }
                                        }]
                                    }
                                }
                            }
                        },
                        "P8S1": {
                            "type": "string",
                            "format": "date-time"
                        }
                    }
                },
                "A11": {
                    "type": "object",
                    "xml": {
                        "name": "A11"
                    },
                    "properties": {
                        "S11": {
                            "type": "string"
                        },
                        "A12": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A12"
                            }]
                        }
                    }
                },
                "A12": {
                    "type": "object",
                    "xml": {
                        "name": "A12"
                    },
                    "properties": {
                        "S12": {
                            "type": "string"
                        },
                        "I12": {
                            "type": "integer",
                            "format": "int64",
                            "description": "(long) "
                        },
                        "A13": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A13"
                            }]
                        }
                    },
                    "required": [
                        "S12",
                        "I12"
                    ]
                },
                "A13": {
                    "type": "object",
                    "xml": {
                        "name": "A13"
                    },
                    "properties": {
                        "S13": {
                            "type": "string"
                        },
                        "A11": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A11"
                            }]
                        }
                    }
                },
                "A14": {
                    "type": "object",
                    "xml": {
                        "name": "A14"
                    },
                    "properties": {
                        "S14": {
                            "type": "string"
                        },
                        "A13": {
                            "allOf": [{
                                "$ref": "#/components/schemas/A13"
                            }]
                        }
                    }
                },
                "A15": {
                    "allOf": [{
                        "$ref": "#/components/schemas/A14"
                    }, {
                        "type": "object",
                        "xml": {
                            "name": "A15"
                        },
                        "properties": {
                            "S13": {
                                "type": "string"
                            },
                            "A11": {
                                "allOf": [{
                                    "$ref": "#/components/schemas/A11"
                                }]
                            },
                            "S15": {
                                "type": "string"
                            }
                        }
                    }]
                },
                "arrayOfA6": {
                    "type": "array",
                    "items": {
                        "$ref": "#/components/schemas/A6"
                    }
                },
                "arrayOfA1": {
                    "type": "array",
                    "items": {
                        "$ref": "#/components/schemas/A1"
                    }
                },
                "arrayOfA11": {
                    "type": "array",
                    "items": {
                        "$ref": "#/components/schemas/A11"
                    }
                },
                "arrayOfA13": {
                    "type": "array",
                    "items": {
                        "$ref": "#/components/schemas/A13"
                    }
                },
                "ComplexArray": {
                    "type": "array",
                    "items": {
                        "type": "string",
                        "example": "3"
                    }
                },
                "responseStatus": {
                    "type": "object",
                    "properties": {
                        "statusCode": {
                            "type": "string"
                        },
                        "message": {
                            "type": "string"
                        },
                        "errorCode": {
                            "type": "string"
                        }
                    },
                    "required": [
                        "message",
                        "errorCode"
                    ]
                },
                "genericArray": {
                        "type": "array",
                        "items": {
                            "anyOf": [{
                                "type": "object"
                            }, {
                                "type": "string"
                            }, {
                                "type": "number"
                            }, {
                                "type": "boolean"
                            }]
                    }
                }

        }
        //Set tSC = ..GetFlatSchema(tSchemas,.tFlatSchemas)
        Set myObj = {
            "DT1": "MyDataType",
            "P01": 123456789,
            "P02": "QmluYXJ5",
            "P03": false,
            "P04": "J",
            "P05": 129,
            "P06": 619.45,
            "P07": "2020-04-13",
            "P08": "2020-07-21T22:05:37Z",
            "P09": 1062.78,
            "P10": 966.01,
            "P11": "EnumString",
            "P12": "ExactStrin",
            "P13": 5408,
            "P14": "a,b,c,d",
            "P15": "Zg==,Zw==,aA==,aQ==",
            "P16": "Doe, John",
            "P17": 774.78,
            "P19": 766,
            "P20": "MCCTAQQEiRMMAUVycm8gdGVzdGUBAQEBAQEBegEBDAFIU1JFR0lTVFJZawEgAWVeJUNvbnN0cnVj\ndCs0Xk15QXBwLkFsbERULjFeNSEBZV56TG9vcCsxNl5XZWJUZXJtaW5hbC5Db3JlLjFeMSEBeF56\nTG9vcCsxNl5XZWJUZXJtaW5hbC5Db3JlLjFeMQcBZF5eXjA=",
            "P21": "Qualquer String",
            "P22": 20,
            "P23": "2020-07-21T22:05:37Z",
            "P24": 5,
            "S01": "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789",
            "S02": "MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODk=",
            "S03": "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789",
            "S04": "MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODk=",
            "L01": {
                "L01Item": ["0123456789012", "0123456789", "01234567890123456789", "012345678901"]
            },
            "L02": {
                "A6": [{
                    "P6S90": "P6S90   10",
                    "P6S1": "A",
                    "P6I1": 6
                }]
            },
            "AR01": {
                "AR01Item": [{
                    "value": "DEF",
                    "_AR01Key": "1"
                }, {
                    "value": "ABC",
                    "_AR01Key": "2"
                }, {
                    "value": "CDE",
                    "_AR01Key": "3"
                }, {
                    "value": "ABC",
                    "_AR01Key": "4"
                }]
            },
            "AR02": {
                "A6": [{
                    "_AR02Key": "1",
                    "P6S90": "P6S90   10",
                    "P6S1": "A",
                    "P6I1": 6
                }, {
                    "_AR02Key": "2",
                    "P6S90": "P6S90   10",
                    "P6S1": "A",
                    "P6I1": 6
                }, {
                    "_AR02Key": "3",
                    "P6S90": "P6S90   10",
                    "P6S1": "C",
                    "P6I1": 6
                }, {
                    "_AR02Key": "4",
                    "P6S90": "P6S90   10",
                    "P6S1": "A",
                    "P6I1": 6
                }, {
                    "_AR02Key": "5",
                    "P6S90": "P6S90   10",
                    "P6S1": "E",
                    "P6I1": 6
                }, {
                    "_AR02Key": "6",
                    "P6S90": "P6S90   10",
                    "P6S1": "A",
                    "P6I1": 6
                }, {
                    "_AR02Key": "7",
                    "P6S90": "P6S90   10",
                    "P6S1": "A",
                    "P6I1": 6
                }]
            },
            "A01": {
                "P1S40": "P1S40",
                "P4S1": "B",
                "A2": {
                    "P2S50": "P2S50",
                    "P2S1": 3,
                    "A3": {
                        "P3S60": "P3S60 Texto",
                        "P3S1": "C",
                        "A4": {
                            "P4S70": "P4S70     012345678901234567890123456789012345678901234567890123456789",
                            "P4S1": "E",
                            "A5": {
                                "P5S80": "P5S80  8",
                                "P5S1": 4,
                                "A6": {
                                    "P6S90": "P6S90   10",
                                    "P6S1": "A",
                                    "P6I1": 6
                                }
                            }
                        }
                    }
                }
            },
            "A07": {
                "L7S1": {
                    "L7S1Item": ["L7S1 1", "L7S1 2", "L7S1 3", "L7S1 4", "L7S1 5", "L7S1 6", "L7S1 7", "L7S1 8", "L7S1 9", "L7S1 10"]
                },
                "P7S1": "2020-07-21"
            },
            "A08": {
                "A8S1": {
                    "A8S1Item": [{
                        "value": "A8S1 1",
                        "_A8S1Key": "Key 1"
                    }, {
                        "value": "A8S1 10",
                        "_A8S1Key": "Key 10"
                    }, {
                        "value": "A8S1 2",
                        "_A8S1Key": "Key 2"
                    }, {
                        "value": "A8S1 3",
                        "_A8S1Key": "Key 3"
                    }, {
                        "value": "A8S1 4",
                        "_A8S1Key": "Key 4"
                    }, {
                        "value": "A8S1 5",
                        "_A8S1Key": "Key 5"
                    }, {
                        "value": "A8S1 6",
                        "_A8S1Key": "Key 6"
                    }, {
                        "value": "A8S1 7",
                        "_A8S1Key": "Key 7"
                    }, {
                        "value": "A8S1 8",
                        "_A8S1Key": "Key 8"
                    }, {
                        "value": "A8S1 9",
                        "_A8S1Key": "Key 9"
                    }]
                },
                "P8S1": "2020-07-21T22:05:37Z"
            },
            "A09": {
                "L9S1": {
                    "A6": [{
                        "P6S90": "P6S90   10",
                        "P6S1": "A",
                        "P6I1": 6
                    }, {
                        "P6S90": "P6S90   10",
                        "P6S1": "A",
                        "P6I1": 6
                    }, {
                        "P6S90": "P6S90   10",
                        "P6S1": "A",
                        "P6I1": 6
                    }, {
                        "P6S90": "P6S90   10",
                        "P6S1": "A",
                        "P6I1": 6
                    }, {
                        "P6S90": "P6S90   10",
                        "P6S1": "A",
                        "P6I1": 6
                    }, {
                        "P6S90": "P6S90   10",
                        "P6S1": "A",
                        "P6I1": 6
                    }, {
                        "P6S90": "P6S90   10",
                        "P6S1": "A",
                        "P6I1": 6
                    }, {
                        "P6S90": "P6S90   10",
                        "P6S1": "A",
                        "P6I1": 6
                    }, {
                        "P6S90": "P6S90   10",
                        "P6S1": "A",
                        "P6I1": 6
                    }, {
                        "P6S90": "P6S90   10",
                        "P6S1": "A",
                        "P6I1": 6
                    }]
                },
                "P9S1": "2020-07-21"
            },
            "A10": {
                "P8S1": "2020-07-21T22:05:37Z"
            },
            "A11": {
                "S11": "String A11",
                "A12": {
                    "S12": "String A12",
                    "I12": 12,
                    "A13": {
                        "S13": "String A13",
                        "A11": {
                            "S11": "String A11",
                            "A12": {
                                "S12": "String A12",
                                "I12": 12,
                                "A13": {
                                    "S13": "String A13",
                                    "A11": {
                                        "S11": "String A11",
                                        "A12": {
                                            "S12": "String A12",
                                            "I12": 12
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //Set myArray = [1,2,3,"abc",{"prop":1}]
        Set tSC = ..Parse("AllDT",myObj,tSchemas,.tResult)
        //Set tSC = ..Parse("genericArray",myArray,tSchemas,.tResult)
	}
	Catch(e)
	{
        w $System.Status.GetOneErrorText(e.AsStatus()),!
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

}

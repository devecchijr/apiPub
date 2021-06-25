Class apiPub.tracer.bp.rule.utils Extends Ens.Rule.FunctionSet
{

// Utility methods to use inside rules for json manipulation 

ClassMethod Age(pdate As %String, pType As %String = "Y") As %Integer [ Final ]
{
    If pdate="" Quit 0
    Quit $H-$ZDTH($TR(pdate,"Z",""),3)/$Select(pType="Y":365, pType="M":30, 1:1)
}

ClassMethod Date(pString As %String) As %String [ Final ]
{
    If pString="" Quit 0
    Quit $ZDTH($TR(pString,"Z",""),3)
}

ClassMethod PrintJSON(pJSON As %Library.DynamicObject) As %String
{
    Quit pJSON.%ToJSON()
}

ClassMethod ToJSON(pJSON As %Library.DynamicObject) As %String
{
    Quit pJSON.%ToJSON()
}

ClassMethod IsUndefined(pVar) As %Boolean
{
    Quit (pVar="")
}

ClassMethod IsDefined(pVar) As %Boolean
{
    Quit (pVar'="")
}

ClassMethod CloneJSON(pJSON As %Library.DynamicObject) As %Library.DynamicObject
{
    Quit ##class(%Library.DynamicObject).%FromJSON(pJSON.%ToJSON())
}

ClassMethod FromJSON(pJSON As %String) As %Library.DynamicObject
{
    Quit ##class(%Library.DynamicObject).%FromJSON(pJSON)
}

ClassMethod Coalesce(params...) As %Library.DynamicObject [ Final ]
{
    If '$D(params) Quit ""
    For i=1:1:params {
        If $Get(params(i))'="" Return params(i)
    }
    Quit params(params)
}

ClassMethod Get(pObj As %Library.DynamicObject, pKey As %String, pDelim As %String = ".") As %Library.DynamicObject [ Final ]
{
    Quit ..GetByLineKey(pObj, pKey, pDelim)
}

ClassMethod GetByLineKey(pObj As %Library.DynamicObject, pKey As %String, pDelim As %String = ".") As %Library.DynamicObject [ Final ]
{
    Set tRef=""
    Try
	{
        Return ##class(apiPub.core.jsonBuilder).GetByLineKey(pObj, pKey, pDelim) 
    }
	Catch(e)
	{
        Set tSC = e.AsStatus()
	}
    Quit tRef
}

ClassMethod Set(pObj As %Library.DynamicObject, pKey As %String, pValue As %Library.DynamicObject, pType As %String = "", pDelim As %String = ".", pInferBoolean As %Boolean = 1) As %Status [ Final ]
{
    Quit ..SetByLineKey(pObj, pKey, pValue, pType, pDelim, pInferBoolean)
}

ClassMethod SetByLineKey(pObj As %Library.DynamicObject, pKey As %String, pValue As %Library.DynamicObject, pType As %String = "", pDelim As %String = ".", pInferBoolean As %Boolean = 1) As %Status [ Final ]
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set tSC = ##class(apiPub.core.jsonBuilder).SetByLineKey(pObj, pKey, pValue, pType)
    }
	Catch(e)
	{
        Set tSC = e.AsStatus()
	}
    Quit tSC
}

ClassMethod Filter(pArray As %Library.DynamicObject, pCallBackClause As %String, pCallBackMethod As %String = "", Output pIndex As %Integer) As %Library.DynamicObject [ Final ]
{
    Set pIndex = -1
    If '$Data(pArray)||'$IsObject(pArray) Quit []
	Set tSC = $System.Status.OK()
    Set tFinalArray=$Select($ClassName(pArray)="%Library.DynamicArray":[],1:{})
    Try
	{
        If pCallBackMethod ="" Set pCallBackClause=..ParseClause(pCallBackClause,3)
        Set tElem = pArray.%GetIterator()
        While (tElem.%GetNext(.key,.value)) {
            If pCallBackMethod'="" {
                Set filter = $ClassMethod($Piece(pCallBackMethod,".",1,*-1),$Piece(pCallBackMethod,".",*),value,key,pArray)
            } Else {
                Set filter=$XECUTE(pCallBackClause,value,key,pArray)
            }
            If filter {                       
                If $ClassName(tFinalArray)="%Library.DynamicArray" 
                {
                    Do tFinalArray.%Push(value) 
                } Else {
                    Do tFinalArray.%Set(key,value,pArray.%GetTypeOf(key)) 
                }
                Set pIndex = key
            }
        }
    }
	Catch(e)
	{
		Write $System.Status.DisplayError(e.AsStatus())
        Set tSC = e.AsStatus()
	}
    Quit tFinalArray
}

ClassMethod ParseClause(pClause As %String, pNumParams As %Integer = 1) As %String [ Final ]
{
    Set tSC = $System.Status.OK()
    If $Find(pClause,"=>")=0 Set tSC = $System.Status.Error(-1,"Invalid clause")
    If $Piece($Translate($Piece(pClause,"=>"),"()",""),",",1)="" {
        Set tSC = $System.Status.Error(-1,"param ("_1_") undefined")        
    }
    If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }

    Set tParams=""
    For i=1:1:pNumParams {
        Set tName=$Piece($Translate($Piece(pClause,"=>",1),"()",""),",",i)
        Set tParams=$Select(tParams'="":tParams_",",1:"")_$Select(tName'="":tName,1:"p"_i)
    }
    Set pClause="("_tParams_") "_$Piece(pClause,"=>",2)
    Set pClause=$Replace(pClause,";","  ")
    Quit pClause
}

}

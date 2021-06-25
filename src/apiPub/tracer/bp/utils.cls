Class apiPub.tracer.bp.utils Extends %RegisteredObject
{

// Utility methods to use inside bpl for json manipulation 

Method Get(pObj As %Library.DynamicObject, pKey As %String, pDelim As %String = ".") As %Library.DynamicObject
{
    Quit ##class(apiPub.core.jsonBuilder).GetByLineKey(pObj, pKey, pDelim)
}

Method Set(pObj As %Library.DynamicObject, pKey As %String, pValue As %Library.DynamicObject, pType As %String = "", pDelim As %String = ".", pInferBoolean As %Boolean = 1) As %Status
{
    Quit ##class(apiPub.core.jsonBuilder).SetByLineKey(pObj, pKey, pValue, pType)
}

Method GetNextObject(pJSON As %Library.DynamicObject, pKey As %String, ByRef pCtrlObj As %Library.DynamicObject, ByRef pOutputObj As %Library.DynamicObject, pDelim As %String = ".") As %Boolean
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
            Set tArray = ##class(apiPub.core.jsonBuilder).GetByLineKey(pJSON, pKey, pDelim)
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

}

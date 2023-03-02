/// This is our raw class with no apiPub customizations
Class apiPub.samples.demo.api Extends %RegisteredObject [ ProcedureBlock ]
{

/// This description is publish as OAS summary.
ClassMethod t01OperationDefaults(Output defaults As %DynamicArray) As %Status [ WebMethod ]
{
    Set defaults = [
        "01 - By default, the api path is the method name.",
        "02 - The OAS header is set on XData block. It's not required.",
        "03 - 200 is the the default code for successful responses and 500 (try it) for internal exceptions.",
        "04 - If there is no complex input parameter (object or stream) the default verb is Get. Otherwise is Post.",
        "05 - Status response type is always published as an output header property."
    ]
    Quit $$$OK
}

/// For application/json response, the node name is "response"
ClassMethod t02Division(pUser As %String, val1 As %Numeric, val2 As %Numeric) As %String [ WebMethod ]
{
  If val2 = 0 Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "The divider value could not be zero"))
  Quit "Hello "_pUser_"! The division result is: "_(val1/val2)
}

/// Multiple inputs and responses. 
Method t03ManyTypes(firstPar As %String = "abc", ByRef secondPar As %DateTime = "2010-01-01 12:00", Output thirdPar As %Numeric, fourfhPar As %Boolean = 0, Output tSC As %Status) As %DynamicArray [ WebMethod ]
{
    Do ..t01OperationDefaults(.tResponse)
    Do tResponse.%Push("06 - Both class and instance methods work")
    Do tResponse.%Push("07 - Every input or output parameter is published")
    Do tResponse.%Push("08 - Simple/primitive type input param by default is published as a query param")
    Do tResponse.%Push("09 - Single or multiple responses matters (try it). For multiple responses, the name of each param is used as an output node.")
    Do tResponse.%Push("10 - For multiple responses or simple types the default name node for method response is ""response""")
    Set thirdPar = 123
    Set tSC = $$$OK
    Quit tResponse
}

/// Iris objects schemas are also published.
Method t04ObjectAsInputAndOutput(code As %Integer, obj As apiPub.samples.demo.myObj) As apiPub.samples.demo.myObj [ WebMethod ]
{
    Quit obj
}

/// You can relate OAS 3.0 schemas with your input param or response
Method t05DynamicTypes(obj As %DynamicObject) As %DynamicObject [ WebMethod ]
{
  Quit obj
}

/// One Input, Many outputs (under nodes)
Method t06ManyOutputs(ByRef obj As apiPub.samples.demo.myObj) As apiPub.samples.demo.myObj [ WebMethod ]
{
    Quit obj
}

/// Many Inputs, Many outputs (under nodes)
Method t07ManyComplexInOut(obj1 As apiPub.samples.demo.myObj, ByRef obj2 As apiPub.samples.demo.myObj) As apiPub.samples.demo.myObj [ WebMethod ]
{
    Quit obj1
}

}

/// This is our raw class with no apiPub customizations
Class apiPub.samples.demo.api Extends %RegisteredObject [ ProcedureBlock ]
{

/// This description is publish as OAS summary.
ClassMethod t00NoInOut() [ WebMethod ]
{
}

/// ApiPub uses the entire method specification to easily and instantly publish Apis, so assumptions are needed.
ClassMethod t01Assumptions(Output assumptions As %DynamicArray) As %Status [ WebMethod ]
{
    Set assumptions = [
        "01 - By default, the api path is the method name.",
        "02 - Application/json is the default Output Type.",
        "03 - The class name is the default OAS title and description.",
        "04 - 200 is the the default code for successful responses and 500 for internal exceptions.",
        "05 - If there is no complex input parameter (object or stream) the default verb is Get. Otherwise is Post.",
        "06 - Status response type is always published as an output header property."
    ]
    Quit $$$OK
}

/// Assumptions for Multiple inputs and responses. 
Method t02ParamAssumptions(firstPar As %String = "abc", ByRef secondPar As %DateTime = "2010-01-01T12:00:00", Output thirdPar As %Numeric, fourfhPar As %Boolean = 0, Output tSC As %Status) As %DynamicArray [ WebMethod ]
{
    Do ..t01Assumptions(.tResponse)
    Do tResponse.%Push("07 - Both class and instance methods work.")
    Do tResponse.%Push("08 - Every input or output parameter is published and its name is used.")
    Do tResponse.%Push("09 - Simple/primitive input param type by default is published as a query param.")
    Do tResponse.%Push("10 - Single or multiple responses matters. For multiple responses, the name of each param is used as an output node.")
    Do tResponse.%Push("11 - For multiple responses or simple types the default name node for method response is ""response""")
    Set thirdPar = 123
    Set tSC = $$$OK
    Quit tResponse
}

/// For application/json response with primitive types, the node name is "response"
ClassMethod t03Division(pUser As %String, val1 As %Numeric, val2 As %Numeric) As %String [ WebMethod ]
{
  If val2 = 0 Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "The divider value could not be zero"))
  Quit "Hello "_pUser_"! The division result is: "_(val1/val2)
}

/// Iris objects schemas are also published.
Method t04ObjectAsInputAndOutput(code As %Integer = 1, obj As apiPub.samples.demo.myObj) As apiPub.samples.demo.myObj [ WebMethod ]
{
    Quit obj
}

/// You can relate OAS 3.0 schemas with your input param or response
Method t05DynamicTypes(obj As %DynamicObject) As %DynamicObject [ WebMethod ]
{
  Quit obj
}

/// One Input, Multiple outputs (under nodes)
Method t06ManyOutputs(ByRef obj As apiPub.samples.demo.myObj) As %ListOfObjects(ELEMENTTYPE="apiPub.samples.demo.myObj") [ WebMethod ]
{
    Set tResponse = ##class(%ListOfObjects).%New()
    Do tResponse.Insert(obj)
    Do tResponse.Insert(obj)
    Quit tResponse
}

/// Multiple Inputs and Outputs (under nodes)
Method t07ManyComplexInOut(obj1 As apiPub.samples.demo.myObj, ByRef obj2 As apiPub.samples.demo.myObj) As apiPub.samples.demo.myObj [ WebMethod ]
{
    Quit obj1
}

}

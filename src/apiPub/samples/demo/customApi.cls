/// This is our class with apiPub customizations
Class apiPub.samples.demo.api Extends %RegisteredObject [ ProcedureBlock ]
{

/// This description is publish as OAS summary.
/// @apiPub[tag="no complex input params"]
/// @apiPub[path="doSomething"]
/// @apiPub[verb="patch"]
ClassMethod t00NoInOut() [ WebMethod ]
{
}

/// Through Customization you can shape the user experience of your API.
/// @apiPub[tag="no complex input params"]
/// @apiPub[path="assumptions"]
/// @apiPub[description="This is a complete description of our API"]
/// @apiPub[params.assumptions.description="array with apiPub operation definitions"]
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
/// @apiPub[tag="no complex input params"]
/// @apiPub[path="/multipleTypes"]
/// @apiPub[params.firstPar.description="first param description"]
/// @apiPub[params.secondPar.description="this is datetime"]
/// @apiPub[params.secondPar.name="dob"]
/// @apiPub[params.thirdPar.description="this is a numeric"]
/// @apiPub[params.fourfhPar.description="this is a boolean"]
/// @apiPub[response.description="array with apiPub operation definitions"]
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

/// For application/json response, the node name is "response", 
/// but you can define another response type 
/// @apiPub[tag="no complex input params"]
/// @apiPub[path="/division/{dividend}/by/{divider}"]
/// @apiPub[params.val1.name="dividend"]
/// @apiPub[params.val1.description="please inform the dividend"]
/// @apiPub[params.val2.name="divider"]
/// @apiPub[params.val2.description="please inform the divider"]
/// @apiPub[params.pUser.name="user"]
/// @apiPub[params.pUser.description="your name"]
/// @apiPub[response.description="result of the division operation"]
/// @apiPub[response.outputType="text/plain"]
/// @apiPub[statusCodes=[{"code":"400","description":"The divider param could not be zero"}]]
ClassMethod t03Division(pUser As %String, val1 As %Numeric, val2 As %Numeric) As %String [ WebMethod ]
{
  If val2 = 0 Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "The divider value could not be zero"))
  Quit "Hello "_pUser_"! The division result is: "_(val1/val2)
}

/// @apiPub[tag="complex input params"]
/// @apiPub[path="/irisObject/{code}"]
/// @apiPub[verb="put"]
/// @apiPub[params.obj.description="sample object"]
/// @apiPub[successfulCode="201"]
/// Iris objects schemas are also published.
Method t04ObjectAsInputAndOutput(code As %Integer = 1, obj As apiPub.samples.demo.myObj) As apiPub.samples.demo.myObj [ WebMethod ]
{
    Quit obj
}

/// @apiPub[tag="complex input params"]
/// @apiPub[path="/dynamic"]
/// @apiPub[params.obj.description="sample dynamic object"]
/// @apiPub[response.description="dynamic response"]
/// You can relate OAS 3.0 schemas with your input param or response
Method t05DynamicTypes(obj As %DynamicObject) As %DynamicObject [ WebMethod ]
{
  Quit obj
}

/// @apiPub[tag="complex input params"]
/// @apiPub[path="/manyOutputs"]
/// @apiPub[params.obj.description="sample object"]
/// @apiPub[response.description="object response"]
/// @apiPub[response.name="list"]
/// One Input, Multiple outputs (under nodes)
Method t06ManyOutputs(ByRef obj As apiPub.samples.demo.myObj) As %ListOfObjects(ELEMENTTYPE="apiPub.samples.demo.myObj") [ WebMethod ]
{
    Set tResponse = ##class(%ListOfObjects).%New()
    Do tResponse.Insert(obj)
    Do tResponse.Insert(obj)
    Quit tResponse
}

/// @apiPub[tag="complex input params"]
/// @apiPub[path="/manyComplexInOut"]
/// @apiPub[params.obj1.description="sample object"]
/// @apiPub[response.description="multiple object responses"]
/// Multiple Inputs and outputs (under nodes)
Method t07ManyComplexInOut(obj1 As apiPub.samples.demo.myObj, ByRef obj2 As apiPub.samples.demo.myObj) As apiPub.samples.demo.myObj [ WebMethod ]
{
    Quit obj1
}

XData apiPub [ MimeType = application/json ]
{
{
  "info":{
    "title":"apiPub Demo",
    "description":"demonstration of how quick and easy it is to publish an API",
    "version":"1.0.0",
    "termsOfService":"http://swagger.io/terms/",
    "contact":{
      "email":"apiteam@swagger.io"
    },
    "license":{
      "name":"Apache 2.0",
      "url":"http://www.apache.org/licenses/LICENSE-2.0.html"
    }
  }
}
}

}

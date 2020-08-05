Class apiPub.service.api Extends apiPub.core.service
{

/// If false allows API Calling
Parameter OnlyOAS As %Boolean = 0;

Parameter OASPath As %String = "Get:/oas";

Parameter DispatchClass As %String = "MyApp.MyService";

/// Use TracerBSName for monitoring
Parameter Traceable As %Boolean = 0;

Parameter TracerBSName = "apiPub.tracer.bs";

Parameter APIDomain = "apiPub";

}

Class apiPub.samples.services Extends apiPub.core.service
{

/// If false allows API Calling
Parameter OnlyOAS As %Boolean = 0;

Parameter OASPath As %String = "Get:/oas";

Parameter DispatchClassOld As %String = "MyApp.MyService";

Parameter DispatchClass As %String = "apiPub.samples.api";

/// Use TracerBSName for monitoring
Parameter Traceable As %Boolean = 0;

Parameter TracerBSName = "apiPub.tracer.bs";

Parameter APIDomain = "Samples";

}

Class apiPub.samples.services Extends apiPub.core.service
{

Parameter OASPath = "Get:/_spec";

Parameter DispatchClass = "apiPub.samples.api";

/// When the Dispatch class is also a Business Service Component and has a different name
Parameter DispatchBSName;

/// Useful to treat documentation and api (urls) separately (different web applications)
Parameter DispatchBaseURL;

/// If false allows API Calling
Parameter OnlyOAS = 0;

/// Use TracerBSName for monitoring
Parameter Traceable = 0;

/// If OASNestedMode=1 publisher avoid name conflict for OAS Schemas (Complex Requests and Responses)
Parameter OASNestedMode = 0;

Parameter TracerBSName = "apiPub.tracer.bs";

Parameter APIDomain = "petStore";

}

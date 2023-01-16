Class apiPub.wizard.module Extends (apiPub.core.service, %Projection.AbstractProjection)
{

Parameter OASPath As %String = "Get:/_spec";

Parameter DispatchClass As %String = "apiPub.wizard.api";

/// When the Dispatch class is also a Business Service Component and has a different name
Parameter DispatchBSName As %String;

/// Useful to treat documentation and api (urls) separately (different web applications)
Parameter DispatchBaseURL As %String;

/// If false allows API Calling
Parameter OnlyOAS As %Boolean = 0;

/// Use TracerBSName for monitoring
Parameter Traceable As %Boolean = 0;

Parameter TracerBSName = "apiPub.tracer.bs";

Parameter BeautifyJsonBodyResponse = 0;

Parameter BeautifyJsonBodyRequest = 0;

Parameter APIDomain = "apiPub Wizard";

/// Automatically creates apiPub wizard web appplication 
ClassMethod CreateProjection(classname As %String) As %Status [ CodeMode = generator, ForceGenerate ]
{
	Set tSC = $System.Status.OK()
	Try {
        Set tCurrentNS = $namespace
        Set appPath=$Replace("/apiPub/wizard/{namespace}","{namespace}",tCurrentNS)
        zn "%SYS" 
        Set webName = appPath
        Set webProperties("DispatchClass") = "apiPub.wizard.module" 
        Set webProperties("NameSpace") = tCurrentNS
        Set webProperties("Description") = "apiPub Wizard Automation" 
        Set webProperties("Enabled") = 1 
        Set webProperties("AutheEnabled") = 32 
        Set webProperties("DeepSeeEnabled")=1 
        If '(##class(Security.Applications).Exists(webName)) {
            Set tSC = ##class(Security.Applications).Create(webName, .webProperties)
            If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) 
            If tSC=1 {
                Write !,"Creating Wizard App ",webName,"..."
            }
        }
        Write !,"Url: http://host:port/swagger-ui/index.html?url=http://host:port/apiPub/wizard/"_tCurrentNS_"/_spec"
        zn tCurrentNS
    }
	Catch(e) {
        zn tCurrentNS
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

}

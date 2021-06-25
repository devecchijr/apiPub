Class apiPub.tracer.bs Extends Ens.BusinessService
{

Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "apiPub.tracer.bo" ];

Parameter SETTINGS = "TargetConfigName:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},";

Method OnProcessInput(pInput As apiPub.service.message, Output pOutput As %RegisteredObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{	
		If ..TargetConfigName="" {
			Set tSC = $$$ERROR($$$GeneralError, "Message not processed - TargetConfigName setting not defined on business host")
			Quit
		}
		Set tSC = ..SendRequestSync(..TargetConfigName,pInput,.pOutput)
	}
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

Method SendASync(pInput As apiPub.service.message, Output pOutput As %RegisteredObject) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{	
		If ..TargetConfigName="" {
			Set tSC = $$$ERROR($$$GeneralError, "Message not processed - TargetConfigName setting not defined on business host")
			Quit
		}
		Set tSC = ..SendRequestAsync(..TargetConfigName,pInput)
		Set pOutput = ##class(apiPub.service.message).%New()
	}
	Catch(e)
	{
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

}

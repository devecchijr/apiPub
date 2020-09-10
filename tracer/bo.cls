Class apiPub.tracer.bo Extends Ens.BusinessOperation
{

Property DefaultForEmptyContentType As %String(MAXLEN = 200) [ InitialExpression = "application/json" ];

Property BeautifyJsonBodyResponse As %Boolean [ InitialExpression = 1 ];

Parameter SETTINGS = "DefaultForEmptyContentType:APIConfig,BeautifyJsonBodyResponse:APIConfig,";

Method BORouter(pRequest As apiPub.service.message, Output pResponse As apiPub.service.message) As %Status
{
    Set tSC = $$$OK 
    Try {
        Set pResponse = ##class(apiPub.service.message).%New()
        Set tSC = $ClassMethod(pRequest.ServiceClass,"ServiceRouter",pRequest,.pResponse)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
		Set tResponseParams = {
            "defaultForEmptyContentType":(..DefaultForEmptyContentType)
			,"beautifyJsonBodyResponse":(..BeautifyJsonBodyResponse)
        }
        Set tSC = ##class(apiPub.service.rest).TreatMsgResponse(pRequest,.pResponse,tResponseParams)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
    }
    Catch(e) {
		Set tSC = e.AsStatus()
    }
    Quit tSC
}

XData MessageMap
{
<MapItems>
    <MapItem MessageType="apiPub.service.message">
        <Method>BORouter</Method>
    </MapItem>
</MapItems>
}

}

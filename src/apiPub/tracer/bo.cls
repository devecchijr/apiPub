Class apiPub.tracer.bo Extends Ens.BusinessOperation
{

Property DefaultForEmptyContentType As %String(MAXLEN = 200) [ InitialExpression = "application/json" ];

Property BeautifyJsonBodyResponse As %Boolean [ InitialExpression = 1 ];

Property SSL As %String;

Property HTTPS As %Boolean;

Property TargetBaseURL As %String(MAXLEN = 200);

Property ReservedOutboundParams As %String(MAXLEN = 250);

Property Headers As %String(MAXLEN = 500);

Parameter SETTINGS = "DefaultForEmptyContentType:APIConfig,BeautifyJsonBodyResponse:APIConfig,TargetBaseURL:APIConfig,Headers:APIConfig,HTTPS:APIConfig,SSL:APIConfig,ReservedOutboundParams:APIConfig";

Method BORouter(pRequest As apiPub.service.message, Output pResponse As apiPub.service.message) As %Status
{
    Set tSC = $$$OK 
    Try {
        Set pResponse = ##class(apiPub.service.message).%New()
 		Set tResponseParams = {
            "defaultForEmptyContentType":(..DefaultForEmptyContentType)
			,"beautifyJsonBodyResponse":(..BeautifyJsonBodyResponse)
        }
        // If is not apiPub service method treat as direct http call using apiPub.service.message)
        // Needed to configure bo parameters ("targetBaseURL,"https","ssl","reservedOutboundParams and headers)
        If pRequest.ServiceClass="" {
            Set pRequest.ServiceClass = "apiPub.core.service"
			Set tRequestParams = {
				"targetBaseURL":(..TargetBaseURL)
				,"https":(..HTTPS)
				,"ssl":(..SSL)
				,"reservedOutboundParams":(..ReservedOutboundParams)
				,"headers":(..Headers)
			}
            Set tSC = $ClassMethod(pRequest.ServiceClass,"ToHttpCall",pRequest,tRequestParams,.pResponse)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        } Else {
            Set tSC = $ClassMethod(pRequest.ServiceClass,"ServiceRouter",pRequest,.pResponse)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        }
        Set tSC = $ClassMethod(pRequest.ServiceClass,"TreatMsgResponse",pRequest,.pResponse,tResponseParams)
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

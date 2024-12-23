Class apiPub.tracer.bo Extends Ens.BusinessOperation
{

Property DefaultForEmptyContentType As %String(MAXLEN = 200) [ InitialExpression = "application/json" ];

Property BeautifyJsonBodyResponse As %Boolean [ InitialExpression = 1 ];

Property SSL As %String;

Property HTTPS As %Boolean;

Property TargetBaseURL As %String(MAXLEN = 200);

Property ReservedOutboundParams As %String(MAXLEN = 250);

Property Headers As %String(MAXLEN = 500);

Property BasicAuthCredentials As %String;

/// ex: if bearer token, create the credentials username as Bearer and the password as the token 
Property OtherAuthCredentials As %String;

Parameter SETTINGS = "DefaultForEmptyContentType:APIConfig,BeautifyJsonBodyResponse:APIConfig,TargetBaseURL:APIConfig,Headers:APIConfig,HTTPS:APIConfig,SSL:APIConfig,ReservedOutboundParams:APIConfig,BasicAuthCredentials:APIConfig:credentialsSelector,OtherAuthCredentials:APIConfig:credentialsSelector";

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
            If ..BasicAuthCredentials'="" {
                Set tCred = ##class(Ens.Config.Credentials).%OpenId(..BasicAuthCredentials)
                If $IsObject(tCred) {
                    Set:pRequest.Headers="" pRequest.Headers = "{}"
                    Set tReq = {}.%FromJSON(pRequest.Headers)
                    Do ##class(apiPub.core.jsonBuilder).s(tReq,"Authorization","Basic "_$SYSTEM.Encryption.Base64Encode(tCred.GetValue(..BasicAuthCredentials,"Username")_":"_tCred.PasswordGet()))
                    Set pRequest.Headers=tReq.%ToJSON()
                }
            }
            If ..OtherAuthCredentials'="" {
                Set tCred = ##class(Ens.Config.Credentials).%OpenId(..OtherAuthCredentials)
                If $IsObject(tCred) {
                    Set:pRequest.Headers="" pRequest.Headers = "{}"
                    Set tReq = {}.%FromJSON(pRequest.Headers)
                    Do ##class(apiPub.core.jsonBuilder).s(tReq,"Authorization",tCred.GetValue(..OtherAuthCredentials,"Username")_" "_tCred.PasswordGet())
                    Set pRequest.Headers=tReq.%ToJSON()
                }
            }
            Set tSC = $ClassMethod(pRequest.ServiceClass,"ToHttpCall",pRequest,tRequestParams,.pResponse)
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            If tSC=1,+pResponse.ResponseStatusCode>399,..AlertOnError=1 {
                Set tAlert = ##class(Ens.AlertRequest).%New()
                Set tAlert.SourceConfigName = ..%ConfigName
                Set tAlert.AlertText = "ERROR #"_pResponse.ResponseStatusCode_": "_pResponse.ResponseStatusLine
                Set tAlert.AlertTime = $ZDT($NOW(),3)
                Set tAlert.SessionId = ..%SessionId 
                Set tSC = ..SendAlert(tAlert)
                If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            }
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

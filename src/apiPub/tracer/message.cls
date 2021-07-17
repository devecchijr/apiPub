Class apiPub.tracer.message Extends (%Persistent, %XML.Adaptor)
{

/// Used to allow synchronization of a Cube by DeepSee
Parameter DSTIME = "AUTO";

Index reqIdIDX On reqId;

Index sessionIdIDX On sessionId;

Index apiDomainIDX On apiDomain;

Index apiOperationIdIDX On apiOperationId;

Index apiPathIDX On apiPath;

Property reqId As %Integer;

Property sessionId As %Integer;

Property intType As %Integer(DISPLAYLIST = ",Inbound,Business,Outbound,", VALUELIST = ",1,2,3");

Property intBusinessType As %String;

Property intBusinessComponent As %String(MAXLEN = "");

Property reqDt As %TimeStamp;

Property respDt As %TimeStamp;

Property timeToComplete As %Numeric(SCALE = 3);

Property status As %Integer(DISPLAYLIST = ",Completed,Error,Aborted,Expired", VALUELIST = ",1,2,3,4");

Property msgStatus As %Integer(DISPLAYLIST = ",Created,Queued,Delivered,Discarded,Suspended,Deferred,Aborted,Error,Completed", VALUELIST = ",1,2,3,4,5,6,7,8,9");

Property responseStatus As %Integer(DISPLAYLIST = ",ND,Success,BusinessError,Error", VALUELIST = ",0,1,2,3");

Property respIsError As %Boolean;

Property respErrorCode As %String;

Property respErrorMsg As %String(MAXLEN = "");

Property callerInfo As %String(MAXLEN = "");

Property apiDomain As %String;

Property apiOperationId As %String(MAXLEN = "");

Property apiPath As %String(MAXLEN = "");

Property targetBaseURL As %String(MAXLEN = "");

Property reqHttpVerb As %String;

Property reqHttpURL As %String(MAXLEN = "");

Property reqHttpParams As %String(MAXLEN = "");

Property respHttpURL As %String(MAXLEN = "");

Property respHttpStatusCode As %Integer;

Property respHttpStatusLine As %String(MAXLEN = "");

Property respHttpReasonPhrase As %String(MAXLEN = "");

Property reqHttpHeaders As %String(MAXLEN = "");

Property reqHttpBody As %Stream.GlobalCharacter;

Property respHttpHeaders As %String(MAXLEN = "");

Property respHttpBody As %Stream.GlobalCharacter;

Property reqBodyId As %Integer;

Property respBodyId As %Integer;

ClassMethod GetJSONPropName(pID, propName As %String, pLineKey, pKeyDelimiter As %String = ".") As %Library.DynamicObject [ SqlProc ]
{
    Set tRef=""
    Try
	{
        Set tObj = ..%OpenId(pID)
        Set tRef = tObj.GetJSONProp(propName,pLineKey,pKeyDelimiter)
    }
	Catch(e)
	{
	}
    Quit tRef
}

Method GetJSONProp(propName As %String, pLineKey, pKeyDelimiter As %String = ".") As %Library.DynamicObject
{
    Set tRef=""
    Try
	{
        Set tProp = $Property($this, propName)
        If $IsObject(tProp),$Find($ClassName(tProp),"Stream") {
            Do tProp.Rewind()
            If $Length(tProp.Read())=0 Return ""
            Do tProp.Rewind()
        } Else {
            If $Length(tProp)=0 Return ""
        }
        Set tJson = {}.%FromJSON(tProp)
        Set tRef = ##class(apiPub.core.jsonBuilder).GetByLineKey(tJson,pLineKey,pKeyDelimiter)
    }
	Catch(e)
	{
	}
    Quit tRef
}

/*
Property reqHUserAgent As %String [ SqlComputeCode = {set {*}=##class(APITracer.monitor.message).GetJSONPropName({ID},"reqHttpHeaders","HTTP_USER_AGENT")}, SqlComputed, Transient ];

Property reqHPath As %String [ SqlComputeCode = {set {*}=##class(APITracer.monitor.message).GetJSONPropName({ID},"reqHttpHeaders","SCRIPT_NAME")}, SqlComputed, Transient ];

Property reqHQueryString As %String [ SqlComputeCode = {set {*}=##class(APITracer.monitor.message).GetJSONPropName({ID},"reqHttpHeaders","QUERY_STRING")}, SqlComputed, Transient ];
*/
Storage Default
{
<Data name="messageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>reqId</Value>
</Value>
<Value name="3">
<Value>sessionId</Value>
</Value>
<Value name="4">
<Value>intType</Value>
</Value>
<Value name="5">
<Value>intBusinessType</Value>
</Value>
<Value name="6">
<Value>intBusinessComponent</Value>
</Value>
<Value name="7">
<Value>reqDt</Value>
</Value>
<Value name="8">
<Value>respDt</Value>
</Value>
<Value name="9">
<Value>timeToComplete</Value>
</Value>
<Value name="10">
<Value>status</Value>
</Value>
<Value name="11">
<Value>msgStatus</Value>
</Value>
<Value name="12">
<Value>responseStatus</Value>
</Value>
<Value name="13">
<Value>respIsError</Value>
</Value>
<Value name="14">
<Value>respErrorCode</Value>
</Value>
<Value name="15">
<Value>respErrorMsg</Value>
</Value>
<Value name="16">
<Value>callerInfo</Value>
</Value>
<Value name="17">
<Value>apiDomain</Value>
</Value>
<Value name="18">
<Value>apiOperationId</Value>
</Value>
<Value name="19">
<Value>apiPath</Value>
</Value>
<Value name="20">
<Value>targetBaseURL</Value>
</Value>
<Value name="21">
<Value>reqHttpVerb</Value>
</Value>
<Value name="22">
<Value>reqHttpURL</Value>
</Value>
<Value name="23">
<Value>reqHttpParams</Value>
</Value>
<Value name="24">
<Value>respHttpURL</Value>
</Value>
<Value name="25">
<Value>respHttpStatusCode</Value>
</Value>
<Value name="26">
<Value>respHttpStatusLine</Value>
</Value>
<Value name="27">
<Value>respHttpReasonPhrase</Value>
</Value>
<Value name="28">
<Value>reqHttpHeaders</Value>
</Value>
<Value name="29">
<Value>reqHttpBody</Value>
</Value>
<Value name="30">
<Value>respHttpHeaders</Value>
</Value>
<Value name="31">
<Value>respHttpBody</Value>
</Value>
<Value name="32">
<Value>reqBodyId</Value>
</Value>
<Value name="33">
<Value>respBodyId</Value>
</Value>
</Data>
<DataLocation>^apiPub.tracer.messageD</DataLocation>
<DefaultData>messageDefaultData</DefaultData>
<IdLocation>^apiPub.tracer.messageD</IdLocation>
<IndexLocation>^apiPub.tracer.messageI</IndexLocation>
<StreamLocation>^apiPub.tracer.messageS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

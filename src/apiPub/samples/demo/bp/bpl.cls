/// 
Class apiPub.samples.demo.bp.bpl Extends Ens.BusinessProcessBPL
{

Storage Default
{
<Data name="bplDefaultData">
<Subscript>"bpl"</Subscript>
<Value name="1">
<Value>currencyAPIKey</Value>
</Value>
</Data>
<DefaultData>bplDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='apiPub.samples.demo.productFilter' response='apiPub.samples.demo.productList' height='2000' width='2000' >
<context>
<property name='ItKey' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
<property name='currencyBody' type='%DynamicObject' initialexpression='{}' instantiate='0' />
<property name='currencyStatusCode' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
<property name='currencyApiKey' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
</context>
<sequence xend='200' yend='650' >
<assign name="get currency Api Key" property="context.currencyApiKey" value="$Get(^currencyApiKey,&quot;&quot;)" action="set" xpos='200' ypos='250' />
<call name='call currency Api' target='currency Api' async='0' xpos='204' ypos='350' >
<request type='apiPub.service.message' >
<assign property="callrequest.HttpVerb" value="&quot;Get&quot;" action="set" />
<assign property="callrequest.APIPath" value="&quot;/v1/latest&quot;" action="set" />
<assign property="callrequest.APIDomain" value="&quot;currency&quot;" action="set" />
<assign property="callrequest.APIOperationId" value="&quot;compositeProcess&quot;" action="set" />
<assign property="callrequest.Trace" value="0" action="set" />
<assign property="callrequest.Params" value="{&quot;apikey&quot;:(context.currencyApiKey),&quot;currencies&quot;:&quot;BRL,EUR&quot;}.%ToJSON()" action="set" />
<assign property="callrequest.CallerInfo" value="&quot;compositeProcess&quot;" action="set" />
</request>
<response type='apiPub.service.message' >
<assign property="context.currencyBody" value="{}.%FromJSON(callresponse.Body)" action="set" />
<assign property="context.currencyStatusCode" value="callresponse.ResponseStatusCode" action="set" />
</response>
</call>
<call name='call bo' target='fromSql' async='0' xpos='200' ypos='450' >
<request type='apiPub.samples.demo.productFilter' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='apiPub.samples.demo.productList' >
<assign property="response" value="callresponse" action="set" />
</response>
</call>
<foreach name='iterate' property='response.productList' key='context.ItKey' xpos='200' ypos='550' xend='200' yend='700' >
<if name='currency ok' condition='context.currencyStatusCode="200"' xpos='200' ypos='250' xend='200' yend='600' >
<true>
<assign name="Set price in BRL" property="response.productList.GetAt(context.ItKey).BRLPrice" value="response.productList.GetAt(context.ItKey).price*context.currencyBody.%Get(&quot;data&quot;).%Get(&quot;BRL&quot;)" action="set" xpos='335' ypos='400' />
<assign name="Set price in EUR" property="response.productList.GetAt(context.ItKey).EURPrice" value="response.productList.GetAt(context.ItKey).price*context.currencyBody.%Get(&quot;data&quot;).%Get(&quot;EUR&quot;)" action="set" xpos='335' ypos='500' />
</true>
</if>
</foreach>
</sequence>
</process>
}

}

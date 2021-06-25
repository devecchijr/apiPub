Class apiPub.tracer.bp Extends (Ens.BusinessProcessBPL, apiPub.tracer.bp.utils)
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='apiPub.service.message' response='apiPub.service.message' height='3550' width='2000' >
<context>
<property name='messageName' type='%String' instantiate='0' />
</context>
<sequence xend='200' yend='350' >
<call name='call apiPub.tracer.bo' target='apiPub.tracer.bo' async='0' xpos='200' ypos='250' >
<request type='Ens.Request' >
<assign property="callrequest" value="request" action="set" />
</request>
<response type='Ens.Response' >
<assign property="response" value="callresponse" action="set" />
</response>
</call>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}

Class apiPub.samples.demo.fastApiProd Extends Ens.Production [ Not ProcedureBlock ]
{

XData ProductionDefinition
{
<Production Name="apiPub.samples.demo.fastApiProd" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>1</ActorPoolSize>
  <Item Name="apiPub.tracer.bs" Category="" ClassName="apiPub.tracer.bs" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="apiPub.tracer.bm" Category="" ClassName="apiPub.tracer.bm" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="apiPub.tracer.bo" Category="" ClassName="apiPub.tracer.bo" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="fromSql" Category="composite services" ClassName="apiPub.samples.demo.bo.fromSql" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="DSN">IRIS</Setting>
    <Setting Target="Adapter" Name="JGService">JGService</Setting>
    <Setting Target="Adapter" Name="Credentials">SYSTEM</Setting>
  </Item>
  <Item Name="JGService" Category="" ClassName="EnsLib.JavaGateway.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Port">44444</Setting>
  </Item>
  <Item Name="currency Api" Category="composite services" ClassName="apiPub.tracer.bo" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="HTTPS">1</Setting>
    <Setting Target="Host" Name="TargetBaseURL">api.freecurrencyapi.com</Setting>
    <Setting Target="Host" Name="SSL">pm.community.intersystems.com</Setting>
  </Item>
  <Item Name="priceList" Category="composite services" ClassName="apiPub.samples.demo.bp.bpl" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="apiPub.samples.demo.fastApi" Category="composite services" ClassName="apiPub.samples.demo.fastApi" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}

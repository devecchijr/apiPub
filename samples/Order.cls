Class apiPub.samples.Order Extends (%Persistent, %XML.Adaptor)
{

Property id As %Integer;

Property petId As %BigInt;

Property quantity As %SmallInt;

Property shipDate As %DateTime [ InitialExpression = {$ZDateTime($Horolog, 3)} ];

Property status As %String(VALUELIST = ",placed,approved,delivered") [ InitialExpression = "placed" ];

Property complete As %Boolean [ InitialExpression = 0 ];

Storage Default
{
<Data name="OrderDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>petId</Value>
</Value>
<Value name="3">
<Value>quantity</Value>
</Value>
<Value name="4">
<Value>shipDate</Value>
</Value>
<Value name="5">
<Value>status</Value>
</Value>
<Value name="6">
<Value>complete</Value>
</Value>
<Value name="7">
<Value>id</Value>
</Value>
</Data>
<DataLocation>^apiPub.samples.OrderD</DataLocation>
<DefaultData>OrderDefaultData</DefaultData>
<IdLocation>^apiPub.samples.OrderD</IdLocation>
<IndexLocation>^apiPub.samples.OrderI</IndexLocation>
<StreamLocation>^apiPub.samples.OrderS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

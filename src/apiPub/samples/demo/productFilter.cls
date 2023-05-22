Class apiPub.samples.demo.productFilter Extends Ens.Request
{

/// product code
Property code As %String;

/// product description
Property description As %String;

Storage Default
{
<Data name="productFilterDefaultData">
<Subscript>"productFilter"</Subscript>
<Value name="1">
<Value>code</Value>
</Value>
<Value name="2">
<Value>description</Value>
</Value>
</Data>
<DefaultData>productFilterDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}

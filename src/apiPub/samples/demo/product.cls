/// product for demo purpose
Class apiPub.samples.demo.product Extends (%Persistent, %JSON.Adaptor)
{

/// product code
Property code As %String;

/// product description
Property description As %String;

/// base price
Property price As %Numeric;

/// stock quantity
Property stockQty As %Integer;

/// available for sale
Property available As %Boolean;

/// created on (datetime)
Property createdOn As %DateTime;

Index codeIdx On code [ Unique ];

Storage Default
{
<Data name="productRequestDefaultData">
<Subscript>"productRequest"</Subscript>
<Value name="1">
<Value>code</Value>
</Value>
<Value name="2">
<Value>description</Value>
</Value>
<Value name="3">
<Value>price</Value>
</Value>
<Value name="4">
<Value>stockQty</Value>
</Value>
<Value name="5">
<Value>available</Value>
</Value>
<Value name="6">
<Value>createdOn</Value>
</Value>
<Value name="7">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^apiPub.samples.demo.productD</DataLocation>
<DefaultData>productRequestDefaultData</DefaultData>
<IdLocation>^apiPub.samples.demo.productD</IdLocation>
<IndexLocation>^apiPub.samples.demo.productI</IndexLocation>
<StreamLocation>^apiPub.samples.demo.productS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

/// product for demo purpose
Class apiPub.samples.demo.item Extends (Ens.Request, Ens.Response)
{

/// product code
Property code As %String;

/// product description
Property description As %String;

/// base price
Property price As %Numeric;

/// BRL price  
Property BRLPrice As %Numeric;

/// EUR price
Property EURPrice As %Numeric;

/// stock quantity
Property stockQty As %Integer;

/// available for sale
Property available As %Boolean;

/// created on (datetime)
Property createdOn As %DateTime;

Storage Default
{
<Data name="itemDefaultData">
<Subscript>"item"</Subscript>
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
<Value>BRLPrice</Value>
</Value>
<Value name="5">
<Value>EURPrice</Value>
</Value>
<Value name="6">
<Value>stockQty</Value>
</Value>
<Value name="7">
<Value>available</Value>
</Value>
<Value name="8">
<Value>createdOn</Value>
</Value>
</Data>
<DefaultData>itemDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}

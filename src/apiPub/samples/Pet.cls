Class apiPub.samples.Pet Extends (%Persistent, %XML.Adaptor)
{

Property id As %Integer;

Property category As apiPub.samples.Category;

/// @apiPub[example="doggie"]
Property name As %String(MAXLEN = "") [ Required ];

Property photoUrls As list Of %String(MAXLEN = "", XMLPROJECTION = "element");

Relationship tags As apiPub.samples.Tag(XMLPROJECTION = "element") [ Cardinality = many, Inverse = pet ];

/// pet status in the store
Property status As %String(VALUELIST = ",available,pending,sold") [ InitialExpression = "available" ];

Index idIDX On id [ Unique ];

Storage Default
{
<Data name="PetDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>id</Value>
</Value>
<Value name="3">
<Value>category</Value>
</Value>
<Value name="4">
<Value>name</Value>
</Value>
<Value name="5">
<Value>photoUrls</Value>
</Value>
<Value name="6">
<Value>status</Value>
</Value>
</Data>
<DataLocation>^apiPub.samples.PetD</DataLocation>
<DefaultData>PetDefaultData</DefaultData>
<IdLocation>^apiPub.samples.PetD</IdLocation>
<IndexLocation>^apiPub.samples.PetI</IndexLocation>
<StreamLocation>^apiPub.samples.PetS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

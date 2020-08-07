Class apiPub.samples.Pet Extends (%Persistent, %XML.Adaptor)
{

Property id As %Integer;

Property category As apiPub.samples.Category;

/// @apiPub[example="doggie"]
Property name As %String(MAXLEN = "");

Property photoUrls As list Of %String(MAXLEN = "", XMLPROJECTION = "element");

Property tags As list Of apiPub.samples.Tag(XMLPROJECTION = "element");

/// pet status in the store
Property status As %String(VALUELIST = ",available,pending,sold");

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
<Value>tags</Value>
</Value>
<Value name="7">
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

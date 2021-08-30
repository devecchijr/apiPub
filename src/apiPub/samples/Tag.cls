Class apiPub.samples.Tag Extends (%Persistent, apiPub.samples.persistent)
{

Property name As %String(MAXLEN = "");

Relationship pet As apiPub.samples.Pet(XMLPROJECTION = "NONE") [ Cardinality = one, Inverse = tags ];

Index petIdx On pet;

Index nameIdx On name;

Storage Default
{
<Data name="TagDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>name</Value>
</Value>
<Value name="3">
<Value>pet</Value>
</Value>
</Data>
<DataLocation>^apiPub.samples.TagD</DataLocation>
<DefaultData>TagDefaultData</DefaultData>
<IdLocation>^apiPub.samples.TagD</IdLocation>
<IndexLocation>^apiPub.samples.TagI</IndexLocation>
<StreamLocation>^apiPub.samples.TagS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

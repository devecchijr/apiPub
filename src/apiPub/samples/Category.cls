Class apiPub.samples.Category Extends (%Persistent, apiPub.samples.persistent)
{

Property name As %String(MAXLEN = "");

Index nameIDX On name;

Storage Default
{
<Data name="CategoryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>name</Value>
</Value>
</Data>
<DataLocation>^apiPub.samples.CategoryD</DataLocation>
<DefaultData>CategoryDefaultData</DefaultData>
<IdLocation>^apiPub.samples.CategoryD</IdLocation>
<IndexLocation>^apiPub.samples.CategoryI</IndexLocation>
<StreamLocation>^apiPub.samples.CategoryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

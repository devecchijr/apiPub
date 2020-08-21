Class apiPub.samples.Tag Extends (%SerialObject, %XML.Adaptor)
{

Property id As %Integer;

Property name As %String(MAXLEN = "");

Storage Default
{
<Data name="TagState">
<Value name="1">
<Value>id</Value>
</Value>
<Value name="2">
<Value>name</Value>
</Value>
</Data>
<State>TagState</State>
<StreamLocation>^apiPub.samples.TagS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

Class apiPub.samples.User Extends (%Persistent, %XML.Adaptor)
{

Property id As %Integer [ Required ];

Property username As %String(MAXLEN = "");

Property firstName As %String(MAXLEN = "");

Property lastName As %String(MAXLEN = "");

Property email As %String(MAXLEN = "");

Property password As %String(MAXLEN = "");

Property phone As %String(MAXLEN = "");

/// User Status
Property userStatus As %SmallInt;

Index idIDX On id [ Unique ];

Storage Default
{
<Data name="UserDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>id</Value>
</Value>
<Value name="3">
<Value>username</Value>
</Value>
<Value name="4">
<Value>firstName</Value>
</Value>
<Value name="5">
<Value>lastName</Value>
</Value>
<Value name="6">
<Value>email</Value>
</Value>
<Value name="7">
<Value>password</Value>
</Value>
<Value name="8">
<Value>phone</Value>
</Value>
<Value name="9">
<Value>userStatus</Value>
</Value>
</Data>
<DataLocation>^apiPub.samples.UserD</DataLocation>
<DefaultData>UserDefaultData</DefaultData>
<IdLocation>^apiPub.samples.UserD</IdLocation>
<IndexLocation>^apiPub.samples.UserI</IndexLocation>
<StreamLocation>^apiPub.samples.UserS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

Class apiPub.samples.User Extends (%Persistent, apiPub.samples.persistent)
{

Property username As %String(MAXLEN = "");

Property firstName As %String(MAXLEN = "");

Property lastName As %String(MAXLEN = "");

Property email As %String(MAXLEN = "");

Property password As %String(MAXLEN = "");

Property phone As %String(MAXLEN = "");

/// User Status
Property userStatus As %SmallInt;

Index usernameIDX On username [ Unique ];

Storage Default
{
<Data name="UserDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>username</Value>
</Value>
<Value name="3">
<Value>firstName</Value>
</Value>
<Value name="4">
<Value>lastName</Value>
</Value>
<Value name="5">
<Value>email</Value>
</Value>
<Value name="6">
<Value>password</Value>
</Value>
<Value name="7">
<Value>phone</Value>
</Value>
<Value name="8">
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

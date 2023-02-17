/// apiPub cached data 
Class apiPub.service.cache Extends %Persistent
{

/// classname||rt for routes
/// classname||nd for xml nodes
/// classname||sc0 for obj schemas nested=0
/// classname||sc1 for obj schemas nested=1
/// classname||methodname||sp for method spec
/// classname||methodname||sch for xdata schemas
/// classname||schemaName||ps for parsing structures
Property Key As %String(MAXLEN = 200);

Property DateTimeCtl As %BigInt;

Property Content As %Stream.GlobalCharacter;

Index CacheIdx On Key [ Unique ];

Storage Default
{
<Data name="cacheDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Key</Value>
</Value>
<Value name="3">
<Value>DateTimeCtl</Value>
</Value>
<Value name="4">
<Value>Content</Value>
</Value>
</Data>
<DataLocation>^apiPub.service.cacheD</DataLocation>
<DefaultData>cacheDefaultData</DefaultData>
<IdLocation>^apiPub.service.cacheD</IdLocation>
<IndexLocation>^apiPub.service.cacheI</IndexLocation>
<StreamLocation>^apiPub.service.cacheS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

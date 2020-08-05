Class apiPub.samples.User Extends (%RegisteredObject, %XML.Adaptor)
{

Property id As %XML.Id(XMLNAME = "id", XMLPROJECTION = "ELEMENT") [ Private, Transient ];

Property username As %String(MAXLEN = "");

Property firstName As %String(MAXLEN = "");

Property lastName As %String(MAXLEN = "");

Property email As %String(MAXLEN = "");

Property password As %String(MAXLEN = "");

Property phone As %String(MAXLEN = "");

/// User Status
Property userStatus As %SmallInt;

}

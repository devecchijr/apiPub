Class apiPub.samples.Pet Extends (%RegisteredObject, %XML.Adaptor)
{

Property id As %XML.Id(XMLNAME = "id", XMLPROJECTION = "ELEMENT") [ Private, Transient ];

Property category As apiPub.samples.Category;

/// @apiPub[example="doggie"]
Property name As %String(MAXLEN = "");

Property photoUrls As list Of %String(MAXLEN = "");

Property tags As list Of apiPub.samples.Tag;

/// pet status in the store
Property status As %String(VALUELIST = ",available,pending,sold");

}

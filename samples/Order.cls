Class apiPub.samples.Order Extends (%RegisteredObject, %XML.Adaptor)
{

Property id As %XML.Id(XMLNAME = "id", XMLPROJECTION = "ELEMENT") [ Private, Transient ];

Property petId As %BigInt;

Property quantity As %SmallInt;

Property shipDate As %DateTime [ InitialExpression = {$ZDateTime($Horolog, 3)} ];

Property status As %String(VALUELIST = ",placed,approved,delivered") [ InitialExpression = "placed" ];

Property complete As %Boolean [ InitialExpression = 0 ];

}

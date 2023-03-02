/// This is a sample iris object for demo
Class apiPub.samples.demo.myObj Extends (%RegisteredObject, %XML.Adaptor)
{

/// string prop description
Property strProp As %String;

/// integer prop description
Property intProp As %Integer;

/// numeric prop description
Property numProp As %Numeric;

/// boolean prop description
Property boolProp As %Boolean;

/// datetime prop description
Property prop4 As %DateTime;

/// self reference prop description
Property self As apiPub.samples.demo.myObj;

}

Class apiPub.samples.demo.productList Extends Ens.Response
{

Property productList As list Of apiPub.samples.demo.item;

Storage Default
{
<Data name="productListDefaultData">
<Subscript>"productList"</Subscript>
<Value name="1">
<Value>productList</Value>
</Value>
</Data>
<DefaultData>productListDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}

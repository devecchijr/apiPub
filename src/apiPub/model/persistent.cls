/// Project or open the persistent using json _id or xml id attribute
Class apiPub.model.persistent Extends %XML.Adaptor
{

Parameter NAMEOFEXPORTID As %String = "id";

Property RowID As %XML.Id(XMLNAME = "id", XMLPROJECTION = "Attribute") [ Private, Transient ];

ClassMethod XMLNew(document As %XML.Document, node As %Integer, containerOref As %RegisteredObject = "") As %RegisteredObject [ CodeMode = objectgenerator, GenerateAfter = %XMLGenerate, ServerOnly = 1 ]
{
 If %compiledclass.Name'="Sample.Persistent" {
  Do %code.WriteLine(" Set tmpnode=document.GetNode(node)")
  Do %code.WriteLine(" Set id=tmpnode.GetAttributeValue(..#NAMEOFEXPORTID)")
  Do %code.WriteLine(" If id="""" {")
  Do %code.WriteLine("    Do tmpnode.MoveToFirstChild()")
  Do %code.WriteLine("    Do {")
  Do %code.WriteLine("        If tmpnode.NodeData=..#NAMEOFEXPORTID ")
  Do %code.WriteLine("          {Do tmpnode.GetText(.id)}")
  Do %code.WriteLine("    } While tmpnode.MoveToNextSibling() ")
  Do %code.WriteLine(" }")
  Do %code.WriteLine(" If id="""" {")
  Do %code.WriteLine("    Quit ##class("_%class.Name_").%New()}")
  Do %code.WriteLine(" Set result=##class("_%class.Name_").%OpenId(id)")
  Do %code.WriteLine(" If result=$$$NULLOREF {")
  Do %code.WriteLine("     Quit ##class("_%class.Name_").%New() }")
  Do %code.WriteLine(" Quit result")

  }

 QUIT $$$OK
}

}

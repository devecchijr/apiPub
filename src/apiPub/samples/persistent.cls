/// Project or open the persistent using json _id or xml id attribute
Class apiPub.samples.persistent Extends %XML.Adaptor
{

Parameter ROWIDNAME As %String = "id";

Parameter VALIDATEREFID As %Boolean = 1;

Property RowID As %XML.Id(XMLNAME = "id", XMLPROJECTION = "Element") [ Private, Transient ];

/// Overload this method to clear children or list process before json or xml ingestion
/// In some cases (update) it causes duplicities
ClassMethod beforeUpdateHandler(obj) As %Persistent
{
    Quit obj
}

ClassMethod XMLNew(document As %XML.Document, node As %Integer, containerOref As %RegisteredObject = "") As %RegisteredObject [ CodeMode = objectgenerator, GenerateAfter = %XMLGenerate, ServerOnly = 1 ]
{
 If %compiledclass.Name'="apiPub.samples.persistent" {
  Do %code.WriteLine(" Set tmpnode=document.GetNode(node)")
  Do %code.WriteLine(" Set id=tmpnode.GetAttributeValue(..#ROWIDNAME)")
  Do %code.WriteLine(" If id="""" {")
  Do %code.WriteLine("    Do tmpnode.MoveToFirstChild()")
  Do %code.WriteLine("    Do {")
  Do %code.WriteLine("        If tmpnode.NodeData=..#ROWIDNAME ")
  Do %code.WriteLine("          {Do tmpnode.GetText(.id)}")
  Do %code.WriteLine("    } While tmpnode.MoveToNextSibling() ")
  Do %code.WriteLine(" }")
  Do %code.WriteLine(" Set result=##class("_%class.Name_").%New()")
  Do %code.WriteLine(" If id'=""""{")
  Do %code.WriteLine("      Set result=##class("_%class.Name_").%OpenId(id)")
  Do %code.WriteLine("      If ..#VALIDATEREFID,'$IsObject(result) Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, ""<404> Invalid Object Reference (""_id_"") for ""_$ClassName($This)))")
  Do %code.WriteLine("      try { set result=$CLASSMETHOD("""_%class.Name_""",""beforeUpdateHandler"",result) } catch nex {}")
  Do %code.WriteLine(" }")
  Do %code.WriteLine(" If result=$$$NULLOREF Set result=##class("_%class.Name_").%New()")
  Do %code.WriteLine(" Quit result")
  }

 QUIT $$$OK
}

}

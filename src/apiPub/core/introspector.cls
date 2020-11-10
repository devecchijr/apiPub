Class apiPub.core.introspector Extends apiPub.core.jsonBuilder
{

// w ##class(apiPub.core.introspector).LoadJSONSpecFile("/irisdev/app/docResources/devecchijr7-Pet-1.0.0-swagger.json")

ClassMethod LoadJSONSpecFile(pFileName As %String) As %Status
{
	Set tSC = $System.Status.OK()
    Try
	{
        Set stream=##class(%FileCharacterStream).%New()
        Set tSC = stream.LinkToFile(pFileName)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        Set tImpClass = {}
        Do ..SetByLineKey(tImpClass,"Export^_generator",$Piece($SYSTEM.Version.GetProduct()," ",1),,"^")
        Do ..SetByLineKey(tImpClass,"Export^_version",26,,"^")
        Do ..SetByLineKey(tImpClass,"Export^_zv",$ZVERSION,,"^")
        Do ..SetByLineKey(tImpClass,"Export^_ts",$ZDATETIME($HOROLOG,3),,"^")
        Do ..SetByLineKey(tImpClass,"Export^Class^_name","apiPub.samples.temp",,"^")
        Do ..SetByLineKey(tImpClass,"Export^Class^Description","Methods spec projected using API first approach mode"_$Char(10)_
        "All of the schemas and information needed on XDATA block were imported from Swagger Spec file"_$Char(10)_
        "All of schemas ared automatically parsed by apiPub tool",,"^")
        Do ..SetByLineKey(tImpClass,"Export^Class^ProcedureBlock",1,,"^")
        Do ..SetByLineKey(tImpClass,"Export^Class^Super","%RegisteredObject",,"^")
        Do ..SetByLineKey(tImpClass,"Export^Class^TimeChanged",$NOW(),,"^")
        Do ..SetByLineKey(tImpClass,"Export^Class^TimeCreated",$NOW(),,"^")
        Set tHeaders = {}
        Set tJSON = ##Class(%Library.DynamicObject).%FromJSON(stream.Read())
        If tJSON.%Size()>0 {
            Set tSC = ..JSONToFlatJSON(tJSON,.tFJSON,{"printResults":0})
            If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
            Set tIndex = 0
            Set tFirstTag=""
            Set tFJ = tFJSON.%GetIterator()
            While tFJ.%GetNext(.key,.value) {
                If key = "tags^0^name" Set tFirstTag = value
                If ($Piece(key,"^",1) = "tags")||($Piece(key,"^",1) = "info")||($Piece(key,"^",1,2) = "components^schemas") {
                    If $Find(key,"^xml^name")>0 continue
                    Do ..SetByLineKey(tHeaders,$Replace(key,"components^",""),value,,"^")
                }
                If $Piece(key,"^",*) = "operationId" {
                    Set tSpecialNot = "" 
                    Set tOperationId = value
                    Set tVerb = $Piece(key,"^",*-1)
                    Set tDesc = ..GetByLineKey(tJSON,$Piece(key,"^",1,*-1)_"^summary","^")
                    If tDesc'="" Set tSpecialNot = $Select(tSpecialNot'="":tSpecialNot_$Char(10),1:tSpecialNot)_tDesc
                    Set tPath = $Piece(key,"^",2,*-2)
                    If tPath'="" Set tSpecialNot = $Select(tSpecialNot'="":tSpecialNot_$Char(10),1:tSpecialNot)_"@apiPub[path="""_tPath_"""]"
                    If tVerb'="",$Find("get",tVerb)=0 Set tSpecialNot = $Select(tSpecialNot'="":tSpecialNot_$Char(10),1:tSpecialNot)_"@apiPub[verb="""_tVerb_"""]"
                    Set tParDesc = $Replace(..GetByLineKey(tJSON,$Piece(key,"^",1,*-1)_"^description","^"),"=","equal")
                    If tParDesc'="" Set tSpecialNot = $Select(tSpecialNot'="":tSpecialNot_$Char(10),1:tSpecialNot)_"@apiPub[params.description="""_tParDesc_"""]"
                    Set tTag = tFJSON.%Get($Piece(key,"^",1,*-1)_"^tags^0")
                    If tTag'=tFirstTag {
                        Set tSpecialNot = $Select(tSpecialNot'="":tSpecialNot_$Char(10),1:tSpecialNot)_"@apiPub[tag="""_tTag_"""]"
                    }
                    Do ..SetByLineKey(tImpClass,"Export^Class^Method^"_tIndex_"^_name",tOperationId,,"^")
                    Do ..SetByLineKey(tImpClass,"Export^Class^Method^"_tIndex_"^WebMethod","1",,"^")
                    Do ..SetByLineKey(tImpClass,"Export^Class^Method^"_tIndex_"^Implementation",$Char(9)_"//your code here"_$Char(10)_$Char(13),,"^")
                    Do ..SetByLineKey(tImpClass,"Export^Class^Method^"_tIndex_"^ReturnType","%Library.DynamicObject",,"^")
                    If tSpecialNot'="" Do ..SetByLineKey(tImpClass,"Export^Class^Method^"_tIndex_"^Description",tSpecialNot,,"^")
                    Set tIndex=tIndex+1
                }
            }
            Do ..SetByLineKey(tImpClass,"Export^Class^XData^_name","apiPub",,"^")
            Do ..SetByLineKey(tImpClass,"Export^Class^XData^MimeType","application/json",,"^")
			If ($IsObject(##class(%Dictionary.ClassDefinition).%OpenId("%JSON.Formatter"))) {
                Set tFormatter = ##class(%JSON.Formatter).%New(),tFormatHeader=""
                Do tFormatter.FormatToString(tHeaders.%ToJSON(),.tFormatHeader)
			} Else {
				Set tFormatHeader = tHeaders.%ToJSON()
			}
            Do ..SetByLineKey(tImpClass,"Export^Class^XData^Data",tFormatHeader,,"^")
        }
        Set tSC = ##class(apiPub.core.converter).JSONToXML(tImpClass,.tXMLImpClass,{"printResults":1})
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
        Set tSC = $System.OBJ.LoadStream(tXMLImpClass,"ck")
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) }
    }
	Catch(e)
	{
		Write $System.Status.DisplayError(e.AsStatus())
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

}

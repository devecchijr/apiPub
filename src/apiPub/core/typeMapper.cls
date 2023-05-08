Class apiPub.core.typeMapper Extends %RegisteredObject
{

ClassMethod GetParamTypes() As %Library.DynamicObject
{
    Quit {
            "%status":"status|string"
            ,"%binary":"string|string|string"
            ,"%base64binary":"string|string|string"
            ,"%boolean":"boolean|boolean||XSDToLogical|LogicalToXSD"
            ,"%date":"string|string|date|XSDToLogical|LogicalToXSD"
            ,"%posixtime":"string|string|date-time|XSDToLogical|LogicalToXSD"
            ,"%stringtimestamp":"string|string|date-time|XSDToLogical|LogicalToXSD"
            ,"%timestamp":"string|string|date-time|XSDToLogical|LogicalToXSD"
            ,"%datetime":"string|string|date-time|XSDToLogical|LogicalToXSD"
            ,"%currency":"number|number"
            ,"%float":"number|number"
            ,"%decimal":"number|number"
            ,"%numeric":"number|number"
            ,"%double":"number|number"
            ,"%float":"number|number"
            ,"%bigint":"number|integer|int64"
            ,"%counter":"number|integer|int64"
            ,"%int":"number|integer|"
            ,"%long":"number|integer|int64"
            ,"%integer":"number|integer"
            ,"%smallint":"number|integer|int32"
            ,"%time":"string|string||XSDToLogical|LogicalToXSD"
            ,"%tinyint":"number|integer|int32"
            ,"%byte":"number|integer|int32"
            ,"%string":"string|string"
            ,"%filebinary":"string|string|binary|stream|stream"
            ,"%binarystream":"string|string|binary|stream|stream"
            ,"%filecharacter":"string|string||stream|stream"
            ,"%globalbinary":"string|string|binary|stream|stream"
            ,"%globalcharacter":"string|string||stream|stream"
    }
}

ClassMethod GetXSDMapTypes() As %Library.DynamicObject
{
    Quit {
        "string":"string|string"
        ,"int":"number|integer"
        ,"integer":"number|integer"
        ,"long":"number|integer|int64"
        ,"negativeinteger":"number|integer"
        ,"nonnegativeinteger":"number|integer"
        ,"nonpositiveinteger":"number|integer"
        ,"positiveinteger":"number|integer"
        ,"short":"number|integer"
        ,"unsignedlong":"number|integer|int64"
        ,"unsignedint":"number|integer"
        ,"unsignedshort":"number|integer"
        ,"decimal":"number|number"
        ,"double":"number|number"
        ,"numeric":"number|number"
        ,"boolean":"boolean|boolean"
        ,"base64binary":"string|string|binary"
        ,"hexbinary":"string|string|binary"
        ,"unsignedbyte":"string|string|byte"
        ,"byte":"number|integer"
        ,"datetime":"string|string|date-time"
        ,"date":"string|string|date"
        ,"duration":"string|string"
        ,"gday":"string|string"
        ,"gmonth":"string|string"
        ,"gmonthday":"string|string"
        ,"gyear":"string|string"
        ,"gyearmonth":"string|string"
        ,"time":"number|integer"
    }
}

}

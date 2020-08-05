/// 
Class apiPub.tracer.cube Extends %DeepSee.CubeDefinition [ DependsOn = apiPub.tracer.message, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="apiPub" displayName="apiPub Monitor" disabled="false" abstract="false" sourceClass="apiPub.tracer.message" actionClass="apiPub.tracer.kpi" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false" enableSqlRestrict="false">
  <dimension name="Date" disabled="false" hasAll="false" allCaption="All Date" allDisplayName="Date" sourceProperty="reqDt" type="time" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Year" disabled="false" timeFunction="Year" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Month" disabled="false" timeFunction="MonthYear" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Day" disabled="false" timeFunction="DayMonthYear" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Hour" disabled="false" timeFunction="HourNumber" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Minute" disabled="false" timeFunction="MinuteNumber" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="IntType" disabled="false" hasAll="false" allCaption="All IntType" allDisplayName="Interact Type" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="intType" disabled="false" sourceProperty="intType" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="intBusinessType" disabled="false" sourceProperty="intBusinessType" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="intBusinessComponent" disabled="false" sourceProperty="intBusinessComponent" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="SourceComponent" disabled="false" hasAll="false" allCaption="All Source Component" allDisplayName="Source Component" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="sourceType" disabled="false" sourceExpression="$Piece(%source.intBusinessType,&quot;|&quot;,1)" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="sourceComponentName" disabled="false" sourceExpression="$Piece(%source.intBusinessComponent,&quot;|&quot;,1)" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="TargetComponent" disabled="false" hasAll="false" allCaption="All Target Component" allDisplayName="Target Component" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="targetType" disabled="false" sourceExpression="$Piece(%source.intBusinessType,&quot;|&quot;,2)" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="targetComponentName" disabled="false" sourceExpression="$Piece(%source.intBusinessComponent,&quot;|&quot;,2)" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="MsgStatus" disabled="false" hasAll="false" allCaption="All MsgStatus" allDisplayName="MsgStatus" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="MsgStatus" disabled="false" sourceProperty="msgStatus" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="InteropStatus" disabled="false" hasAll="false" allCaption="All InteropStatus" allDisplayName="InteropStatus" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="InteropStatus" disabled="false" sourceProperty="status" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="ResponseStatus" disabled="false" hasAll="false" allCaption="All ResponseStatus" allDisplayName="ResponseStatus" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="ResponseStatus" disabled="false" sourceProperty="responseStatus" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="API" disabled="false" hasAll="false" allCaption="All API" allDisplayName="API" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="APIDomain" disabled="false" sourceProperty="apiDomain" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="APIOperationId" disabled="false" sourceProperty="apiOperationId" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="ErrorMessage" disabled="false" hasAll="false" allCaption="All ErrorMessage" allDisplayName="ErrorMessage" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="ErrorCode" disabled="false" sourceProperty="respErrorCode" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="ErrorMessage" disabled="false" sourceProperty="respErrorMsg" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="CallerInfo" disabled="false" hasAll="false" allCaption="All CallerInfo" allDisplayName="CallerInfo" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="CallerInfo" disabled="false" sourceProperty="callerInfo" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="Http Params" disabled="false" hasAll="false" allCaption="All Http Params" allDisplayName="Http Params" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Http Params" disabled="false" sourceProperty="reqHttpParams" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="Http Response" disabled="false" hasAll="false" allCaption="All Http Response" allDisplayName="Http Response" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Status Code" disabled="false" sourceProperty="respHttpStatusCode" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Reason Phrase" disabled="false" sourceProperty="respHttpReasonPhrase" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Status Line" disabled="false" sourceProperty="respHttpStatusLine" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <measure name="AverageTime" displayName="Average Time" disabled="false" sourceProperty="timeToComplete" aggregate="AVG" type="number" hidden="false" searchable="false">
  </measure>
  <measure name="MaxTime" displayName="Maximum Time" disabled="false" sourceProperty="timeToComplete" aggregate="MAX" type="number" hidden="false" searchable="true">
  </measure>
  <measure name="MinTime" displayName="Minimum Time" disabled="false" sourceProperty="timeToComplete" aggregate="MIN" type="number" hidden="false" searchable="false">
  </measure>
  <listing name="SessionIDs" displayName="SessionIDs" disabled="false" listingType="table" fieldList="sessionId,reqDt,apiDomain,apiOperationId,apiPath,targetBaseURL,timeToComplete,intBusinessType,respErrorMsg" orderBy="reqDt DESC">
  </listing>
  <listing name="UltimasMensagens" disabled="false" listingType="table" fieldList="sessionId,apiDomain,apiOperationId,apiPath,reqDt,respErrorMsg,respHttpStatusCode,respHttpReasonPhrase,respHttpStatusLine,reqHttpParams,callerInfo,targetBaseURL,timeToComplete,intBusinessType" orderBy="reqDt DESC">
  </listing>
</cube>
}

Parameter DOMAIN;

}

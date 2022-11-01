Class apiPub.tracer.kpi Extends %DeepSee.KPI
{

/// This XData definition defines the KPI.
XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi xmlns="http://www.intersystems.com/deepsee/kpi"
 name="apiPub Tracer" sourceType="mdx"
 caption="apiPub Tracer"
>
<action name="LinkToEnsembleTrace" displayName="Goes to Ensemble Trace from a message" />
<action name="LinkToProduction" displayName="Goes to Interop Production" />
</kpi>
}

ClassMethod %OnDashboardAction(pAction As %String, pContext As %ZEN.proxyObject) As %Status
{
    If ((pAction = "LinkToEnsembleTrace")) {
        Set pContext.command = "newWindow:EnsPortal.VisualTrace.zen?SESSIONID="_pContext.valueList_";"
    }
    If ((pAction = "LinkToProduction")) {
        Set pContext.command = "newWindow:EnsPortal.ProductionConfig.zen"
    }
    Quit $$$OK
}

}

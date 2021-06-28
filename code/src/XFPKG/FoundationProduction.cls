Class XFPKG.FoundationProduction Extends Ens.Production [ Not ProcedureBlock ]
{

ClassMethod OnStart(pTimeStarted As %String) As %Status
{
  do ##class(%SYS.Journal.System).Stop()
	quit $$$OK
}

XData ProductionDefinition
{
<Production Name="XFPKG.FoundationProduction" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>1</ActorPoolSize>
  <Item Name="XF.CCDA.FileInboud" Category="" ClassName="XF.CCDA.FileInboud" PoolSize="10" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/output/ccda/</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.xml</Setting>
    <Setting Target="Host" Name="TargetConfigNames">XF.SDA3.FileOutbound</Setting>
    <Setting Target="Adapter" Name="ConfirmComplete">1</Setting>
    <Setting Target="Adapter" Name="FileAccessTimeout">20</Setting>
  </Item>
  <Item Name="XF.SDA3.FileOutbound" Category="" ClassName="XF.SDA3.FileOutbound" PoolSize="10" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/output/sda3/</Setting>
    <Setting Target="Host" Name="Filename">%f</Setting>
  </Item>
</Production>
}

}

if ( (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null )
{
	Add-PsSnapin Microsoft.SharePoint.PowerShell
}
[void][Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")

Function New-SiteCollectionAdministrator 
{

Param(
        [Parameter(ParameterSetName='url',Mandatory=$false)]
        [string]
        $Url,

        [Parameter(ParameterSetName='object',Mandatory=$false)]
        [Microsoft.SharePoint.SPWeb]
        $Web,

        [Parameter(Mandatory=$true)]
        [string]
        $UserName
)

	
	$siteAdmin = New-Object Microsoft.SharePoint.Administration.SPSiteAdministration($Url)
	$OriginalAdmin = $siteAdmin.SecondaryContactLoginName
	
	Set-SPSite -Identity $Url -SecondaryOwnerAlias $ENV:USERNAME
	if ( -NOT($web) ) {
		$Web = Get-SPWeb -Site $Url
	} else {
		$Url = $Web.Url
	}
	
	$WebUser = $Web.AllUsers | ? { $_ -match $UserName }
	if ( [string]::IsNullOrEmpty($WebUser) ) {
		$WebUser = New-SPUser -UserAlias $UserName -web $Url
	}
	Write-Host "Making $WebUser a site admin for $Url"
	$webUser.IsSiteAdmin = 1
	$webUser.update()
	
	Set-SPSite -Identity $Url -SecondaryOwnerAlias $OriginalAdmin
}

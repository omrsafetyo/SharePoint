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

        [Parameter(Mandatory=$false)]
        [string]
        $UserName
)

	if ( -NOT($web) ) {
		$Web = Get-SPWeb -Site $Url
	}
	$siteAdmin = New-Object Microsoft.SharePoint.Administration.SPSiteAdministration($siteUrl)
	$OriginalAdmin = $siteAdmin.SecondaryContactLoginName
	
	Set-SPSite -Identity $siteUrl -SecondaryOwnerAlias $ENV:USERNAME
	
	$WebUser = $Web.AllUsers | ? { $_ -match $UserName }
	if ( [string]::IsNullOrEmpty($WebUser) ) {
		$WebUser = New-SPUser -UserAlias $UserName -web $siteUrl
	}
	Write-Host "Making $WebUser a site admin for $siteUrl"
	$webUser.IsSiteAdmin = 1
	$webUser.update()
	
	Set-SPSite -Identity $siteUrl -SecondaryOwnerAlias $OriginalAdmin
}

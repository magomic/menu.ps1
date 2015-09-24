# DrawMenu ist - quasi - eine Unterfunktion von Menu() Rückgabewert von Menu() kann auch $pos sein
# Quelle: http://mspowershell.blogspot.de/2009/02/cli-menu-in-powershell.html
# github: https://github.com/magomic/menu.ps1

Add-Type -Language CSharp @"
namespace toolslist
{

    public class element
    {
        public element(string pdesc, string cmd)
        {
            _desc = pdesc;
            _cmd = cmd;
        }
        public string _desc;
        public string _cmd;
    }

    public class MainList
    {
        public System.Collections.ArrayList Arr = new System.Collections.ArrayList();
        
        public bool addtool(string pdesc, string pcmd)
        {
            try
            {
                    Arr.Add(new element(pdesc,pcmd));
            }
            catch
            {
                return false;
            }
            return true;
        }

        public element getelement(int pnr)
        {
            return (element)Arr[pnr];
        }
        public int getcount()
        {
            return Arr.Count;
        }
        
    }

}
"@



function DrawMenu {
    ## supportfunction to the Menu function below
    param ([toolslist.MainList]$menuItems, $menuPosition, $menuTitel)
    $fcolor = $host.UI.RawUI.ForegroundColor
    $bcolor = $host.UI.RawUI.BackgroundColor
    write-host "Position: $menuPosition"
    #$host.ui.rawui.readkey()

    $l = $menuItems.getcount -1
    cls
    $menuwidth = $menuTitel.length + 4
    Write-Host "`t" -NoNewLine
    Write-Host ("*" * $menuwidth) -fore $fcolor -back $bcolor
    Write-Host "`t" -NoNewLine
    Write-Host "* $menuTitel *" -fore $fcolor -back $bcolor
    Write-Host "`t" -NoNewLine
    Write-Host ("*" * $menuwidth) -fore $fcolor -back $bcolor
    Write-Host ""
    Write-host "L: $l MenuItems: $menuItems.arr MenuPosition: $menuposition"
    # write-host "i: $i; l: $l"
    # $Host.ui.rawui.readkey()
    for ($i = 0; $i -le $l;$i++) {
        Write-Host "`t" -NoNewLine
        if ($i -eq $menuPosition) {
            Write-Host ([toolslist.element]$menuItems.getelement($i))._desc -fore $bcolor -back $fcolor
        } else {
            Write-Host ([toolslist.element]$menuItems.getelement($i))._desc -fore $fcolor -back $bcolor
        }
    }
}

function Menu {
    ## Generate a small "DOS-like" menu.
    ## Choose a menuitem using up and down arrows, select by pressing ENTER
    param ([toolslist.MainList]$menuItems, $menuTitel = "MENU")
    $vkeycode = 0
    $pos = 0
    DrawMenu $menuItems $pos $menuTitel
    While ($vkeycode -ne 13) {
        $press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
        $vkeycode = $press.virtualkeycode
        Write-host "$($press.character)" -NoNewLine
        If ($vkeycode -eq 38) {if($pos -eq 0){$pos=$menuItems.getcount-1}else{$pos--} } #up
        If ($vkeycode -eq 40) {if($pos -eq $menuItems.getcount-1){$pos=0}else{$pos++} } #down
        if ($pos -lt 0) {$pos = 0}
        if ($pos -ge $menuItems.getcount-1) {$pos = $menuItems.getcount -1}
        DrawMenu $menuItems $pos $menuTitel
    }
    # Write-Output $($menuItems[$pos])
    write-output $($pos)
}

function WinToolsMenue
{
	# evtl Hashtable mit key 1, 2, 3, .. ? oder objekt

while ($true)
{


	# $hash = @{0="saps taskmgr"; 1="saps appwiz.cpl";2="saps mmsys.cpl"}
	$list = new-object toolslist.MainList
	$list.addtool("taskmgr (Taskmanager)", "saps taskmgr")
	$list.addtool("appwiz.cpl (Programs)", "saps appwiz.cpl")
	$list.addtool("mmsys.cpl (Device.Sound)", "saps mmsys.cpl")
	$list.addtool("odbcad32 (DB-ConnectionStrings)", "saps odbcad32")
	$list.addtool("cmd /c control printers (Drucker)", "resmon (ResourcenMonitor)")
	$list.addtool("mlcfg32.cpl (Email32)", "saps mlcfg32.cpl")
	$list.addtool("sysdm.cpl (Erw. Systemeig./Benutzerprofile)")
	$list.addtool("eventvwr.msc (Win.logs)","saps eventvwr.msc")
	$list.addtool("msconfig (Win.StartOptions)","saps msconfig")
	$list.addtool("cmd /c control admintools (Verwaltung)","cmd /c control admintools")
	$list.addtool("mstsc (RemoteDesktop)", "saps mstsc")
	$list.addtool("desk.cpl (Display)", "saps desk.cpl")
	$list.addtool("regedit (Registry)","saps regedit")
	$list.addtool("net use (Netzlaufwerke)")
	$list.addtool("Server pingen (ODBC-Dateien auslesen und Server pingen, z.b. ls.disp..)","kein befehl")
	$list.addtool("Anzahl Profile","kein Befehl")
	$list.addtool("pst-Dateien finden und einbinden","kein Befehl")
	$list.addtool("DeinstallationsMenü","kein Befehl")
	$list.addtool("<-- back","return")
	

	#$tools = "taskmgr (Taskmanager)", "appwiz.cpl (Programs)", "mmsys.cpl (Device.Sounds)", "odbcad32 (DB-ConnectionStrings)", "cmd /c control printers (Drucker)","resmon (RessourcenMonitor)", "mlcfg32.cpl (Email32)","sysdm.cpl (Erw. Systemeig./Benutzerprofile)", "eventvwr.msc (Win.logs)", "msconfig (Win.StartOptionen)" ,"cmd /c control admintools (Verwaltung)" , "mstsc (Remote Desktop)", "desk.cpl (Display)", "regedit (Registry)", "net use (Netzlaufwerke)", "Server Pingen (ODBC-Dateien auslesen und Server pingen, z.b. ls.disp,..)", "Anzahl Profile", "pst-Dateien finden und einbinden", "DeinstallationsMenü","<-- back"
# gibt es einen fraport internen nslookup für ip's von nbr's? vpn-server o.ä.?
#
	$a = Menu $list "Windows Tools"
	iex $list.getelement($a)._cmd
	break
	
	switch ($a)
	{
		# 0 {saps taskmgr}
		0 {iex $hash.0}
		# 1 {saps appwiz}
		1 {iex $hash.1}
		2 {saps mmsys.cpl}
		3 {saps odbcad32}
		4 {cmd /c control printers}
		5 {mlcfg32.cpl}
		6 {saps resmon}
		7 {saps sysdm.cpl}
		8 {saps eventvwr.msc}
		9 {saps msconfig}
		10 {cmd /c control admintools}
		11 {saps mstsc}
		12 {saps desk.cpl}
		13 {saps regedit}
		14 {& Netzlw}
		15 {& serverping}
		16 {& profilescount}
		17 {& pstfiles}
		18 {& uninstallmenu}
		19 {return}
	}
}
}

# START
while ($true)
{
	# $bad = "Windows Tools", "gpupdate (Fraport Gruppenrichtlinien)","exit"
	$bad = new-object toolslist.MainList
	$bad.addtool("Windows Tools","kein Befehl")
	$bad.addtool("gpupdate (Richtlinien)","cmd /c gpupdate /force")

	$a = Menu $bad "BlackBox"
		

	switch ($a)
	{	
		0 {WinToolsMenue}
		1 {cmd /c gpupdate /force}
		2 {return}
	}
}

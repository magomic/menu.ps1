# DrawMenu ist - quasi - eine Unterfunktion von Menu() Rückgabewert von Menu() kann auch $pos sein
# Quelle: http://mspowershell.blogspot.de/2009/02/cli-menu-in-powershell.html
# github: https://github.com/magomic/menu.ps1
# v0.2.3 improvements in menu
# v0.2.2 setupexe verbessert (cancel copy)
# v0.2.1 copy setupexe
# v0.2.0 Umstellung auf Array mit Hashtable

# <Vordefinierte Variablen>
	$setupexe = 'F:\Develop\basteltmp\bla.zip'
	$packages = 'D:\EmpirumAgent\Packages\'
	$title = "AdminBox v0.2.2"
# </Vordefinierte Variablen>


# <ConsoleOptions>
	$Host.UI.RawUI.Buffersize = @{width=120;height=3000}
	$Host.UI.RawUI.Windowsize = @{width=120;height=60}
	$Host.UI.RawUI.WindowTitle = $title
	$Host.UI.RawUI.BackgroundColor = DarkMagenta
# </ConsoleOptions>

# <Klassendefinition>

# </Klassendefinition>


#<Funktionen> 

	# <SharedFunctions>
	function DrawMenu ([Ref]$menuItems, $menuPosition, $menuTitel)
	{
		try
		{
			#supportfunction to the Menu function below

			$fcolor = $host.UI.RawUI.ForegroundColor
			$bcolor = $host.UI.RawUI.BackgroundColor
			#write-host "Position: $menuPosition"
			#$host.ui.rawui.readkey()

			$l = $menuItems.value.count -1
			
			# <Computername>
				$menuTitel += [string]::concat(' ', $env:COMPUTERNAME)
			# </Computername>
			
			# <RAM> physical ram usage of own process
				$ram = get-process -ID $PID | select -property WorkingSet 
				$ram = [math]::Round(([int32]$ram.WorkingSet)/1012/1024,2) # KB
				$menuTitel += [string]::concat(' ', $ram, ' KB')
			# </RAM>
			
			cls
			$menuwidth = $menuTitel.length + 4
			Write-Host "`t" -NoNewLine
			Write-Host ("*" * $menuwidth) -fore $fcolor -back $bcolor
			Write-Host "`t" -NoNewLine
			Write-Host "* $menuTitel *" -fore $fcolor -back $bcolor
			Write-Host "`t" -NoNewLine
			Write-Host ("*" * $menuwidth) -fore $fcolor -back $bcolor
			Write-Host ""
			#Write-debug "L: $l MenuItems:", $menuItems.value.count, " MenuPosition: ", $menuposition, ' menuItems.value[0].desc: ', menuItems.value[0].desc, ' menuItems.value[0].cmd: ', menuItems.value[0].cmd
			#write-host "i: $i; l: $l"
			#$Host.ui.rawui.readkey()
			for ($i = 0; $i -le $l;$i++) 
			{
				Write-Host "`t" -NoNewLine
				if ($i -eq $menuPosition) 
				{
					Write-Host ($menuItems.value[$i].desc) -fore $bcolor -back $fcolor
				} else 
				{
					Write-Host ($menuItems.value[$i].desc) -fore $fcolor -back $bcolor
				}
			}
		}
		catch 
		{ 
			throw $_
		}
	}
		
	function Menu ([Ref]$menuItems, $menuTitel) 
	{
		## Generate a small "DOS-like" menu.
		## Choose a menuitem using up and down arrows, select by pressing ENTER
		try{
		$vkeycode = 0
		$pos = 0
		# cmd /c pause | out-null
		
		DrawMenu $menuItems $pos $menuTitel -debug
		While ($vkeycode -ne 13) 
		{
			$press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
			$vkeycode = $press.virtualkeycode
			Write-host "$($press.character)" -NoNewLine
			If ($vkeycode -eq 38) {if($pos -eq 0)		  				 {$pos = $menuItems.value.Count -1} else {$pos--} } #up
			If ($vkeycode -eq 40) {if($pos -eq $menuItems.value.count -1){$pos = 0} 						else {$pos++} } #down
			# if ($pos -lt 0) {$pos = 0}
			# if ($pos -ge $menuItems.value.cout -1) {$pos = $menuItems.value.count -1}
			#$host.ui.rawui.readkey()
			DrawMenu $menuItems $pos $menuTitel 
		}
		# Write-Output $($menuItems[$pos])
		write-output $pos
		}
		catch 
		{
			throw $_
		}
	}
	
	function MainMenu 
	{
		try
		{
			$Host.UI.RawUI.BackgroundColor = "DarkMagenta"
			
			$mm = @( 	@{desc='local menu';cmd='localMenu'}, 
						@{desc='remote menu';cmd='remoteMenu'}, 
						@{desc='Exit';cmd='exit'} )
			
			
			while ($true)
			{
				$a = Menu ([Ref]$mm) $title
				iex $mm[$a].cmd
			}
		}
		catch
		{
			#Write-Warning "Fehler beim Aufruf $([char]34)$($bad.getelement($a)._cmd)$([char]34)"
			write-warning 'localMenu'
			write-warning "($_)"
			
			write-host "press key to continue..."
			$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			# cmd /c pause | out-null
			& localMenu
		}
	}	
	# </SharedFunctions>


	# <LocalFunctions>
	function setupexe
	{
		# Ziel-Ordner bzw. Programme auflisten und auswählen lassen Apps auf lw d:
		try{

			$app = Read-Host "Application? "
			# $lst = ls D:\*$app*\ | select -Property FullName, Name | foreach { @{cmd=   $_.FullName; desc=$_.FullName} }
			$lst = ls D:\*$app*\ | select -Property FullName, Name | foreach { @{exec=[string]::concat('saps ', $_.FullName,'\bla.zip');cmd= [string]::Concat('cmd /c copy /y /z ',$setupexe,' ', $_.FullName); desc=$_.FullName} }
			$lst += @{desc="<- Cancel";cmd="localMenu"}
			$answer = Menu ([Ref]$lst) 'Choose Destiny for setup.exe' # Menue mit mainlist bauen und Position bekmomen
			iex $lst[$answer].cmd
			write-host $lst[$answer].cmd
			ls $lst[$answer].desc
			
			write-host "press key to continue..."
			$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			
			# choice menu
			$ch = @( @{desc="JA";cmd= $lst[$answer].exec}, @{desc="NEIN";cmd="localMenu"}  )
			$tit =[string]::concat("Execute setup.exe in ", $lst[$answer].desc, "?")
			$answer2= Menu ([Ref]$ch) $tit
			# write-host $ch[$answer2].cmd
			iex $ch[$answer2].cmd
			
			
			write-host "press key to continue..."
			$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		}
		catch
		{
			throw $_
		}
	}

	function WinToolsMenue
	{
		try
		{
			$mm = @( 	@{desc='taskmgr (Taskmanager)';cmd='saps taskmgr'}, 
			@{desc='appwiz.cpl (Programs)';cmd='saps appwiz.cpl'}, 
			@{desc='mmsys.cpl (Device.Sound)';cmd='saps mmsys.cpl'}, 
			@{desc='odbcad32 (DB-ConnectionStrings)';cmd='saps odbcad32'}, 
			@{desc='cmd /c control printers (Drucker)';cmd='cmd /c control printers'}, 
			@{desc='resmon (ResourcenMonitor)';cmd='saps resmon'}, 
			@{desc='mlcfg32.cpl (Email32)';cmd='saps mlcfg32.cpl'}, 
			@{desc='sysdm.cpl (Erw. Systemeig./Benutzerprofile)';cmd='saps sysdm.cpl'}, 
			@{desc='eventvwr.msc (Win.logs)';cmd='saps eventvwr.msc'}, 
			@{desc='msconfig (Win.StartOptions)';cmd='saps msconfig'}, 
			@{desc='cmd /c control admintools (Verwaltung)';cmd='cmd /c control admintools'}, 
			@{desc='mstsc (RemoteDesktop)';cmd='saps mstsc'}, 
			@{desc='desk.cpl (Display)';cmd='saps desk.cpl'}, 
			@{desc='regedit (Registry)';cmd='saps regedit'}, 
			@{desc='net use (Netzlaufwerke)';cmd='net use; cmd /c pause | out-null'}, 
			@{desc='Server pingen (ODBC-Dateien auslesen und Server pingen, z.b. ls.disp..)';cmd='kein befehl'}, 
			@{desc='Anzahl Profile';cmd='gwmi win32_userprofile | select @{LABEL="last used";EXPRESSION={$_.ConvertToDateTime($_.lastusetime)}}, LocalPath, SID | ft -a; cmd /c pause | out-null'}, 
			@{desc='pst-Dateien finden und einbinden';cmd='kein Befehl'}, 
			@{desc='uninstall menu';cmd='kein Befehl'}, 
			# @{desc='';cmd=''}, 
			@{desc='<-- back';cmd='localMenu'} )
			
			while ($true)
			{
			# gibt es einen fraport internen nslookup für ip's von nbr's? vpn-server o.ä.?
				$a = Menu ([Ref]$mm) "WindowsBox"
				iex $mm[$a].cmd
			}
		}
		catch
		{
			throw $_ # Fehler nach oben weitergeben
		}
	}

	function localMenu 
	{
		$Host.UI.RawUI.BackgroundColor = "DarkMagenta"
		try
		{
			$mm = @( 	@{desc='Windows Tools';cmd='WinToolsMenue'}, 
						@{desc='copy Empirum setup.exe';cmd='setupexe'}, 
						@{desc='gpupdate (Richtlinien)';cmd='cmd /c gpupdate /force'}, 
						@{desc='<-- back ';cmd='MainMenu'} )
			
			
			while ($true)
			{
				$a = Menu ([Ref]$mm) 'BlueBox'
				iex $mm[$a].cmd
			}
		}
		catch
		{
			#Write-Warning "Fehler beim Aufruf $([char]34)$($bad.getelement($a)._cmd)$([char]34)"
			write-warning 'localMenu'
			write-warning "($_)"
			
			write-host "press key to continue..."
			$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			# cmd /c pause | out-null
			& localMenu
		}
	}
	# <LocalFunctions>
	
	# <RemoteFunctions>
	
	function remSetupexe ($FRA)
	{
		try{

			$app = Read-Host "Application? "
			# $lst = ls D:\*$app*\ | select -Property FullName, Name | foreach { @{cmd=   $_.FullName; desc=$_.FullName} }
			$p = [string]::concat('\\',$FRA,'\D$\EmpirumAgent\Packages\*\',$app,'\*')
			$lst = ls $p | select -Property FullName, Name | foreach { @{exec=[string]::concat('saps ', $_.FullName,'\bla.zip');cmd= [string]::Concat('cmd /c copy /y /z ',$setupexe,' ', $_.FullName); desc=$_.FullName} }
			$lst += @{desc="<- Cancel";cmd="localMenu"}
			$answer = Menu ([Ref]$lst) 'Choose Destiny for setup.exe' # Menue mit mainlist bauen und Position bekmomen
			iex $lst[$answer].cmd
			write-host $lst[$answer].cmd
			ls $lst[$answer].desc
			
			write-host "press key to continue..."
			$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			
			# choice menu
			$ch = @( @{desc="JA";cmd= $lst[$answer].exec}, @{desc="NEIN";cmd="localMenu"}  )
			$tit =[string]::concat("Execute setup.exe in ", $lst[$answer].desc, "?")
			$answer2= Menu ([Ref]$ch) $tit
			# write-host $ch[$answer2].cmd
			iex $ch[$answer2].cmd
			
			
			write-host "press key to continue..."
			$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		}
		catch
		{
			throw $_
		}
	}
	
	function remoteMenu 
	{
		try
		{
			$FRA = Read-Host 'HOSTNAME:' 
			# Regex syntax check [1-3]
			
			if($FRA -match "^FRA\d{12}")
			{			
				$Host.UI.RawUI.BackgroundColor = "DarkRed"
			
				$mm = @( 	@{desc='remote windows Tools';cmd="remWinToolsMenue $FRA"}, 
							@{desc='remote copy Empirum setup.exe';cmd="remSetupexe $FRA"}, 
							@{desc='<-- back';cmd='MainMenu'} )
				$t = [string]::concat('RedBox ', $FRA)
				
				while ($true)
				{
					$a = Menu ([Ref]$mm) $t
					iex $mm[$a].cmd
				}
			}
		}
		catch
		{
			#Write-Warning "Fehler beim Aufruf $([char]34)$($bad.getelement($a)._cmd)$([char]34)"
			# write-warning 'localMenu'
			throw $_
			
			write-host "press key to continue..."
			$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			# cmd /c pause | out-null
			
		}
	}
	
	function remWinToolsMenue ($FRA)
	{
		$mm = @( @{desc="remote Processes"; cmd=[string]::concat("gwmi -Class win32_process -computername ", $env:Computername, " | select -Property ProcessID, Name, WorkingSetSize")},
				@{desc="remote registry" ;cmd='[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey googlen' }
		
		)
	}
	# </RemoteFunctions>
	

# </Funktionen>


# START
& MainMenu

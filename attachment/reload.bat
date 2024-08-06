ECHO Off
REM This little batch files calls the awesome nircmd utility to focus Chrome window send an F5 and swtich
REM back to Eclipse. This is no longer possible with VBScript in WIN7 as Chrome can only be focused but won't
REM accept key sends unless a click is made. Seriously donate to the NirSoft for making this tool.

nircmd.exe win activate ititle "chrome"
nircmd.exe win max ititle "chrome"
nircmd.exe sendkey f5 press
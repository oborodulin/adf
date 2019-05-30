@Echo Off
rem {Copyright}
rem {License}
rem �������� ��������� ������ ���������� ���������� ������� OHW � Adf-����������� �������� ViewController
rem ������� �� ������� - ������ ��� ����������

setlocal EnableExtensions EnableDelayedExpansion
cls
1>nul chcp 1251
rem ��������� �� ���������:
set module_name=%~nx0
rem ��������
set oper=replace
rem ���� �������� ���������� ������
set ohw_uri_file=adf-settings.xml
rem ������� ������� ��������� �� �������
set is_adflib_changed=false
rem ����� ����������
set EXEC_MODE=RUN

rem ���������� ���������� �� ������� ��������� �����
if exist "%b2eincfilepath%\chgcolor.exe" (
	set ChangeColor_8_0="%b2eincfilepath%chgcolor.exe" 08
	set ChangeColor_10_0="%b2eincfilepath%chgcolor.exe" 0A
	set ChangeColor_11_0="%b2eincfilepath%chgcolor.exe" 0B
	set ChangeColor_12_0="%b2eincfilepath%chgcolor.exe" 0C
	set ChangeColor_13_0="%b2eincfilepath%chgcolor.exe" 0D
	set ChangeColor_14_0="%b2eincfilepath%chgcolor.exe" 0E
	set ChangeColor_15_0="%b2eincfilepath%chgcolor.exe" 0F
)
rem ������ ���������� �������:
rem ��������� ���������� � �����, �� �����������, ���������� ������ ���
:start_parse
set p_param=%~1
set p_key=%p_param:~0,3%
set p_value=%p_param:~4%

if "%p_param%" EQU "" goto end_parse

if "%p_key%" EQU "-em" set EXEC_MODE=%p_value%
if "%p_key%" EQU "-ld" set adflib_dir=%p_value%
if "%p_key%" EQU "-lp" set adflib_path=%p_value%
if "%p_key%" EQU "-td" set temp_dir=%p_value%
if "%p_key%" EQU "-en" set environment=%p_value%
if "%p_key%" EQU "-dd" set deploy_dir=%p_value%
if "%p_key%" EQU "-df" set deploy_file=%p_value%
if "%p_key%" EQU "-jr" set jar=%p_value%
if "%p_key%" EQU "-hf" set hosts_file=%p_value%
if "%p_key%" EQU "-pf" set help_provider_file=%p_value%
if "%p_key%" EQU "-sv" set svn=%p_value%
if "%p_key%" EQU "-su" set svn_user=%p_value%
if "%p_key%" EQU "-sp" set svn_pass=%p_value%
if "%p_key%" EQU "-op" set oper=%p_value%
if "%p_key%" EQU "-up" set update_mark=%p_value%
if "%p_key%" EQU "-co" set commit_mark=%p_value%

shift
goto start_parse

:end_parse

rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=Victory ADF: Replace OHW baseURI {Current_Version}. {Copyright} {Current_Date} ["
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=�����: %EXEC_MODE%"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ]

rem ���������� ���� � ���������
for /f %%i in (%adflib_dir%) do Set adflib_dir=%%~dpni
rem ��������� ������� ��������� Adf-����������
if NOT "%adflib_path%" EQU "" Set adflib_dir=

if "%adflib_dir%" EQU "" (
	if exist "%adflib_path%" (
		for /f %%i in (%adflib_path%) do (
			Set adflib_dir=%%~dpi
			Set adflib_dir=!adflib_dir:~0,-1!
			Set adflib_file_mask=%%~nxi
		)
	)
) else (
	Set adflib_file_mask=*-View.jar
)

for /f %%i in (%deploy_dir%) do Set deploy_dir=%%~dpni
for /f %%i in (%deploy_file%) do Set deploy_file=%%~dpnxi
for /f %%i in (%temp_dir%) do Set temp_dir=%%~dpni
rem ��� ����������, ���������� ������� ���������� �� ���� ����� ear-������
if "%deploy_dir%" EQU "" (
	if exist "%deploy_file%" (
		for /f %%i in ("%deploy_file%") do (
			Set deploy_file=%%~dpnxi
			Set deploy_dir=%%~dpi
			set deploy_dir=!deploy_dir:~0,-1!
			Set deploy_file_name=%%~nxi
		)
	)
)
if /i "%EXEC_MODE%" EQU "DBG" echo "%deploy_dir%" "%deploy_file%"  "%deploy_file_name%"

if "%adflib_dir%" EQU "" if "%deploy_dir%" EQU "" call :exec_format %module_name% & endlocal & exit /b 1
if "%deploy_dir%" EQU "" if "%adflib_dir%" EQU "" call :exec_format %module_name% & endlocal & exit /b 1
if "%environment%" EQU "" call :exec_format %module_name% & endlocal & exit /b 1

rem �������� �� ���������
if not defined update_mark set update_mark=on
if not defined commit_mark set commit_mark=on
if "%temp_dir%" EQU "" set temp_dir=%TMP% 

rem ���� OHW ��� ���������� � �������������� ���������������� WebLogic (�� ���������)
set OHW_base_URI_DEF=localhost:7101
set OHW_base_URI_DEV=dc11-wlst-01.metinvest.ua:7001
set OHW_base_URI_TEST=dc11-wlst-02.metinvest.ua:7001
set OHW_base_URI_PROD=sak-weblogic01.duk.root.local:7001

rem ���� ������ ���� ������, �� �������������� ��������, � ���������� context root
rem ��� ��������������� ����� - ����� �� ���������
for /f %%i in ("%hosts_file%") do Set hosts_file=%%~dpnxi
for /f %%i in ("%hosts_file%") do Set hosts_file_name=%%~ni
if exist "%hosts_file%" (
	for /F "usebackq eol=; tokens=1,2,3,4 delims=/	" %%a in ("%hosts_file%") do (
		if /i "%EXEC_MODE%" EQU "DBG" echo  %%a	%%b	%%c	%%d
		if /i "%%~a" EQU "INT" (
			set OHW_dir_DEF=%%~b
			set OHW_base_URI_DEF=%%~c
			set OHW_app_RC_DEF=%%~d
		)
		if /i "%%~a" EQU "DEV" (
			set OHW_dir_DEV=%%~b
			set OHW_base_URI_DEV=%%~c
			set OHW_app_RC_DEV=%%~d
		)
		if /i "%%~a" EQU "TEST" (
			set OHW_dir_TEST=%%~b
			set OHW_base_URI_TEST=%%~c
			set OHW_app_RC_TEST=%%~d
		)
		if /i "%%~a" EQU "PROD" (
			set OHW_dir_PROD=%%~b
			set OHW_base_URI_PROD=%%~c
			set OHW_app_RC_PROD=%%~d
		)
	)
)
rem ���������� ���� 
if /i "%environment%" EQU "dev" (
	set new_OHW_base_URI=%OHW_base_URI_DEV%/%OHW_app_RC_DEV%
	set new_OHW_dir=%OHW_dir_DEV%
) else if /i "%environment%" EQU "test" (
	set new_OHW_base_URI=%OHW_base_URI_TEST%/%OHW_app_RC_TEST%
	set new_OHW_dir=%OHW_dir_TEST%
) else if /i "%environment%" EQU "prod" (
	set new_OHW_base_URI=%OHW_base_URI_PROD%/%OHW_app_RC_PROD%
	set new_OHW_dir=%OHW_dir_PROD%
) else (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo error
	echo ��������� ����� ���� ������ dev, test ��� prod! ���������, ����������, ��������� ������� �������.
	call :exec_format %module_name% & endlocal & exit /b 1
)
if /i "%EXEC_MODE%" EQU "DBG" echo %OHW_base_URI_DEV%	%OHW_base_URI_TEST%	%OHW_base_URI_PROD%	=^>	%new_OHW_base_URI%
if /i "%EXEC_MODE%" EQU "DBG" echo %OHW_dir_DEF%	=^>	%new_OHW_dir%
if /i "%oper%" EQU "delete" (
	if not exist "%deploy_dir%" if not exist "%adflib_dir%" (
		rem ChangeColor 12 0 
		%ChangeColor_12_0%
		echo error
		echo ������� ���������� ^(%deploy_dir%^) ���������� ��� ear-����� ���������� ^(%deploy_file%^) �� ������\! ���������, ����������, ��������� ������� �������.
		call :exec_format %module_name% & endlocal & exit /b 1
	)
	for /f %%i in ("%help_provider_file%") do Set help_provider_file=%%~dpnxi
	if not exist "%help_provider_file%" (
		rem ChangeColor 12 0 
		%ChangeColor_12_0%
		echo error
		echo ���� %help_provider_file% �� ������\! ���� ���� �������� ������ ������ ������ ����� ���������� ������� � %ohw_uri_file%.
		call :exec_format %module_name% & endlocal & exit /b 1
	)	
)
if not exist "%adflib_dir%" if not exist "%deploy_dir%" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo error
	echo ������� Adf-��������� ^(%adflib_dir%^) �� ������\! ���������, ����������, ��������� ������� �������.
	call :exec_format %module_name% & endlocal & exit /b 1
)
for /f %%i in ("%temp_dir%") do Set temp_dir=%%~dpni
if not exist "%temp_dir%" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo error
	echo ��������� ������� ^(%temp_dir%^) �� ������\! ���������, ����������, ��������� ������� �������.
	call :exec_format %module_name% & endlocal & exit /b 1
)
rem ��������� ��������:
rem Adf-��������� � ear-�������
set tmp_adflib_dir=%temp_dir%\adflib
set tmp_ear_dir=%temp_dir%\ear
rem ����� ��������� (��������� ��� ����������� jar)
set tmp_manifest_dir=%temp_dir%\adflib\manifest
set tmp_ear_manifest_dir=%temp_dir%\ear\manifest

rem �������:
if not defined jar set jar=jar.exe
rem ������ SVN
if not defined svn set svn="C:\Program Files\TortoiseSVN\bin\TortoiseProc.exe"
set tortoise_svn=%svn:TortoiseProc.exe=%
set slik_svn=%svn:svn.exe=%
rem ���� ������ TortoiseSVN
if /i not %svn% EQU %tortoise_svn% (
	set svn_update=/command:update /closeonend:1 /path:
	set svn_commit=/command:commit /logmsg:"�������� ����� ���������� ���������� ������� �������� ��������� (%environment%)" /closeonend:1 /path:
)
rem ���� ������ SlikSvn
if /i not %svn% EQU %slik_svn% (
	set svn_update=update 
	set svn_commit=commit 
	set svn_up_switches=--username %svn_user% --password %svn_pass%
	set svn_co_switches=-m "�������� ����� ���������� ���������� ������� �������� ��������� (%environment%)" --username %svn_user% --password %svn_pass%
)
rem ���� ������� ��������� �������� �������� Adf-��������� ��� ear-�������
if exist "%adflib_dir%" (
	set last_time_check_file=%temp_dir%\%environment%_jar_last_time_check.tmp 
) else if exist "%deploy_file%" ( 
	set last_time_check_file=%temp_dir%\%environment%_%deploy_file_name%_last_time_check.tmp
) else (
	set last_time_check_file=%temp_dir%\%environment%_%hosts_file_name%_ear_last_time_check.tmp
)
rem �������� ������� ����������� ��
FOR /F "tokens=3 delims= " %%G in ('reg query "hklm\system\controlset001\control\nls\language" /v Installlanguage') DO (
	IF "%%~G" EQU "0409" (
		set OS_LOCALE=en
	) ELSE (
		set OS_LOCALE=ru
	)
)
echo.
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=���������: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=%environment% "
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=["
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=%OS_LOCALE%"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ]
if exist "%adflib_path%" (
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=�������������� Adf-����������: " 
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo %adflib_file_mask%
) else (
	if exist "%adflib_dir%" (
		rem ChangeColor 8 0
		%ChangeColor_8_0%
		echo | set /p "dummyName=������� Adf-��������� (%adflib_file_mask%): " 
		rem ChangeColor 15 0
		%ChangeColor_15_0%
		echo %adflib_dir%
	)
)
if exist "%deploy_dir%" (
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=������� ���������� ���������� (ear): "
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo %deploy_dir%
)
if exist "%deploy_file%" (
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=�������������� ear-����� ����������: "
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo %deploy_file%
)
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=��������� �������: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %temp_dir%
if exist "%hosts_file%" (
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=���� ������ OHW: "
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo %hosts_file%
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=���� OHW ���������: " 
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=%new_OHW_base_URI% "
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=["
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=%oper%"
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo ]
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=������� OHW ���������: %OHW_dir_DEF% => "
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo %new_OHW_dir%
)
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=���� ��������� ����� �������: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %last_time_check_file%
if /i "%update_mark%" EQU "on" (
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=SVN-������: "
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo %svn%
) else if /i "%commit_mark%" EQU "on" (
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=SVN-������: "
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo %svn%
)
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=���� � ������� jar: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %jar%
echo.

Choice /T 10 /D Y /M "���������� ��������� ������ OHW"
if "%Errorlevel%" EQU "2" exit /b 1

rem �������� ���������� �������� ����� ���������
if not exist "%tmp_manifest_dir%" 1>nul MD "%tmp_manifest_dir%"

rem �������� ��������� ����� �������
if exist "%last_time_check_file%" (
	for /F "usebackq tokens=1,2,3 delims= " %%i in ("%last_time_check_file%") do (
		rem ��� ������� � ���������� �����������. ���� ����������, �� ������ ��������� ���� ������, � ����� ���� � �����
		IF /i "%OS_LOCALE%" EQU "en" (
			set last_time=%%j %%k
			set last_time=!last_time:.=,!
		) ELSE (
			set last_time=%%i %%j
		)
	)
	for /F "tokens=1* delims=," %%n in ("!last_time!") do set last_time=%%n
	call :date_to_int last_int_time "!last_time!"
) else (
	set last_time=� ������ ���
	set last_int_time=0
)

rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=��������� ������ ����� ���������: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %last_time%

rem ��������� �������� �������� Adf-��������� � ear-�������
if /i "%update_mark%" EQU "on" (
	call :svn_update Adf-��������� "%adflib_dir%" "%adflib_dir%\*"
	if /i "%oper%" EQU "delete" call :svn_update ear-������� "%deploy_dir%" "%deploy_dir%\*"
)

if not exist "%adflib_dir%" goto ear_process
rem ���� �� ������� �������� ViewController � �������� �������� Adf-��������� �������������� ����� (dev/test/prod)
echo.
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=Adf-���������� �������� ViewController ("
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=%adflib_dir%"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ^)
rem ChangeColor 8 0
%ChangeColor_8_0%
echo -----------------------------------------------------------
FOR /f "tokens=1,2" %%a IN ('2^>nul FORFILES /p "%adflib_dir%" /m "%adflib_file_mask%" /C "cmd /c echo @file @fdate_@ftime"') DO (
	set adflib_file=%%~a
	set adflib_time=%%~b
	rem �� ������� �������� _ �� ������ (��� �������������)
  	set adflib_time=!adflib_time:_= !
	                   
	rem �������� �������� ����� �������
	call :date_to_int adflib_int_time "!adflib_time!"

	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=!adflib_file!	!adflib_time! (!adflib_int_time!)... "

	rem ���� Adf-���������� ���� �������� ����� ��������� ������ ����� � �������
	if %last_int_time% LSS !adflib_int_time! (
		
		rem �������� � ������� �� ��������� ������� Adf-����������
		for /f %%i in ("!adflib_file!") do Set adflib_name=%%~ni
		rem ���� ��������� ������� ������ �� ����������
		if not exist "%tmp_adflib_dir%\!adflib_name!" (
			1>nul MD "%tmp_adflib_dir%\!adflib_name!"

			pushd "%tmp_adflib_dir%\!adflib_name!"

			rem ���������� ����� META-INF\adf-settings.xml � ���������
			rem %zip% x %adflib_dir%\!adflib_file! -o%tmp_adflib_dir%\!adflib_name! -i@ohw_extract.txt -aoa
	
			rem ���������� ������ ����������
			%jar% xvf "%adflib_dir%\!adflib_file!" 1>nul 2>nul

			if /i "%EXEC_MODE%" EQU "DBG" echo ��������� ���������� ������ ���������� � �������� "%tmp_adflib_dir%\!adflib_name!" & pause
			rem ������� ����� ��������� �� ��������� �������
			if exist "%tmp_adflib_dir%\!adflib_name!\META-INF\MANIFEST.MF" (
				1>nul move /y %tmp_adflib_dir%\!adflib_name!\META-INF\MANIFEST.MF %tmp_manifest_dir%\MANIFEST.MF
	                )
			if /i "%EXEC_MODE%" EQU "DBG" echo ��������� ������� ����� ��������� � %tmp_manifest_dir%\MANIFEST.MF & pause
			rem ������ ����� �� ��������� ����������� ���������� ������ �������� �������� �������������� ����� (dev/test/prod)
			if /i "%oper%" EQU "replace" (
				%b2eincfilepath%fnr.exe --cl --dir "%tmp_adflib_dir%\!adflib_name!\META-INF" --fileMask "*.xml" --find "%OHW_base_URI_DEF%/%OHW_app_RC_DEF%" --replace "%new_OHW_base_URI%"
		
				rem ���� ��������� dev ��� prod, �� ��� ������ ���� ������� ���������� �� ������������ � �������
				if /i "%environment%" EQU "dev" (
					%b2eincfilepath%fnr.exe --cl --dir "%tmp_adflib_dir%\!adflib_name!\META-INF" --fileMask "*.xml" --find "%OHW_base_URI_PROD%/%OHW_app_RC_DEF%" --replace "%new_OHW_base_URI%"
				) else if /i "%environment%" EQU "prod" (
					%b2eincfilepath%fnr.exe --cl --dir "%tmp_adflib_dir%\!adflib_name!\META-INF" --fileMask "*.xml" --find "%OHW_base_URI_DEV%/%OHW_app_RC_DEF%" --replace "%new_OHW_base_URI%"
				) else if "%environment%" EQU "test" (
					%b2eincfilepath%fnr.exe --cl --dir "%tmp_adflib_dir%\!adflib_name!\META-INF" --fileMask "*.xml" --find "%OHW_base_URI_DEV%/%OHW_app_RC_DEF%" --replace "%new_OHW_base_URI%"
				)
			) else if /i "%oper%" EQU "delete" (
				rem �������� ����� ����������� ����������
				type nul > "%tmp_adflib_dir%\!adflib_name!\META-INF\%ohw_uri_file%.tmp"

				for /F "tokens=* delims=" %%i in ('findstr /V /G:%help_provider_file% "%tmp_adflib_dir%\!adflib_name!\META-INF\%ohw_uri_file%"') do (
					echo %%i>>"%tmp_adflib_dir%\!adflib_name!\META-INF\%ohw_uri_file%.tmp" 
				)
				move /y "%tmp_adflib_dir%\!adflib_name!\META-INF\%ohw_uri_file%.tmp" "%tmp_adflib_dir%\!adflib_name!\META-INF\%ohw_uri_file%" 1>nul
				if /i "%EXEC_MODE%" EQU "DBG" echo ��������� �������� ����� OHW �� "%tmp_adflib_dir%\!adflib_name!\META-INF\%ohw_uri_file%" & pause
			)
			rem ��������� �������
			rem %zip% u -tzip %adflib_dir%\!adflib_file! %tmp_adflib_dir%\!adflib_name!\* -mx0
		
			rem ����������� ������ Adf-���������� (http://grep.codeconsult.ch/2011/11/15/manifest-mf-must-be-the-first-resource-in-a-jar-file-heres-how-to-fix-broken-jars/)
			if exist "%tmp_manifest_dir%\MANIFEST.MF" (
				%jar% cvf0m "%adflib_dir%\!adflib_file!" "%tmp_manifest_dir%\MANIFEST.MF" . 1>nul 2>nul
			) else (
				%jar% cvf0M "%adflib_dir%\!adflib_file!" . 1>nul 2>nul
			)
			if /i "%EXEC_MODE%" EQU "DBG" echo ��������� ����������� ������ "%adflib_dir%\!adflib_file!" & pause
			rem ������� �� ���������� �������� Adf-���������� � ������� ���, � ��� �� ���� ���������
			popd
			1>nul RD /S /Q "%tmp_adflib_dir%\!adflib_name!" 2>nul
			if exist "%tmp_manifest_dir%\MANIFEST.MF" 1>nul del /Q "%tmp_manifest_dir%\MANIFEST.MF"
			if /i "%EXEC_MODE%" EQU "DBG" echo ��������� �������� ��������� �������� "%tmp_adflib_dir%\!adflib_name!" � ����� "%tmp_manifest_dir%\MANIFEST.MF" & pause
			rem ChangeColor 10 0 
			%ChangeColor_10_0%
			echo Ok	
			set is_adflib_changed=true
		) else (
			rem ChangeColor 14 0 
			%ChangeColor_14_0%
			echo processing...
		)
	) else (
		rem ChangeColor 10 0 
		%ChangeColor_10_0%
		echo pass	
	)
)
1>nul RD /S /Q "%tmp_adflib_dir%" 2>nul
rem ChangeColor 8 0
%ChangeColor_8_0%
echo -----------------------------------------------------------
:ear_process
if not exist "%deploy_dir%" goto end_ohw
rem �������� ����� ����������� ���������� - ��������� ������ ���������� *.EAR
if /i "%oper%" EQU "delete" (
	rem �������� ���������� �������� ����� ���������
	if not exist "%tmp_ear_manifest_dir%" 1>nul MD "%tmp_ear_manifest_dir%"
	
	echo.
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=EAR-������ ���������� ("
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=%deploy_dir%"
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo ^)
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo -----------------------------------------------------------
	FOR /f "tokens=1,2,3,4" %%a IN ('2^>nul FORFILES /S /p "%deploy_dir%" /m "*.ear" /C "cmd /c echo @path @file @fdate_@ftime @relpath"') DO (
		set ear_path=%%~a
		set ear_file=%%~b
		set test_ear_file=!ear_file:-=!
		set ear_relpath=%%~d
		set process_file=true

		if /i "%EXEC_MODE%" EQU "DBG" echo "!ear_file!" - "%deploy_file_name%"
		if exist "%deploy_file%" (
			if /i "!ear_file!" EQU "%deploy_file_name%" (
				set process_file=true
			) else (
				set process_file=false
			)
		)
		rem ���� ����� ���������� ��� ������ (*-x.y.z.ear) � �� *-help.ear
		if "!ear_file!" EQU "!test_ear_file!" if /i "!process_file!" EQU "true" (
			set ear_time=%%~c
			rem �� ������� �������� _ �� ������ (��� �������������)
	  		set ear_time=!ear_time:_= !
	                   
			rem �������� �������� ����� �������
			call :date_to_int ear_int_time "!ear_time!"

			rem ChangeColor 15 0
			%ChangeColor_15_0%
			echo | set /p "dummyName=!ear_relpath!	!ear_time! (!ear_int_time!)... "

			rem ���� ear-����� ��� ������ ����� ��������� ������ ����� � �������
			if %last_int_time% LSS !ear_int_time! (

				rem �������� � ������� �� ��������� ������� ear-������
				for /f %%i in ("!ear_file!") do Set ear_name=%%~ni
				rem ���� ��������� ������� �� ����������
				if not exist "%tmp_ear_dir%\!ear_name!" (
					1>nul MD "%tmp_ear_dir%\!ear_name!"

					pushd "%tmp_ear_dir%\!ear_name!"

					rem ���������� ear-������
					%jar% xvf "!ear_path!" 1>nul 
					rem 2>nul

					rem ������� ����� ��������� �� ��������� �������
					if exist "%tmp_ear_dir%\!ear_name!\META-INF\MANIFEST.MF" (
						1>nul move /y %tmp_ear_dir%\!ear_name!\META-INF\MANIFEST.MF %tmp_ear_manifest_dir%\MANIFEST.MF
	        	        	)
					if /i "%EXEC_MODE%" EQU "DBG" echo ��������� ���������� ������ � "%tmp_ear_dir%\!ear_name!" � ������� ����� ��������� %tmp_ear_manifest_dir%\MANIFEST.MF & pause
					rem ����� � ���������� ����������� war-������
					FOR /f "tokens=1" %%i IN ('2^>nul DIR /B "%tmp_ear_dir%\!ear_name!\*.war"') DO (
						set war_file=%%i
						set war_name=%%~ni

						if not exist "%tmp_ear_dir%\!war_name!" 1>nul MD "%tmp_ear_dir%\!war_name!"
						pushd "%tmp_ear_dir%\!war_name!"
					
						%jar% xvf "%tmp_ear_dir%\!ear_name!\!war_file!" 1>nul 
						rem 2>nul

						if /i "%EXEC_MODE%" EQU "DBG" echo ��������� ���������� ������ � "%tmp_ear_dir%\!ear_name!\!war_file!" & pause
						rem ������ ����� �� ��������� ����������� ���������� ������ �������� �������� �������������� ����� (dev/test/prod)
						set tmp_adf_settings_dir=%tmp_ear_dir%\!war_name!\WEB-INF\classes\META-INF
						%b2eincfilepath%fnr.exe --cl --dir "!tmp_adf_settings_dir!" --fileMask "*.xml" --find "%OHW_base_URI_DEF%/%OHW_app_RC_DEF%" --replace "%new_OHW_base_URI%"
		
						rem ������ ���� ������� ���������� �� ������������ � �������
						call :replace_host_and_dir "!tmp_adf_settings_dir!"

						if /i "%EXEC_MODE%" EQU "DBG" echo ��������� ������ ����� � "!tmp_adf_settings_dir!" & pause
						rem ����������� ������ war-������ (��� ����� ���������)
						%jar% cvf0M "%tmp_ear_dir%\!ear_name!\!war_file!" . 1>nul 
						rem 2>nul

						if /i "%EXEC_MODE%" EQU "DBG" echo ��������� ����������� ������ "%tmp_ear_dir%\!ear_name!\!war_file!" & pause
						rem ������� �� ���������� �������� war-������ � ������� ���
						popd
						1>nul 2>nul RD /S /Q "%tmp_ear_dir%\!war_name!"
					)
					rem pause
					rem ����������� ������ ear-������ (http://grep.codeconsult.ch/2011/11/15/manifest-mf-must-be-the-first-resource-in-a-jar-file-heres-how-to-fix-broken-jars/)
					if exist "%tmp_ear_manifest_dir%\MANIFEST.MF" (
						%jar% cvf0m "!ear_path!" "%tmp_ear_manifest_dir%\MANIFEST.MF" . 1>nul 
						rem 2>nul
					) else (
						%jar% cvf0M "!ear_path!" . 1>nul 
						rem 2>nul
					)
					if /i "%EXEC_MODE%" EQU "DBG" echo ��������� ����������� ������ "!ear_path!" & pause
					rem ������� �� ���������� �������� ear-������ � ������� ���, � ��� �� ���� ���������
					popd
					1>nul 2>nul RD /S /Q "%tmp_ear_dir%\!ear_name!"
					if exist "%tmp_ear_manifest_dir%\MANIFEST.MF" 1>nul del /Q "%tmp_ear_manifest_dir%\MANIFEST.MF"
					if /i "%EXEC_MODE%" EQU "DBG" echo ��������� �������� ��������� �������� "%tmp_ear_dir%\!ear_name!" � ����� "%tmp_ear_manifest_dir%\MANIFEST.MF" & pause
					rem ChangeColor 10 0 
					%ChangeColor_10_0%
					echo Ok	
				) else (
					rem ChangeColor 14 0 
					%ChangeColor_14_0%
					echo processing...
				)
			) else (
				rem ChangeColor 10 0 
				%ChangeColor_10_0%
				echo pass	
			)
		)
	)
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo -----------------------------------------------------------
)
:end_ohw
rem ��������� ����� ���������� ������ ����� �� ��������� ���������
type nul > "%last_time_check_file%"
echo %date% %time%>>"%last_time_check_file%"

rem ��������� ��������� � ��������� Adf-��������� � ear-�������
if /i "%commit_mark%" EQU "on" (
	call :svn_commit Adf-��������� "%adflib_dir%\*"
	if /i "%oper%" EQU "delete" call :svn_commit ear-������� "%deploy_dir%\*"
)
rem ���� ���� ��������� �� �������
rem if /i "%is_adflib_changed%" EQU "true" (
rem 	endlocal & exit /b 0
rem ) else (
rem 	endlocal & exit /b 1
rem )
endlocal & exit /b 0

rem ==========================================================================
rem ��������� svn_update - �������� �������� �� SVN
rem ==========================================================================
:svn_update
set dir_label=%~1
set work_dir=%2
set work_files=%3
echo.
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=SVN: ���������� �������� %dir_label%... "
if exist %svn% (
	pushd %work_dir%
	%svn% %svn_update% %work_files% %svn_up_switches%
	popd
	rem ChangeColor 10 0
	%ChangeColor_10_0%
	echo Ok
) else (
	rem ChangeColor 12 0
	%ChangeColor_12_0%
	echo error
	echo SVN: ������� %dir_label% �� ������� - �� ������ SVN-������. ��������, ��� ������� ��������� ���������� ��������������.
)
exit /b 0

rem ==========================================================================
rem ��������� svn_commit - �������� ��������� ������ � SVN
rem ==========================================================================
:svn_commit
set dir_label=%~1
set work_files=%2
echo.
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=SVN: �������� ��������� � �������� %dir_label%... "

if not exist %svn% goto svn_client_notfound

rem pushd %adflib_dir%
start "SVN: �������� ��������� � �������� Adf-���������" %svn% %svn_commit% %work_files% %svn_co_switches% 
rem popd
rem ChangeColor 10 0
%ChangeColor_10_0%
echo Ok
exit /b 0

rem ==========================================================================
rem ��������� svn_client_notfound - ����� ��������� �� ���������� SVN-�������
rem ==========================================================================
:svn_client_notfound
rem ChangeColor 12 0 
%ChangeColor_12_0%
echo error
echo SVN: ��������� ������� � �������� %dir_label% (%work_dir%) �� ������������� - �� ������ SVN-������. ��������, ��� ������� ��������� �������� ��������������.
exit /b 2

rem ==========================================================================
rem ��������� replace_host_and_dir - ������ ����� � �������� OHW
rem ==========================================================================
:replace_host_and_dir
set adf_settings_dir=%~1

%b2eincfilepath%fnr.exe --cl --dir "%adf_settings_dir%" --fileMask "*.xml" --find "%OHW_base_URI_PROD%/%OHW_app_RC_DEF%" --replace "%new_OHW_base_URI%"
%b2eincfilepath%fnr.exe --cl --dir "%adf_settings_dir%" --fileMask "*.xml" --find "%OHW_base_URI_TEST%/%OHW_app_RC_DEF%" --replace "%new_OHW_base_URI%"
%b2eincfilepath%fnr.exe --cl --dir "%adf_settings_dir%" --fileMask "*.xml" --find "%OHW_base_URI_DEV%/%OHW_app_RC_DEF%" --replace "%new_OHW_base_URI%"
rem %b2eincfilepath%fnr.exe --cl --dir "%adf_settings_dir%" --fileMask "*.xml" --find "%OHW_dir_DEF%" --replace "%new_OHW_dir%"
exit /b 0

rem ==========================================================================
rem ��������� exec_format - ������ ������� ������� �������
rem ==========================================================================
:exec_format
echo.
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ������ ������� �������:
rem ChangeColor 15 0
%ChangeColor_15_0%
echo  | set /p "dummyName=%~nx1 [<"
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=�����"
rem ChangeColor 15 0
%ChangeColor_15_0%
echo ^>...]
echo.
rem ChangeColor 8 0
%ChangeColor_8_0%
echo �����:
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -ld"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=:���������� ���� � �������� jar-������� Adf-��������� �������� ViewController (*-View.jar). "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo  | set /p "dummyName=���� �� ������, �� ������ ���� ������ ���� "
rem ChangeColor 11 0
%ChangeColor_11_0%
echo -lp
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -lp"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo  | set /p "dummyName=:���������� ���� � jar-������ Adf-���������� ������� ViewController. "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=���� �� ������, �� ������ ���� ������ ���� "
rem ChangeColor 11 0
%ChangeColor_11_0%
echo -ld
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -en"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=:"
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=(�����������) "
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ��������� [dev^|test^|prod]
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -hf"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=:"
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=(�����������) "
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ���������� ���� � ����� ������ ��� ������ ���������
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -pf"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=:"
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=(�����������) "
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ���������� ���� � �����, ����������� ������ ������ ������ �������� ���������� ������ � ����� adf-settings.xml
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -td"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :��������� �������, ������� �������� ��� �� ����� ����� ������� ���������� ������� ������� (�� ��������� %TMP%, �� ����� ������� ������� ��� ��������� SVN)
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -dd"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :���������� ���� � �������� ear-������� ����������
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -df"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :���������� ���� � ear-������ ����������
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -em"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :����� ���������� [RUN - �������, EML - ��������, DBG - �������]
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -op"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :�������� � ������ [replace/delete] (�� ��������� replace)
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -jr"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :���� � ������� jar (�� ��������� jar.exe - ��������� ������� ���� JDK..\bin � PATH)
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -sv"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :���� � SVN-������� (�� ��������� ������ TortoiseSVN. ��� �� �������������� ������ SlikSvn)
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -su"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :����� ������������ SVN
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -sp"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :������ ������������ SVN
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -up"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :������� ���������� �������� �������� SVN [on/off] (�� ��������� on)
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -co"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :������� �������� ��������� � SVN [on/off] (�� ��������� on)
exit /b 0

rem http://www.cyberforum.ru/cmd-bat/thread613576.html
:date_to_int 
set tmp.result=%~2

rem �������� ������� ����������� ��
IF /i "%OS_LOCALE%" EQU "en" (
	for /F "tokens=1,2,3* delims=/ " %%i in ("%tmp.result%") do (
		set month=%%i
		IF 1!month! LSS 100 SET month=0!month!
		set day=%%j
		IF 1!day! LSS 100 SET day=0!day!
		set year=%%k
	)
) ELSE (
	for /F "tokens=1,2,3* delims=. " %%i in ("%tmp.result%") do (
		set day=%%i
		IF 1!day! LSS 100 SET day=0!day!
		set month=%%j
		IF 1!month! LSS 100 SET month=0!month!
		set year=%%k
	)
)
set year=%year:~-2%
for /F "tokens=2,3* delims=: " %%i in ("%tmp.result%") do (
	set hours=%%i
	IF 1!hours! LSS 100 SET hours=0!hours!
	set minutes=%%j
	IF 1!minutes! LSS 100 SET minutes=0!minutes!
)
set /a %1=%year%%month%%day%%hours%%minutes%
exit /b 0

rem ---------------- EOF ohw.cmd ----------------
@Echo Off
rem {Copyright}
rem {License}
rem �������� ���������� ������ �� ������� WebLogic

setlocal EnableExtensions EnableDelayedExpansion
cls
1>nul chcp 1251
rem ��������� �� ���������
set module_name=%~nx0
set return_code=0

if defined b2eprogramfilename %extd% /tempfile %TMP%
set revert_cfg_file=%result%
for /f %%i in ("%revert_cfg_file%") do Set revert_cfg_file=%%~dpni_rev_cfg.tmp

if defined b2eprogramfilename %extd% /tempfile %TMP%
set tmp_app_versions_file=%result%
for /f %%i in ("%tmp_app_versions_file%") do Set tmp_app_versions_file=%%~dpni_app_ver.tmp

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
rem ������ ���������� �������
rem ��������� ���������� � �����, �� �����������, ���������� ������ ���
:start_parse
set p_param=%~1
set p_key=%p_param:~0,3%
set p_value=%p_param:~4%
set p_value=%p_value:"=%

if "%p_param%" EQU "" goto end_parse

if "%p_key%" EQU "-cf" set cfg_file=%p_value%
if "%p_key%" EQU "-em" set EXEC_MODE=%p_value%
if "%p_key%" EQU "-vf" set wls_app_versions_file=%p_value%
if "%p_key%" EQU "-wh" set WLS_HOST=%p_value%
if "%p_key%" EQU "-wc" set wls_credentials_file=%p_value%
if "%p_key%" EQU "-jh" set java_home=%p_value%
if "%p_key%" EQU "-oh" set oracle_home=%p_value%
if "%p_key%" EQU "-we" set WLS_ENV=%p_value%
if "%p_key%" EQU "-dd" set DISTRIB_DIR=%p_value%

shift
goto start_parse

:end_parse

if "%cfg_file%" EQU "" call :exec_format %module_name% & endlocal & exit /b 1
if "%wls_app_versions_file%" EQU "" call :exec_format %module_name% & endlocal & exit /b 1
if "%wls_credentials_file%" EQU "" call :exec_format %module_name% & endlocal & exit /b 1
if "%WLS_HOST%" EQU "" call :exec_format %module_name% & endlocal & exit /b 1
if "%EXEC_MODE%" EQU "" set EXEC_MODE=RUN

if /i "%EXEC_MODE%" EQU "EML" (
	set wls_arc_list_file=d:\wls_arc_list_file.txt
) else (
	if defined b2eprogramfilename %extd% /tempfile %TMP%
	set wls_arc_list_file=!result!
	for /f %%i in ("%wls_arc_list_file%") do Set wls_arc_list_file=%%~dpni_wls_list.tmp
)
if not exist "%cfg_file%" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo ERROR-01: �� ������ ���������������� ����: %cfg_file%^!
 	call :exec_format %module_name% & endlocal & exit /b 1
)
if not exist "%wls_credentials_file%" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo ERROR-11: �� ������ ���� ������� ������ WLS: %wls_credentials_file%^!
 	call :exec_format %module_name% & endlocal & exit /b 1
)

rem �������� ������� ������ WLS
for /F "usebackq eol=; tokens=1,2,3 delims=	" %%i in ("%wls_credentials_file%") do (
	if /i "%WLS_HOST%" EQU "%%i" (
		set WLS_USER_NAME=%%j
		set WLS_PASSWORD=%%k
	)
)
if "%WLS_USER_NAME%" EQU "" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo ERROR-12: �� ���������� ������� ������ WLS � ����� %wls_credentials_file%^!
 	endlocal & exit /b 1
)
if "%WLS_PASSWORD%" EQU "" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo ERROR-12: �� ���������� ������� ������ WLS � ����� %wls_credentials_file%^!
 	endlocal & exit /b 1
)

rem ������������� ���� � �������������� �������
if NOT "%DISTRIB_DIR%" EQU "" (
	if not exist "%DISTRIB_DIR%" (
		rem ChangeColor 12 0 
		%ChangeColor_12_0%
		echo ERROR-10: �� ������ ������� �������������: %DISTRIB_DIR%^!
	 	call :exec_format %module_name% & endlocal & exit /b 1
	)
	for /f %%i in ("%cfg_file%") do Set distrib_arc_name=%%~ni 
	if not "!distrib_arc_name!" equ "" Set distrib_arc_name=!distrib_arc_name: =!
	set tmp_distrib_dir=%TMP%\!distrib_arc_name!
	if exist "!tmp_distrib_dir!" 1>nul RD /Q /S "!tmp_distrib_dir!"
	1>nul MD "!tmp_distrib_dir!\all"
	1>nul MD "!tmp_distrib_dir!\cr"
	set distrib_all_path=%DISTRIB_DIR%\!distrib_arc_name!-all.7z
	set distrib_release_path=%DISTRIB_DIR%\!distrib_arc_name!-current-release.7z
)
rem ��� ���������� �������� ��������, ������������� �� ���������
if "%java_home%" EQU "" Set java_home=C:\Program Files\Java\jdk1.7.0_67\
if "%oracle_home%" EQU "" Set oracle_home=C:\oracle\Middleware\Oracle_Home
if "%WLS_ENV%" EQU "" Set WLS_ENV=%oracle_home%\wlserver\server\bin\setWLSEnv.cmd
if /i NOT "%EXEC_MODE%" EQU "DBG" set to_nul=1^>nul

rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=Victory ADF: WLS Deployer {Current_Version}. {Copyright} {Current_Date} ["
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=�����: %EXEC_MODE%"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ]
echo.
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=���������������� ����: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=%cfg_file% "
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=(�������� ������� ������� - "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=%revert_cfg_file%"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ^)
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=���� ������� ������� WLS: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %wls_credentials_file%
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=���� ����������������� ������� WLS: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %WLS_HOST%
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=���� ������ �������: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=%wls_app_versions_file% "
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=(��������� - "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=%tmp_app_versions_file%"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ^)
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=���� ������ ������� WLS: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %wls_arc_list_file%

rem ������������� ���������� �����
if "%JAVA_HOME%" EQU "" set JAVA_HOME=%java_home%
if "%BEA_HOME%" EQU "" set BEA_HOME=%oracle_home%

if not exist "%java_home%" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo ERROR-02: �� ������ ������� JAVA_HOME: %java_home%^!
	if /i not "%EXEC_MODE%" EQU "EML" call :exec_format %module_name% & endlocal & exit /b 1
)
if not exist "%WLS_ENV%" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo ERROR-03: �� ������ ��������� ���� ��������� ��������� WLS: %WLS_ENV%^!
	if /i not "%EXEC_MODE%" EQU "EML" call :exec_format %module_name% & endlocal & exit /b 1
)

rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=JAVA_HOME: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %java_home%
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=ORACLE_HOME (BEA_HOME): "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %oracle_home%
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=���� � setWLSEnv.cmd: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %WLS_ENV%
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=��������� �������: "
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %TMP%
rem ������ ���������� ������ � ������ �������
if /i "%EXEC_MODE%" EQU "DBG" (
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=������� ������ WLS: "
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo %WLS_USER_NAME%:%WLS_PASSWORD%
)
echo.

Choice /T 10 /D Y /M "���������� ���������� �������"
if "%Errorlevel%" EQU "2" exit /b 0
echo.

rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=����������� ��������� WebLogic... " 
if /i not "%EXEC_MODE%" EQU "EML" %to_nul% call %WLS_ENV%
rem ChangeColor 10 0 
%ChangeColor_10_0%
echo Ok

rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=��������� �������� ������ ������� ����������������� �����... " 
call :create_revert_cfg_file "%cfg_file%" "%revert_cfg_file%"
rem ChangeColor 10 0 
%ChangeColor_10_0%
echo Ok

rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=��������� ������ ������� �� WLS (" 
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=%WLS_HOST%"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=)... " 
call :create_wls_arc_list "%wls_arc_list_file%"
rem ChangeColor 10 0 
%ChangeColor_10_0%
echo Ok

echo.
rem ������ �������� ��������� ������� �� ���������
set all_deploy_done=false
if defined b2eprogramfilename %extd% /getfilename %cfg_file%
set cfg_file_name=%result%

rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=���������� Java-������� �� " 
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName=%cfg_file_name%" 
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :
echo -----------------------------------------------------------
for /F "usebackq eol=; skip=2 tokens=1,2,3,4,5 delims=	" %%i in ("%cfg_file%") do (
	set l_arc_path=%%i
	set l_arc_name=%%~ni
	set l_arc_type=%%~xi
	if not "!l_arc_type!" equ "" set l_arc_type=!l_arc_type:.=!
	set l_redeploy_mark=%%j
	for /f "tokens=1,2 delims=:" %%q in ("!l_redeploy_mark!") do (
		set l_deploy_mode=%%q
		set l_deploy_dependency=%%r
	)
	set l_mng_servers=%%k
	if not "!l_mng_servers!" equ "" set l_mng_servers=!l_mng_servers: =!
	set l_mark_dir=%%~l
	set l_plan=%%~m
	
	call :arc_deploy_process "!l_arc_path!" "!l_arc_name!" "!l_arc_type!" "!l_deploy_mode!" "!l_deploy_dependency!" "!l_mng_servers!" "!l_mark_dir!" "!l_plan!"
	
	if /i "%EXEC_MODE%" EQU "DBG" (
		rem ChangeColor 15 0
		%ChangeColor_15_0%
		pause 
	)
)
rem ��������� ���� ������ �������
%to_nul% move /y "%tmp_app_versions_file%" "%wls_app_versions_file%"

rem ��������� ������������
if not exist "%DISTRIB_DIR%" goto exit_wls_redeploy
rem ChangeColor 8 0
%ChangeColor_8_0%
echo -----------------------------------------------------------
rem ChangeColor 15 0
%ChangeColor_15_0%
echo ���������� �������������:
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=%distrib_all_path%... "
call :check_empty_dir "%tmp_distrib_dir%\all"
if %ERRORLEVEL% EQU 2 (
	if /i not "%EXEC_MODE%" EQU "EML" %to_nul% 7za.exe u -t7z -mx9 -mmt=on -ms=off -ssw -up1q0r2x1y2z1w2 "%distrib_all_path%"  "%tmp_distrib_dir%\all\*.*"
	rem ChangeColor 10 0 
	%ChangeColor_10_0%
	echo Ok
) else (
	rem ChangeColor 14 0 
	%ChangeColor_14_0%
	echo pass
)
rem ChangeColor 8 0
%ChangeColor_8_0%
echo | set /p "dummyName=%distrib_release_path%... "
call :check_empty_dir "%tmp_distrib_dir%\cr"
if %ERRORLEVEL% EQU 2 (
	if /i not "%EXEC_MODE%" EQU "EML" %to_nul% 7za.exe u -t7z -mx9 -mmt=on -ms=off -ssw -up1q0r2x1y2z1w2 "%distrib_release_path%" "%tmp_distrib_dir%\cr\*.*"
	rem ChangeColor 10 0 
	%ChangeColor_10_0%
	echo Ok
) else (
	rem ChangeColor 14 0 
	%ChangeColor_14_0%
	echo pass
)
if exist "%tmp_distrib_dir%" 1>nul RD /Q /S "%tmp_distrib_dir%"

:exit_wls_redeploy
rem ChangeColor 15 0
%ChangeColor_15_0%

endlocal & exit /b %return_code%

rem ==========================================================================
rem ������������ ������� ���������� �������� ������
rem ==========================================================================
:arc_deploy_process
rem setlocal
set _ad_arc_path=%~1
set _ad_arc_name=%~2
set _ad_arc_type=%~3
set _ad_deploy_mode=%~4
set _ad_deploy_dependency=%~5
set _ad_mng_servers=%~6
set _ad_mark_dir=%~7
set _ad_plan=%~8

if not exist "%_ad_arc_path%" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo ERROR-09: �� ������ ����� !l_arc_path!. ���������, ����������, ���������������� ����...
	set return_code=9
	goto next_archive
)
rem ChangeColor 15 0
%ChangeColor_15_0%
	echo | set /p "dummyName=- %_ad_arc_name%.%_ad_arc_type%"
rem ChangeColor 8 0
%ChangeColor_8_0%
	echo | set /p "dummyName=... "

rem ���� ������ �����������
if /i "%_ad_deploy_mode%" EQU "DISTRIB" (
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=["
	rem ChangeColor 14 0 
	%ChangeColor_14_0%
	echo | set /p "dummyName=%_ad_deploy_mode%"
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=] "
	if exist "%DISTRIB_DIR%" (
		%to_nul% copy "%_ad_arc_path%" "%tmp_distrib_dir%\all\%_ad_arc_name%.%_ad_arc_type%"
		rem ChangeColor 10 0 
		%ChangeColor_10_0%
		echo Ok
	) else (
		rem ChangeColor 12 0 
		%ChangeColor_12_0%
		echo ERROR-10: �� ������ ������� �������������: %DISTRIB_DIR%^!
	)
	goto end_arc_deploy_process
)
rem ���������� ����� ��������� META-INF\MANIFEST.MF
call :extract_manifest "%_ad_arc_path%" "%TMP%\%_ad_arc_name%" "%_ad_arc_type%" "%_ad_arc_name%" d_arc_version d_arc_extension
if NOT %ERRORLEVEL% EQU 0 goto next_archive

if exist "%DISTRIB_DIR%" %to_nul% copy "%_ad_arc_path%" "%tmp_distrib_dir%\all\%_ad_arc_name%-%d_arc_version%.%_ad_arc_type%"

rem ��������� ������������� ���������� ������ �� ��������-��������	
rem ������������ ���������� �� ��������-��������
call :check_empty_dir "%_ad_mark_dir%"
set check_mark_dir=%ERRORLEVEL%
if NOT %check_mark_dir% EQU 0 goto to_deploy

rem ���� ����� ������������ � ������ wls
call :check_arc_on_wls "%d_arc_extension%" "%wls_arc_list_file%"
if %ERRORLEVEL% EQU 1 (
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=[%d_arc_version%] "
	rem ChangeColor 14 0 
	%ChangeColor_14_0%
	echo pass ^(empty mark directory^)
	goto end_arc_deploy_process
)

:to_deploy

rem ������� ���������� � ���������� ������
call :compare_versions "%wls_arc_list_file%" "%d_arc_extension%" "%d_arc_version%" "%_ad_arc_type%" %check_mark_dir% d_calc_deploy d_wls_arc_version

rem ���� �������� ����� - PROD � ������ ������ ����� �� ��� �� WLS
if /i "%_ad_deploy_mode%" EQU "PROD" if /i "%d_wls_arc_version%" EQU "%d_arc_version%" (
	if /i "%EXEC_MODE%" EQU "DBG" echo %d_wls_arc_version%  - %d_arc_version%
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo ERROR-04: ����� ������ %d_arc_version% �� WLS ^(%WLS_HOST%^) ��� ����������^! ��������, ����������, ������ ������ � ��� ���������
	rem set return_code=4
	goto next_archive
)
rem ���� ���� ��������� ������ �������� ������� � WLS, ����� ��������� ������������� � ������ IN-PLACE
if /i "%all_deploy_done%" EQU "true" set _ad_deploy_mode=IN-PLACE

rem ���� ��� ��������� ������ ���� ���������� ������ �� WLS � �������� ����� ���������� IN-PLACE, � �������� ����� - PROD
if %check_mark_dir% EQU 2 if NOT "%d_wls_arc_version%" EQU "" if /i "%d_calc_deploy%" EQU "IN-PLACE" if /i "%_ad_deploy_mode%" EQU "PROD" (
	if /i "%EXEC_MODE%" EQU "DBG" echo %d_wls_arc_version%  - %d_calc_deploy%
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo ERROR-04: ����� ������ %d_arc_version% �� WLS ^(%WLS_HOST%^) ��� ����������. ��������, ����������, ������ ������ � ��� ���������
	rem set return_code=4
	goto next_archive
)
rem ���� ����� ����������� �� WLS
if /i "%d_calc_deploy%" EQU "none" (
	call :in_place_deploy "%_ad_arc_path%" "%_ad_arc_type%" "%_ad_mng_servers%" "%d_arc_extension%" "%_ad_plan%"
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=["
	rem ChangeColor 14 0 
	%ChangeColor_14_0%
	echo | set /p "dummyName=IN-PLACE "
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=%d_wls_arc_version% -> %d_arc_version%] "
	rem ChangeColor 10 0 
	%ChangeColor_10_0%
	echo Ok
	if exist "%DISTRIB_DIR%" %to_nul% copy "%_ad_arc_path%" "%tmp_distrib_dir%\cr\%_ad_arc_name%-%d_arc_version%.%_ad_arc_type%"
	goto end_arc_deploy_process
)

rem ������� � WLS ����� (� ������ IN-PLACE) ��� ��� ��������� ������ (��� ���������� ������ � ������ PROD)
call :undeploy "%wls_arc_list_file%" "%revert_cfg_file%" "%wls_app_versions_file%" "%_ad_arc_path%" "%_ad_deploy_mode%" "%_ad_deploy_dependency%" "%_ad_mng_servers%" "%d_arc_extension%" "%d_calc_deploy%"

rem ������ ������� ���������� � ������� ������
if /i "%_ad_deploy_mode%" EQU "IN-PLACE" (
	call :in_place_deploy "%_ad_arc_path%" "%_ad_arc_type%" "%_ad_mng_servers%" "%d_arc_extension%" "%_ad_plan%"
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=["
	rem ChangeColor 14 0 
	%ChangeColor_14_0%
	echo | set /p "dummyName=%_ad_deploy_mode% "
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=%d_wls_arc_version% -> %d_arc_version%] "
	if exist "%DISTRIB_DIR%" %to_nul% copy "%_ad_arc_path%" "%tmp_distrib_dir%\cr\%_ad_arc_name%-%d_arc_version%.%_ad_arc_type%"
) else if /i "%_ad_deploy_mode%" EQU "PROD" (
	call :prod_redeploy "%_ad_arc_path%" "%_ad_arc_type%" "%_ad_mng_servers%" "%d_arc_extension%" "%_ad_plan%"
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=["
	rem ChangeColor 14 0 
	%ChangeColor_14_0%
	echo | set /p "dummyName=%_ad_deploy_mode% "
	rem ChangeColor 15 0
	%ChangeColor_15_0%
	echo | set /p "dummyName=%d_wls_arc_version% -> %d_arc_version%] "
	if exist "%DISTRIB_DIR%" %to_nul% copy "%_ad_arc_path%" "%tmp_distrib_dir%\cr\%_ad_arc_name%-%d_arc_version%.%_ad_arc_type%"
) else if /i not "%_ad_deploy_mode%" EQU "DISTRIB" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo ERROR-05: ����� ���������� ������ ���� IN-PLACE, PROD ��� DISTRIB. ���������, ����������, ���������������� ����
	set return_code=5
	goto next_archive
)
rem ChangeColor 10 0 
%ChangeColor_10_0%
echo Ok
goto end_arc_deploy_process
:next_archive
echo.
:end_arc_deploy_process
if /i not "%EXEC_MODE%" EQU "EML" if exist "%_ad_mark_dir%" %to_nul% del /Q "%_ad_mark_dir%\*.*"
if exist "%TMP%\%_ad_arc_name%\MANIFEST.MF" %to_nul% del /Q "%TMP%\%_ad_arc_name%\MANIFEST.MF"
rem endlocal  
exit /b 0

rem ==========================================================================
rem ���������� ����� ��������� META-INF\MANIFEST.MF �� ��������� ������ �
rem ��������� ������ ������ � ����� ����������
rem �������: ERRORLEVEL 1 - ������, 0 - ����
rem ==========================================================================
:extract_manifest 
rem setlocal
set _em_arc_path=%~1
set _em_to_dir=%~2
set _em_arc_type=%~3
set _em_arc_name=%~4

if not exist "%_em_to_dir%\MANIFEST.MF" (
	if not exist "%_em_to_dir%" MD "%_em_to_dir%"
	7za e "%_em_arc_path%" -o"%_em_to_dir%" META-INF\MANIFEST.MF -aoa %to_nul%
)
if not exist "%_em_to_dir%\MANIFEST.MF" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo ERROR-06: � ������ �� ������ ���� ���������: META-INF\MANIFEST.MF
	set return_code=6
	endlocal & exit /b 1
)
rem ����� ������ ������ � ������������ ���������� ������
for /F "usebackq tokens=1,2 delims=:" %%a in ("%_em_to_dir%\MANIFEST.MF") do (
	if /i "%%a" EQU "Implementation-Version" set arc_version=%%b
	if /i "%%a" EQU "Weblogic-Application-Version" set arc_version=%%b
	if /i "%%a" EQU "Extension-Name" set arc_extension=%%b
	if /i "%%a" EQU "ApplicationName" set arc_extension=%%b
)
if /i "!arc_extension!" EQU "" if /i "%_em_arc_type%" EQU "ear" set arc_extension=%_em_arc_name%
if not "!arc_version!" EQU "" set arc_version=!arc_version: =!
if not "!arc_extension!" EQU "" set arc_extension=!arc_extension: =!

if /i "!arc_version!" EQU "" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo | set /p "dummyName=ERROR-07: � ����� ��������� MANIFEST.MF �� ������� ������ ������: "
	if /i "%_em_arc_type%" EQU "ear" (
		echo Weblogic-Application-Version
	) else (
		echo Implementation-Version
	)
	set return_code=7
	exit /b 1
)
if /i "!arc_extension!" EQU "" (
	rem ChangeColor 12 0 
	%ChangeColor_12_0%
	echo | set /p "dummyName=ERROR-08: � ����� ��������� MANIFEST.MF �� ������� ��� "
	if /i "%_em_arc_type%" EQU "ear" (
		echo ����������: ApplicationName
	) else (
		echo ����������: Extension-Name
	)
	set return_code=8
	exit /b 1
)
rem endlocal
set "%5=!arc_version!"
set "%6=!arc_extension!"
exit /b 0

rem ==========================================================================
rem ������ ��������� ���� � �������� �������� ������� ����������������� �����
rem ==========================================================================
:create_revert_cfg_file 
setlocal enableextensions disabledelayedexpansion
set _cfg_file=%~1
set _revert_cfg_file=%~2

for /f "eol=; tokens=1,* delims=�" %%a in ('
     cmd /v:off /e /q /c"set "counter^=10000000" & for /f usebackq^ skip^=2^ delims^=^  %%c in ("%_cfg_file%") do (set /a "counter+^=1" & echo(�%%c)"
     ^| sort /r
 ') do (
	echo %%b>>"%_revert_cfg_file%"
)
endlocal & exit /b 0

rem ==========================================================================
rem ������������� ������� ��������� ������ �� ������� ������ � ��������-��������
rem �������: ERRORLEVEL 1 - ��� ��������, 2 - ����� ������ (� �������� ���� �����), 
rem 0 - ����� �� ������ (� �������� ��� ������)
rem ==========================================================================
:check_empty_dir
setlocal 
set _mark_dir=%~1
if not exist "%_mark_dir%" exit /b 1
for /F %%i in ('2^>nul dir /b /A:-D "%_mark_dir%\*.*"') do exit /b 2
endlocal & exit /b 0

rem ==========================================================================
rem ������ ���� �� ������� ������� ����������� �� �������� �������  WLS
rem ==========================================================================
:create_wls_arc_list
setlocal 
set _cl_wls_arc_list_file=%~1
if /i not "%EXEC_MODE%" EQU "EML" %to_nul% java weblogic.Deployer -adminurl %WLS_HOST% -username %WLS_USER_NAME% -password %WLS_PASSWORD% -listapps > "%_cl_wls_arc_list_file%"
if /i "%EXEC_MODE%" EQU "DBG" type "%_cl_wls_arc_list_file%"
endlocal & exit /b 0

rem ==========================================================================
rem ���������� ������ ������� � ���������� ������������� � ��� ����������.
rem ��� �� ��������� ������ �� ������� �� ��������� ����.
rem ==========================================================================
:compare_versions 
rem setlocal 
set _cv_wls_arc_list_file=%~1
set _cv_arc_extension=%~2
set _cv_arc_version=%~3
set _cv_arc_type=%~4
set _cv_check_mark_dir=%~5

rem �������, ��� ����� ����������� �� WLS
set cv_calc_deploy=none
set find_extension=false
set find_version=false
set impl_version=
set num_impl_version=
set max_num_impl_version=0
set max_impl_version=
rem ���������� �� ������ �������
for /F "usebackq skip=1 tokens=1,2,3,* delims=,[] " %%a in ("%_cv_wls_arc_list_file%") do (
	if /i "%_cv_arc_extension%" EQU "%%a" (
		set find_extension=true
		set find_version=false
		set wls_version=%%c
		if NOT "!wls_version!" EQU "" set test_wls_version=!wls_version:LibImplVersion=!
		if /i "%EXEC_MODE%" EQU "DBG" echo  %_cv_arc_extension% "%%a" "%%b" "%%c" "%%d" - [!wls_version! - !test_wls_version!]
		rem ���� ���������������� �� ����������, �� �������� ���������� ��� ����������
		if /i "!wls_version!" EQU "!test_wls_version!" (
			set wls_version=%%b
			if NOT "!wls_version!" EQU "" set test_wls_version=!wls_version:Version=!
		)
		set cv_calc_deploy=IN-PLACE
		if /i "%EXEC_MODE%" EQU "DBG" echo v2 %_cv_arc_extension% "%%a" "%%b" "%%c" "%%d" - [!wls_version! - !test_wls_version!]
		rem ���� ���������� ������ ���������� �� WLS
		if /i NOT  "!wls_version!" EQU "" (
			if /i NOT  "!wls_version!" EQU "!test_wls_version!" (
				for /f "tokens=1,2 delims==" %%q in ("!wls_version!") do (
		                	set impl_version=%%r
			                set num_impl_version=!impl_version:.=!
					if !num_impl_version! GTR !max_num_impl_version! if /i NOT "%_cv_arc_version%" EQU "!impl_version!" set cv_calc_deploy=PROD
				)
				set find_version=true
				if /i "%EXEC_MODE%" EQU "DBG" echo l %_cv_arc_extension%  - !impl_version!
			)
		) else (
			rem �������� ���������� ������ �� ����� ������
			if exist "%wls_app_versions_file%" (
				for /F "usebackq tokens=1,2,3,4 delims=	" %%i in ("%wls_app_versions_file%") do (
					if /i "%_cv_arc_extension%" EQU "%%j" (
						if /i "%%l" EQU "" set impl_version=%%k
						if /i NOT "%%l" EQU "" set impl_version=%%l
				                set num_impl_version=!impl_version:.=!
						if !num_impl_version! GTR !max_num_impl_version! if /i NOT "%_cv_arc_version%" EQU "!impl_version!" set cv_calc_deploy=PROD
						set find_version=true
						set max_impl_version=!impl_version!
					)
				)
				if /i "%EXEC_MODE%" EQU "DBG" echo f %_cv_arc_extension%  - !impl_version! [!wls_version!]
			)
		)
	)
	rem ���������� ������������ ������������� ������ ������
	if /i "!find_version!" EQU "true" if !num_impl_version! GTR !max_num_impl_version! (
							set max_num_impl_version=!num_impl_version!
							set max_impl_version=!impl_version!
						)
)
if /i "%EXEC_MODE%" EQU "DBG" echo m %_cv_arc_extension%  - !max_impl_version!
rem ����� ��������� ������ �� ������� � ���������� ����
if /i "%find_extension%" EQU "true" (
	if /i "!find_version!" EQU "true" (
		echo %_cv_arc_type%	%_cv_arc_extension%	!max_impl_version!	%_cv_arc_version%>>"%tmp_app_versions_file%"
	) else (
		echo %_cv_arc_type%	%_cv_arc_extension%	%_cv_arc_version%>>"%tmp_app_versions_file%"
	)
) else (
	echo %_cv_arc_type%	%_cv_arc_extension%	%_cv_arc_version%>>"%tmp_app_versions_file%"
)
:found_wls_version
rem endlocal
set "%6=%cv_calc_deploy%"
set "%7=!max_impl_version!"
exit /b 0 
rem :compare_versions 

rem ==========================================================================
rem ��������� ����� �� ������� WLS � ������ IN-PLACE
rem ==========================================================================
:in_place_deploy 
setlocal 
set _arc_path=%~1
set _arc_type=%~2
set _mng_servers=%~3
set _arc_extension=%~4
set _plan=%~5

set arg_plan=
if exist "%_plan%" set arg_plan=-plan "%_plan%"
if /i "%_arc_type%" EQU "ear" (
	if /i NOT "%arg_plan%" EQU "" (
		rem ChangeColor 14 0 
		%ChangeColor_14_0%
		echo | set /p "dummyName=plan: %_plan%"
	)
	if /i not "%EXEC_MODE%" EQU "EML" %to_nul% java weblogic.Deployer -stage -deploy -adminurl %WLS_HOST% -username %WLS_USER_NAME% -password %WLS_PASSWORD% -targets %_mng_servers% -name %_arc_extension% %_arc_path% %arg_plan%
) else (
	if /i not "%EXEC_MODE%" EQU "EML" %to_nul% java weblogic.Deployer -stage -deploy -library -adminurl %WLS_HOST% -username %WLS_USER_NAME% -password %WLS_PASSWORD% -targets %_mng_servers% -name %_arc_extension% %_arc_path%
)
endlocal & exit /b 0

rem ==========================================================================
rem ��������� ����� �� ������� WLS � ������ PROD
rem ==========================================================================
:prod_redeploy 
setlocal 
set _arc_path=%~1
set _arc_type=%~2
set _mng_servers=%~3
set _arc_extension=%~4
set _plan=%~5

set arg_plan=
if exist "%_plan%" set arg_plan=-plan "%_plan%"
rem ������ ���������� ��������� � ������������ ������
if /i "%_arc_type%" EQU "ear" (
	if /i NOT "%arg_plan%" EQU "" (
		rem ChangeColor 14 0 
		%ChangeColor_14_0%
		echo | set /p "dummyName=plan: %_plan%"
	)
	if /i not "%EXEC_MODE%" EQU "EML" %to_nul% java weblogic.Deployer -redeploy -adminurl %WLS_HOST% -username %WLS_USER_NAME% -password %WLS_PASSWORD% -targets %_mng_servers% -name %_arc_extension% -source "%_arc_path%" %arg_plan% -retiretimeout 300
) else (
	rem ��������� ������ - � IN PLACE ������
	call :in_place_deploy "%_arc_path%" "%_arc_type%" "%_mng_servers%" "%arc_extension%" "%_plan%"
)
endlocal & exit /b 0

rem ==========================================================================
rem ������� ������ � ������� WLS �������� ������������ � ���������������� �����
rem ==========================================================================
:undeploy
rem setlocal 
set _un_wls_arc_list_file=%~1
set _un_revert_cfg_file=%~2
set _un_wls_app_versions_file=%~3
set _un_arc_path=%~4
set _un_deploy_mode=%~5
set _un_deploy_dependency=%~6
set _un_mng_servers=%~7
set _un_arc_extension=%~8
set _un_calc_deploy=%~9

if defined b2eprogramfilename %extd% /getextension "%_un_arc_path%"
set un_arc_type=%result%

rem ���� ����� ���������� PROD, ��� ����������� ��� ear-�������
if /i "%_un_deploy_mode%" EQU "PROD" if /i "%_un_deploy_dependency%" EQU "NONE" if /i "%un_arc_type%" EQU "ear" (
	call :prod_undeploy "%_un_wls_app_versions_file%" "%_un_mng_servers%" "%_un_arc_extension%"
	goto undeploy_done
)
rem ���� ����� ���������� IN-PLACE, ����������� �� ���� ����������� � ������� �������� ��� �� ����
if /i "%_un_deploy_mode%" EQU "IN-PLACE" if /i NOT "%all_deploy_done%" EQU "true" (
	if /i "%_un_deploy_dependency%" EQU "ALL" (
		rem ������� � ������� ��� ����������� ������ � �������� �������
		rem ChangeColor 13 0
		%ChangeColor_13_0%
		echo | set /p "dummyName=undeploy:"
		for /F "usebackq eol=; tokens=1,2,3,4,5 delims=	" %%i in ("%_un_revert_cfg_file%") do (
			set l_arc_path=%%i
			set l_arc_name=%%~ni
			set l_arc_type=%%~xi
			set l_arc_type=!l_arc_type:.=!
			set l_redeploy_mark=%%j
			for /f "tokens=1,2 delims=:" %%q in ("!l_redeploy_mark!") do (
				set l_deploy_mode=%%q
				set l_deploy_dependency=%%r
			)
			set l_mng_servers=%%k
			set l_mng_servers=!l_mng_servers: =!

			call :all_undeploy_process "!l_arc_path!" "!l_arc_name!" "!l_arc_type!" "%_un_arc_extension%" "!l_mng_servers!" "%_un_deploy_mode%" "%_un_wls_app_versions_file%" "%_un_wls_arc_list_file%"
			if NOT !ERRORLEVEL! EQU 0 (
				set all_deploy_done=true
				goto undeploy_done
			)
		)
	)
	rem ���� ��� �����������
	if /i "%_un_deploy_dependency%" EQU "NONE" (
		rem ���� �������� ������ ��� �� �������
		if /i "%_un_calc_deploy%" EQU "none" goto undeploy_done
		rem ���� �������� ����� IN-PLACE
		rem ChangeColor 13 0
		%ChangeColor_13_0%
		echo | set /p "dummyName=undeploy:"
		rem ChangeColor 8 0
		%ChangeColor_8_0%
		echo | set /p "dummyName=%_un_arc_extension%... "
		if /i not "%EXEC_MODE%" EQU "EML" %to_nul% java weblogic.Deployer -undeploy -adminurl %WLS_HOST% -username %WLS_USER_NAME% -password %WLS_PASSWORD% -targets %_un_mng_servers% -name %_un_arc_extension%
		rem ChangeColor 11 0
		%ChangeColor_11_0%
		echo | set /p "dummyName=done "
	)
)
:undeploy_done
rem endlocal & 
exit /b 0
rem :undeploy

rem ==========================================================================
rem ������� ����� � �������� ������ ����������� �� ����������� �������
rem ==========================================================================
:all_undeploy_process
rem setlocal 
set _au_arc_path=%~1
set _au_arc_name=%~2
set _au_arc_type=%~3
set _mau_arc_extension=%~4
set _au_mng_servers=%~5
set _mau_deploy_mode=%~6
set _au_wls_app_versions_file=%~7
set _au_wls_arc_list_file=%~8

rem ���������� ����� ��������� META-INF\MANIFEST.MF
call :extract_manifest "%_au_arc_path%" "%TMP%\%_au_arc_name%" "%_au_arc_type%" "%_au_arc_name%" u_arc_version u_arc_extension
if NOT %ERRORLEVEL% EQU 0 goto next_undeploy

call :check_arc_on_wls "%u_arc_extension%" "%_au_wls_arc_list_file%"
if %ERRORLEVEL% EQU 0 goto next_undeploy

rem ���� ����� �������� ������ IN-PLACE
if /i "%_mau_deploy_mode%" EQU "IN-PLACE" (
	rem ��������� ������� ��� ����������� ������ ������ � �������
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=%u_arc_extension%... "
	if /i not "%EXEC_MODE%" EQU "EML" %to_nul% java weblogic.Deployer -undeploy -adminurl %WLS_HOST% -username %WLS_USER_NAME% -password %WLS_PASSWORD% -targets %_au_mng_servers% -name %u_arc_extension%
	rem ChangeColor 11 0
	%ChangeColor_11_0%
	echo | set /p "dummyName=done "
) else (
	rem � ������ PROD ��������� ������ ����������
	if /i "%_mau_deploy_mode%" EQU "PROD" if /i "%_au_arc_type%" EQU "ear" call :prod_undeploy "%_au_wls_app_versions_file%" "%_au_mng_servers%" "%u_arc_extension%"
)
:next_undeploy
rem endlocal
if /i "%_mau_arc_extension%" EQU "%u_arc_extension%" exit /b 1
exit /b 0

rem ==========================================================================
rem ������� ear-������ � ������������ ������ (PROD), �������� ���� ������
rem ==========================================================================
:prod_undeploy 
setlocal 
set _wls_app_versions_file=%~1
set _mng_servers=%~2
set _arc_extension=%~3

rem ChangeColor 13 0
%ChangeColor_13_0%
echo | set /p "dummyName=undeploy:"
rem ���� ��� ����� ������
if not exist "%_wls_app_versions_file%" (
	rem ������� ��� ����
	rem ChangeColor 8 0
	%ChangeColor_8_0%
	echo | set /p "dummyName=%_arc_extension%... "
	if /i not "%EXEC_MODE%" EQU "EML" %to_nul% java weblogic.Deployer -undeploy -adminurl %WLS_HOST% -username %WLS_USER_NAME% -password %WLS_PASSWORD% -targets %_mng_servers% -name %_arc_extension%
	rem ChangeColor 11 0
	%ChangeColor_11_0%
	echo | set /p "dummyName=done "
) else (
	rem ����� ������� ���������� ������
	for /F "usebackq tokens=1,2,3,4 delims=	" %%a in ("%_wls_app_versions_file%") do (
		if /i "%_arc_extension%" EQU "%%b" (
			set l_app_version=%%c
			rem ChangeColor 8 0
			%ChangeColor_8_0%
			echo | set /p "dummyName=%_arc_extension% v.!l_app_version!... "
			if /i not "%EXEC_MODE%" EQU "EML" %to_nul% java weblogic.Deployer -undeploy -adminurl %WLS_HOST% -username %WLS_USER_NAME% -password %WLS_PASSWORD% -targets %_mng_servers% -name %_arc_extension% -appversion !l_app_version!
			rem ChangeColor 11 0
			%ChangeColor_11_0%
			echo | set /p "dummyName=done "
		)
	)
)
endlocal & exit /b 0

rem ==========================================================================
rem ��������� ��������� �� ����� �� ������� WLS
rem �������: ERRORLEVEL 1 - ����� ������, 0 - ����� �� ������
rem ==========================================================================
:check_arc_on_wls 
setlocal 
set _arc_extension=%~1
set _wls_arc_list_file=%~2
for /F "usebackq skip=1 tokens=1,* delims=,[] " %%a in ("%_wls_arc_list_file%") do (
	if /i "%_arc_extension%" EQU "%%a" (
		endlocal & exit /b 1
	)
)
endlocal & exit /b 0

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
echo %~nx1 [^<�����^>...]
echo.
rem ChangeColor 8 0
%ChangeColor_8_0%
echo �����:
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -cf"
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName= :(�����������) "
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ���������� ���� � ����������������� �����
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -vf"
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName= :(�����������) "
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ���������� ���� � ����� ������ ������� WLS [��� ������ ������� ������� ���� ������, ������������ ����������� ��������]
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -wc"
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName= :(�����������) "
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ���������� ���� � ����� ������� ������� WLS [�������� ������ ����: ]
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -wh"
rem ChangeColor 15 0
%ChangeColor_15_0%
echo | set /p "dummyName= :(�����������) "
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ���� ����������������� ������� WLS [������: ��� ���������� - localhost:7001, ��� ��������� - t3://sak-testwls01:7001]
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -jh"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :���������� ���� � �������� JAVA_HOME
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -oh"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :���������� ���� � �������� ORACLE_HOME [BEA_HOME]
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -we"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :���������� ���� � ���������� ����� ��������� ��������� WLS [setWLSEnv.cmd]
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -em"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :����� ���������� [RUN - �������, EML - ��������: ���� ������ ������� d:\wls_arc_list_file.txt, DBG - �������]
rem ChangeColor 11 0
%ChangeColor_11_0%
echo | set /p "dummyName=   -dd"
rem ChangeColor 8 0
%ChangeColor_8_0%
echo :���������� ���� � ������������� �������� ������� ����������� [*-all.7z - �������� ��� ������ ������� ������; *-current-release.7z - ������ ���������� ������ ��� ���������� �� WLS]
exit /b 0
rem ---------------- EOF wls_redeploy.cmd ----------------
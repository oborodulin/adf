@Echo Off
D:\Projects.java\Utils\CI\ohw\ohw.cmd -ld:"D:\Projects.java\AdfLib" -td:"D:\Projects.java\Utils\CI\tmp" -en:dev ^
					-pf:"D:\Projects.java\Utils\CI\ohw\help-provider.txt" -op:delete ^
					-up:off -co:off %*
rem 					-hf:"D:\Projects.java\Utils\CI\ohw\erp_hosts.txt" ^
rem 	-jr:"C:\Progra~1\Java\jdk1.8.0_65\bin\jar.exe" ^
rem 	-sv:"C:\Progra~1\SlikSvn\bin\svn.exe" -su:CIServer -sp:cis_12345 ^

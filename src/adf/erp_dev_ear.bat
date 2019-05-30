@Echo Off
D:\Projects.java\Utils\CI\ohw\ohw.cmd -td:"D:\Projects.java\Utils\CI\tmp" -en:dev ^
					-df:"D:\Projects.java\Deploy\Dev\erp.ear" ^
					-hf:"D:\Projects.java\Utils\CI\ohw\erp_hosts.txt" ^
					-pf:"D:\Projects.java\Utils\CI\ohw\help-provider.txt" -op:delete ^
					-up:off -co:off
rem 	-jr:"C:\Progra~1\Java\jdk1.8.0_65\bin\jar.exe" ^
rem 	-sv:"C:\Progra~1\SlikSvn\bin\svn.exe" -su:CIServer -sp:cis_12345 ^

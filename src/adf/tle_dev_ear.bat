@Echo Off
D:\Projects.java\Utils\CI\ohw\ohw.exe -td:"D:\Projects.java\Utils\CI\tmp" -en:dev ^
					-df:"D:\Projects.java\Deploy\Dev\tle.ear" ^
					-hf:"D:\Projects.java\Utils\CI\ohw\tle_hosts.txt" ^
					-pf:"D:\Projects.java\Utils\CI\ohw\help-provider.txt" -op:delete ^
					-up:off -co:off
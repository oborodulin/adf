@Echo Off
@Echo Off
D:\Projects.java\Utils\CI\ohw\ohw.cmd -td:"D:\Projects.java\Utils\CI\tmp" -en:prod ^
					-df:"D:\Projects.java\Deploy\Prod\erp.ear" ^
					-hf:"D:\Projects.java\Utils\CI\ohw\erp_hosts.txt" ^
					-pf:"D:\Projects.java\Utils\CI\ohw\help-provider.txt" -op:delete ^
					-up:off -co:off

set BEA_HOME=C:\oracle\Middleware\Oracle_Home_JDev
set WLS_CREDENTIALS=

call %BEA_HOME%\wlserver\server\bin\setWLSEnv.cmd 
java weblogic.Deployer -noexit -adminurl t3://localhost:7101 %WLS_CREDENTIALS% -redeploy -name erp-audit -source %DEPLOY_HOME%\Dev\erp.ear -upload -remote -verbose

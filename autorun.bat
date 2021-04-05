REM install doygwin packages and configuration

REM install cygwin with all packages 
call %~dp0\cygwin-auto-install\cygwin-install

REM configure dwww and doc-base documents
call %~dp0\etc\doc-base\postinstall

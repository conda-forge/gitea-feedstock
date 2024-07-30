echo on

@REM Debug: print all environment variables
SET

# Used by Makefile to include version in binary
echo %PKG_VERSION% > VERSION

@REM Makefile uses subshells (m2-bash), which may not inherit the full path
@REM Attempt to get around this by starting our own subshell with an explicit
@REM PATH (converted from Windows to Unix format) and invoke build.sh

set "PATH_UNIX=%PATH:\=/%"
set "PATH_UNIX=%PATH_UNIX:c:/=/c/%"
set "PATH_UNIX=%PATH_UNIX:d:/=/d/%"
set "PATH_UNIX=%PATH_UNIX:;=:%"

echo #!/bin/sh > build-win.sh
echo set -eux >> build-win.sh
echo export PATH="%PATH_UNIX%" >> build-win.sh
echo TAGS="bindata timetzdata sqlite sqlite_unlock_notify" make build >> build-win.sh
sh build-win.sh
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir %PREFIX%\bin
cp gitea.exe %PREFIX%\bin

@REM There are non-go files
go-licenses save . --save_path=license-files
if not exist license-files\github.com\ (exit /b 2)

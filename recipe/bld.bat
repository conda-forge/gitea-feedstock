echo on

@REM Debug: print all environment variables
SET

cd %RECIPE_DIR%
bash build.sh
if %errorlevel% neq 0 exit /b %errorlevel%
exit /b 0

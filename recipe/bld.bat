bash -lc %RECIPE_DIR%\build.sh
if %errorlevel% neq 0 exit /b %errorlevel%
exit /b 0

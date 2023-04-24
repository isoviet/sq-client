cd "node_modules"
cd "rg"
start /w /min cmd /c npm install
cd ..
move /Y rg ../rg
cd ..
start /w /min cmd /c npm install
rmdir /s /q "node_modules/rg"
move /Y "rg" "node_modules/rg"
echo install complete
pause
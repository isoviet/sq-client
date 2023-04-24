chcp 1251

set version=101
set swc=.\swc\clothesPerks1.swc .\swc\clothesPerks2.swc .\swc\clothesPerks3.swc .\swc\clothesPerks4.swc

call mxmlc buildSWF.mxml -include-libraries %swc% -output ".\content\clothes%version%.swf" -static-rsls
@pause
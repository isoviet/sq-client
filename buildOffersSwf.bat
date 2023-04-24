chcp 1251

set version=38
set swc=.\swc\offers.swc

call mxmlc buildSWF.mxml -include-libraries %swc% -output ".\content\offers%version%.swf" -static-rsls
@pause
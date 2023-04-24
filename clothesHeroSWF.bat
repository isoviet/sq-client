chcp 1251

set version=40
set swc=.\swc\heroClothes.swc

call mxmlc buildSWF.mxml -include-libraries %swc% -output ".\content\clothesHero%version%.swf" -static-rsls
@pause
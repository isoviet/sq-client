chcp 1251

set version=123
set swc=.\swc\awards.swc .\swc\beasts.swc .\swc\clanTotemIcons.swc .\swc\dialogBank.swc .\swc\dialogShop.swc .\swc\dialogsRuntime.swc .\swc\gameContent.swc .\swc\gameObjects.swc .\swc\icons.swc .\swc\shamanPerks.swc .\swc\smiles.swc
call mxmlc buildSWF.mxml -include-libraries %swc% -output ".\content\runtime%version%.swf" -static-rsls
@pause
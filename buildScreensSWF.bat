chcp 1251

set version=68
set swc=.\swc\editor.swc .\swc\roomInterior.swc .\swc\screenAward.swc .\swc\screenClan.swc .\swc\screenCollection.swc .\swc\screenProfile.swc .\swc\screenRating.swc .\swc\screenShamanTree.swc .\swc\screenWardrobe.swc

call mxmlc buildSWF.mxml -include-libraries %swc% -output ".\content\screens%version%.swf" -static-rsls
@pause
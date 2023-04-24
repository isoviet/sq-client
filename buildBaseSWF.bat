chcp 1251

set version=276
set swc=.\swc\event.swc .\swc\mobileMapLocations.swc .\swc\api.swc .\swc\atlas.swc .\swc\blooddy.swc .\swc\box2D.swc .\swc\clothesIcons.swc .\swc\components.swc .\swc\dialogs.swc .\swc\dialogsBase.swc .\swc\dialogLocation.swc .\swc\footer.swc .\swc\GoldenCup.swc .\swc\header.swc .\swc\hero.swc .\swc\inspirit.swc .\swc\learning.swc .\swc\lua.swc .\swc\other.swc .\swc\planet.swc .\swc\preCacheAnimation.swc .\swc\quests.swc .\swc\repost.swc .\swc\screens.swc .\swc\senocular.swc .\swc\shamanEmotions.swc

call mxmlc buildSWF.mxml -include-libraries %swc% -output ".\content\base%version%.swf" -static-rsls
@pause
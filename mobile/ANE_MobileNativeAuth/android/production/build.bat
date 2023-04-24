set FLEX_SDK=C:\ascsdk\17.0.0
adt -package -target ane extension.ane extension.xml -swc NativeAuth.swc -platform Android-ARM -C android . -platform default -C default .

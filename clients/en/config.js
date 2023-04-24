var version = 287;

params['swf'] = "client_release" + version + ".swf";
params['config'] = document.location.protocol + "//squirrelseng.realcdn.ru/config_release.xml";
params['width'] = 900;
params['height'] = 620;

A.init(1831459647);
A.bind("GAME_LOADED/" + params['api'], sendTime);
A.bind("PLAYER_LOADED/" + params['api'], sendTime);
A.action("FRAME_LOADED/" + params['api']);

embedSwf(params);
var version = 1248;

params['swf'] = document.location.protocol + "//squirrels2.itsrealgames.com/release/client_release" + version + ".swf";
params['config'] = document.location.protocol + "//squirrels2.itsrealgames.com/config_release.xml";
params['original'] = params['swf'];
params['protocol'] = document.location.protocol;
params['width'] = 900;
params['height'] = 620;

switch (params['api'])
{
	case "vk":
		break;
}

A.init(3609792031);
A.bind("GAME_LOADED/" + params['api'], sendTime);
A.bind("PLAYER_LOADED/" + params['api'], sendTime);
A.action("FRAME_LOADED/" + params['api']);

embedSwf(params);
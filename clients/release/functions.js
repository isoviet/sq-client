var startTime = new Date().getTime();

function timeLeft()
{
	var currentTime = new Date().getTime();

	var time = parseInt((currentTime - startTime) / 1000);

	startTime = currentTime;

	return time;
}

function sendTime(path, binded)
{
	if (path != binded)
		return;

	var time = timeLeft();
	if (time < 0)
		return;

	this.action(path + "/" + time);
}

function achtung()
{
	document.getElementById("achtung").innerHTML = "<div id=\"close_achtung\"><a href=\"#\">x</a></div><span>Эта версия браузера не поддерживается игрой.<br />Стабильность и работа игры не гарантируются.</span>";
	document.getElementById("achtung").style.display = "block";
	document.getElementById("close_achtung").onclick = function() {this.parentNode.parentNode.removeChild(this.parentNode);};

	return false;
}

function checkSupport(ua, reg, version)
{
	var result = reg.exec(ua);
	if (result == null)
		return achtung();

	result = result[0].split("/");
	if (result.length < 2)
		return achtung();

	var user_version = result[1].split(".");
	for (var i = 0; i < user_version.length; i++)
	{
		if (+user_version[i] > version[i])
			return true;
		if (+user_version[i] < version[i])
			return achtung();
	}

	return true;
}

function getParams()
{
	var prmstr = window.location.search.substr(1);
	return prmstr != null && prmstr != "" ? transformToAssocArray(prmstr) : {};
}

function transformToAssocArray(prmstr)
{
	var params = {};
	var prmarr = prmstr.split("&");
	for ( var i = 0; i < prmarr.length; i++)
	{
		var tmparr = prmarr[i].split("=");
		params[tmparr[0]] = tmparr[1];
	}
	return params;
}

function getMode()
{
	var ua = navigator.userAgent.toLowerCase();

	if (ua.indexOf("opera") != -1)
	{
		if (checkSupport(ua, /version\/[0-9]{1,2}\.[0-9]{1,2}/i, [10,60]))
			return "window";
	}
	else if (ua.indexOf("firefox") != -1)
		checkSupport(ua, /firefox\/[0-9]{1,2}\.[0-9]{1,2}/i, [3,6]);

	return "opaque";
}

function loadScript(path)
{
	var newPath = path + "?" + new Date().getTime();

	var scriptElement = document.createElement("script");
	scriptElement.setAttribute("type", "text/javascript");
	scriptElement.setAttribute("src", newPath);

	return document.getElementsByTagName("html")[0].appendChild(scriptElement);
}

function embedSwf(params)
{
	var mode = getMode();
	if (mode == false)
		return;

	var flashvars = location.href.substr(location.href.indexOf("?") + 1) + "&useApiType=" + params['api'] + "&useLocale=" + (params['locale'] ? params['locale'] : "ru") + "&config=" + params['config'] + "&protocol=" + params['protocol'];
	var callback = function (event) {
		if (event.success === false || !event.ref)
			return false;

		swfLoadEvent();
	};

	if (params['swf'] === params['original'])
		callback = false;

	if (params['api'] === "mm")
	{
		var getparams = parseGetString(window.name);
		if (getparams['fast_hash'] !== undefined)
			flashvars += "&hash=" + getparams['fast_hash'];
	}

	swfobject.embedSWF(params['swf'], "flash-app", params['width'], params['height'], "14.1.0", "expressInstall.swf", {}, {'wmode': "direct", 'flashvars': flashvars, 'AllowScriptAccess': "always", 'allowNetworking': "all", 'allowFullScreen': "true", 'allowFullscreenInteractive': "true"}, {'id': "flash-app", 'name': "flash-app"}, callback);
}

function parseGetString(string)
{
	var array = string.split("&");
	var result = {};

	for (var key in array)
	{
		var splitted = array[key].split("=");
		if (typeof splitted[1] === "undefined")
			continue;

		result[splitted[0]] = splitted[1];
	}

	return result;
}

function loadFailed()
{
	params['swf'] = params['original'];
	embedSwf(params);
}

function swfLoadEvent()
{
	var initialTimeout = setTimeout(function () {
		var counter = 0;
		var loadCheckInterval = setInterval(function () {
			counter += 1;
			var result = checkLoad(counter);

			if (result === 0)
				return;
			if (result === 2)
				loadFailed();

			clearInterval(loadCheckInterval);
		}, 1000);
	}, 1000);
}

function checkLoad(counter)
{
	var type = "chrome";
	if (!!window.opera || navigator.userAgent.indexOf(" OPR/") >= 0)
		type = "opera";
	if (typeof InstallTrigger !== "undefined")
		type = "firefox";
	if (Object.prototype.toString.call(window.HTMLElement).indexOf("Constructor") > 0)
		type = "safari";
	if (!!window.chrome && type !== "opera")
		type = "chrome";
	if (!!document.documentMode)
		type = "ie";

	var swf = swfobject.getObjectById("flash-app");
	if (!swf || swf === null)
		return 2;

	switch (type)
	{
		case "opera":
		case "safari":
		case "chrome":
		case "firefox":
			var totalFrames = swf.TotalFrames();
			break;
		case "ie":
			var totalFrames = (swf.TotalFrames !== 0 && !swf.TotalFrames ? 0 : swf.TotalFrames);
			break;
	}

	var percentLoaded = swf.PercentLoaded();

	if ((percentLoaded !== 0 && !percentLoaded) || (totalFrames !== 0 && !totalFrames)) // do nothing if cannot get data (specific browser)
		return 1;
	if (counter >= 3 && percentLoaded === 0 && totalFrames === 0)
		return 2;
	if (percentLoaded !== 0)
		return 1;
	return 0;
}

function initGA(trackId)
{
	(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

	ga('create', trackId, 'auto');
}

function setUserID(userId)
{
	ga('set', '&uid', userId);
}

function trackGA(message)
{
	ga('send', message);
}
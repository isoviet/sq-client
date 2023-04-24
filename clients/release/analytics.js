/**
 * Analytics frontend
 * @version 1.0.0
 */
window.A = {
	'_account': 0,
	'_hooks': {},
	'_url': (document.location.protocol == "https:" ? "https:" : "http:") + "//api.bigstat.net",

	'_send': function(path)
	{
		var a = document.createElement("script");
		a.type = "text/javascript";
		a.async = true;
		a.src = this._url + "/" + this._account + "/" + path + "?" + new Date().getTime();
		a.onload = a.onerror = function()
		{
			if (this.parentNode == null)
				return;
			this.parentNode.removeChild(this);
		};
		a.onreadystatechange = function()
		{
			if (this.readyState != "complete")
				return;

			if (this.parentNode == null)
				return;
			this.parentNode.removeChild(this);
		};

		var s = document.getElementsByTagName("script")[0];
		s.parentNode.insertBefore(a, s);
	},

	'_call': function(path)
	{
		var pieces = path.split("/");

		var next = this._hooks;
		var real = "";

		if ('__hooks__' in next)
			this._apply(path, next['__hooks__']);

		for (var i in pieces)
		{
			var piece = pieces[i];
			if (!(piece in next))
				break;

			next = next[piece];

			if (real != "")
				real = real + "/";
			real = real + piece;

			if (!('__hooks__' in next))
				continue;

			this._apply(path, next['__hooks__'], real);
		}
	},

	'_apply': function(path, hooks, real)
	{
		for (var i = 0; i < hooks.length; i++)
			hooks[i].call(this, path, real);
	},

	'_clean': function(path)
	{
		path = path.toUpperCase();
		path = path.replace(/^\/+|\/+$/, "");
		path = path.replace(/\s+/g, "/");
		path = path.replace(/\/+/g, "/");

		return path;
	},

	'init': function(account)
	{
		this._account = account;
	},

	'action': function(path)
	{
		if (this._account == 0)
			return;

		path = this._clean(path);

		this._send(path);
		this._call(path);
	},

	'bind': function(path, callback)
	{
		path = this._clean(path);

		var pieces = path.split("/");

		var next = this._hooks;
		for (var i in pieces)
		{
			var piece = pieces[i];
			if (!(piece in next))
				next[piece] = {};

			next = next[piece];
		}

		if (!('__hooks__' in next))
			next['__hooks__'] = [];
		next = next['__hooks__'];

		next[next.length] = callback;
	}
}
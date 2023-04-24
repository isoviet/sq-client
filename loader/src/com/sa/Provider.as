package com.sa
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	import com.api.Request;

	import by.blooddy.crypto.serialization.JSON;

	public class Provider extends EventDispatcher
	{
		static private const API_FORMAT:String = "JSON";

		private var apiVersion:String;

		public function Provider():void
		{
			super();
			Logger.add("Using StandAlone API");
		}

		public function execute(req:Request):void
		{
			var self:Provider = this;

			var variables:URLVariables = new URLVariables();
			variables['id'] = Services.userId;
			variables['appId'] = Services.appId;
			variables['sig']	= generateSignature(variables);
			variables['time']	= new Date();
			for (var key:String in req.options)
				variables[key] = req.options[key];

			variables['method']	= req.method;

			Logger.add("SA request " + req.method);

			var request:URLRequest = new URLRequest();
			request.url = Services.apiUrl;
			request.method = URLRequestMethod.GET;
			request.data = variables;

			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;

			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
			{
				self.onError(new Error(e.text));
			});
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void
			{
				self.onError(new Error(e.text));
			});
			loader.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				Logger.add("SA method " + (req as Request).method);
				Logger.add("SA vars " + (req as Request).options);
				req.received = true;

				var data:Object;
				Logger.add("SA response " + e.currentTarget.data);
				try
				{
					data = by.blooddy.crypto.serialization.JSON.decode(e.currentTarget.data);
				}
				catch (error:Error)
				{
					self.onError(error);
				}

				Logger.add("SA response data: " + data);

				if ("error" in data)
					self.onError(data['error']);
				else if ("response" in data && req.onComplete != null)
					req.onComplete(data['response']);
			});

			for (var tries:int = 3; tries != 0; tries--)
			{
				try
				{
					loader.load(request);
					return;
				}
				catch (error:Error)
				{
					onError(error);
				}
			}
		}

		private function onError(error:Object):void
		{
			if (error is Error)
			{
				Logger.add("Failed to execute SA query: " + error + "\n" + (error as Error).getStackTrace());
				return;
			}

			Logger.add("Failed to execute SA query: " + error['error']);
		}

		private function generateSignature(params:Object):String
		{
			return Services.sessionKey;
		}
	}
}
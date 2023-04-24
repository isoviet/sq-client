package utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;

	import com.inspirit.MultipartURLLoader;

	public class LoaderUtil
	{
		static public function load(url:String, isPost:Boolean, variables:Object = null, onComplete:Function = null, onError:Function = null, data:* = null):URLLoader
		{
			var request:URLRequest = new URLRequest();
			if (isPost)
				request.method = URLRequestMethod.POST;
			else
				request.method = URLRequestMethod.GET;
			request.url = url;

			if (variables != null)
			{
				var urlVariabels:URLVariables = new URLVariables();
				for (var key:* in variables)
					urlVariabels[key] = variables[key];
				request.data = urlVariabels;
			}

			var complete:Function = function(onComplete:Function, data:*):Function
			{
				return function(e:Event):void
				{
					if (onComplete == null)
						return;
					if (data == null)
						onComplete(e);
					else
						onComplete(e, data);
				};
			}(onComplete, data);

			var error:Function = function(onError:Function, data:*):Function
			{
				return function(e:Event):void
				{
					Logger.add("Failed to load url: " + e);

					if (onError == null)
						return;
					if (data == null)
						onError(e);
					else
						onError(e, data);
				};
			}(onError, data);

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, complete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, error);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);

			try
			{
				loader.load(request);
			}
			catch (e:Error)
			{
				error(e);
			}

			return loader;
		}

		static public function uploadFile(url:String, data:ByteArray, variables:Object, onComplete:Function = null, onError:Function = null):void
		{
			var complete:Function = function(onComplete:Function):Function
			{
				return function(e:Event):void
				{
					if (onComplete == null)
						return;
					onComplete(e);
				};
			}(onComplete);

			var error:Function = function(onError:Function):Function
			{
				return function(e:Event):void
				{
					Logger.add("Failed to uploadFile: " + e);

					if (onError == null)
						return;
					onError(e);
				};
			}(onError);

			var loader:MultipartURLLoader = new MultipartURLLoader();
			for (var key:String in variables)
				loader.addVariable(key, variables[key]);
			loader.addFile(data, "photo.png", "photo");

			loader.addEventListener(Event.COMPLETE, complete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, error);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);

			try
			{
				loader.load(url);
			}
			catch (e:Error)
			{
				error(e);
			}
		}
	}
}
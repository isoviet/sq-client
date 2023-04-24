package squirrels.itsrealgames.com.api
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import by.blooddy.crypto.serialization.JSON;

	import squirrels.itsrealgames.com.api.enums.AuthMethods;
	import squirrels.itsrealgames.com.api.enums.SocialType;

	import squirrels.itsrealgames.com.api.enums.UserMethods;

	/**
	 * ...
	 * @author Sprinter
	 */
	public class NativeAuth extends EventDispatcher {
		private static const ERROR_JSON_PARSE: String = 'error parse data callback to json object';
		private static const PACKAGE_JAR: String = 'squirrels.itsrealgames.com.api';//'ru.realgames.squirrels.api';
		private static const MAIN_CLASS_FUNCTION: String = 'actions';
		private static const INIT_ACTION_METHOD: String = 'init';

		private static const EVENT_AUTH_SUCCESS: String = "authSuccess";
		private static const EVENT_AUTH_FAIL: String = "authFail";
		private static const EVENT_GET_USER: String = "onGetUser";

		private static var context:ExtensionContext = null;
		private static var _onSuccess: Function = null;
		private static var _onFail: Function = null;

		public function NativeAuth(social: SocialType, appId: String, onSuccess: Function, onFail: Function)
		{
			_onSuccess = onSuccess;
			_onFail = onFail;

			try
			{
				if( context == null ) {
					context = ExtensionContext.createExtensionContext(PACKAGE_JAR, "");
					context.addEventListener(StatusEvent.STATUS, statusHandle);
					context.call(MAIN_CLASS_FUNCTION, INIT_ACTION_METHOD, social.toString(), appId);
				}
			} catch (e: Error) {
				log('constructor Error: '  + e.message);
			}
		}

		public function auth(method: AuthMethods, ... args): void
		{
			if (context) context.call(MAIN_CLASS_FUNCTION, method.toString());
		}

		public function userMethods(method: UserMethods, onSuccess: Function, onFail: Function): void
		{
			MethodListeners.addOnceListener(method.toString(), onSuccess, onFail);
			if (context) context.call(MAIN_CLASS_FUNCTION, method.toString());
		}

		private function statusHandle(e: StatusEvent): void
		{
			if (e.level != null && e.level.length > 0)
			{
				try
				{
					var jsonObject:Object = by.blooddy.crypto.serialization.JSON.decode(e.level);

				}
				catch (error:Error)
				{
					log('ERROR: ' + error.message);
				}

				if (jsonObject == null || !jsonObject.hasOwnProperty('event'))
				{
					log('ERROR: ' + ERROR_JSON_PARSE);
					return;
				}

				switch(jsonObject.event)
				{
					case EVENT_AUTH_SUCCESS:
						_onSuccess(jsonObject.value);
						break;
					case EVENT_AUTH_FAIL:
						_onFail(jsonObject.value);
						break;
					case EVENT_GET_USER:
						MethodListeners.callMethod(UserMethods.getUser.toString(), jsonObject.value);
						break;
				}
			}
		}

		private function log(msg:*):void{
			trace("[ NativeAuth ] " + msg);
		}
	}
}

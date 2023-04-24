package
{
	import flash.external.ExternalInterface;

	import com.api.Services;

	public class Analytics
	{
		private var trackerId:String;

		private var socialType:String;

		public function Analytics(userId:int = 0):void
		{
			switch(Config.LOCALE)
			{
				case Config.EN_LOCALE:
					this.trackerId = "UA-26927118-9";
					break;
				default:
					this.trackerId = "UA-26927118-4";
					break;
			}

			var session:Object = PreLoader.loaderInfo.parameters as Object;
			if ("useApiType" in session)
				this.socialType = session['useApiType'];
			else if ("useapitype" in session)
				this.socialType = session['useapitype'];
			else
				this.socialType = Config.DEFAULT_API;

			if (this.socialType.toUpperCase() != "MM")
				return;

			initGA();
			if (userId != 0)
				setUserID(userId);

			count("/LOGIN?" + this.socialType.toUpperCase());
		}

		static public function dailyQuest():void
		{
			action("DAILY_QUEST/START/" + getNet());
		}

		static public function fullScreen():void
		{
			action("FULLSCREEN_SHOW/" + getNet());
		}

		static public function gameLoaded():void
		{
			action("GAME_LOADED/" + getNet());
		}

		static public function fpsDAU(category:int):void
		{
			action("CLIENT_FPS/" + category);
		}

		static public function fpsAVG(value:int):void
		{
			action("CLIENT_FPS_AVG/" + value);
		}

		static public function fpsMIN(value:int):void
		{
			action("CLIENT_FPS_MIN/" + value);
		}

		static public function hardwareAcceleration():void
		{
			action("ACCELERATION_ENABLED/");
		}

		static public function playerLogin(status:int):void
		{
			switch (status)
			{
				case 0:
					action("PLAYER_LOADED/" + getNet());
					break;
				case 1:
					action("LOGIN_EXIST/" + getNet());
					break;
				case 2:
					action("LOGIN_FAILED/" + getNet());
					break;
				case 3:
					action("LOGIN_BLOCKED/" + getNet());
					break;
				case 4:
					action("LOGIN_WRONG_VERSION/" + getNet());
					break;
			}
		}

		static private function action(path:String):void
		{
			try
			{
				ExternalInterface.call("A.action", path);
			}
			catch (e:Error)
			{}
		}

		static private function getNet():String
		{
			switch (Services.netType())
			{
				case Config.API_VK_ID:
					return "VK";
				case Config.API_MM_ID:
					return "MM";
				case Config.API_OK_ID:
					return "OK";
				case Config.API_FS_ID:
					return "FS";
				case Config.API_FB_ID:
					return "FB";
				case Config.API_SA_ID:
					return "SA";
			}

			return "NULL";
		}

		private function initGA():void
		{
			try
			{
				ExternalInterface.call("initGA", this.trackerId);
			}
			catch (e:Error)
			{}
		}

		private function setUserID(userId:int):void
		{
			try
			{
				ExternalInterface.call("setUserID", userId);
			}
			catch (e:Error)
			{}
		}

		private function count(message:String):void
		{
			try
			{
				ExternalInterface.call("trackGA", message);
			}
			catch (e:Error)
			{}
		}
	}
}
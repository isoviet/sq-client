package dialogs
{
	import flash.events.EventDispatcher;

	import events.GameEvent;
	import screens.ScreenDisconnected;
	import screens.ScreenLocation;
	import screens.ScreenProfile;
	import screens.ScreenWardrobe;
	import screens.Screens;
	import views.TvView;

	public class DialogManager
	{
		static public var dispatcher:EventDispatcher = new EventDispatcher();

		static private const ALLOWED_CLASSES:Array = [TvView, DialogRebuyVIP, DialogNewLevel, DialogRepost, DialogMessage, DialogMapApproved, DialogReturnedAward, DialogViralityQuest];
		static private const MILTI_CLASSES:Array = [DialogRatingLeague, DialogNewLevel, DialogRepost];

		static private var dialogsQueue:Array = [];

		static private var _isEnyDialogShowed:Boolean = false;

		public function DialogManager():void
		{}

		static public function show(obj:Object):void
		{
			isEnyDialogShowed = true;

			if (!checkAllowed(obj))
			{
				obj.showDialog();
				return;
			}

			if (!checkOnlyOne(obj))
			{
				obj.showDialog();
				removeFromQueue(obj);
				return;
			}

			add(obj);

			if (dialogsQueue.length > 1)
				return;

			obj.showDialog();
		}

		static public function hide(obj:Object):void
		{
			if (!checkAllowed(obj))
			{
				obj.hideDialog();

				if(dialogsQueue.length == 0)
					isEnyDialogShowed = false;

				return;
			}

			if (dialogsQueue[0] != obj)
			{
				obj.hideDialog();

				if(dialogsQueue.length == 0)
					isEnyDialogShowed = false;

				return;
			}

			removeFirst();

			if (Screens.active is ScreenDisconnected)
				return;

			showNext();

		}

		static public function onChangeScreen():void
		{
			if (dialogsQueue.length == 0)
				return;


			if (!(Screens.active is ScreenLocation || Screens.active is ScreenProfile || Screens.active is ScreenWardrobe))
			{
				dialogsQueue[0].hideDialog();
				return;
			}

			if (!dialogsQueue[0].visible)
				dialogsQueue[0].showDialog();
		}

		static private function checkOnlyOne(obj:Object):Boolean
		{
			for (var k:int = 0; k < MILTI_CLASSES.length; k++) // исключения
				if (obj is MILTI_CLASSES[k])
					return true;

			for(var i:int = 0; i < dialogsQueue.length; i++)
				if (obj == dialogsQueue[i])
					return false;
			return true;
		}

		static private function checkAllowed(obj:Object):Boolean
		{
			for(var i:int = 0; i < ALLOWED_CLASSES.length; i++)
				if (obj is ALLOWED_CLASSES[i])
					return true;
			return false;
		}

		static private function add(obj:Object):void
		{
			dialogsQueue.push(obj);
		}

		static private function showNext():void
		{
			if (dialogsQueue.length == 0)
			{
				isEnyDialogShowed = false;
				return;
			}

			dialogsQueue[0].showDialog();
		}

		static private function removeFirst():void
		{
			if (dialogsQueue.length == 0)
				return;

			dialogsQueue[0].hideDialog();
			dialogsQueue.splice(0, 1);
		}

		static private function removeFromQueue(obj:Object):void
		{
			for(var i:int = 0; i < dialogsQueue.length; i++)
				if (obj == dialogsQueue[i])
					dialogsQueue.splice(i, 1);
		}

		static public function get isEnyDialogShowed():Boolean
		{
			return _isEnyDialogShowed;
		}

		static public function set isEnyDialogShowed(value:Boolean):void
		{
			if(_isEnyDialogShowed != value)
			{
				_isEnyDialogShowed = value;
				dispatcher.dispatchEvent(new GameEvent(GameEvent.CHANGED));
			}
		}
	}
}
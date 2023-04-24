package screens
{
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	import dialogs.Dialog;
	import dialogs.DialogManager;
	import events.ScreenEvent;

	public class Screens extends Sprite
	{
		static public const TV:int = 1;
		static public const GAME:int = 2;
		static public const MAX_TYPE:int = 3;

		static private var status:int = 0;
		static private var callbacks:Array = [];

		static private var _instance:Screens;

		private var storage:Object = {};
		private var dialogs:Dictionary = new Dictionary();
		private var active:Screen = null;
		private var showLazyDialog:Boolean = false;
		private var showReportDialog:Boolean = false;

		private var screenToComeback:Vector.<Screen> = new Vector.<Screen>();

		public function Screens():void
		{
			_instance = this;

			super();
		}

		static public function get instance():Screens
		{
			return _instance;
		}

		static public function setStatus(value:int):void
		{
			var oldStatus:int = status;
			status |= value;

			if (oldStatus == MAX_TYPE || status != MAX_TYPE)
				return;
			while (callbacks.length > 0)
				(callbacks.pop() as Function)();
		}

		static public function removeStatus(value:int):void
		{
			status &= ~value;
		}

		static public function addCallback(value:Function):void
		{
			if (status == MAX_TYPE)
				value();
			else
				callbacks.push(value);
		}

		static public function get active():Screen
		{
			if (!_instance)
				return null;
			return _instance.active;
		}

		static public function get screenToComeback():Screen
		{
			return _instance.screenToComeback.length == 0 ? _instance.storage["Location"] : _instance.screenToComeback[0];
		}

		static public function getName(screen:*):String
		{
			for (var name:String in _instance.storage)
				if (_instance.storage[name] == screen)
					return name;

			return "";
		}

		static public function register(name:String, screen:Screen):void
		{
			_instance.register(name, screen);
		}

		static public function show(screen:*):void
		{
			_instance.show(screen);
		}

		static public function reshow(screen:*):void
		{
			_instance.reshow(screen);
		}

		static public function hide():void
		{
			_instance.hide();
		}

		static public function toggleChildren(visible:Boolean):void
		{
			_instance.toggleChildren(visible);
		}

		static public function addDialog(dialog:Dialog):void
		{
			_instance.addDialog(dialog);
		}

		static public function hideDialogs():void
		{
			_instance.hideDialogs();
		}

		static public function set showLazyDialog(value:Boolean):void
		{
			_instance.showLazyDialog = value;
		}

		static public function get showLazyDialog():Boolean
		{
			return _instance.showLazyDialog;
		}

		static public function set showReportDialog(value:Boolean):void
		{
			_instance.showReportDialog = value;
		}

		static public function get showReportDialog():Boolean
		{
			return _instance.showReportDialog;
		}

		private function addDialog(dialog:Dialog):void
		{
			this.dialogs[dialog] = true;
		}

		private function register(name:String, screen:Screen):void
		{
			if (name in this.storage)
				return;

			if (screen is ScreenLocation)
				this.screenToComeback.push(screen);

			this.storage[name] = screen;
		}

		private function show(screen:*):void
		{
			if (screen is String)
			{
				if (!(screen in this.storage))
					return;
				screen = this.storage[screen];
			}

			if (this.active == screen)
				return;

			if (this.active != null)
			{
				if (screen == Screens.screenToComeback)
					this.screenToComeback.shift();
				else
				{
					if (this.screenToComeback.indexOf(this.active) != -1)
						this.screenToComeback.splice(this.screenToComeback.indexOf(this.active), 1);
					this.screenToComeback.unshift(this.active);
				}
			}

			hide();
			addChild(screen);

			this.active = screen;
			this.active.show();

			if (this.active is ScreenGame || this.active is ScreenSchool || this.active is ScreenLearning || this.active is ScreenDisconnected)
				removeStatus(GAME);
			else
				setStatus(GAME);

			dispatchEvent(new ScreenEvent(ScreenEvent.SHOW, this.active));

			DialogManager.onChangeScreen();
		}

		private function reshow(screen:*):void
		{
			hide();
			show(screen);
		}

		private function hide():void
		{
			if (this.active == null)
				return;

			hideDialogs();

			this.active.hide();
			removeChild(this.active);

			dispatchEvent(new ScreenEvent(ScreenEvent.HIDE, this.active));

			this.active = null;
		}

		private function hideDialogs():void
		{
			for (var dialog:* in this.dialogs)
			{
				if (!(dialog as Dialog).visible || (dialog as Dialog).captured)
					continue;
				(dialog as Dialog).hide();
			}
		}

		private function toggleChildren(visible:Boolean):void
		{
			for (var i:int = 0; i < this.numChildren; i++)
			{
				var child:Object = getChildAt(i);
				if (child is Screen)
					continue;

				child.visible = visible;
			}
		}
	}
}
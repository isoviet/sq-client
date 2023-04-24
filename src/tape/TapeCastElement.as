package tape
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;

	import footers.FooterGame;
	import game.mainGame.CastItem;
	import game.mainGame.entity.EntityFactory;
	import statuses.StatusIcons;
	import views.widgets.HotKeyView;

	public class TapeCastElement extends TapeObject
	{
		static private const FILTER:GlowFilter = new GlowFilter(0x00FF00, 1, 5, 5, 2, 3, true);

		static private const BUTTON_WIDTH:int = 48;
		static private const BUTTON_HEIGHT:int = 38;

		private var activeState:TapeEditActive = null;

		protected var button:DisplayObject;

		protected var status:StatusIcons = null;

		public var castItem:CastItem;
		public var icon:DisplayObject;

		public function TapeCastElement(item:CastItem):void
		{
			super();

			this.tabEnabled = false;
			this.castItem = item;

			this.activeState = new TapeEditActive();
			this.activeState.visible = false;
			addChild(this.activeState);

			this.button = new TapeEditButton() as DisplayObject;
			(this.button as SimpleButton).tabEnabled = false;

			addChild(this.button);

			this.icon = EntityFactory.getIconByClass(item.itemClass);
			this.icon.x += int((BUTTON_WIDTH - this.icon.width) * 0.5);
			this.icon.y += int((BUTTON_HEIGHT - this.icon.height) * 0.5);
			this.icon.cacheAsBitmap = true;

			if (this.icon is InteractiveObject)
				(this.icon as InteractiveObject).mouseEnabled = false;

			alignment(this.icon);
			addChild(this.icon);

			if (EntityFactory.getId(item.itemClass) != -1)
				this.status = new StatusIcons(this, EntityFactory.getTitle(this.castItem.itemClass).length * 7 + 30,
					EntityFactory.getTitle(this.castItem.itemClass), false, new Point(0, FooterGame.statusLinePosition));

			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onFullScreen);
			onFullScreen();

			correctViewStatus();
		}

		private function onFullScreen(e:Event=null):void
		{
			if(this.status == null) return;
			if(FullScreenManager.instance().fullScreen)
				this.status.fixed = null;
			else
				correctViewStatus();
		}

		private function correctViewStatus(e:Event = null):void
		{
			if(this.status == null)
				return;
			var point:Point = this.parent ? this.parent.localToGlobal(new Point(this.x, this.y)) : new Point(this.x, this.y);
			this.status.setPosition(point.x - this.status.width * 0.5 + this.width * 0.5, FooterGame.statusLinePosition);
		}

		public function setHotKeyStatus(key:int):void
		{
			if (EntityFactory.getId(this.castItem.itemClass) == -1)
				return;

			if(this.status != null)
			{
				this.status.updateIcons([new HotKeyView(String(key))]);
				correctViewStatus();
			}
		}

		public function clearHotKeyStatus():void
		{
			if (EntityFactory.getId(this.castItem.itemClass) == -1)
				return;

			if(this.status != null)
			{
				this.status.updateIcons([]);
				correctViewStatus()
			}
		}

		public function dispose():void
		{
			if (this.status == null)
				return;

			this.status.remove();
			this.status = null;
		}

		public function addSelect():void
		{
			this.activeState.visible = true;
		}

		public function removeSelect():void
		{
			this.activeState.visible = false;
		}

		private function alignment(icon:DisplayObject):void
		{
			if (icon is IceBox1)
			{
				icon.x += 4;
				icon.y += 3;
			}

			if (icon is IceBox2)
			{
				icon.x += 4;
				icon.y += 3;
			}
		}
	}
}
package game.mainGame.perks.clothes
{
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Vec2;

	import screens.ScreenStarling;

	import protocol.Connection;
	import protocol.PacketClient;

	import starling.core.Starling;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import utils.IndexUtil;
	import utils.starling.StarlingAdapterSprite;

	public class PerkClothesSelective extends PerkClothes
	{
		protected var selectCursor:StarlingAdapterSprite = null;
		protected var selectedId:int = 0;

		protected var _globalPos:Point = new Point();
		protected var _localPos:Point = new Point();
		private var eventClick:Boolean = false;

		public function PerkClothesSelective(hero:Hero)
		{
			super(hero);
		}

		override public function get target():int
		{
			return this.selectedId;
		}

		override public function dispose():void
		{
			resetSelection();
			super.dispose();
		}

		override public function resetRound():void
		{
			resetSelection();
			super.resetRound();
		}

		override protected function deactivate():void
		{
			resetSelection();
			super.deactivate();
		}

		override public function onUse():void
		{
			if (!this.hero || !this.hero.game)
				return;

			this.selectedId = 0;
			setTimeout(setSelection, 100);
		}

		override public function set active(value:Boolean):void
		{
			if (!value)
				resetSelection();
			super.active = value;
		}

		protected function setSelection():void
		{
			if (!this.hero.isSelf || !this.hero.game)
				return;

			Mouse.hide();
			ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onStarlingTouch);

			if (this.selectCursor)
				this.selectCursor.removeFromParent();
			this.selectCursor = new StarlingAdapterSprite(new HeroPointer());
			this.selectCursor.x = this._localPos.x;
			this.selectCursor.y = this._localPos.y;
			ScreenStarling.upLayer.addChild(this.selectCursor.getStarlingView());

			eventClick = true;
		}

		protected function resetSelection():void
		{
			if (!this.hero.isSelf)
				return;

			if (this.selectCursor)
				this.selectCursor.removeFromParent();

			eventClick = false;

			Mouse.show();

			ScreenStarling.instance.removeEventListener(TouchEvent.TOUCH, onStarlingTouch);
		}

		public function onStarlingTouch(event: TouchEvent): void
		{
			var touch:Touch = event.getTouch(Starling.current.stage);

			// if mouse leave stage
			if(!touch)
				return;
			_globalPos.setTo(touch.globalX, touch.globalY);
			_localPos = touch.getLocation(ScreenStarling.instance);

			this.selectCursor.x = _localPos.x;
			this.selectCursor.y = _localPos.y;

			if (touch.phase == TouchPhase.BEGAN)
			{}
			else if (touch.phase == TouchPhase.ENDED && eventClick)
				onEnded();
			else if (touch.phase == TouchPhase.MOVED)
			{}
		}

		protected function onEnded():void
		{
			onSelect(_localPos);
		}

		protected function onSelect(e:Point):void
		{
			if (e) {/*unused*/}

			if (!this.hero.game)
			{
				resetSelection();
				return;
			}

			var squirrels:Object = this.hero.game.squirrels.players;
			var squirrelsToSelect:int = 0;
			var selected:Array = [];
			for each (var hero:Hero in squirrels)
			{
				if (!checkHero(hero))
					continue;

				squirrelsToSelect++;

				var pos:b2Vec2 = hero.position.Copy();
				pos.Subtract(new b2Vec2(_localPos.x / Game.PIXELS_TO_METRE, _localPos.y / Game.PIXELS_TO_METRE));
				if (hero.hitTestStarling(_localPos) || pos.Length() < 6)
					selected.push(hero);
			}

			if (selected.length != 0)
			{
				this.selectedId = (IndexUtil.getMaxIndex(selected) as Hero).id;
				Connection.sendData(PacketClient.ROUND_SKILL, this.code, !this.active, this.target, this.json);
				resetSelection();
			}

			if (squirrelsToSelect == 0)
				resetSelection();
		}

		protected function checkHero(hero:Hero):Boolean
		{
			return true;
		}
	}
}
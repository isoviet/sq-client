package game.mainGame
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;

	import Box2D.Common.Math.b2Math;

	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.simple.Box;

	import utils.starling.StarlingAdapterSprite;

	public class CastHint extends StarlingAdapterSprite
	{
		static private const FADE_SPEED:Number = 0.1;

		static private const GLOW_FILTER:GlowFilter = new GlowFilter(0x666666, 0.5, 60, 60, 100, 1, true, true);
		static private const TEXTFORMAT:TextFormat = new TextFormat(null, 12, 0xFFFFFF, true);
		static private const SHADOW_FILTER:Array = [new DropShadowFilter(0, 45, 0x350801, 1 ,2, 2, 7)];

		private var pinSprite:StarlingAdapterSprite = new StarlingAdapterSprite();

		private var pinClasses:Array = [];
		private var keys:Array = [];

		private var _isGhost:Boolean;

		public var canGhost:Boolean;
		private var sprite: Sprite = new Sprite();
		private var _createdPins: Object = {};
		private var sprDelete: Sprite = new CastDelete();

		public function CastHint():void
		{
			sprite.graphics.lineStyle(3, 0xFFFFFF);
			sprite.graphics.beginFill(0xFFFFFF, 0.7);
			sprite.graphics.drawRoundRectComplex(0, 0, 50, 50, 5, 5, 5, 5);
			sprite.graphics.endFill();
			sprite.scaleX = sprite.scaleY = 0.7;

			addChildStarling(this.pinSprite);
			this.touchable = false;
		}

		public function dispose(): void
		{
			if (_createdPins)
			{
				for(var key: String in _createdPins)
				{
					_createdPins[key].removeFromParent();
				}

			}
		}

		override public function get visible():Boolean
		{
			return super.visible;
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if (value)
				Game.stage.addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
			else
				Game.stage.removeEventListener(Event.ENTER_FRAME, onUpdate);
		}

		public function set pinsVisible(value:Boolean):void
		{
			this.pinSprite.visible = value;
		}

		public function get isGhost():Boolean
		{
			return _isGhost;
		}

		public function clearHints() : void
		{
			while (this.pinSprite.numChildren > 0)
				this.pinSprite.removeChildStarlingAt(0);

			while (numChildren > 0)
				removeChildStarlingAt(0);
		}

		public function set isGhost(value:Boolean):void
		{
			_isGhost = value;
			redraw();
		}

		public function setPins(pinClasses:Array, keys:Array):void
		{
			if (canGhost)
			{
				pinClasses.unshift(Box);
				keys.unshift("Z");
			}

			if (pinClasses == null || keys == null)
				return;

			if (pinClasses.length != keys.length)
				return;

			if ((pinClasses.join() == this.pinClasses.join() && keys.join() == this.keys.join()))
				return;

			this.pinClasses = pinClasses;
			this.keys = keys;

			redraw();
		}

		private function onUpdate(e:Event):void
		{
			var fade:Boolean = this.mouseX * this.scaleX > 0 && this.mouseX * this.scaleX < this.width && this.mouseY * this.scaleY > 0 && this.mouseY * this.scaleY < this.height;
			this.alpha += fade ? -FADE_SPEED : FADE_SPEED;
			this.alpha = b2Math.Clamp(this.alpha, 0, 1);
		}

		private function redraw():void
		{
			var spriteItem: Sprite = new Sprite();
			var mx: Matrix;
			var rect: Rectangle;

			while (this.pinSprite.numChildren > 0)
				this.pinSprite.removeChildStarlingAt(0);

			sprite.addChild(sprDelete);
			_createdPins['delete'] = new StarlingAdapterSprite(sprite, true);
			sprite.removeChild(sprDelete);
			this.pinSprite.addChildStarling(_createdPins['delete']);

			for (var i:String in pinClasses)
			{
				while (spriteItem.numChildren > 0)
					spriteItem.removeChildAt(0);

				spriteItem.scaleX = spriteItem.scaleY = 1;

				var index:int = int(i);
				var classPin:Class = pinClasses[index];

				spriteItem.addChild(sprite);
				var image:Sprite = EntityFactory.getIconByClass(classPin) as Sprite;
				var centerSprite: Sprite = new Sprite();

				image.x = 0;
				image.y = 0;

				centerSprite.addChild(image);
				centerSprite.scaleX = centerSprite.scaleY = 0.7;
				if (classPin == Box)
				{
					image.x = -image.width / 2;
					image.y = -image.height / 2;
				}

				centerSprite.x = spriteItem.width / 2;
				centerSprite.y = spriteItem.height / 2;
				spriteItem.addChild(centerSprite);

				var text:GameField = new GameField(keys[index], 0, 0, TEXTFORMAT);
				text.x = 23;
				text.y = 20;
				text.filters = SHADOW_FILTER;
				spriteItem.addChild(text);

				if (_createdPins[classPin])
					_createdPins[classPin].removeFromParent();

				_createdPins[classPin] = new StarlingAdapterSprite(spriteItem, true);

				_createdPins[classPin].touchable = false;

				_createdPins[classPin].x = (index + 1) * 40;
				this.pinSprite.addChildStarling(_createdPins[classPin]);

				this.pinSprite.touchable = false;
			}

		}
	}
}
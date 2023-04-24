package game.mainGame.perks.mana.ui
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

	import events.GameEvent;
	import footers.FooterGame;
	import game.gameData.FlagsManager;
	import game.gameData.PowerManager;
	import game.mainGame.GameMap;
	import game.mainGame.SquirrelCollection;
	import game.mainGame.gameEditor.SquirrelCollectionEditor;
	import game.mainGame.perks.Perk;
	import game.mainGame.perks.mana.PerkFactory;
	import game.mainGame.perks.mana.PerkReborn;
	import game.mainGame.perks.ui.ToolBar;
	import game.mainGame.perks.ui.ToolButton;
	import screens.ScreenEdit;
	import screens.ScreenGame;
	import screens.ScreenSchool;
	import screens.Screens;
	import statuses.StatusIcons;

	import com.greensock.TweenNano;

	import protocol.Flag;
	import protocol.PacketServer;

	import starling.core.Starling;

	public class PerksToolBar extends ToolBar
	{
		private static const LENGTH_ONEC:Number = 57.462; // 91.5 * 0.628

		private static const RED_COLOR:Number = 0xff0000;
		private static const GREEN_COLOR:Number = 0x00ff00;
		private static const GREY_COLOR:Number = 0x000000;
		private static const TIME_ANIM:Number = 0.16;
		private static const OFFSET_PANEL_X:Number = 0;
		private static const OFFSET_PANEL_Y:Number = -12;
		private static const BUTTON_WIDTH:Number = 33;

		static private const RECT_WIDTH:Number = 45;

		static private var _instance:PerksToolBar;
		static private var rectPosition:Point = new Point(Config.GAME_WIDTH, 525);
		static private var border:Rectangle = new Rectangle(0, 90, Config.GAME_WIDTH, Config.GAME_HEIGHT - 140);

		private var radius:Number;
		private var angleLength:Number;

		private var arrow:Sprite = null;
		private var arrowRespawn:ImageArrowRespawn = null;

		private var viewAsRectangleBar:Boolean = true;
		private var starlingGlobalCoordinate:Point = new Point(0,0);

		static public function instance():PerksToolBar
		{
			return _instance;
		}

		static public function set hero(value:Hero):void
		{
			if (!_instance)
				return;
			for each (var button:PerkButton in _instance.buttons)
				button.hero = value;
		}

		public function PerksToolBar():void
		{
			_instance = this;

			for (var i:int = 0; i < PerkFactory.PERK_TOOLBAR.length; i++)
				addButton(new PerkButton(PerkFactory.PERK_TOOLBAR[i]));

			PowerManager.addEventListener(GameEvent.MANA_CHANGED, onMana);
			Perk.dispatcher.addEventListener(Perk.CHANGE_STATE, onUpdate);

			this.buttonSprite.x = 0;
			this.buttonSprite.y = 0;

			this.arrowRespawn = new ImageArrowRespawn();
			this.arrowRespawn.x = -21;
			this.arrowRespawn.y = -40;
			addChild(this.arrowRespawn);

			this.arrow = new Sprite();
			this.arrow.addChild(new ArrowMovie()).y = -13;
			hideArrow();

			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onFullScreen);
			onFullScreen();

			this.arrowRespawn = new ImageArrowRespawn();
			this.arrowRespawn.x = -21;
			this.arrowRespawn.y = -40;
			addChild(this.arrowRespawn);
		}

		private function onFullScreen(e:Event=null):void
		{
			border = new Rectangle(0,90, GameMap.gameScreenWidth, GameMap.gameScreenHeight-140);
			if (FullScreenManager.instance().fullScreen)
				rectPosition = new Point(GameMap.gameScreenWidth / 2 + this.width / 2, GameMap.gameScreenHeight - 95);
			else
				rectPosition = new Point(GameMap.gameScreenWidth, GameMap.gameScreenHeight - 95);
		}

		public function visibleAs(_visible:Boolean, asBar:Boolean):void
		{
			this.viewAsRectangleBar = asBar;
			visible = _visible;
		}

		private function onUpdate(e:Event):void
		{
			redraw(false);
		}

		override public function addButton(button:ToolButton):void
		{
			super.addButton(button);
		}

		public function set visibleArrowRespawn(value:Boolean):void
		{
			this.arrowRespawn.visible = value;
			if (value)
				this.arrowRespawn.play();
			else
				this.arrowRespawn.stop();
		}

		public function showArrow(perk:Class):void
		{
			if(this.buttons == null) return;

			for(var i:int = 0; i <  this.buttons.length; i++)
				if((this.buttons[i] as PerkButton).perk == perk)
				{
					if (!contains(this.arrow))
						addChild(this.arrow);
					this.arrow.visible = true;

					if (this.viewAsRectangleBar)
					{
						this.arrow.rotation = -90;
						this.arrow.x = -(this.buttons.length - i) * RECT_WIDTH + RECT_WIDTH/2;
						this.arrow.y = - 15;
					}
					else
					{
						var angle:Number = i * this.angleLength - this.angleLength * 5;
						this.arrow.rotation = angle * 180 / Math.PI;
						this.arrow.x = Math.cos(angle) * this.radius;
						this.arrow.y = Math.sin(angle) * this.radius;
					}
					return;
				}
		}

		public function hideArrow():void
		{
			if (!this.buttons)
				return;
			if (contains(this.arrow))
				removeChild(this.arrow);
			this.arrow.visible = false;
			visibleArrowRespawn = false;
		}

		override public function set visible(value:Boolean):void
		{
			if (super.visible == value)
				return;

			if(value && !this.viewAsRectangleBar)
				EnterFrameManager.addListener(onUpdatePosition);
			else
				EnterFrameManager.removeListener(onUpdatePosition);

			super.visible = value;

			updateHotKeysStatuses();
			FooterGame.onPerksShown();
			if (Screens.active is ScreenSchool)
				ScreenSchool.onPerksShown(value);

			for (var i:int = 0; i < this.buttons.length && value == false; i++)
				(this.buttons[i] as PerkButton).getStatus().hide();

			onUpdatePosition();

			if (value)
				redraw(true);
			else
				visibleArrowRespawn = false;
		}

		private function onUpdatePosition():void
		{
			if (!this.parent)
				return;

			var point:Point;

			var self:Hero = Screens.active is ScreenEdit ? (SquirrelCollection.instance as SquirrelCollectionEditor).self : Hero.self;
			if (self && GameMap.instance)
				point = new Point(self.x + GameMap.instance.x, self.y + GameMap.instance.y);
			else
			{
				this.visible = false;
				return;
			}

			if (!this.viewAsRectangleBar)
			{
				this.starlingGlobalCoordinate = Starling.current.stage.localToGlobal(point);
				this.starlingGlobalCoordinate.x = int(this.starlingGlobalCoordinate.x) + OFFSET_PANEL_X;
				this.starlingGlobalCoordinate.y = int(this.starlingGlobalCoordinate.y) + OFFSET_PANEL_Y;

				if (this.starlingGlobalCoordinate.x - this.radius < border.x)
					this.starlingGlobalCoordinate.x = border.x + this.radius;
				if (this.starlingGlobalCoordinate.y - this.radius < border.y)
					this.starlingGlobalCoordinate.y = border.y + this.radius;
				if (this.starlingGlobalCoordinate.x + this.radius > border.x + border.width)
					this.starlingGlobalCoordinate.x = border.x + border.width - this.radius;
				if (this.starlingGlobalCoordinate.y + this.radius > border.y + border.height)
					this.starlingGlobalCoordinate.y = border.y + border.height - this.radius;
			}
			else
				this.starlingGlobalCoordinate = rectPosition;

			var flashLocalCoordinate:Point = this.parent.globalToLocal(this.starlingGlobalCoordinate);
			if (this.x == flashLocalCoordinate.x && this.y == flashLocalCoordinate.y)
				return;
			this.x = flashLocalCoordinate.x;
			this.y = flashLocalCoordinate.y;

			redrewStatus();
		}

		override public function get perksAvailable():Boolean
		{
			return !(Locations.currentLocation.nonPerk && !(Screens.active is ScreenSchool)) && (FooterGame.gameState == PacketServer.ROUND_START) && !(!FlagsManager.has(Flag.MAGIC_SCHOOL_FINISH) && !(Screens.active is ScreenSchool));
		}

		override public function get perksVisible():Boolean
		{
			return super.perksVisible && !(FooterGame.hero && FooterGame.hero.isHare) && (((Screens.active is ScreenGame || Screens.active is ScreenEdit) && FlagsManager.has(Flag.MAGIC_SCHOOL_FINISH)) || (Screens.active is ScreenSchool && ScreenSchool.type == ScreenSchool.MAGIC));
		}

		public function toggleFreeRespawn(value:Boolean):void
		{
			for each (var button:PerkButton in this.buttons)
			{
				if (button.perk != PerkReborn)
					continue;
				button.cost = value ? 0 : button.pekManaCost;
			}
		}

		public function toggleFreeCast(value:Boolean):void
		{
			for each (var button:PerkButton in this.buttons)
				button.cost = (value || button.active) ? 0 : button.pekManaCost;
		}

		override protected function get keyCode():uint
		{
			return Keyboard.TAB;
		}

		override protected function onKey(e:KeyboardEvent):void
		{
			if (e.shiftKey || e.ctrlKey)
				return;

			if (!this.perksAvailable || !this.perksVisible)
				return;

			if (Game.chat && Game.chat.visible ||(Screens.active is ScreenEdit))
				return;

			if (e.keyCode == this.keyCode)
			{
				this.visibleAs(!this.visible, false);
				return;
			}

			if (this.needVisible && !this.visible)
				return;

			var length:int = Math.min(this.buttons.length, this.hotKeys.length);
			for (var i:int = 0; i < length; i++)
			{
				if (e.keyCode != this.hotKeys[i])
					continue;
				this.buttons[i].onClick();
			}
		}

		private function redraw(animation:Boolean):void
		{
			this.radius = LENGTH_ONEC * this.buttons.length / 6.28;
			this.angleLength = LENGTH_ONEC / this.radius;
			var angle_offset:Number = -this.angleLength * 5.5;

			graphics.clear();

			for(var i:int = 0; i < this.buttons.length; i++)
			{
				var color:Number = GREEN_COLOR;
				if (!(this.buttons[i] as PerkButton).available)
					color = GREY_COLOR;
				else if (!(this.buttons[i] as PerkButton).isEnoughtMana)
					color = RED_COLOR;

				if (this.viewAsRectangleBar)
					placementRect((i - this.buttons.length) * RECT_WIDTH, this.buttons[i], color, animation);
				else
					placementSector(i * this.angleLength + angle_offset, this.buttons[i], color, animation);
			}
		}

		private function redrewStatus():void
		{
			var angle_offset:Number = -this.angleLength * 5;
			for(var i:int = 0; i < this.buttons.length; i++)
			{
				var perk:PerkButton = this.buttons[i] as PerkButton;
				var status:StatusIcons = perk.getStatus() as StatusIcons;

				if (this.viewAsRectangleBar)
				{
					status.setPosition(rectPosition.x - (this.buttons.length - i) * RECT_WIDTH, rectPosition.y - 70);
					continue;
				}

				var angle:Number = i * this.angleLength + angle_offset;
				var r:Number = this.radius + status.height / 2;
				var point:Point = new Point(r * Math.cos(angle) + this.starlingGlobalCoordinate.x, r * Math.sin(angle) + this.starlingGlobalCoordinate.y - status.height / 2);

				if (angle < - Math.PI / 2 || angle > Math.PI / 2)
					point.x -= status.width;

				var fixed:Boolean = !(point.x < border.x
				|| point.x > border.x + border.width - status.width
				|| point.y < border.y + status.height / 2
				|| point.y > border.y + border.height - status.height / 2);

				if (fixed)
					status.setPosition(point.x, point.y);
				else
					status.fixed = null;
			}
		}

		private function placementSector(angle:Number, displayObject:DisplayObject, color:int, animation:Boolean):void
		{
			graphics.lineStyle(0,0x000000, 0);
			graphics.moveTo(0,0);
			graphics.beginGradientFill(GradientType.RADIAL, [color, color], [0,0.5], [Math.min(230, (this.buttons.length - 8) * 35), 255]);

			var w:Number = BUTTON_WIDTH;
			var offset:Point = new Point(buttonSprite.x - w / 2, buttonSprite.y - w / 2);
			var r2:Number = radius - w / 2;
			var r1:Number = animation ? radius - w / 2 - 20 : r2;
			var angle2:Number = angle + angleLength / 2;

			displayObject.x = r1 * Math.cos(angle2) + offset.x;
			displayObject.y = r1 * Math.sin(angle2) + offset.y;

			var toPoint:Point = new Point(r2 * Math.cos(angle2) + offset.x, r2 * Math.sin(angle2) + offset.y);
			displayObject.scaleX = displayObject.scaleY = animation ? 0.85 : 1;

			if(animation)
				TweenNano.to(displayObject, TIME_ANIM, {scaleX:1, scaleY:1, x:toPoint.x, y:toPoint.y, overwrite:true});

			w = this.angleLength + angle;
			for (angle; angle < w; angle += 0.12)
				graphics.lineTo(this.radius * Math.cos(angle), this.radius * Math.sin(angle));
			for (angle -= 0.12; angle < w + 0.001; angle += 0.001)
				graphics.lineTo(this.radius * Math.cos(angle), this.radius * Math.sin(angle));

			graphics.lineTo(0,0);
			graphics.endFill();
		}

		private function placementRect(position:Number, displayObject:DisplayObject, color:int, animation:Boolean):void
		{
			var rect:Rectangle = new Rectangle(position, 0, RECT_WIDTH, RECT_WIDTH);
			var moveTo:Point = new Point(rect.x + rect.width / 2 - BUTTON_WIDTH / 2, rect.y + rect.height / 2 - BUTTON_WIDTH / 2);

			var gradientMatrix:Matrix = new Matrix();
			gradientMatrix.createGradientBox(rect.width, rect.height, Math.PI / 2, 0, 0);
			graphics.beginGradientFill(GradientType.LINEAR, [color, color], [0, 0.6], [70, 255], gradientMatrix);
			graphics.drawRect(rect.x, rect.y, rect.width, rect.height);

			displayObject.x = moveTo.x;
			displayObject.y = animation ? moveTo.y + 15 : moveTo.y;

			displayObject.scaleX = displayObject.scaleY = animation ? 0.9 : 1;

			if(animation)
				TweenNano.to(displayObject, TIME_ANIM, {scaleX: 1, scaleY: 1, x: moveTo.x, y: moveTo.y, overwrite: true});

			this.graphics.endFill();
		}

		private function onMana(e:GameEvent):void
		{
			visibleArrowRespawn = false;

			updateButtons();
			redraw(false);
		}
	}
}
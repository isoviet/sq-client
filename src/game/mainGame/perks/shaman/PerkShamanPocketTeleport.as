package game.mainGame.perks.shaman
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.utils.Timer;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.perks.ICounted;
	import screens.ScreenStarling;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundCommand;

	import starling.core.Starling;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import utils.starling.StarlingAdapterSprite;

	public class PerkShamanPocketTeleport extends PerkShamanActive implements ICounted
	{
		static private const RADIUS:Number = 100 / Game.PIXELS_TO_METRE;

		private var selectCursor: StarlingAdapterSprite = null;
		private var radius:Number;

		private var delayTimer:Timer = new Timer(1000, 45);

		private var radiusView:DisplayObject = null;

		private var _globalPos: Point = new Point();
		private var _localPos: Point = new Point();

		public function PerkShamanPocketTeleport(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_POCKET_TELEPORT;

			this.selectCursor = new StarlingAdapterSprite(new HeroPointer());
			this.radius = (1 + countBonus() / 100) * RADIUS;
		}

		public function onStarlingTouch(event: TouchEvent): void {
			var touch:Touch = event.getTouch(Starling.current.stage);

			// if mouse leave stage
			if(!touch)
				return;
			_globalPos.setTo(touch.globalX, touch.globalY);
			_localPos = touch.getLocation(ScreenStarling.instance);

			this.selectCursor.x = _localPos.x;
			this.selectCursor.y = _localPos.y;

			if (touch.phase == TouchPhase.BEGAN) {
			} else if (touch.phase == TouchPhase.ENDED) {
				onClick();
			} else if (touch.phase == TouchPhase.MOVED) {

			}
		}

		override public function get available():Boolean
		{
			return super.available && !this.delayTimer.running;
		}

		override public function update(timeStep:Number = 0):void
		{
			if (timeStep) {/*unused*/}

			var currentAvailable:Boolean = this.available;
			if (this.lastAvalibleState != currentAvailable || this.delayTimer.running)
				dispatchEvent(new Event("STATE_CHANGED"));

			this.lastAvalibleState = currentAvailable;
		}

		override public function dispose():void
		{
			this.delayTimer.stop();
			resetSelection();

			super.dispose();
		}

		override public function reset():void
		{
			this.delayTimer.reset();
			this.delayTimer.start();

			super.reset();
		}

		public function get charge():int
		{
			return this.delayTimer.currentCount;
		}

		public function get count():int
		{
			return this.delayTimer.repeatCount;
		}

		public function resetTimer():void
		{}

		override protected function activate():void
		{
			if (!this.hero || !this.hero.game || !this.hero.isSelf || !this.hero.shaman)
			{
				this.active = false;
				return;
			}

			super.activate();

			setSelection();

			if (this.isMaxLevel)
				return;

			if (!this.radiusView)
				this.radiusView = new PerkRadius();

			this.radiusView.width = this.radiusView.height = int(this.radius * 2 * Game.PIXELS_TO_METRE);
			this.radiusView.y = - Hero.Y_POSITION_COEF;

			this.hero.addChild(this.radiusView);
		}

		override protected function deactivate():void
		{
			resetSelection();

			super.deactivate();

			if (this.radiusView && this.radiusView.parent)
				this.radiusView.parent.removeChild(this.radiusView);
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundCommand.PACKET_ID]);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundCommand.PACKET_ID:
					var data:Object = (packet as PacketRoundCommand).dataJson;

					if (!('pocketTeleport' in data))
						return;

					if (!this.hero || data['pocketTeleport'][0] != this.hero.id)
						return;

					this.hero.magicTeleportTo(new b2Vec2(data['pocketTeleport'][1], data['pocketTeleport'][2]));
					this.hero.sendLocation();

					if (!this.hero.isSelf)
						return;

					this.delayTimer.reset();
					this.delayTimer.start();
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function setSelection():void
		{
			if (!this.hero.isSelf || !this.hero.game)
				return;

			Mouse.hide();
			if (this.selectCursor)
				this.selectCursor.removeFromParent();

			this.selectCursor = new StarlingAdapterSprite(new HeroPointer());

			ScreenStarling.upLayer.addChild(this.selectCursor.getStarlingView());
			ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onStarlingTouch);
			this.selectCursor.x = _localPos.x;
			this.selectCursor.y = _localPos.y;
		}

		private function resetSelection():void
		{
			if (!this.hero.isSelf)
				return;

			if (this.selectCursor)
				this.selectCursor.removeFromParent();

			ScreenStarling.instance.removeEventListener(TouchEvent.TOUCH, onStarlingTouch);
			Mouse.show();
		}

		private function onClick():void
		{
			if (!this.hero.game)
			{
				this.active = false;
				return;
			}

			this.active = false;

			var touchPoint:Point = _globalPos;
			touchPoint = this.hero.game.squirrels.globalToLocal(_globalPos);
			var destination:b2Vec2 = new b2Vec2(touchPoint.x / Game.PIXELS_TO_METRE, touchPoint.y / Game.PIXELS_TO_METRE);

			var distance:b2Vec2 = this.hero.position.Copy();
			distance.Subtract(destination);

			if (distance.Length() > this.radius && !this.isMaxLevel)
				return;

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'pocketTeleport': [this.hero.id, destination.x, destination.y]}));
		}
	}
}
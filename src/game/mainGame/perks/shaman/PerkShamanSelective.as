package game.mainGame.perks.shaman
{
	import flash.geom.Point;
	import flash.ui.Mouse;

	import Box2D.Common.Math.b2Vec2;

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

	import utils.IndexUtil;
	import utils.starling.StarlingAdapterSprite;

	public class PerkShamanSelective extends PerkShamanActive
	{
		protected var selectCursor: StarlingAdapterSprite = null;

		protected var selectionsCount:int = 1;

		private var selectedCount:int = 0;

		private var _selectedHeroes:Array = [];

		protected var _globalPos: Point = new Point();
		protected var _localPos: Point = new Point();
		private var eventMove: Boolean = false;
		private var eventClick: Boolean = false;

		public function PerkShamanSelective(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.selectCursor = new StarlingAdapterSprite(new HeroPointer());

			ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onStarlingTouch);
		}

		override public function dispose():void
		{
			resetSelection();
			super.dispose();
		}

		override protected function activate():void
		{
			if (!this.hero || !this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			setSelection();

			this.selectedCount = 0;
		}

		override protected function deactivate():void
		{
			resetSelection();

			super.deactivate();
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

					if ('selectionFinished' in data && data['selectionFinished'][0] == this.code && data['selectionFinished'][1] == this.hero.id)
					{
						onSelectionFinish(data['selectionFinished'][2]);
						return;
					}

					if (!('heroSelected' in data))
						return;

					if (!this.hero || data['heroSelected'][0] != this.code || data['heroSelected'][1] != this.hero.id)
						return;

					if (!this.active)
						return;

					this.selectedHero = data['heroSelected'][2];
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		protected function setSelection():void
		{
			if (!this.hero.isSelf || !this.hero.game)
				return;

			Mouse.hide();
			ScreenStarling.instance.addEventListener(TouchEvent.TOUCH, onStarlingTouch);

			this.selectCursor.x = _localPos.x;
			this.selectCursor.y = _localPos.y;
			if (this.selectCursor)
				this.selectCursor.removeFromParent();

			this.selectCursor = new StarlingAdapterSprite(new HeroPointer());

			ScreenStarling.upLayer.addChild(this.selectCursor.getStarlingView());

			eventMove = true;
			eventClick = true;
		}

		protected function resetSelection():void
		{
			if (!this.hero.isSelf)
				return;

			if (this.selectCursor)
				this.selectCursor.removeFromParent();

			eventClick = false;
			eventMove = false;

			Mouse.show();

			this._selectedHeroes.splice(0);
			ScreenStarling.instance.removeEventListener(TouchEvent.TOUCH, onStarlingTouch);
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
			} else if (touch.phase == TouchPhase.ENDED && eventClick) {
				onEnded();
			} else if (touch.phase == TouchPhase.MOVED) {

			}
		}

		protected function onEnded(): void {
			onSelect(_localPos);
		}

		protected function onSelect(e:Point):void
		{
			if (e) {/*unused*/}

			if (!this.hero.game)
			{
				this.active = false;
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
				if (hero.hitTestStarling(_localPos, false) || pos.Length() < 6)
					selected.push(hero);
			}

			if (selected.length != 0)
			{
				var selectedHeroId:int = (IndexUtil.getMaxIndex(selected) as Hero).id;
				this._selectedHeroes.push(selectedHeroId);
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'heroSelected': [this.code, this.hero.id, selectedHeroId]}));
				squirrelsToSelect--;
			}

			if (++this.selectedCount != this.selectionsCount && squirrelsToSelect != 0)
				return;

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'selectionFinished': [this.code, this.hero.id, this._selectedHeroes.length]}));
			this._selectedHeroes.splice(0);
		}

		protected function set selectedHero(heroId:int):void
		{
			if (!this.hero.game)
				return;

			var hero:Hero = this.hero.game.squirrels.get(heroId);
			if (!hero)
				return;

			hero.heroView.showActiveAura();
			hero.heroView.showPerkAnimation(new PerkShamanFactory.perkData[PerkShamanFactory.getClassById(this.code)]['buttonClass'], 1000);
		}

		protected function onSelectionFinish(selectedHeroesCount:int):void
		{
			if (selectedHeroesCount) {/*unused*/}

			this.active = false;
		}

		protected function checkHero(hero:Hero):Boolean
		{
			return hero && hero.isExist && (hero.id != this.hero.id) && !hero.isHare && !hero.shaman && (this._selectedHeroes.indexOf(hero.id) == -1) && !hero.isDead && !hero.inHollow;
		}
	}
}
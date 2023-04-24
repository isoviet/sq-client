package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import by.blooddy.crypto.serialization.JSON;

	import com.greensock.TweenMax;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundCommand;

	import utils.IntUtil;

	public class PerkClothesHatter extends PerkClothes
	{
		private var squirrelsCount:int = 0;
		private var newPositions:Object = {};

		private var view:MovieClip;

		public function PerkClothesHatter(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override public function get maxCountUse():int
		{
			return 1;
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.heroView.fly;
		}

		override public function dispose():void
		{
			super.dispose();

			if (this.view)
				this.view.removeEventListener(Event.CHANGE, onCompleteView);
		}

		override protected function activate():void
		{
			if (!this.hero.game || this.hero.game.paused || this.hero.isDead || this.hero.inHollow)
			{
				this.active = false;
				return;
			}

			super.activate();

			this.hero.game.paused = true;

			this.view = new HatterPerkView();
			this.view.addEventListener(Event.CHANGE, onCompleteView);
			this.view.y = - Hero.Y_POSITION_COEF;
			this.hero.heroView.addChild(this.view);

			if (!this.hero || !this.hero.game || this.hero.id != Game.selfId)
				return;

			swapSquirrels();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.hero && this.hero.game)
				this.hero.game.paused = false;

			if (!this.view)
				return;

			this.view.removeEventListener(Event.CHANGE, onCompleteView);

			if (this.view.parent)
				this.view.parent.removeChild(this.view);
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

					if ('hatterFail' in data)
					{
						this.active = false;
						return;
					}

					if (!('hatter' in data))
						return;

					if (!this.hero || data['hatter'][0] != this.hero.id)
						return;

					if (!this.active)
						return;

					var swaps:Array = data['hatter'][1];
					this.squirrelsCount = swaps.length;
					this.newPositions = {};

					for (var i:int = 0; i < swaps.length; i++)
					{
						var hero1:Hero = this.hero.game.squirrels.get(swaps[i][0]);
						var hero2:Hero = this.hero.game.squirrels.get(swaps[i][1]);
						if (!checkHero(hero1) || !checkHero(hero2))
						{
							this.squirrelsCount --;
							continue;
						}
						swap(hero1, hero2);
					}

					if (this.squirrelsCount == 0)
						this.active = false;
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function swapSquirrels():void
		{
			var shaman:Array = [];
			var squirrels:Array = [];
			var swaps:Array = [];

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (!checkHero(hero))
					continue;

				if (hero.shaman)
				{
					shaman.push(hero);
					continue;
				}

				if (hero.id == this.hero.id)
					continue;

				squirrels.push(hero);
			}

			if (shaman.length == 0)
				squirrels.push(this.hero);
			else
				swaps.push([this.hero.id, shaman[0].id]);

			var shortLenght:int = int(squirrels.length / 3);
			while (squirrels.length > shortLenght)
				squirrels.splice(int(Math.random() * squirrels.length), 1);

			if (squirrels.length > 1)
			{
				var shift:int = IntUtil.randomInt(1, squirrels.length - 1);

				for (var i:int = 0; i < squirrels.length; i++)
					swaps.push([squirrels[i].id, squirrels[(i + shift) % squirrels.length].id]);
			}

			if (swaps.length > 0)
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'hatter': [this.hero.id, swaps]}));
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'hatterFail': true}));
		}

		private function swap(hero1:Hero, hero2:Hero):void
		{
			TweenMax.to(hero1, 1, {'x': hero2.position.x * Game.PIXELS_TO_METRE, 'y': hero2.position.y * Game.PIXELS_TO_METRE, 'onCompleteParams': [hero1, hero2], 'onComplete': onCompleteTween});
		}

		private function onCompleteTween(hero1:Hero, hero2:Hero):void
		{
			this.squirrelsCount --;
			if (checkHero(hero1) && checkHero(hero2))
				this.newPositions[hero1.id] = hero2.position.Copy();

			if (this.squirrelsCount != 0)
				return;

			if (this.hero && this.hero.game && this.hero.game.squirrels)
			{
				for (var hero:String in this.newPositions)
				{
					var squirrel:Hero = this.hero.game.squirrels.get(int(hero));
					if (!checkHero(squirrel))
						continue;
					squirrel.position = this.newPositions[hero];
				}
			}

			this.active = false;
		}

		protected function onCompleteView(e:Event):void
		{
			this.view.removeEventListener(Event.CHANGE, onCompleteView);

			if (this.view && this.view.parent)
				this.view.parent.removeChild(this.view);
		}

		private function checkHero(hero:Hero):Boolean
		{
			return hero && hero.isExist && !hero.isDead && !hero.inHollow && !hero.hover;
		}
	}
}
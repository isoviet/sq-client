package game.mainGame.entity.shaman
{
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.Cast;
	import game.mainGame.IUpdate;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.cast.ICastChange;
	import game.mainGame.entity.simple.InvisibleBody;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.BuffRadialView;
	import game.mainGame.perks.shaman.PerkShamanFactory;

	import by.blooddy.crypto.serialization.JSON;

	import com.greensock.TweenMax;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class StormCloud extends InvisibleBody implements ICastChange, ILifeTime, IUpdate
	{
		static private const DEFAULT_RADIUS:int = 100 / Game.PIXELS_TO_METRE;
		static private const SPEED_BONUS_FACTOR:int = 15;

		private var _cast:Cast = null;
		private var oldCastRadius:Number;

		private var radiusView:StarlingAdapterSprite = null;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 0;
		private var disposed:Boolean = false;

		private var deserializedIds:Array = null;
		private var speedyHeroes:Object = {};

		private var buff:BuffRadialView = null;
		private var timer:Timer = new Timer(100, 100);

		public var bonusTime:Number;

		public function StormCloud():void
		{
			this.view = new StarlingAdapterMovie(new StormCloudImg);
			this.view.stop();
			this.view.alignPivot();
			this.view.y = -60;
			addChildStarling(this.view);

			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function build(world:b2World):void
		{
			this.timer.delay = this.bonusTime / 100;

			this.builded = true;

			super.build(world);

			this.view.play();

			this.radiusView = new StarlingAdapterSprite(new PerkRadius());
			this.radiusView.scaleXY((DEFAULT_RADIUS * Game.PIXELS_TO_METRE * 2) / this.radiusView.width);

			addChildStarling(this.radiusView);
			this.radiusView.alignPivot();

			for (var i:int = 0; i < this.deserializedIds.length; i++)
			{
				var hero:Hero = this.gameInst.squirrels.get(this.deserializedIds[i]);
				if (!hero || hero.isDead || hero.inHollow || (hero.id in this.speedyHeroes))
					return;

				var bonus:Number = hero.runSpeed * (SPEED_BONUS_FACTOR / 100);
				this.speedyHeroes[hero.id] = bonus;
				hero.runSpeed += bonus;
			}

			this.deserializedIds.splice(0);
		}

		override public function dispose():void
		{
			this.removeFromParent();

			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			for (var id:String in this.speedyHeroes)
				resetSquirrel(int(id));

			this.speedyHeroes = null;

			super.dispose();
		}

		override public function serialize():*
		{
			var data:Array = super.serialize();
			var ids:Array = [];
			for (var id:String in this.speedyHeroes)
				ids.push(int(id));
			data.push([this.playerId, this.bonusTime, this.aging, this.lifeTime, ids]);

			return data;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			var dataPointer:Array = data.pop();

			this.playerId = dataPointer[0];
			this.bonusTime = dataPointer[1];
			this.aging = Boolean(dataPointer[2]);
			this.lifeTime = dataPointer[3];
			this.deserializedIds = dataPointer[4];
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.aging || this.disposed || !this.builded)
				return;

			this._lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
			{
				destroy();
				return;
			}

			for each (var hero:Hero in this.gameInst.squirrels.players)
			{
				if (!checkHero(hero))
					continue;

				var distance:b2Vec2 = this.position.Copy();
				distance.Subtract(hero.position);

				if (distance.Length() > DEFAULT_RADIUS)
				{
					if (!(hero.id in this.speedyHeroes) || !hero.isSelf)
						continue;

					this.timer.start();
					continue;
				}

				if (hero.id in this.speedyHeroes && hero.isSelf)
				{
					this.timer.reset();
					this.buff.update(0);
					continue;
				}

				commandBoostSquirrel(hero.id);
			}
		}

		public function get aging():Boolean
		{
			return this._aging;
		}

		public function set aging(value:Boolean):void
		{
			this._aging = value;
		}

		public function get lifeTime():Number
		{
			return this._lifeTime;
		}

		public function set lifeTime(value:Number):void
		{
			this._lifeTime = value;
		}

		public function set cast(cast:Cast):void
		{
			this._cast = cast;
		}

		public function setCastParams():void
		{
			this.oldCastRadius = this._cast.castRadius;
			this._cast.castRadius = 0;
		}

		public function resetCastParams():void
		{
			if (!this._cast)
				return;

			this._cast.castRadius = this.oldCastRadius;
		}

		private function commandBoostSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId)
				return;

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'stormSquirrel': [this.id, heroId]}));
			Hero.self.sendLocation();
		}

		private function commandResetSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId || !this.gameInst)
				return;

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'resetStormSquirrel': [this.id, heroId]}));
			Hero.self.sendLocation();
		}

		private function boostSquirrel(heroId:int):void
		{
			if (!this.gameInst)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || hero.isDead || hero.inHollow || (hero.id in this.speedyHeroes))
				return;

			var speedBonus:Number = SPEED_BONUS_FACTOR / 100 * hero.runSpeed;
			this.speedyHeroes[hero.id] = speedBonus;
			hero.runSpeed += speedBonus;

			if (!hero.isSelf)
				return;

			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(SquirrelEvent.DIE, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);

			if (!buff)
				buff = new BuffRadialView((new PerkShamanFactory.perkData[PerkShamanFactory.getClassById(PerkShamanFactory.PERK_STORM)]['buttonClass'] as SimpleButton).upState, 0.7, 0.5, gls("Белка получила бонус скорости 15%."));

			this.timer.reset();
			hero.addBuff(buff, this.timer);
		}

		private function removeSquirrel(heroId:int):void
		{
			resetSquirrel(heroId);
			delete this.speedyHeroes[heroId];
		}

		private function resetSquirrel(heroId:int):void
		{
			if (!this.gameInst)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || !hero.isExist || !(hero.id in this.speedyHeroes))
				return;

			hero.runSpeed -= this.speedyHeroes[hero.id];

			if (!hero.isSelf)
				return;

			if (this.timer.running)
				this.timer.reset();

			if (this.buff)
				hero.removeBuff(this.buff, this.timer);

			hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
		}

		private function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;

			TweenMax.to(this, 0.1, {'alpha': 0, 'onComplete': death});
		}

		private function death():void
		{
			if (this.gameInst)
				gameInst.map.destroyObjectSync(this, true);
		}

		private function onComplete(e:TimerEvent):void
		{
			commandResetSquirrel(Game.selfId);
		}

		private function onEvent(e:Event):void
		{
			commandResetSquirrel(e['player']['id']);
		}

		private function checkHero(hero:Hero):Boolean
		{
			return !(!hero || !hero.isExist || hero.isDead || hero.inHollow || hero.isHare || hero.isDragon) && (hero.shaman && (hero.id == this.playerId) || !hero.shaman);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('stormSquirrel' in data)
			{
				if (data['stormSquirrel'][0] != this.id)
					return;

				boostSquirrel(data['stormSquirrel'][1]);
			}

			if ('resetStormSquirrel' in data)
			{
				if (data['resetStormSquirrel'][0] != this.id)
					return;

				removeSquirrel(data['resetStormSquirrel'][1]);
			}
		}
	}
}
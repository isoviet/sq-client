package game.mainGame.perks.clothes
{
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.joints.JointAmur;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	import utils.starling.StarlingAdapterMovie;

	public class PerkClothesAmur extends PerkClothesSelective
	{
		static public const MAX_DISTANCE:int = 15;
		static public const SPEED:Number = 500;

		protected var victimIds:Array = [];
		protected var movieArrow:StarlingAdapterMovie = null;
		protected var movieMiss:StarlingAdapterMovie = null;

		public function PerkClothesAmur(hero:Hero)
		{
			super(hero);
		}

		override public function get totalCooldown():Number
		{
			return this.perkLevel == 0 ? 20 : 5;
		}

		override public function get available():Boolean
		{
			return super.available && !this.movieArrow;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.movieArrow)
				return;
			if (this.victimIds.length == 0)
			{
				this.hero.game.map._foregroundObjects.removeChildStarling(this.movieArrow);
				this.movieArrow = null;
				return;
			}
			var victim:Hero = this.hero.game.squirrels.get(this.victimIds[0]);
			if (victim.isDead || victim.inHollow)
			{
				this.hero.game.map._foregroundObjects.removeChildStarling(this.movieArrow);
				this.movieArrow = null;
				this.victimIds = [];
				return;
			}
			var pos:b2Vec2 = new b2Vec2(this.movieArrow.x, this.movieArrow.y);
			pos.Subtract(new b2Vec2(victim.x, victim.y));
			pos.NegativeSelf();
			if (pos.Length() > (SPEED * timeStep))
			{
				this.movieArrow.rotation = Math.atan2(pos.y, pos.x) * Game.R2D;
				pos.Normalize();
				this.movieArrow.x += SPEED * timeStep * pos.x;
				this.movieArrow.y += SPEED * timeStep * pos.y;
				return;
			}
			createJoint();

			this.hero.game.map._foregroundObjects.removeChildStarling(this.movieArrow);
			this.movieArrow = null;
			this.victimIds = [];
		}

		override public function resetRound():void
		{
			super.resetRound();

			if (this.movieArrow)
				this.hero.game.map._foregroundObjects.removeChildStarling(this.movieArrow);
			this.movieArrow = null;
			this.victimIds = [];

			if (this.movieMiss)
			{
				this.movieMiss.stop();
				this.movieMiss.removeEventListener(Event.ENTER_FRAME, onFrame);
				this.hero.game.map._foregroundObjects.removeChildStarling(this.movieMiss);
				this.movieMiss = null;
			}
		}

		override public function get json():String
		{
			var squirrels:Object = this.hero.game.squirrels.players;
			var targetHero:Hero = this.hero.game.squirrels.get(this.target);
			var victimId:int = 0;
			var dist:Number = 0;

			for each (var hero:Hero in squirrels)
			{
				if (hero.id == this.target)
					continue;
				if (!checkHero(hero))
					continue;
				var pos:b2Vec2 = hero.position.Copy();
				pos.Subtract(targetHero.position);
				if (pos.Length() > MAX_DISTANCE)
					continue;
				if (victimId != 0 && (pos.Length() > dist))
					continue;
				victimId = hero.id;
				dist = pos.Length();
			}

			return by.blooddy.crypto.serialization.JSON.encode({'id': victimId});
		}

		override protected function activate():void
		{
			super.activate();

			if (this.movieArrow)
				this.hero.game.map._foregroundObjects.removeChildStarling(this.movieArrow);
			this.movieArrow = new StarlingAdapterMovie(new AmurShotView());
			this.movieArrow.loop = true;
			this.movieArrow.play();
			this.movieArrow.x = this.hero.x;
			this.movieArrow.y = this.hero.y;
			this.hero.game.map._foregroundObjects.addChildStarling(this.movieArrow);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (this.hero == null)
				return;
			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var roundSkill:PacketRoundSkill = packet as PacketRoundSkill;
					if (roundSkill.state == PacketServer.SKILL_ERROR)
						return;
					if (roundSkill.type != this.code || roundSkill.playerId != this.hero.id)
						return;
					if (roundSkill.state == PacketServer.SKILL_ACTIVATE)
					{
						this.victimIds = [];
						this.victimIds.push(roundSkill.targetId);
						if (roundSkill.scriptJson['id'] != 0)
							this.victimIds.push(roundSkill.scriptJson['id']);
					}
					this.active = roundSkill.state == PacketServer.SKILL_ACTIVATE;
					break;
			}
		}

		override protected function checkHero(hero:Hero):Boolean
		{
			return this.hero.id != hero.id && !hero.isDead && !hero.inHollow;
		}

		protected function createJoint():void
		{
			if (this.victimIds.length < 2)
			{
				if (this.victimIds.length == 1)
				{
					var victim:Hero = this.hero.game.squirrels.get(this.victimIds[0]);
					this.movieMiss = new StarlingAdapterMovie(new AmurHitView());
					this.movieMiss.addEventListener(Event.ENTER_FRAME, onFrame);
					this.movieMiss.play();
					this.movieMiss.x = victim.x;
					this.movieMiss.y = victim.y + 20;
					this.hero.game.map._foregroundObjects.addChildStarling(this.movieMiss);
				}
				return;
			}
			var joint:JointAmur = new JointAmur();
			joint.damping = 0;
			joint.frequency = 5;
			joint.hero0 = this.hero.game.squirrels.get(this.victimIds[0]);
			joint.hero1 = this.hero.game.squirrels.get(this.victimIds[1]);
			this.hero.game.map.add(joint);
			joint.build(this.hero.game.world);
		}

		private function onFrame(e:Event):void
		{
			if (!this.hero || !this.hero.game || !this.hero.game.map)
				return;
			if (!this.movieMiss)
				return;
			if (this.movieMiss.currentFrame < this.movieMiss.totalFrames - 1)
				return;
			this.movieMiss.stop();
			this.movieMiss.removeEventListener(Event.ENTER_FRAME, onFrame);
			this.hero.game.map._foregroundObjects.removeChildStarling(this.movieMiss);
			this.movieMiss = null;
		}
	}
}
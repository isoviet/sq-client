package game.mainGame
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import Box2D.Common.Math.b2Vec2;

	import controllers.ControllerHeroLocal;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.editor.BlueTeamBody;
	import game.mainGame.entity.editor.RedTeamBody;
	import game.mainGame.entity.joints.JointGum;
	import game.mainGame.events.SquirrelEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoomRound;

	import utils.InstanceCounter;
	import utils.starling.StarlingAdapterSprite;

	public class SquirrelCollection extends StarlingAdapterSprite implements IUpdate
	{
		static private const ALIVE_DELAY:int = 5 * 1000;

		static private var _instance:SquirrelCollection = null;

		protected var synchronizingHeroId:int;
		protected var aliveTimer:Timer = new Timer(ALIVE_DELAY);

		public var heroClass:Class = Hero;
		public var players:Object = {};

		public var selfCollected:Boolean = false;

		static public function get instance():SquirrelCollection
		{
			return _instance;
		}

		public function SquirrelCollection():void
		{
			_instance = this;

			Logger.add("SquirrelCollection.SquirrelCollection");

			InstanceCounter.onCreate(this);
			super();

			this.aliveTimer.addEventListener(TimerEvent.TIMER, onSendAlive);
			this.aliveTimer.reset();

			Hero.listenSelf([SquirrelEvent.DIE], onSelfDie);
		}

		public function checkSquirrelsCount(resetAvailable:Boolean = true):void
		{}

		public function round(packet:PacketRoomRound):void
		{}

		protected function onSendAlive(e:TimerEvent = null):void
		{
			Connection.sendData(PacketClient.ROUND_ALIVE);
		}

		public function dispose():void
		{
			Logger.add("SquirrelCollection.dispose");

			Hero.forget(onSelfDie);

			this.aliveTimer.stop();
			this.aliveTimer.removeEventListener(TimerEvent.TIMER, onSendAlive);
			this.aliveTimer = null;

			InstanceCounter.onDispose(this);
			clear();

			_instance = null;
		}

		public function set(ids:Vector.<int>):void
		{
			clear();
			if (ids.length == 0)
				return;

			for (var i:int = 0; i < ids.length; i++)
				add(ids[i]);
		}

		public function getIds():Vector.<int>
		{
			var ids:Vector.<int> = new Vector.<int>();
			for (var id:String in this.players)
				ids.push(parseInt(id));
			return ids;
		}

		public function add(id:int):void
		{
			if (!SquirrelGame.instance || !this.players || id in this.players)
				return;

			Logger.add("SquirrelCollection.add: " + id);

			this.players[id] = new this.heroClass(id, SquirrelGame.instance.world, 0, 0);

			if (SquirrelGame.instance && SquirrelGame.instance.sideIcons)
				SquirrelGame.instance.sideIcons.register(this.players[id]);

			addChildStarling(this.players[id]);
			addChild(this.players[id]);

			if (Game.selfId && (Game.selfId in this.players))
			{
				addChild(this.players[Game.selfId]);
				addChildStarling(this.players[Game.selfId]);
			}

			setController(id);
		}

		public function show():void
		{
			for each (var player:Hero in this.players)
				player.show();
		}

		public function reset():void
		{
			for each (var player:Hero in this.players)
				player.reset();
		}

		public function hide():void
		{
			for each (var player:Hero in this.players)
				player.hide();
		}

		public function remove(id:int):void
		{
			var hero:Hero = get(id);
			if (hero == null)
				return;

			Logger.add("SquirrelCollection.remove " + id);

			SquirrelGame.instance.sideIcons.remove(hero);

			hero.remove();

			if (contains(hero))
				removeChild(hero);

			if (containsStarling(hero))
				removeChildStarling(hero);

			delete this.players[id];
		}

		public function get count():int
		{
			var counter:int = 0;

			for each (var player:Hero in this.players)
			{
				if (player == null)
					continue;
				counter++;
			}
			return counter;
		}

		public function get isSynchronizing():Boolean
		{
			return (Game.selfId == this.synchronizingHeroId);
		}

		public function place():void
		{
			var position:Vector.<b2Vec2> = GameMap.instance.squirrelsPosition;
			var index:int = 0;

			var heroes:Array = [];
			for each (var player:Hero in this.players)
				heroes.push(player);
			heroes.sort(sortById);

			if (position.length != 0)
			{
				for (var i:int = 0; i < heroes.length; i++)
				{
					player = heroes[i];
					if (player.shaman)
						continue;

					player.position = position[index++];
					if (index == position.length)
						index = 0;
				}
			}

			position = GameMap.instance.shamansPosition;
			index = 0;

			if (position.length != 0)
			{
				for (i = 0; i < heroes.length; i++)
				{
					player = heroes[i];
					if (!player.shaman)
						continue;

					player.position = position[index++];
					if (index == position.length)
						index = 0;
				}
			}
		}

		public function getPositionRebornSkill(heroId:int, team:int):b2Vec2
		{
			var position:b2Vec2 = null;
			switch (team)
			{
				case Hero.TEAM_NONE:
					for each (var hero:Hero in this.players)
					{
						if (!hero.shaman || hero.isDead || hero.id == heroId || checkDie(hero))
							continue;

						position = hero.position;
					}
					if (position == null && GameMap.instance.squirrelsPosition.length > 0)
						position = GameMap.instance.squirrelsPosition[0];
					break;
				case Hero.TEAM_BLUE:
					for each (hero in this.players)
					{
						if (!hero.shaman || hero.isDead || hero.id == heroId || hero.team != Hero.TEAM_BLUE || checkDie(hero))
							continue;

						position = hero.position;
					}
					if (position == null && GameMap.instance.get(BlueTeamBody).length > 0)
						position = (GameMap.instance.get(BlueTeamBody)[0] as IGameObject).position;
					break;
				case Hero.TEAM_RED:
					for each (hero in this.players)
					{
						if (!hero.shaman || hero.isDead || hero.id == heroId || hero.team != Hero.TEAM_RED || checkDie(hero))
							continue;

						position = hero.position;
					}
					if (position == null && GameMap.instance.get(RedTeamBody).length > 0)
						position = (GameMap.instance.get(RedTeamBody)[0] as IGameObject).position;
					break;
			}
			return position;
		}

		public function clear():void
		{
			var removingIds:Vector.<int> = getIds();

			Logger.add("SquirrelCollection.clear before(" + removingIds.join(" | ") + ")");

			for (var i:int = 0; i < removingIds.length; i++)
				remove(removingIds[i]);

			removingIds = getIds();
			if (removingIds.length > 0)
				Logger.add("Warning: Not all Squirrels removed !!! (" + removingIds.join(" | ") + ")");
			this.players = {};

			while (this.numChildren > 0)
			{
				removeChildAt(0);
				removeChildStarlingAt(0);
			}
		}

		public function setSynchronizer(playerId:int):void
		{
			this.synchronizingHeroId = playerId;
		}

		public function resetShamans():void
		{
			for (var playerId:String in this.players)
				get(int(playerId)).shaman = false;
		}

		public function getShamans():Array
		{
			var result:Array = [];
			for each (var player:Hero in this.players)
			{
				if (player.shaman)
					result.push(player);
			}
			return result;
		}

		public function setShamans(shamans:Vector.<int>, withReset:Boolean = true):void
		{
			if (withReset)
				resetShamans();

			for each (var shamanId:int in shamans)
			{
				var shaman:Hero = get(shamanId);
				if (shaman == null)
					continue;

				shaman.shaman = true;
				addChildStarling(shaman);
			}

			if (!Hero.self)
				return;
			addChild(Hero.self);
			addChildStarling(Hero.self);
		}

		public function setHares(hares:Vector.<int>):void
		{
			for (var playerId:String in this.players)
				get(int(playerId)).isHare = false;

			for each (var hareId:int in hares)
			{
				var hare:Hero = get(hareId);
				if (hare == null)
					continue;

				hare.isHare = true;
				addChild(hare);
			}

			if (Hero.self)
				addChild(Hero.self);
		}

		public function setDragons(dragons:Vector.<int>):void
		{
			for (var playerId:String in this.players)
				get(int(playerId)).isDragon = false;

			for each (var dragonId:int in dragons)
			{
				var dragon:Hero = get(dragonId);
				if (dragon == null)
					continue;
				dragon.isDragon = true;
				addChild(dragon);
			}

			if (Hero.self)
				addChild(Hero.self);
		}

		public function get(id:int):Hero
		{
			if (!(id in this.players))
				return null;
			return this.players[id];
		}

		public function update(timeStep:Number = 0):void
		{
			for each (var player:Hero in this.players)
				player.update(timeStep);
		}

		public function get activeSquirrelCount():int
		{
			var count:int = 0;
			for each (var player:Hero in this.players)
			{
				if (player.inHollow || player.isDead)
					continue;
				count++;
			}
			return count;
		}

		public function getActiveSquirrels():Array
		{
			var result:Array = [];
			for each (var player:Hero in this.players)
			{
				if (!player.inHollow && !player.isDead && !player.shaman && !player.isHare)
					result.push(player);
			}
			return result;
		}

		public function hasActiveSquirrel(withoutShaman:Boolean = true):Boolean
		{
			for each (var player:Hero in this.players)
			{
				if (player.isHare || player.shaman && withoutShaman || player.inHollow || player.isDead)
					continue;
				return true;
			}
			return false;
		}

		public function createGum(self:int, other:int):Boolean
		{
			if (!get(self) || !get(other))
				return false;

			if (findGum(self, other))
				return false;

			var joint:JointGum = new JointGum();
			joint.hero0 = get(self);
			joint.hero1 = get(other);
			GameMap.instance.add(joint);
			joint.build(SquirrelGame.instance.world);
			return true;
		}

		public function findGum(self:int, other:int):JointGum
		{
			var gums:Array = GameMap.instance.get(JointGum);
			for each(var gum:JointGum in gums)
			{
				if (gum.hero0 && (gum.hero0.id == self || gum.hero0.id == other) && gum.hero1 && (gum.hero1.id == self || gum.hero1.id == other))
					return gum;
			}
			return null;
		}

		protected function setController(id:int):void
		{
			new ControllerHeroLocal(this.players[id], false);
		}

		protected function onSelfDie(e:SquirrelEvent = null):void
		{}

		protected function checkDie(hero:Hero):Boolean
		{
			var shift:int = 80;
			if (hero.x < -shift || hero.checkShift(shift))
				return true;
			return hero.y > 620;
		}

		private function sortById(a:Hero, b:Hero):int
		{
			return int(a.id) < int(b.id) ? 1 : -1;
		}
	}
}
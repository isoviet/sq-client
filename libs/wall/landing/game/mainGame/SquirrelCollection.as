package landing.game.mainGame
{
	import flash.display.Sprite;

	import Box2D.Common.Math.b2Vec2;

	import landing.controllers.ControllerHeroLocal;
	import landing.game.mainGame.events.SquirrelEvent;

	public class SquirrelCollection extends Sprite implements IUpdate
	{
		protected var players:Object = new Object();
		protected var game:SquirrelGame;

		public function SquirrelCollection(game:SquirrelGame):void
		{
			super();

			this.game = game;

			clear();
		}

		public function dispose():void
		{
			clear();

			this.game = null;
			this.players = null;

			while (this.numChildren > 0)
				removeChildAt(0);
		}

		public function set(ids:Array):void
		{
			clear();

			if (ids.length == 0)
				return;

			for each (var id:int in ids)
				add(id);
		}

		public function add(id:int):void
		{
			if (id in this.players)
				return;

			this.players[id] = new wHero(id, this.game.world, 0, 0, false, false);

			addChild(this.players[id]);

			if (WallShadow.SELF_ID in this.players)
				addChild(this.players[WallShadow.SELF_ID]);

			if (id == WallShadow.SELF_ID)
				get(id).addEventListener(SquirrelEvent.DIE, onSelfDie, false, 0, true);

			setController(id);
		}

		public function show():void
		{
			for each (var player:wHero in this.players)
				player.show();
		}

		public function reset():void
		{
			for each (var player:wHero in this.players)
				player.reset();
		}

		public function hide():void
		{
			for each (var player:wHero in this.players)
				player.hide();
		}

		public function remove(id:int):void
		{
			if (!(id in this.players))
				return;

			var hero:wHero = get(id);
			hero.remove();

			if (contains(hero))
				removeChild(hero);

			delete players[id];
		}

		public function get count():int
		{
			var counter:int = 0;

			for each (var player:wHero in this.players)
				counter++;

			return counter;
		}

		public function get self():wHero
		{
			return get(WallShadow.SELF_ID);
		}

		public function place():void
		{
			var position:Vector.<b2Vec2> = this.game.map.squirrelsPosition;
			var index:int = 0;

			if (position.length != 0)
			{
				for each (var player:wHero in this.players)
				{
					if (player.isShaman)
						continue;

					player.position = position[index++];
					if (index == position.length)
						index = 0;
				}
			}

			position = this.game.map.shamansPosition;
			index = 0;

			if (position.length != 0)
			{
				for each (player in this.players)
				{
					if (!player.isShaman)
						continue;

					player.position = position[index++];
					if (index == position.length)
						index = 0;
				}
			}
		}

		public function clear():void
		{
			for each (var player:wHero in this.players)
				remove(player['id']);

			while (this.numChildren > 0)
				removeChildAt(0);
		}

		public function resetShamans():void
		{
			for (var playerId:* in this.players)
				get(playerId).shaman = false;
		}

		public function setShamans(shamans:Array):void
		{
			resetShamans();

			for each (var shamanId:int in shamans)
			{
				var shaman:wHero = get(shamanId);
				if (shaman == null)
					continue;

				shaman.shaman = true;
				addChild(shaman);
			}

			if (get(WallShadow.SELF_ID))
				addChild(get(WallShadow.SELF_ID));
		}

		public function get(id:int):wHero
		{
			return this.players ? this.players[id] : null;
		}

		public function update(timeStep:Number = 0):void
		{
			for each (var player:wHero in this.players)
				player.update(timeStep);
		}

		public function get activeSquirrelCount():int
		{
			var count:int = 0;
			for each (var player:wHero in this.players)
			{
				if (player.inHollow || player.isDead)
					continue;

				count++;
			}
			return count;
		}

		public function hasActiveSquirrel():Boolean
		{
			for each (var player:wHero in this.players)
			{
				if (player.isShaman || player.inHollow || player.isDead)
					continue;

				return true;
			}

			return false;
		}

		protected function setController(id:int):void
		{
			if (id != WallShadow.SELF_ID)
				return;

			new ControllerHeroLocal(this.players[id], false);
		}

		protected function onSelfDie(e:SquirrelEvent):void
		{}
	}
}
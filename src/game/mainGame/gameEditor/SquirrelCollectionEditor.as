package game.mainGame.gameEditor
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	import Box2D.Common.Math.b2Vec2;

	import controllers.ControllerHero;
	import controllers.ControllerHeroLocal;
	import controllers.ControllerHeroRemote;
	import dialogs.DialogRecord;
	import footers.FooterGame;
	import game.mainGame.GameMap;
	import game.mainGame.SquirrelCollection;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.editor.BlueTeamBody;
	import game.mainGame.entity.editor.RedTeamBody;
	import game.mainGame.entity.editor.SquirrelBody;
	import game.mainGame.entity.joints.JointRopeToSquirrel;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.HeroBattle;
	import game.mainGame.gameRecord.Recorder;
	import game.mainGame.perks.hare.ui.HarePerksToolBar;
	import game.mainGame.perks.mana.PerkFactory;
	import game.mainGame.perks.mana.ui.PerksToolBar;
	import screens.ScreenEdit;

	public class SquirrelCollectionEditor extends SquirrelCollection
	{
		private var _selfHeroId:int;

		private var controller:ControllerHero;
		private var arrow:MovieClip;

		public function SquirrelCollectionEditor():void
		{
			super();

			this.arrow = new ArrowMovie();
			this.arrow.rotation = -90;
			this.arrow.x = -13;
			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		}

		override public function add(id:int):void
		{
			var location:int = (SquirrelGame.instance as SquirrelGameEditor).lastTestedMap.location;
			Logger.add("---onAdd---", location, (SquirrelGame.instance as SquirrelGameEditor).lastTestedMap.subLocation);
			switch (location)
			{
				case Locations.BATTLE_ID:
				case Locations.TENDER:
					this.heroClass = HeroBattle;
					break;
				default:
					this.heroClass = Hero;
					break;
			}

			super.add(id);
			get(id).addEventListener(SquirrelEvent.DIE, onSelfDie, false, 0, true);
			get(id).addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}

		public function get self():Hero
		{
			return this.players[selfHeroId];
		}

		override public function get isSynchronizing():Boolean
		{
			return true;
		}

		override public function place():void
		{
			var players:Array = GameMap.instance.get(SquirrelBody).concat(GameMap.instance.get(BlueTeamBody)).concat(GameMap.instance.get(RedTeamBody));

			var positions:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for each (var player:IGameObject in players)
				positions.push(player.position);

			var index:int = 0;

			if (positions.length != 0)
			{
				for each (var hero:Hero in this.players)
				{
					if (hero.shaman)
						continue;

					hero.position = positions[index++];

					if (index == positions.length)
						index = 0;
				}
			}
		}

		override public function show():void
		{
			super.show();

			setHitArea();
		}

		public function placeRoped(isSnake:Boolean = false):void
		{
			var playersIds:Array = [];
			var position:Vector.<b2Vec2> = GameMap.instance.squirrelsPosition;

			if (position.length != 0)
				for each (var player:Hero in this.players)
				{
					if (player.shaman)
						continue;

					player.position = position[0];
					playersIds.push(player.id);
				}

			position = GameMap.instance.shamansPosition;
			var index:int = 0;

			if (position.length != 0)
			{
				for each (player in this.players)
				{
					if (!player.shaman)
						continue;

					player.position = position[index++];
					if (index == position.length)
						index = 0;
				}
			}

			if (isSnake)
				for (var i:int = 0; i < playersIds.length; i++)
				{
					get(playersIds[i]).position = GameMap.instance.squirrelsPosition[0];
					if (i + 1 < playersIds.length)
					{
						var joint:JointRopeToSquirrel = new JointRopeToSquirrel();
						joint.hero0 = get(playersIds[i]);
						joint.hero1 = get(playersIds[i + 1]);
						GameMap.instance.add(joint);
					}
				}
			else
				for (i = 0; i < playersIds.length; i += 2)
				{
					if (i + 1 >= playersIds.length)
						break;

					joint = new JointRopeToSquirrel();
					joint.hero0 = get(playersIds[i]);
					joint.hero1 = get(playersIds[i + 1]);
					GameMap.instance.add(joint);

					if (GameMap.instance.squirrelsPosition.length >= 2)
						get(playersIds[i + 1]).position = GameMap.instance.squirrelsPosition[1];
				}
		}

		override public function clear():void
		{
			this.selfHeroId = 0;
			super.clear();
		}

		public function get selfHeroId():int
		{
			return _selfHeroId;
		}

		public function set selfHeroId(value:int):void
		{
			if (controller)
				controller.remove();

			var hero:Hero = this.players[value];

			if (hero)
				controller = DialogRecord.recorder.isReplay ? new ControllerHeroRemote(hero, Recorder.FIRST_ID) : new ControllerHeroLocal(hero);

			var prevHero:Hero = get(this._selfHeroId);
			if (prevHero)
			{
				prevHero.castStop(false);
				prevHero.removeCircle();
				if (SquirrelGame.instance.cast)
					SquirrelGame.instance.cast.castObject = null;
			}

			this._selfHeroId = value;
			FooterGame.hero = this.self;
			PerksToolBar.hero = this.self;
			HarePerksToolBar.hero = this.self;
			Hero.self = this.self;
		}

		public function next():void
		{
			var ids:Vector.<int> = getIds();
			ids.sort(sortByNumber);

			var start:int = ids.indexOf(String(selfHeroId)) + 1;
			for (var i:int = start; i < start + ids.length; i++)
			{
				var hero:Hero = get(ids[i % ids.length]);
				if (hero.isDead || hero.inHollow)
					continue;
				selfHeroId = ids[i % ids.length];
				break;
			}
		}

		private function sortByNumber(a: int, b: int): int
		{
			return a <= b ? 1: -1;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);
			if (self && (self.inHollow))
				next();

			if (!contains(arrow))
				addChild(arrow);

			var hero:Hero = this.self;
			this.arrow.visible = hero != null;
			if (!hero)
				return;

			this.arrow.x = hero.x;
			this.arrow.y = hero.y - 60;
		}

		override protected function setController(id:int):void
		{}

		override protected function onSelfDie(e:SquirrelEvent = null):void
		{
			if (PerkFactory.SKILL_RESURECTION in ScreenEdit.allowedPerks)
				return;

			super.onSelfDie();

			if (Hero.self.shaman)
			{
				var alive:Array = [];
				for each(var hero:Hero in this.players)
				{
					if (hero.inHollow || hero.isDead || hero.shaman || hero.team != Hero.self.team && hero.team != Hero.TEAM_NONE || hero.isHare)
						continue;

					alive.push(hero);
				}

				if (alive.length > 0)
				{
					var newShaman:Hero = alive[int(Math.random() * alive.length)];
					newShaman.team = Hero.self.team;
					Hero.self.shaman = false;
					this.setShamans([newShaman.id] as Vector.<int>, false);
				}
			}

			if (Hero.self.id == this.selfHeroId)
				next();
		}

		private function setHitArea():void
		{
			for each (var hero:Hero in this.players)
			{
				var hitSprite:Sprite = new Sprite();
				hitSprite.graphics.beginFill(0xff4925, 0);
				hitSprite.graphics.drawRect(-23, -30, 46, 50);
				hitSprite.graphics.endFill();

				hero.mouseChildren = false;
				hero.hitArea = hitSprite;
				hero.addChild(hitSprite);
			}
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.TAB)
				return;
			next();
		}

		private function onClick(e:MouseEvent):void
		{
			if (!(e.currentTarget is Hero))
				return;

			if (this.selfHeroId == (e.currentTarget as Hero).id)
				return;

			this.selfHeroId = (e.currentTarget as Hero).id;
		}
	}
}
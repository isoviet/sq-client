package game.mainGame.gameEvent
{
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.view.VolcanoView;
	import game.mainGame.gameNet.GameMapNet;
	import sounds.GameSounds;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundCommand;

	import starling.display.Sprite;

	import utils.starling.utils.StarlingConverter;

	public class GameMapVolcanoNet extends GameMapNet
	{
		static private const HIT_TIMEOUT:Number = 0.33;

		static private const VOLCANO_COUNT:int = 9;
		static private const VOLCANO_WIDTH:int = 100;

		static private const BASE_TIME:int = 5;

		static private const STEP_INCREASE_COUNT:int = 3;
		static private const START_COUNT:int = 3;

		static private const VOLCANO_TOTAL_TIME:int = 8;

		static private const VOLCANO_PREPARE:int = 0;
		static private const VOLCANO_ACTIVE:int = 3;
		static private const VOLCANO_DEACTIVE:int = 5;

		static private var volcanoData:Array = null;
		static private var isDamage:Boolean = false;
		static private var hitTimeout:Number = 0.0;

		private var views:Vector.<VolcanoView> = new <VolcanoView>[];
		private var viewPlatform:Sprite = null;
		public var startTimer:int = 0;
		public var volcanoTimer:int = 0;

		public function GameMapVolcanoNet(game:SquirrelGame)
		{
			super(game);

			for (var i:int = 0; i < VOLCANO_COUNT; i++)
			{
				var volcano:VolcanoView = new VolcanoView();
				volcano.x = i * VOLCANO_WIDTH;
				volcano.y = Config.GAME_HEIGHT + 8;
				volcano.deactive();
				addChildStarling(volcano);

				this.views.push(volcano);
			}
			this.viewPlatform = StarlingConverter.imageWithTextureFill(new PlatformGroundWild, Config.GAME_WIDTH, 32);
			this.viewPlatform.y = Config.GAME_HEIGHT + 32;
			addChildStarling(this.viewPlatform);

			EnterFrameManager.addPerSecondTimer(onTime);
		}

		override public function round(packet:PacketRoomRound):void
		{
			super.round(packet);

			switch (packet.type)
			{
				case PacketServer.ROUND_START:
					volcanoData = null;
					hitTimeout = 0;
					isDamage = false;

					this.volcanoTimer = 0;
					this.startTimer = 0;
					for (var i:int = 0; i < this.views.length; i++)
						this.views[i].deactive();
					if (!this.game.squirrels.isSynchronizing)
						return;
					setVolcanos();
					break;
			}
		}

		override public function dispose():void
		{
			super.dispose();

			EnterFrameManager.removePerSecondTimer(onTime);
		}

		override public function serialize():*
		{
			var result:Array = by.blooddy.crypto.serialization.JSON.decode(super.serialize());

			var volcano:Array = [this.startTimer, this.volcanoTimer, volcanoData, (this.game.squirrels as SquirrelCollectionVolcano).scores];

			result.push({"volcano": volcano});
			return by.blooddy.crypto.serialization.JSON.encode(result);
		}

		override public function deserialize(data:*):void
		{
			var result:Array = by.blooddy.crypto.serialization.JSON.decode(data);
			var volcano:Object = result.pop();
			if (!("volcano" in volcano))
			{
				super.deserialize(data);
				return;
			}

			super.deserialize(by.blooddy.crypto.serialization.JSON.encode(result));

			this.startTimer = volcano['volcano'][0];
			this.volcanoTimer = volcano['volcano'][1];
			volcanoData = volcano['volcano'][2];
			(this.game.squirrels as SquirrelCollectionVolcano).scores  = volcano['volcano'][3];
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			super.onPacket(packet);

			if (packet.packetId != PacketRoundCommand.PACKET_ID)
				return;

			var data:Object = (packet as PacketRoundCommand).dataJson;
			if ('volcanoData' in data)
				volcanoData = data['volcanoData'];
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (hitTimeout > 0)
			{
				hitTimeout = Math.max(0, hitTimeout - timeStep);
				return;
			}
			if (!isDamage)
				return;
			var actives:Array = this.activeIds;
			var hero:HeroVolcano = Hero.self as HeroVolcano;
			if (!hero || hero.isDead)
				return;
			var posX:int = (hero.position.x * Game.PIXELS_TO_METRE);
			for (var i:int = 0; i < actives.length; i++)
			{
				if (!((actives[i] * VOLCANO_WIDTH) <= posX && posX <= (VOLCANO_WIDTH + actives[i] * VOLCANO_WIDTH)))
					continue;
				hitTimeout = HIT_TIMEOUT;
				hero.health--;
				if (hero.health == 0)
					hero.kill();
				break;
			}
		}

		private function setVolcanos():void
		{
			volcanoData = [];

			var times:int = int((this.mapTime - BASE_TIME) / VOLCANO_TOTAL_TIME);
			for (var i:int = 0; i < times; i++)
			{
				var ids:Array = [];
				for (var j:int = 0; j < VOLCANO_COUNT; j++)
					ids.push(j);

				var array:Array = [];
				var count:int = Math.min(VOLCANO_COUNT - 1, START_COUNT + i / STEP_INCREASE_COUNT);
				while (array.length < count)
					array.push(ids.splice(int(Math.random() * ids.length), 1));
				volcanoData.push(array);
			}
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'volcanoData': volcanoData}));
		}

		private function get activeIds():Array
		{
			if (volcanoData == null)
				return [];
			var id:int = this.volcanoTimer / VOLCANO_TOTAL_TIME;
			if (volcanoData.length <= id)
				return [];
			return volcanoData[id];
		}

		private function onTime():void
		{
			if (this.gameState != PacketServer.ROUND_START)
				return;

			if (this.startTimer < BASE_TIME)
			{
				this.startTimer++;
				return;
			}

			var state:int = this.volcanoTimer % VOLCANO_TOTAL_TIME;
			switch (state)
			{
				case VOLCANO_PREPARE:
					var actives:Array = this.activeIds;
					for (var i:int = 0; i < actives.length; i++)
						this.views[actives[i]].prepare();
					GameSounds.play("volcano_prepare");
					break;
				case VOLCANO_ACTIVE:
					isDamage = true;

					actives = this.activeIds;
					for (i = 0; i < actives.length; i++)
						this.views[actives[i]].active();
					GameSounds.play("volcano_active2");
					break;
				case VOLCANO_DEACTIVE:
					isDamage = false;

					actives = this.activeIds;
					for (i = 0; i < actives.length; i++)
						this.views[actives[i]].deactive();
					break;
			}
			this.volcanoTimer++;
		}
	}
}
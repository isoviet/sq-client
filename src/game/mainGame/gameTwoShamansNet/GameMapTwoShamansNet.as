package game.mainGame.gameTwoShamansNet
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.Portals;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.editor.RedShamanBody;
	import game.mainGame.entity.simple.PortalBB;
	import game.mainGame.entity.simple.PortalBBDirected;
	import game.mainGame.entity.simple.PortalBR;
	import game.mainGame.entity.simple.PortalBRDirected;
	import game.mainGame.entity.simple.PortalBlue;
	import game.mainGame.entity.simple.PortalBlueDirected;
	import game.mainGame.entity.simple.PortalRB;
	import game.mainGame.entity.simple.PortalRBDirected;
	import game.mainGame.entity.simple.PortalRR;
	import game.mainGame.entity.simple.PortalRRDirected;
	import game.mainGame.entity.simple.PortalRed;
	import game.mainGame.entity.simple.PortalRedDirected;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.gameNet.GameMapNet;

	import protocol.Connection;
	import protocol.PacketClient;

	public class GameMapTwoShamansNet extends GameMapNet
	{
		public var redShamanPortals:Portals = new Portals();
		public var blueShamanPortals:Portals = new Portals();

		public function GameMapTwoShamansNet(game:SquirrelGame):void
		{
			super(game);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			this.redShamanPortals.doTeleport();
			this.blueShamanPortals.doTeleport();
		}

		override public function clear():void
		{
			if (this.redShamanPortals)
				this.redShamanPortals.reset();
			if (this.blueShamanPortals)
				this.blueShamanPortals.reset();

			super.clear();
		}

		override public function dispose():void
		{
			super.dispose();

			this.redShamanPortals = null;
			this.blueShamanPortals = null;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
			var index:int;

			index = this.shamanTools.indexOf(EntityFactory.getId(PortalBlue));
			if (index != -1)
			{
				this.shamanTools.splice(index, 1);
				this.shamanTools.push(EntityFactory.getId(PortalBB));
				this.shamanTools.push(EntityFactory.getId(PortalBR));
			}

			index = this.shamanTools.indexOf(EntityFactory.getId(PortalRed));
			if (index != -1)
			{
				this.shamanTools.splice(index, 1);
				this.shamanTools.push(EntityFactory.getId(PortalRB));
				this.shamanTools.push(EntityFactory.getId(PortalRR));
			}

			index = this.shamanTools.indexOf(EntityFactory.getId(PortalBlueDirected));
			if (index != -1)
			{
				this.shamanTools.splice(index, 1);
				this.shamanTools.push(EntityFactory.getId(PortalBBDirected));
				this.shamanTools.push(EntityFactory.getId(PortalBRDirected));
			}

			index = this.shamanTools.indexOf(EntityFactory.getId(PortalRedDirected));
			if (index != -1)
			{
				this.shamanTools.splice(index, 1);
				this.shamanTools.push(EntityFactory.getId(PortalRBDirected));
				this.shamanTools.push(EntityFactory.getId(PortalRRDirected));
			}
		}

		public function get redShamansPosition():Vector.<b2Vec2>
		{
			var players:Array = get(RedShamanBody);

			var positions:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for each (var player:IGameObject in players)
				positions.push(player.position);

			return positions;
		}

		public function get blueShamansPosition():Vector.<b2Vec2>
		{
			return shamansPosition;
		}

		override protected function onHollow(e:HollowEvent):void
		{
			Logger.add("GameMapTwoShamansNet.onHollow", this.isBrokenWorld);
			if (this.isBrokenWorld)
			{
				Connection.sendData(PacketClient.PING, 3);
				Connection.sendData(PacketClient.LEAVE);
				return;
			}

			Connection.sendData(PacketClient.ROUND_HOLLOW, e.hollowType);
		}
	}
}
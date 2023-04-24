package game.mainGame.entity.editor
{
	import flash.utils.setTimeout;

	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;

	import game.mainGame.entity.ILandSound;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import particles.Explode;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterSprite;
	import utils.starling.utils.StarlingConverter;

	public class PlatformGlassBlock extends PlatformBlockBody implements ISensor, ILandSound
	{
		private var destroyed:Boolean = false;

		public function PlatformGlassBlock():void
		{
			super();

			this.friction = 0.3;
			this.density = 0.8;

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function get landSound():String
		{
			return "glass";
		}

		override public function dispose():void
		{
			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			super.dispose();
		}

		public function beginContact(contact:b2Contact):void
		{}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			if (this.destroyed)
				return;

			if (impulse.normalImpulses[0] < 1500)
				return;

			if (!(this.gameInst && this.gameInst.squirrels.isSynchronizing))
				return;

			this.destroyed = true;

			var worldManifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(worldManifold);

			commandDestroy(worldManifold.m_points[0], this.gameInst.gravity, impulse.normalImpulses[0]);
		}

		override protected function initPlatformBD():void
		{
			this.platform = new GlassBlock;
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new GlassBlock());
		}

		override protected function draw():void
		{
			super.draw();
		}

		private function playAnimation(point:b2Vec2, gravity:b2Vec2, impulse:Number):void
		{
			var piecesSprite:StarlingAdapterSprite = new StarlingAdapterSprite();
			for (var i:int = 0; i < _width / this.blockWidth; i++) {
				for (var j:int = 0; j < _height / this.blockHeight; j++)
				{
					var blockPieces: StarlingAdapterSprite = StarlingConverter.splitMClipToSprite(new GlassBlockPieces());
						blockPieces.x += i * this.blockWidth;
						blockPieces.y += j * this.blockHeight;
						piecesSprite.addChildStarling(blockPieces);
				}
			}

			addChildStarling(piecesSprite);
			Explode.explodeBody(piecesSprite, point, gravity, impulse);
		}

		private function commandDestroy(point:b2Vec2, gravity:b2Vec2, impulse:Number):void
		{
			if (this.gameInst is SquirrelGameEditor)
				setTimeout(destroy, 0, point, gravity, impulse);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'destroyGlass': [this.id, [point.x, point.y], [gravity.x, gravity.y], impulse]}));
		}

		private function destroy(point:b2Vec2, gravity:b2Vec2, impulse:Number):void
		{
			playAnimation(point, gravity, impulse);
			if (!this.gameInst)
				return;

			this.gameInst.map.remove(this, true);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;
			if ('destroyGlass' in data)
			{
				if (data['destroyGlass'][0] != this.id)
					return;

				destroy(new b2Vec2(data['destroyGlass'][1][0], data['destroyGlass'][1][1]), new b2Vec2(data['destroyGlass'][2][0], data['destroyGlass'][2][1]), data['destroyGlass'][3]);
			}
		}
	}
}
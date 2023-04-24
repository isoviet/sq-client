package syncronize
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import game.mainGame.GameMap;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSync;
	import protocol.packages.server.PacketRoundSynchronizer;
	import protocol.packages.server.structs.PacketRoundSyncInfo;

	public class SyncCollection {
		static private const SYNC_DELAY:int = 10 * 1000;

		private var syncTimer:Timer = new Timer(SYNC_DELAY);
		private var diffQueue:Vector.<ISyncObject> = new Vector.<ISyncObject>();
		private var map:GameMap;
		private var _doSync:Boolean = false;
		private var syncObjectCollection: SyncObjectCollection;

		public function SyncCollection(map:GameMap):void {
			this.map = map;
			this.syncTimer.addEventListener(TimerEvent.TIMER, onTimer);
			syncObjectCollection = new SyncObjectCollection();

			Connection.listen(onPacket, [PacketRoundSync.PACKET_ID, PacketRoundSynchronizer.PACKET_ID]);
		}

		public function get doSync():Boolean {
			return this._doSync;
		}

		public function set doSync(value:Boolean):void {
			this._doSync = value;

			if (value)
				return;

			stopSync();
		}

		public function register(object:ISyncObject):void {
			syncObjectCollection.add(object);
		}

		public function remove(id:int):void {
			syncObjectCollection.remove(id);
		}

		public function startSync():void {
			if (!this._doSync)
				return;

			Logger.add("SYNC start");
			this.syncTimer.reset();
			this.syncTimer.start();
		}

		public function stopSync():void {
			Logger.add("SYNC stop");
			this.syncTimer.stop();
		}

		public function reset():void {
			Logger.add("SYNC reset");
			this.diffQueue = new Vector.<ISyncObject>();
			syncObjectCollection.reset();
		}

		public function update():void {
			var gameObjects: Array = map.gameObjects();

			while (this.diffQueue.length != 0) {
				var object:ISyncObject = this.diffQueue.shift();
				syncObjectCollection.syncObjects(object, gameObjects);
			}
		}

		private function sendDiffs():void {
			if (this.map.isBrokenWorld) {
				Connection.sendData(PacketClient.PING, 3);
				Connection.sendData(PacketClient.LEAVE);
				return;
			}

			var data:Array = [];

			for each (var diffObject:ISyncObject in syncObjectCollection.syncObjectsPool)
				data.push(diffObject.id, diffObject.position.x, diffObject.position.y, diffObject.angle, diffObject.linearVelocity.x, diffObject.linearVelocity.y, diffObject.angularVelocity);

			if (data.length > 0)
				Connection.sendData(PacketClient.ROUND_SYNC, PacketClient.SYNC_ALL, data);
		}

		private function onTimer(e:TimerEvent):void {
			sendDiffs();
		}

		private function buildDiff(syncId:int, objects:Vector.<PacketRoundSyncInfo>):void {
			for (var i:int = 0; i < objects.length; i++) {
				var data:Array = [
					objects[i].objectId,
					objects[i].posX,
					objects[i].posY,
					objects[i].angle,
					objects[i].angular,
					objects[i].velX,
					objects[i].velY
				];

				this.diffQueue.push(new SyncPacketParser(data, syncId));
			}
		}

		private function onPacket(packet:AbstractServerPacket):void {
			switch (packet.packetId) {
				case PacketRoundSync.PACKET_ID:
					var sync: PacketRoundSync = packet as PacketRoundSync;
					buildDiff(sync.playerId, sync.info);
					break;
				case PacketRoundSynchronizer.PACKET_ID:
					this.doSync = (packet as PacketRoundSynchronizer).playerId == Game.selfId;
					break;
			}
		}
	}
}
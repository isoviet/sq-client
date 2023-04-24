package syncronize
{
	import game.mainGame.entity.simple.GameBody;

	public class SyncObjectCollection {
		private var _syncObjectsPool:Array = [];

		public function add(object:ISyncObject):void {
			if (exist(object))
				return;

			this._syncObjectsPool.push(object);
		}

		public function get syncObjectsPool(): Array {
			return _syncObjectsPool;
		}

		public function syncObjects(object: ISyncObject, gameObjectCollection: Array): Boolean {
			if (!object || !object.id)
				return false;

			var item: GameBody = gameObjectCollection[object.id] as GameBody;
			if (item && object) {
				if (!GameBody(item).hasOwnProperty('syncObject'))
					return false;

				var syncObj: SyncGameBody = (item as GameBody).syncObject;

				if (syncObj != null) {
					if (syncObj.personalId != 0 && syncObj.personalId != object.personalId)
						return false;
					syncObj.sync(object);
					return true;
				}
			}
			return false;
		}

		private function exist(object:ISyncObject): Boolean {
			return this._syncObjectsPool.indexOf(object) != -1;
		}

		public function remove(id: int): void {
			for each (var obj:ISyncObject in this._syncObjectsPool) {
				if (obj.id != id)
					continue;
				this._syncObjectsPool.splice(this._syncObjectsPool.indexOf(obj), 1);
				break;
			}
		}

		public function reset(): void {
			for each (var syncObject:ISyncObject in this._syncObjectsPool)
				syncObject.dispose();

			_syncObjectsPool = [];
		}
	}
}
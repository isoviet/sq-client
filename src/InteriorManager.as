package
{
	import flash.events.EventDispatcher;

	import events.GameEvent;
	import footers.FooterTop;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketDecorations;

	public class InteriorManager
	{
		static private var _previewId:int = -1;

		static private var currentInterior:Object = {};
		static private var decorations:Vector.<int> = new <int>[];

		static private var loaded:Boolean = false;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static public function init():void
		{
			Connection.listen(onPacket, PacketDecorations.PACKET_ID);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function haveDecoration(id:int):Boolean
		{
			return decorations.indexOf(id) != -1;
		}

		static public function set previewId(value:int):void
		{
			_previewId = value;

			dispatcher.dispatchEvent(new GameEvent(GameEvent.INTERIOR_CHANGE));
		}

		static public function get previewId():int
		{
			return _previewId;
		}

		static public function getSetAvailable(decoration:int):Boolean
		{
			var type:int = InteriorData.getType(decoration);

			switch (type)
			{
				case InteriorData.CURTAINS:
					if (!(InteriorData.WINDOW in currentInterior) || currentInterior[InteriorData.WINDOW] == -1)
						return false;
					break;
				case InteriorData.VASE:
					if (!(InteriorData.TABLE in currentInterior) || currentInterior[InteriorData.TABLE] == -1)
						return false;
					break;
			}

			return true;
		}

		static public function getHideAvailable(decoration:int):Boolean
		{
			var type:int = InteriorData.getType(decoration);

			switch (type)
			{
				case InteriorData.WALLPAPER:
				case InteriorData.FLOOR:
				case InteriorData.RACK:
				case InteriorData.CHAIR:
					return false;
				case InteriorData.WINDOW:
					if (InteriorData.CURTAINS in currentInterior && currentInterior[InteriorData.CURTAINS] != -1)
						return false;
					break;
				case InteriorData.TABLE:
					if (InteriorData.VASE in currentInterior && currentInterior[InteriorData.VASE] != -1)
						return false;
					break;
			}
			return true;
		}

		static public function loadSelf():void
		{
			if (loaded)
				return;
			loaded = true;

			var type:int;
			for (var i:int = 0; i < Game.self['interior'].length; i++)
			{
				type = InteriorData.getType(Game.self['interior'][i]);
				if (type in currentInterior)
				{
					var removedIndex:int = Game.self['interior'].indexOf(currentInterior[type]);
					Game.self['interior'].splice(removedIndex, 1);
					Connection.sendData(PacketClient.INTERIOR_CHANGE, [currentInterior[type], 0]);
				}

				currentInterior[type] = Game.self['interior'][i];
			}

			FooterTop.loadTapeInterior();
		}

		static public function setDecoration(newDecoration:int):void
		{
			var type:int = InteriorData.getType(newDecoration);

			if (currentInterior[type] == newDecoration)
				return;

			var changeArray:Array = [newDecoration, 1];

			var oldDecoration:int = (type in currentInterior ? currentInterior[type] : -1);
			if (oldDecoration != -1)
			{
				var oldIndex:int = Game.self['interior'].indexOf(oldDecoration);
				Game.self['interior'].splice(oldIndex, 1);
				changeArray = changeArray.concat([oldDecoration, 0]);
			}

			currentInterior[type] = newDecoration;
			Game.self['interior'].push(newDecoration);
			Connection.sendData(PacketClient.INTERIOR_CHANGE, changeArray);

			dispatcher.dispatchEvent(new GameEvent(GameEvent.INTERIOR_CHANGE));
		}

		static public function hideDecoration(decoration:int):void
		{
			var type:int = InteriorData.getType(decoration);

			if (currentInterior[type] != decoration)
				return;

			currentInterior[type] = -1;
			var oldIndex:int = Game.self['interior'].indexOf(decoration);
			Game.self['interior'].splice(oldIndex, 1);

			Connection.sendData(PacketClient.INTERIOR_CHANGE, [decoration, 0]);

			dispatcher.dispatchEvent(new GameEvent(GameEvent.INTERIOR_CHANGE));
		}

		static private function onPacket(packet:PacketDecorations):void
		{
			decorations = decorations.concat(packet.decorationId);
			dispatcher.dispatchEvent(new GameEvent(GameEvent.INTERIOR_CHANGE));
		}
	}
}
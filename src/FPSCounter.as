package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	import screens.ScreenGame;

	import protocol.Connection;
	import protocol.PacketClient;

	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class FPSCounter extends Sprite
	{
		static private var _instance:FPSCounter;

		private static var groups: Array = [];
		private static var groups_info: Array = [0, 10, 20, 30];
		private static var sended_avg_group: Array = [];
		private static var sended_bad_group: Array = [];
		static private const RANGES:Array = [0, 15, 25];
		static private const MAP_IDS:Array = [];
		static private var bad_fps_groups:Array =
		[
		 0,
		 5,
		 10,
		 20,
		 30,
		 40,
		 50,
		 60,
		 70,
		 80,
		 90
		];

		private var field:GameField = new GameField("FPS: 0", 0, 0, new TextFormat(null, 14, 0x000000));
		private var lastUpdate:int = 0;
		private var graphSprite:Shape = new Shape();
		private var graphSprite2:Shape = new Shape();
		private var clearCount:int = 0;

		private var lastFps:int = 0;
		private var stageHasFocus:Boolean = false;

		private var statCounters:Array = null;

		private var fpsDauSended:Object = {};

		public function FPSCounter():void
		{
			_instance = this;
			this.y = 200;
			addChild(this.graphSprite2);
			addChild(this.graphSprite);
			addChild(this.field);
			clearGraph();
			addEventListener(MouseEvent.MOUSE_UP, dragStop);
			addEventListener(MouseEvent.MOUSE_DOWN, dragStart);
			Game.gameSprite.addChild(this);

			this.visible = false;

			Game.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			try
			{
				ExternalInterface.call("eval", "var obj = swfobject.getObjectById(\"flash-app\");obj.addEventListener('focus', function(e){obj.hasFocus(true);},false);obj.addEventListener('blur', function(e){obj.hasFocus(false);},false);");
				ExternalInterface.addCallback("hasFocus", hasFocus);
			}
			catch (e:Error)
			{}
		}

		private static function reduce(array: Array): Number {
			var result: Number = 0;

			for (var i: int = 0, j: int = array.length; i < j; i++) {
				result += Number(array[i]);
			}
			return result;
		}

		private static function reduceNormalize(array: Array): Number {
			var result: Number = 0;

			for (var i: int = 0, j: int = array.length; i < j; i++) {
				result += Number(array[i]) * i;
			}
			return result;
		}

		private static function get_group(dt: Number): int
		{
			var fps: Number = 1000.0 / dt;
			var group: int = 0;

			for (var i: int = groups_info.length - 1; i >= 0; --i)
			{
				var current_fps: int = groups_info[i];

				if (current_fps > fps)
					continue;

				group = i;
				break;
			}

			return group;
		}

		private static function get_bad_fps_group(percent: Number): int
		{
			 percent *= 100;

			 var rounded_percent: int = 0;

			 for (var i: int = bad_fps_groups.length - 1; i >= 0; --i)
			 {
				var current_percent: int = bad_fps_groups[i];
				if (current_percent > percent)
					continue;

					rounded_percent = current_percent;
					break;
			 }

			 return rounded_percent;
		}

		public static function sendAlterAnalytics(): void {
			calculateAVG();
		}

		private static function calculateAVG(): void {
			var sum: Number = reduce(groups);
			if (sum == 0)
				return ;

			var normalized: Array = groups.map(function (item:*, index: int, array: Array) : Number
			{
				if (index || array) {/*unused*/}

				return Number(item) / sum;
			});

			var avg: Number = reduceNormalize(normalized);
			var rounded_avg: int = Math.round(avg);
			var bad_percent: int = get_bad_fps_group(normalized[0]);

			if (sended_avg_group.indexOf(rounded_avg) == -1) {
				sended_avg_group.push(rounded_avg);
				Analytics.fpsAVG(rounded_avg);
			}

			if (sended_bad_group.indexOf(bad_percent) == -1) {
				sended_bad_group.push(bad_percent);
				Analytics.fpsMIN(bad_percent);
			}
		}

		static public function addMark(color:int):void
		{
			var graphX:int = getTimer() / 1000 * 100 % Config.GAME_WIDTH;

			_instance.graphSprite2.graphics.lineStyle(1, color);
			_instance.graphSprite2.graphics.drawRect(graphX, 0, 0, 50);
		}

		static public function get count():int
		{
			return _instance.lastFps;
		}

		static public function startStat():void
		{
			groups = [0, 0, 0, 0];
			_instance.statCounters = new Array(RANGES.length);
			for (var i:int = 0; i < RANGES.length; i++)
				_instance.statCounters[i] = 0;
		}

		static public function sendStat(mapId:int):void
		{
			if (!_instance.statCounters)
				return;

			var maxCount:int = 0;
			var statResult:int = 0;
			for (var i:int = 0; i < RANGES.length; i++)
			{
				if (maxCount >= _instance.statCounters[i])
					continue;

				maxCount = _instance.statCounters[i];
				statResult = i;
			}

			CONFIG::release{
				if (maxCount != 0)
				{
					if (MAP_IDS.indexOf(mapId) != -1)
					{
						var mapStat:Number = mapId << 8;
						mapStat = (mapStat | ScreenGame.location) << 8;
						mapStat = mapStat | statResult;
						Connection.sendData(PacketClient.COUNT, PacketClient.FPS_MAP, mapStat);
					}

					var locationStat:uint = ScreenGame.location << 8;
					locationStat = locationStat | statResult;

					Connection.sendData(PacketClient.COUNT, PacketClient.FPS_ROUND, statResult);
					Connection.sendData(PacketClient.COUNT, PacketClient.FPS_LOCATION, locationStat);

					if (!(statResult in _instance.fpsDauSended))
					{
						_instance.fpsDauSended[statResult] = 1;
						Analytics.fpsDAU(statResult);
					}
				}
			}

			_instance.statCounters = null;
		}

		private function hasFocus(value:Boolean):void
		{
			this.stageHasFocus = value;
		}

		public static function onEnterFrameStarling(dt: Number): void {
			var group: Number = get_group(dt * 1000);
			groups[group] += dt;
		}

		private function onEnterFrame(e:Event):void
		{
			this.graphSprite.graphics.lineStyle(1, this.stageHasFocus ? 0xFF0000 : 0xC0C0C0);

			var curTime:int = getTimer();
			update(curTime - this.lastUpdate);
			this.lastUpdate = getTimer();
			if (!this.visible)
				return;
			Game.gameSprite.addChild(this);

		}

		private function update(time:int):void
		{
			var fps:int = 1000 / time;
			if (this.visible)
				this.field.text = "FPS: " + fps + " Time:" + time;

			var graphX:int = getTimer() / 1000 * 100;
			if (graphX > Config.GAME_WIDTH * (this.clearCount + 1))
			{
				clearGraph();
				this.clearCount++;
			}

			this.graphSprite.graphics.lineTo(graphX % Config.GAME_WIDTH, -((fps + this.lastFps) / 2) + 50);
			this.lastFps = fps;

			countStat(fps);
		}

		private function clearGraph():void
		{
			this.graphSprite.graphics.clear();
			this.graphSprite2.graphics.clear();
			this.graphSprite.graphics.beginFill(0xC0C0C0, 0.5);
			this.graphSprite.graphics.drawRect(0, 0, Config.GAME_WIDTH, 50);
			this.graphSprite.graphics.endFill();
			this.graphSprite.graphics.lineStyle(1, 0xFF0000);
			this.graphSprite.graphics.moveTo(0, 50);
		}

		private function dragStop(e:Event):void
		{
			this.stopDrag();
		}

		private function dragStart(e:Event):void
		{
			this.startDrag(false, new Rectangle(0, 0, 0, 690));
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.F || !e.ctrlKey)
				return;

			this.visible = !this.visible;
			try {
				Game.starling.showStats = !Game.starling.showStats;

				if (Game.starling.showStats && CONFIG::debug)
					Game.starling.showStatsAt(HAlign.LEFT, VAlign.CENTER);

			} catch (e: Error) {
				Logger.add("starling showStats error: ");
			}
		}

		private function countStat(fps:int):void
		{
			if (!this.statCounters || !this.stageHasFocus)
				return;

			for (var i:int = 0; i < RANGES.length; i++)
			{
				if (i == RANGES.length - 1 || fps < RANGES[i + 1])
				{
					this.statCounters[i]++;
					break;
				}
			}
		}
	}
}
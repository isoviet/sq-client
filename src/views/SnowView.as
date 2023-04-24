package views
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	import utils.starling.StarlingAdapterSprite;

	public class SnowView extends StarlingAdapterSprite
	{
		static public const DEFAULT_MODE:int = 0;
		static public const NEW_YEAR_MODE:int = 6;

		static private var _instance:SnowView = null;

		private var _windX:Number = 1;
		private var _windY:Number = 1;

		private var newWindX:Number = 0;
		private var deltaX:Number = 0;

		private var snowGenerateTimer:Timer = new Timer(2000);
		private var snowGenerateRareTimer:Timer = new Timer(2000);

		private var changeWindTimer:Timer = new Timer(20 * 1000, 1);
		private var deltaTimer:Timer = new Timer(30);

		private var mode:int = 0;

		private var activationArray:Array = [];

		private var frequentlyArray:Object = {};
		private var rareArray:Object = {};

		private var initedFlakes:Boolean = false;

		public function SnowView():void
		{
			super();

			this.mouseChildren = false;
			this.mouseEnabled = false;

			_instance = this;
		}

		static public function start(mode:int, playerId:int):void
		{
			if (!_instance)
				return;

			_instance.start(mode, playerId);
		}

		static public function stop(mode:int, playerId:int):void
		{
			if (!_instance)
				return;

			_instance.stop(mode, playerId);
		}

		static public function fullStop(mode:int = 0, all:Boolean = false):void
		{
			if (_instance == null)
				return;

			if (!all)
			{
				var newArray:Array = [];
				for (var i:int = 0; i < _instance.activationArray.length; i++)
				{
					if (_instance.activationArray[i]['mode'] == mode)
						continue;

					newArray.push(_instance.activationArray[i]);
				}

				_instance.activationArray = newArray;

				if (_instance.activationArray.length != 0)
				{
					_instance.mode = _instance.activationArray[_instance.activationArray.length - 1];
					return;
				}
			}
			else
				_instance.activationArray = [];

			_instance.stopAnimation();
		}

		public function get windX():Number
		{
			return this._windX;
		}

		public function set windX(value:Number):void
		{
			this._windX = value;
		}

		public function get windY():int
		{
			return this._windY;
		}

		public function set windY(value:int):void
		{
			this._windY = value;
		}

		public function start(mode:int, playerId:int):void
		{
			var isPlayed:Boolean = (this.activationArray.length != 0);

			this.activationArray.push({'mode': mode, 'playerId': playerId});
			this.mode = mode;

			if (isPlayed)
				return;

			if (!this.initedFlakes)
			{
				initFlakes();
				this.initedFlakes = true;
			}

			this.snowGenerateTimer.reset();
			this.snowGenerateTimer.start();

			this.changeWindTimer.reset();
			this.changeWindTimer.start();

			setTimeout(startSnowRareTimer, 500);
		}

		private function startSnowRareTimer():void
		{
			this.snowGenerateRareTimer.reset();
			this.snowGenerateRareTimer.start();
		}

		public function stop(mode:int, playerId:int):void
		{
			if (this.activationArray.length == 0)
				return;

			for (var i:int = this.activationArray.length - 1; i >= 0; i--)
				if ((this.activationArray[i]['playerId'] == playerId) && (this.activationArray[i]['mode'] == mode))
				{
					this.activationArray.splice(i, 1);
				}

			if (this.activationArray.length != 0)
			{
				this.mode = this.activationArray[this.activationArray.length - 1]['mode'];
				return;
			}

			stopAnimation();
		}

		private function init():void
		{
			this.snowGenerateTimer.addEventListener(TimerEvent.TIMER, snowGenerator);
			this.snowGenerateRareTimer.addEventListener(TimerEvent.TIMER, snowGenerator2);
			this.changeWindTimer.addEventListener(TimerEvent.TIMER_COMPLETE, changeWind);
			this.deltaTimer.addEventListener(TimerEvent.TIMER, deltaWind);
		}

		private function initFlakes():void
		{
			init();

			this.rareArray[NEW_YEAR_MODE] = [NewYearFlakeImage];
			this.frequentlyArray[NEW_YEAR_MODE] = [NewYearFlakeImage];
		}

		private function stopAnimation():void
		{
			this.snowGenerateTimer.stop();
			this.snowGenerateRareTimer.stop();
			this.changeWindTimer.stop();

			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);
		}

		private function snowGenerator(e:TimerEvent):void
		{
			var flakeImage:StarlingAdapterSprite;
			switch (this.mode)
			{
				case SnowView.DEFAULT_MODE:
					return;
				default:
					flakeImage = new StarlingAdapterSprite(new frequentlyArray[this.mode][int(Math.random() * frequentlyArray[this.mode].length)]());
			}

			flakeImage.rotation = Math.random() * 360;
			var flake:SnowFlake = new SnowFlake(this, flakeImage);
			flake.x = -30 + Math.random() * (Config.GAME_WIDTH + 30);
			flake.y = -30;
			addChildStarling(flake);
		}

		private function snowGenerator2(e:TimerEvent):void
		{
			var flakeImage:StarlingAdapterSprite;
			switch (this.mode)
			{
				case SnowView.DEFAULT_MODE:
					return;
				default:
					flakeImage = new StarlingAdapterSprite(new this.rareArray[this.mode][int(Math.random() * this.rareArray[this.mode].length)]());
			}

			flakeImage.rotation = Math.random() * 360;
			var flake:SnowFlake = new SnowFlake(this, flakeImage);
			flake.x = -30 + Math.random() * (Config.GAME_WIDTH + 30);
			flake.y = -30;
			addChildStarling(flake);
		}

		private function changeWind(e:TimerEvent):void
		{
			this.newWindX = Math.random() * 2 - Math.random() * 2;
			this.deltaX = (this.newWindX - this._windX) / (50 + Math.random() * 20);

			this.deltaTimer.reset();
			this.deltaTimer.start();
		}

		private function deltaWind(e:TimerEvent):void
		{
			this.windX += this.deltaX;

			if (Math.round(this.windX * 10) / 10 == Math.round(this.newWindX * 10) / 10)
			{
				this.deltaTimer.stop();
				this.changeWindTimer.reset();
				this.changeWindTimer.start();
			}
		}
	}
}
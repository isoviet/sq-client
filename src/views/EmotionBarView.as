package views
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import events.GameEvent;
	import game.gameData.EmotionManager;
	import game.gameData.GameConfig;
	import loaders.RuntimeLoader;
	import statuses.Status;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.BitmapClip;

	public class EmotionBarView extends Sprite
	{
		static public var _emotionButtons:Array = null;
		static private const WIDTH_MAX:int = 10;

		private var newButtons:Array = [];
		private var newView:Sprite = new Sprite();

		private var _hero:Hero;

		static public function isBoughtPack(id:int):Boolean
		{
			var smiles:Array = GameConfig.getSmilesElements(id);
			for (var i:int = 0; i < smiles.length; i++)
			{
				if (EmotionManager.smiles.indexOf(smiles[i]) != -1)
					continue;
				return false;
			}
			return true;
		}

		static public function get emotionButtons():Array
		{
			if (!_emotionButtons)
				_emotionButtons = [
					{'btn': MovieSmile7, 'image':ImageSmile7, 'frame': 16},
					{'btn': MovieSmile0, 'image':ImageSmile0, 'frame': 11},
					{'btn': MovieSmile3, 'image':ImageSmile3, 'frame': 55},
					{'btn': MovieSmile6, 'image':ImageSmile6, 'frame': 31, 'shift': -10},
					{'btn': MovieSmile1, 'image':ImageSmile1, 'frame': 42},
					{'btn': MovieSmile2, 'image':ImageSmile2, 'frame': 37, 'shift': -10},
					{'btn': MovieSmile5, 'image':ImageSmile5, 'frame': 24},
					{'btn': MovieSmile9, 'image':ImageSmile9, 'frame': 41},
					{'btn': MovieSmile4, 'image':ImageSmile4, 'frame': 41},
					{'btn': MovieSmile8, 'image':ImageSmile8, 'frame': 24},
					//Пасха
					{'btn': EasterSmile0, 'frame': 11},
					{'btn': EasterSmile1, 'frame': 16, 'shift': -9},
					{'btn': EasterSmile2, 'frame': 22},
					{'btn': EasterSmile3, 'frame': 21},
					{'btn': EasterSmile4, 'frame': 22},
					//Новый год
					{'btn': NewYearSmile4, 'frame': 11},
					{'btn': NewYearSmile2, 'frame': 16},
					{'btn': NewYearSmile6, 'frame': 21},
					{'btn': NewYearSmile0, 'frame': 16, 'shift': -9},
					{'btn': NewYearSmile9, 'frame': 9},
					{'btn': NewYearSmile8, 'frame': 52, 'shift': -7},
					{'btn': NewYearSmile5, 'frame': 14},
					{'btn': NewYearSmile7, 'frame': 24},
					{'btn': NewYearSmile3, 'frame': 22},
					{'btn': NewYearSmile1, 'frame': 16},
					//дополнительные 25
					{'btn': MovieSmile10, 'image':ImageSmile10, 'frame': 24},
					{'btn': MovieSmile11, 'image':ImageSmile11, 'frame': 14},
					{'btn': MovieSmile12, 'image':ImageSmile12, 'frame': 50},
					{'btn': MovieSmile13, 'image':ImageSmile13, 'frame': 28}
				];
			return _emotionButtons;
		}

		public function EmotionBarView():void
		{
			EmotionManager.addEventListener(GameEvent.SMILES_CHANGED, onChange);

			addChild(this.newView);
			if (EmotionManager.smiles.length == 0)
				return;
			RuntimeLoader.load(function():void
			{
				fillSmiles();
			}, true);
		}

		public function get hero():Hero
		{
			return this._hero;
		}

		public function set hero(value:Hero):void
		{
			this._hero = value;
		}

		public function fillSmiles():void
		{
			while (this.newView.numChildren > 0)
				this.newView.removeChildAt(0);

			this.newButtons.splice(0);

			for (var i:int = 0; i < emotionButtons.length; i++)
			{
				if (EmotionManager.smiles.indexOf(i) == -1)
					continue;
				var movieButton:Sprite = new Sprite();
				var movie:MovieClip;

				if("image" in emotionButtons[i])
				{
					movie = new emotionButtons[i]['image'];
					movie.stop();
				}
				else
				{
					movie = new emotionButtons[i]['btn'];
					movie.gotoAndStop(emotionButtons[i]['frame']);
				}

				movieButton.name = i.toString();
				movieButton.addChild(BitmapClip.replace(movie));
				movieButton.graphics.beginFill(0x000000, 0);
				movieButton.graphics.drawCircle(0, 0, 25);
				movieButton.x = 25 + (this.newButtons.length % WIDTH_MAX) * 40;
				movieButton.y = 15 + 40 * int(this.newButtons.length / WIDTH_MAX);
				movieButton.scaleX = movieButton.scaleY = 0.9;
				movieButton.buttonMode = true;
				new Status(movieButton, EmotionManager.NAMES[i]);
				movieButton.addEventListener(MouseEvent.CLICK, setEmotion);
				this.newView.addChild(movieButton);
				this.newButtons.push(movieButton);
			}

			var emotionsBG:CommonToolbarBG = new CommonToolbarBG();
			emotionsBG.width = 10 + Math.min(this.newButtons.length, WIDTH_MAX) * 40;
			emotionsBG.height = 40 * int((this.newButtons.length - 1) / WIDTH_MAX + 1);
			emotionsBG.y = -5;
			this.newView.addChildAt(emotionsBG, 0);

			this.newView.x = (WIDTH_MAX - Math.min(this.newButtons.length, WIDTH_MAX)) * 20;
			this.newView.y = -40 * int((this.newButtons.length - 1) / WIDTH_MAX);
		}

		private function onChange(e:GameEvent):void
		{
			if (EmotionManager.smiles.length == 0)
				return;
			RuntimeLoader.load(function():void
			{
				fillSmiles();
			}, true);
		}

		private function setEmotion(e:MouseEvent):void
		{
			if (!this.hero || this.hero.isDead)
				return;

			for (var i:int = 0; i < this.newButtons.length; i++)
			{
				if (e.currentTarget != this.newButtons[i])
					continue;
				this.hero.setEmotion(int(e.currentTarget.name) + Hero.EMOTION_MAX_TYPE);
				Connection.sendData(PacketClient.ROUND_SMILE, int(e.currentTarget.name));
				break;
			}
		}
	}
}
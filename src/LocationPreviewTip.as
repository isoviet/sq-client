package
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import dialogs.Dialog;
	import views.LocationPreview;

	import utils.HtmlTool;

	public class LocationPreviewTip extends Sprite
	{
		static private const FORMAT_TITLE:TextFormat = new TextFormat(null, 11, 0x000000, true);
		static private const FORMAT_VALUE:TextFormat = new TextFormat(null, 11, 0x000000);
		static private const FORMAT_BLOCK:TextFormat = new TextFormat(null, 11, 0xFF0000);

		static private const DELAY:Number = 0.3;

		static private const DATA:Array = [
			{'value': Locations.ISLAND_ID,	'title': gls("Солнечные долины"),	'clip': "LocationIslandsPreview",	'x': 135,	'y': 185,	'description': gls("Солнечные долины, созданные внезапным катаклизмом - идеальное место для молодых белок. Теплая трава и горный снег - лучше не бывает!")},
			{'value': Locations.SWAMP_ID,	'title': gls("Топи"),			'clip': "LocationSwampPreview",		'x': 70,	'y': 110,	'description': gls("Когда-то давно на месте чудесного леса образовалось труднопроходимое, скрывающее в себе опасности болото.")},
			{'value': Locations.DESERT_ID,	'title': gls("Пустыня"),		'clip': "LocationDesertPreview",	'x': 400,	'y': 165,	'description': gls("Только самые смелые белки отправляются в бескрайнюю Пустыню в долгое и рискованное путешествие на поиски сокровищ.")},
			{'value': Locations.ANOMAL_ID,	'title': gls("Аномальная зона"),	'clip': "LocationAnomalZonePreview",	'x': 270,	'y': 235,	'description': gls("Волей злодейки-судьбы метеорит упал прямо на Спасательный шаттл. И на месте корабля образовалась Аномальная зона.")},
			{'value': Locations.STORM_ID,	'title': gls("Шторм"),			'clip': "LocationStormPreview",		'x': 550,	'y': 200,	'description': gls("В самом центре мира белок разбушевался Шторм. Леденящие душу опасности поджидают тебя здесь.")},
			{'value': Locations.HARD_ID,	'title': gls("Испытания"),		'clip': "LocationHardPreview",		'x': 450,	'y': 165,	'description': gls("Отряды самых смелых, умелых и тренированных белок направляются в Испытания, чтобы показать, на что они способны.")},
			{'value': Locations.BATTLE_ID,	'title': gls("Битва"),			'clip': "LocationBattlePreview",	'x': 330,	'y': 230,	'description': gls("Битва — постоянное место обитания настоящих белок-гладиаторов. Девиз участников битвы — «Победа или смерть!».")},
			{'value': Locations.WILD_ID,	'title': gls("Дикие земли"),		'clip': "LocationWildLandsPreview",	'x': 310,	'y': 230,	'description': gls("Тайна Диких земель долго оставалась не раскрытой. Чудовище бесследно исчезло, а маленькие пушистые храбрецы смогли войти в темные недра красных земель.")},
			{'value': Locations.OLYMPIC_ID,	'title': gls("Стадион"),		'clip': "LocationOlympicPreview",	'x': 140,	'y': 270,	'description': gls("Место для олимпийских соревнований закрыто на реконструкцию, чтобы предстать перед белками в новом обличии.")},
			{'value': Locations.SCHOOL_ID,	'title': gls("Школа"),			'clip': "LocationShamanPreview",	'x': 330,	'y': 230,	'description': gls("В школе юные белки проходят обучение магии и шаманству. Освоив магию, сможешь её использовать. Узнав секреты шамана, сможешь вести за собой бельчат.")}
		];

		static public function location(id:int):Object
		{
			for each(var loc:Object in DATA)
				if(loc.value == id)
					return loc;
			return DATA[0];
		}

		static private var id:int = -1;
		static private var timer:Number = 0;

		private var data:Object = {};

		private var owners:Object = null;

		private var currentLocation:int = -1;

		private var fieldName:GameField = null;
		private var fieldDescription:GameField = null;
		private var fieldOnline:GameField = null;
		private var fieldCost:GameField = null;
		private var fieldLevel:GameField = null;

		private var spriteDetails:Sprite = new Sprite();

		private var locationPreview:LocationPreview = null;

		public var blocked:Boolean = false;

		public function LocationPreviewTip(owners:Object):void
		{
			super();

			this.owners = owners;
			this.visible = false;

			init();
		}

		public function updateOnline(online: Vector.<int>):void
		{
			for (var id:* in this.data)
				this.data[id]['online'] = ((id in online) ? online[id] : 0).toString();

			if (this.visible)
				this.fieldOnline.htmlText = HtmlTool.span(this.data[id]['online'], "online");
		}

		private function init():void
		{
			for each(var item:Object in DATA)
				this.data[item['value']] = item;

			if (Config.isEng)
			{
				this.data[Locations.DESERT_ID]['description'] = gls("Надвигается огромная песчаная буря. Доступ в локацию временно закрыт для всех белок.");
				this.data[Locations.ANOMAL_ID]['description'] = gls("Временно недоступно. Обнаружена инопланетная активность. Группа иследователей ведёт работу.");
			}

			for each (var owner:MovieClip in this.owners)
			{
				owner.addEventListener(MouseEvent.MOUSE_OVER, onShow);
				owner.addEventListener(MouseEvent.MOUSE_UP, onShow);
				owner.addEventListener(MouseEvent.MOUSE_OUT, close);
				owner.addEventListener(Event.REMOVED_FROM_STAGE, onOwnerHide);
			}

			var back:DisplayObject = new DialogBaseBackground();
			back.width = 345;
			back.height = 310;
			back.filters = [Dialog.FILTER_SHADOW];
			addChild(back);

			this.locationPreview = new LocationPreview();
			this.locationPreview.x = 15;
			this.locationPreview.y = 40;
			addChild(this.locationPreview);

			this.fieldName = new GameField("", 0, 10, Dialog.FORMAT_CAPTION_18_CENTER);
			this.fieldName.filters = Dialog.FILTERS_CAPTION;
			this.fieldName.width = back.width;
			this.fieldName.multiline = true;
			this.fieldName.wordWrap = true;
			addChild(this.fieldName);

			this.fieldDescription = new GameField("", 15, 200, new TextFormat(null, 14, 0x000000, false, null, null, null, null, "center"));
			this.fieldDescription.width = back.width - 30;
			this.fieldDescription.multiline = true;
			this.fieldDescription.wordWrap = true;
			addChild(this.fieldDescription);

			this.spriteDetails.addChild(new GameField(gls("Онлайн:"), 15, 280, FORMAT_TITLE));
			this.fieldOnline = new GameField("0", 70, 280, FORMAT_VALUE);
			this.spriteDetails.addChild(this.fieldOnline);

			this.spriteDetails.addChild(new GameField(gls("Требуется:"), 120, 280, FORMAT_TITLE));
			this.fieldCost = new GameField("", 190, 280, FORMAT_VALUE);
			this.spriteDetails.addChild(this.fieldCost);

			var image:DisplayObject = new ImageIconEnergy();
			image.scaleX = image.scaleY = 0.6;
			image.x = 210;
			image.y = 280;
			this.spriteDetails.addChild(image);

			this.fieldLevel = new GameField("", 240, 280, FORMAT_VALUE);
			this.spriteDetails.addChild(this.fieldLevel);

			this.spriteDetails.graphics.beginFill(0xFFFFFF, 1);
			this.spriteDetails.graphics.drawRoundRect(68, 280, 40, 16, 5, 5);
			this.spriteDetails.graphics.drawRoundRect(188, 280, 35, 16, 5, 5);
			addChild(this.spriteDetails);

			EnterFrameManager.addListener(onTime);
		}

		private function onShow(e:MouseEvent):void
		{
			if (this.blocked)
				return;

			id = -1;
			for (var key:String in this.owners)
			{
				if (!(key in this.data))
					continue;
				if (this.owners[key] != e.currentTarget)
					continue;
				id = int(key);
				break;
			}
			if (id == -1)
				return;

			if (this.visible && id == this.currentLocation)
				return;

			updateData();

			this.x = this.data[this.currentLocation]['x'];
			this.y = this.data[this.currentLocation]['y'];

			if (e.type == MouseEvent.MOUSE_UP && Game.gameSprite.contains(this))
				Game.gameSprite.removeChild(this);

			if (Game.gameSprite.contains(this))
				return;
			Game.gameSprite.addChild(this);
		}

		private function updateData():void
		{
			if (this.currentLocation == id)
				return;

			this.currentLocation = id;

			this.locationPreview.previewClip = this.data[id]['clip'];

			var location:Location = Locations.getLocation(id);
			var banned:Array = [Locations.SCHOOL_ID, Locations.OLYMPIC_ID];
			if (Config.isEng)
				banned.push(Locations.ANOMAL_ID, Locations.DESERT_ID);
			var enable:Boolean = banned.indexOf(id) == -1;

			this.fieldName.text = this.data[id]['title'];
			this.fieldDescription.text = this.data[id]['description'];

			this.fieldOnline.text = enable ? this.data[id]['online'] : "-";
			this.fieldCost.text = enable ? String(location.cost) : "-";
			this.fieldLevel.text = (location.level == 0) ? gls("Доступно всем") : gls("С {0} уровня", location.level);
			this.fieldLevel.setTextFormat(location.level > Experience.selfLevel ? FORMAT_BLOCK : FORMAT_VALUE);

			if (Config.isEng && (location.id == Locations.DESERT_ID || location.id == Locations.ANOMAL_ID))
				this.fieldLevel.text = gls("В разработке");
		}

		private function onOwnerHide(e:Event):void
		{
			timer = 0;
			id = -1;

			if (!this.visible)
				return;
			close();
		}

		private function close(e:MouseEvent = null):void
		{
			timer = 0;
			id = -1;

			this.visible = false;

			if (!Game.gameSprite.contains(this))
				return;
			Game.gameSprite.removeChild(this);
		}

		private function onTime():void
		{
			if (id == -1)
				return;
			if (timer >= DELAY)
				return;
			timer += EnterFrameManager.delay;

			if (timer >= DELAY)
				this.visible = true;
		}
	}
}
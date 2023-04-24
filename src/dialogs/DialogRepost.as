package dialogs
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;

	import buttons.ButtonBase;
	import game.gameData.CollectionsData;
	import loaders.ScreensLoader;
	import screens.ScreenAward;
	import screens.ScreenProfile;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.WallTool;

	public class DialogRepost extends Dialog
	{
		static private var NUMBER_IMAGES:Array = null;

		private var type:String;
		private var id:int;

		public function DialogRepost(type:String, id:int = 0):void
		{
			super();

			Logger.add("DialogRepost.show()", type, id);

			this.type = type;
			this.id = id;

			init();
		}

		override public function show():void
		{
			super.show();

			Connection.sendData(PacketClient.COUNT, PacketClient.CAN_REPOST, Game.self['type']);
		}

		private function init():void
		{
			addChild(image);

			var buttonRepost:ButtonBase = new ButtonBase(gls("Поделиться"));
			buttonRepost.x = 165 - int(buttonRepost.width * 0.5);
			buttonRepost.y = 315;
			buttonRepost.addEventListener(MouseEvent.CLICK, postWall);
			addChild(buttonRepost);

			place();

			this.width = 360;
			this.height = 370;
		}

		override protected function effectOpen():void
		{}

		private function get image():Sprite
		{
			var answer:Sprite = new Sprite();
			answer.x = -25;
			answer.y = -25;

			var caption:GameField = new GameField("", 0, 0, Dialog.FORMAT_CAPTION_18_CENTER);
			caption.filters = Dialog.FILTERS_CAPTION;
			var view:DisplayObject;
			var upperLayer:Sprite = new Sprite();

			switch (this.type)
			{
				case WallTool.WALL_AWARD://Готово
					caption.text = gls("Я получил\nновое достижение!");
					caption.x = 187;
					caption.y = 71;

					view = new RepostAwardImage();
					view.x = 60;
					view.y = 92;

					var awardView:DisplayObject = Award.getImage(this.id);
					awardView.addEventListener(MouseEvent.CLICK, onViewScreenAward);
					awardView.width = awardView.height = 156;
					upperLayer.addChild(awardView);
					upperLayer.x = 114;
					upperLayer.y = 131;
					break;
				/*case WallTool.WALL_CLAN_CREATE://Готово
					caption.text = gls("Я создал клан");
					caption.x = 186;
					caption.y = 61;

					view = new RepostClanCreateImage();
					view.x = 30;
					view.y = 76;

					var field:GameField = new GameField(ClanManager.getClan(Game.self['clan_id']).name, 0, 0, new TextFormat(GameField.PLAKAT_FONT, 15, 0xFFFFFF));
					field.x = -int(field.textWidth * 0.5);
					upperLayer.addChild(field);
					upperLayer.rotation = -20;
					upperLayer.x = 180;
					upperLayer.y = 190;
					break;*/
				/*case WallTool.WALL_CLAN_LEVEL://Не вызывается
					caption.text = gls("Мой клан достиг\nнового уровня");
					caption.x = 192;
					caption.y = 60;

					view = new RepostClanLevelImage();
					view.x = 60;
					view.y = 84;

					upperLayer.addChild(getImageFromNumber(this.id));
					upperLayer.scaleX = upperLayer.scaleY = 2.8;
					upperLayer.x = 180 - int(upperLayer.width * 0.5);
					upperLayer.y = 200 - int(upperLayer.height * 0.5);
					break;*/
				case WallTool.WALL_COLLECTION_REGULAR:
					//Я выставил на обмен - нет графики
					break;
				case WallTool.WALL_COLLECTION_UNIQUE://Готово
					caption.text = gls("Я получил новый\nэлемент коллекции");
					caption.x = 188;
					caption.y = 70;

					view = new RepostCollectionElementImage();
					view.x = 82;
					view.y = 110;

					var imageClass:Class = CollectionsData.getUniqueClass(id);
					upperLayer.addChild(new imageClass());
					upperLayer.scaleX = upperLayer.scaleY = 1.8;
					upperLayer.x = 185 - int(upperLayer.width * 0.5);
					upperLayer.y = 210 - int(upperLayer.height * 0.5);
					break;
				case WallTool.WALL_COLLECTION_AWARD://Готово
					caption.text = gls("Я обменял коллекции\nна костюм скрэта!");
					caption.x = 188;
					caption.y = 68;

					view = new RepostCollectionScratImage();
					view.x = 16;
					view.y = 96;

					imageClass = getDefinitionByName(CollectionsData.trophyData[this.id]['icon']) as Class;
					upperLayer.addChild(new imageClass());
					upperLayer.scaleX = upperLayer.scaleY = 2.3;
					upperLayer.x = 185 - int(upperLayer.width * 0.5);
					upperLayer.y = 240 - int(upperLayer.height * 0.5);
					break;
				case WallTool.WALL_COLLECTION_EXCHANGE:
					//Я обменялся с кем либо - нет графики
					break;
				/*case WallTool.WALL_NEW_PACKAGE://готово
					caption.text = gls("Я купил новый костюм!");
					caption.x = 194;
					caption.y = 57;

					view = new RepostBuyPackageImage();
					view.x = 27;
					view.y = 46;

					upperLayer.addChild(new PackageImageLoader(this.id));
					upperLayer.x = 185 - int(upperLayer.width * 0.5);
					upperLayer.y = 240 - int(upperLayer.height * 0.5);
					break;*/
				/*case WallTool.WALL_SHAMAN_CERTIFICATE://готово
					caption.text = this.id == 0 ? gls("Я окончил\nшколу шамана!") : gls("Я прошёл военную\nподготовку!");
					caption.x = this.id == 0 ? 193 : 183;
					caption.y = 70;

					view = this.id == 0 ? new RepostSchoolImage() : new RepostSchoolBattlelImage();
					view.x = this.id == 0 ? 65 : 53;
					view.y = this.id == 0 ? 89 : 102;
					break;*/
				case WallTool.WALL_SHAMAN_EXP://готово
					caption.text = gls("Я получил новый\nуровень шамана!");
					caption.x = 190;
					caption.y = 69;

					view = new RepostShamanLevelImage();
					view.x = 50;
					view.y = 106;

					upperLayer.addChild(getImageFromNumber(this.id));
					upperLayer.x = 187 - int(upperLayer.width * 0.5);
					upperLayer.y = 130 - int(upperLayer.height * 0.5);
					break;
				/*case WallTool.WALL_SHAMAN_SKILL://Не вызывается
					caption.text = gls("Я выучил навык шамана!");
					caption.x = 182;
					caption.y = 54;

					view = new RepostShamanSkillImage();
					view.x = 45;
					view.y = 69;

					var data:Object = PerkShamanFactory.perkData[PerkShamanFactory.getClassById(this.id)];
					imageClass = data['buttonClass'] as Class;
					upperLayer.addChild((new imageClass() as SimpleButton).upState);
					upperLayer.x = 180 - int(upperLayer.width * 0.5);
					upperLayer.y = 219 - int(upperLayer.height * 0.5);

					field = new GameField(data['name'], 0, 0, new TextFormat(GameField.PLAKAT_FONT, 18, 0xFFE000));
					field.x = 172 - int(field.textWidth * 0.5) - upperLayer.x;
					field.y = 121 - upperLayer.y;
					upperLayer.addChild(field);
					break;*/
				/*case WallTool.WALL_SHAMAN_BRANCH://Не вызывается
					caption.text = gls("Я выбрал\nпрофессию шамана!");
					caption.x = 191;
					caption.y = 64;

					switch (this.id)
					{
						case ShamanTreeManager.MENTOR:
							view = new RepostShamanBranch0Image();
							view.x = 55;
							view.y = 94;
							break;
						case ShamanTreeManager.LEADER:
							view = new RepostShamanBranch1Image();
							view.x = 56;
							view.y = 98;
							break;
						case ShamanTreeManager.CREATOR:
							view = new RepostShamanBranch2Image();
							view.x = 52;
							view.y = 97;
							break;
					}
					break;*/
			}
			answer.addChild(view);
			answer.addChild(caption);
			answer.addChild(upperLayer);

			caption.x -= int(caption.textWidth * 0.5);
			caption.y -= int(caption.textHeight * 0.5);

			return answer;
		}

		private function onViewScreenAward(event:MouseEvent):void
		{
			ScreenProfile.setPlayerId(Game.selfId);
			ScreensLoader.load(ScreenAward.instance);
		}

		private function getImageFromNumber(value:int):Sprite
		{
			var answer:Sprite = new Sprite();

			if (value == 0)
				answer.addChild(new RepostNumber0);
			else while (value > 0)
			{
				for (var i:int = 0; i < answer.numChildren; i++)
					answer.getChildAt(i).x += 20;
				answer.addChildAt(new numberImages[value % 10], 0);
				value = int(value / 10);
			}
			return answer;
		}

		private function get numberImages():Array
		{
			if (!NUMBER_IMAGES)
				NUMBER_IMAGES = [RepostNumber0, RepostNumber1, RepostNumber2, RepostNumber3, RepostNumber4, RepostNumber5, RepostNumber6, RepostNumber7, RepostNumber8, RepostNumber9];
			return NUMBER_IMAGES;
		}

		private function get bitmapData():BitmapData
		{
			var answer:BitmapData = new BitmapData(280, 280);
			var sprite:Sprite = new Sprite();

			var caption:GameField = new GameField("", 0, 0, Dialog.FORMAT_CAPTION_18_CENTER);
			caption.filters = Dialog.FILTERS_CAPTION;
			var view:DisplayObject;
			var upperLayer:Sprite = new Sprite();

			switch (this.type)
			{
				case WallTool.WALL_AWARD://Готово+
					caption.text = gls("Я получил\nновое достижение!");
					caption.x = 140;
					caption.y = 28;
					caption.width = 276;
					caption.height = 50;

					view = new RepostAwardImage();
					view.x = 7;
					view.y = 23;

					var awardView:DisplayObject = Award.getImage(this.id);
					awardView.width = awardView.height = 156;
					upperLayer.addChild(awardView);
					upperLayer.x = 61;
					upperLayer.y = 62;
					break;
				/*case WallTool.WALL_CLAN_CREATE://Готово+
					caption.text = gls("Я создал клан");
					caption.x = 118;
					caption.y = 16;

					view = new RepostClanCreateImage();
					view.scaleX = view.scaleY = 0.875;
					view.y = 19;

					var field:GameField = new GameField(ClanManager.getClan(Game.self['clan_id']).name, 0, 0, new TextFormat(GameField.PLAKAT_FONT, 13, 0xFFFFFF));
					field.x = -int(field.textWidth * 0.5);
					upperLayer.addChild(field);
					upperLayer.rotation = -20;
					upperLayer.x = 140;
					upperLayer.y = 120;
					break;*/
				/*case WallTool.WALL_CLAN_LEVEL://Не вызывается
					caption.text = gls("Мой клан достиг\nнового уровня");
					caption.x = 192;
					caption.y = 60;

					view = new RepostClanLevelImage();
					view.x = 60;
					view.y = 84;

					upperLayer.addChild(getImageFromNumber(this.id));
					upperLayer.scaleX = upperLayer.scaleY = 2.8;
					upperLayer.x = 180 - int(upperLayer.width * 0.5);
					upperLayer.y = 200 - int(upperLayer.height * 0.5);
					break;*/
				case WallTool.WALL_COLLECTION_REGULAR:
					//Я выставил на обмен - нет графики
					break;
				case WallTool.WALL_COLLECTION_UNIQUE://Готово+
					caption.text = gls("Я получил новый\nэлемент коллекции");
					caption.x = 140;
					caption.y = 30;

					view = new RepostCollectionElementImage();
					view.x = 25;
					view.y = 50;

					var imageClass:Class = CollectionsData.getUniqueClass(id);
					upperLayer.addChild(new imageClass());
					upperLayer.scaleX = upperLayer.scaleY = 1.8;
					upperLayer.x = 130 - int(upperLayer.width * 0.5);
					upperLayer.y = 150 - int(upperLayer.height * 0.5);
					break;
				case WallTool.WALL_COLLECTION_AWARD://Готово+
					caption.text = gls("Я обменял коллекции\nна костюм скрэта!");
					caption.x = 140;
					caption.y = 26;

					view = new RepostCollectionScratImage();
					view.scaleX = view.scaleY = 0.83;
					view.y = 14;

					imageClass = getDefinitionByName(CollectionsData.trophyData[this.id]['icon']) as Class;
					upperLayer.addChild(new imageClass());
					upperLayer.scaleX = upperLayer.scaleY = 1.9;
					upperLayer.x = 145 - int(upperLayer.width * 0.5);
					upperLayer.y = 130 - int(upperLayer.height * 0.5);
					break;
				case WallTool.WALL_COLLECTION_EXCHANGE:
					//Я обменялся с кем либо - нет графики
					break;
				/*case WallTool.WALL_NEW_PACKAGE://готово+
					caption.text = gls("Я купил новый костюм!");
					caption.x = 140;
					caption.y = 20;

					view = new RepostBuyPackageImage();
					view.scaleX = view.scaleY = 0.86;
					view.x = 3;
					view.y = 2;

					upperLayer.addChild(new PackageImageLoader(this.id));
					upperLayer.x = 140 - int(upperLayer.width * 0.5);
					upperLayer.y = 160 - int(upperLayer.height * 0.5);
					break;*/
				/*case WallTool.WALL_SHAMAN_CERTIFICATE://готово+
					caption.text = this.id == 0 ? gls("Я окончил\nшколу шамана!") : gls("Я прошёл военную\nподготовку!");
					caption.scaleX = caption.scaleY = 0.87;
					caption.x = 140;
					caption.y = 30;

					view = this.id == 0 ? new RepostSchoolImage() : new RepostSchoolBattlelImage();
					view.x = this.id == 0 ? 13 : 6;
					view.y = this.id == 0 ? 20 : 3;
					break;*/
				case WallTool.WALL_SHAMAN_EXP://готово
					caption.text = gls("Я получил новый\nуровень шамана!");
					caption.scaleX = caption.scaleY = 0.87;
					caption.x = 140;
					caption.y = 28;

					view = new RepostShamanLevelImage();
					view.scaleX = view.scaleY = 0.93;
					view.y = 52;

					upperLayer.addChild(getImageFromNumber(this.id));
					upperLayer.x = 128 - int(upperLayer.width * 0.5);
					upperLayer.y = 75 - int(upperLayer.height * 0.5);
					break;
				/*case WallTool.WALL_SHAMAN_SKILL://Не вызывается
					caption.text = gls("Я выучил навык шамана!");
					caption.x = 140;
					caption.y = 54;

					view = new RepostShamanSkillImage();
					view.x = 45;
					view.y = 69;

					var data:Object = PerkShamanFactory.perkData[PerkShamanFactory.getClassById(this.id)];
					imageClass = data['buttonClass'] as Class;
					upperLayer.addChild((new imageClass() as SimpleButton).upState);
					upperLayer.x = 180 - int(upperLayer.width * 0.5);
					upperLayer.y = 219 - int(upperLayer.height * 0.5);

					field = new GameField(data['name'], 0, 0, new TextFormat(GameField.PLAKAT_FONT, 18, 0xFFE000));
					field.x = 172 - int(field.textWidth * 0.5) - upperLayer.x;
					field.y = 121 - upperLayer.y;
					upperLayer.addChild(field);
					break;*/
				/*case WallTool.WALL_SHAMAN_BRANCH://Не вызывается
					caption.text = gls("Я выбрал\nпрофессию шамана!");
					caption.x = 140;
					caption.y = 64;

					switch (this.id)
					{
						case ShamanTreeManager.MENTOR:
							view = new RepostShamanBranch0Image();
							view.x = 55;
							view.y = 94;
							break;
						case ShamanTreeManager.LEADER:
							view = new RepostShamanBranch1Image();
							view.x = 56;
							view.y = 98;
							break;
						case ShamanTreeManager.CREATOR:
							view = new RepostShamanBranch2Image();
							view.x = 52;
							view.y = 97;
							break;
					}
					break;*/
			}
			var emblem:DisplayObject = PreLoader.getLogo();
			emblem.scaleX = emblem.scaleY = Config.isRus ? 1.0 : 0.5;
			emblem.x = int((280 - emblem.width) * 0.5);
			emblem.y = 275 - emblem.height;

			sprite.addChild(view);
			sprite.addChild(caption);
			sprite.addChild(upperLayer);
			sprite.addChild(emblem);

			caption.x -= int(caption.textWidth * 0.5);
			caption.y -= int(caption.textHeight * 0.5);

			answer.draw(sprite);
			return answer;
		}

		private function get text():String
		{
			switch (this.type)
			{
				case WallTool.WALL_AWARD:
					return Award.DATA[this.id]['awardText'];
				/*case WallTool.WALL_CLAN_CREATE:
					return gls("Я создал клан в игре Трагедия Белок");*/
				/*case WallTool.WALL_CLAN_LEVEL:
					return gls("Мой клан достиг {0} уровня в игре Трагедия Белок", this.id);*/
				case WallTool.WALL_COLLECTION_REGULAR:
					return gls("Я готов обменять «{0}» в игре Трагедия Белок", CollectionsData.regularData[this.id]['tittle']);
				case WallTool.WALL_COLLECTION_UNIQUE:
					return gls("Мною собрана коллекция «{0}» в игре Трагедия Белок!", CollectionsData.uniqueData[this.id]['collectionName']);
				case WallTool.WALL_COLLECTION_AWARD:
					return gls("Я получил награду за собранную коллекцию уникальных предметов в игре Трагедия Белок");
				case WallTool.WALL_COLLECTION_EXCHANGE:
					return gls("Я обменялся в игре Трагедия Белок");
				/*case WallTool.WALL_NEW_PACKAGE:
					return gls("У меня новый костюм в игре Трагедия Белок");
				case WallTool.WALL_SHAMAN_CERTIFICATE:
					return this.id == 0 ? gls("Я получил Аттестат Шамана в игре Трагедия Белок и теперь мне доступна вся магия") : gls("Я прошел курс молодого бойца в игре Трагедия Белок и готов к сражениям!");*/
				case WallTool.WALL_SHAMAN_EXP:
					return gls("Я получил новый уровень шамана! Играй в Трагедию белок вместе со мной.");
				/*case WallTool.WALL_SHAMAN_SKILL:
					return "";
				case WallTool.WALL_SHAMAN_BRANCH:
					return "";*/
			}
			return "";
		}

		private function postWall(e:MouseEvent):void
		{
			var quality:String = "";
			if (Game.stage.quality != StageQuality.HIGH)
			{
				quality = Game.stage.quality;
				Game.stage.quality = StageQuality.HIGH;
			}

			if (this.type == WallTool.WALL_SHAMAN_EXP)
				Connection.sendData(PacketClient.COUNT, PacketClient.SHAMAN_LEVEL_REPOST);
			NewsImageGenerator.save(this.bitmapData, "Package_" + this.id, false);
			WallTool.place(Game.self, this.type, this.id, new Bitmap(this.bitmapData), this.text);

			if (quality != "")
				Game.stage.quality = quality;

			Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.AWARD_POST, 1);
			hide();
		}
	}
}
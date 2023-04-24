package dialogs.shaman
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import dialogs.Dialog;
	import game.gameData.ShamanTreeManager;
	import game.mainGame.perks.shaman.PerkShamanFactory;
	import sounds.GameSounds;
	import statuses.Status;
	import views.shamanTree.ShamanSkillView;

	import utils.FiltersUtil;
	import utils.HtmlTool;

	public class DialogShamanSkill extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #1B120E;
				text-align: left;
			}
			.bold {
				font-weight: bold;
				text-align: center;
			}
			.red {
				font-size: 10px;
				color: #FF0000;
			}
			.description {
				font-size: 14px;
				color: #000000;
			}
			.number {
				font-size: 14px;
				color: #00997F;
				font-weight: bold;
			}
		]]>).toString();

		static private const DEFAULT_HEIGHT:int = 283;
		static private const DESCRIPTION_HEIGHT:int = 70;
		static private const PROGRESS_WIDTH:int = 190;

		private var levelsBackground:MovieClip;
		private var background:MovieClip;

		private var footerSprite:Sprite;

		private var buttons:Sprite;
		private var buttonsArray:Array;
		private var scoreSprite:Sprite;
		private var nameField:GameField;

		private var skillStateField:GameField;
		private var descriptionField:GameField;
		private var scoreField:GameField;
		private var skillImage:Bitmap = null;

		private var freeProgress:Shape;

		private var paidProgress:Shape;
		private var goldCost:Array = null;

		private var style:StyleSheet;

		public var currentSkill:ShamanSkillView = null;

		public function DialogShamanSkill():void
		{
			super("", false, false);

			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			this.background = new ShamanSkillDialogImage();
			this.background.crossButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				GameSounds.play("click");
				hide();
			});
			addChild(this.background);

			this.nameField = new GameField("", 132, 33, new TextFormat(GameField.DEFAULT_FONT, 22, 0x83501f, true));
			addChild(this.nameField);

			this.skillStateField = new GameField("", 132, 56, new TextFormat(GameField.DEFAULT_FONT, 12, 0x83501f));
			addChild(this.skillStateField);

			this.descriptionField = new GameField("", 132, 72, this.style);
			this.descriptionField.width = 295;
			this.descriptionField.multiline = true;
			this.descriptionField.wordWrap = true;
			addChild(this.descriptionField);

			var circle:Shape = new Shape();
			circle.x = 8;
			circle.y = 38;
			circle.graphics.beginFill(0xF0A956, 0.45);
			circle.graphics.drawCircle(57, 46, 55);
			circle.graphics.endFill();
			addChild(circle);

			this.scoreSprite = new Sprite();
			this.scoreSprite.x = 42;
			this.scoreSprite.y = 128;
			this.scoreSprite.graphics.beginFill(0x83501f);
			this.scoreSprite.graphics.drawRoundRect(0, 0, 44, 18, 15);
			this.scoreSprite.graphics.endFill();
			this.scoreSprite.mouseEnabled = false;
			this.scoreSprite.mouseChildren = false;
			addChild(this.scoreSprite);

			this.scoreField = new GameField("0/6", 0, -2, new TextFormat(GameField.DEFAULT_FONT, 16, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER));
			this.scoreField.width = 44;
			this.scoreField.autoSize = TextFieldAutoSize.CENTER;
			this.scoreField.antiAliasType = AntiAliasType.NORMAL;
			this.scoreSprite.addChild(this.scoreField);

			place();

			this.width = 443;

			this.footerSprite = new Sprite();
			this.footerSprite.x = 23;
			this.footerSprite.y = this.height - 115;
			addChild(this.footerSprite);

			this.levelsBackground = new SkillLevelsBackground();
			this.footerSprite.addChild(this.levelsBackground);

			this.buttons = new Sprite();
			this.footerSprite.addChild(this.buttons);

			var learningField:GameField = new GameField(gls("Изучение навыка"), 130, -24, new TextFormat(GameField.DEFAULT_FONT, 16, 0x6D3500));
			this.footerSprite.addChild(learningField);

			this.freeProgress = new Shape();
			this.freeProgress.graphics.beginFill(0x33CC00);
			this.freeProgress.graphics.drawRect(0, 0, PROGRESS_WIDTH, 3);
			this.freeProgress.x = 0;
			this.freeProgress.y = 84;
			this.footerSprite.addChild(this.freeProgress);

			this.paidProgress = new Shape();
			this.paidProgress.graphics.beginFill(0x33CC00);
			this.paidProgress.graphics.drawRect(0, 0, PROGRESS_WIDTH, 3);
			this.paidProgress.x = 210;
			this.paidProgress.y = 84;
			this.footerSprite.addChild(this.paidProgress);

			var progressBorder:Shape;
			for (var i:int = 0; i < 2; i++)
			{
				progressBorder = new Shape();
				progressBorder.graphics.lineStyle(1, 0xFFFFFF, 1, true);
				progressBorder.graphics.beginFill(0xFFFFFF, 0);
				progressBorder.graphics.drawRoundRectComplex(0, 0, PROGRESS_WIDTH, 3, 2, 2, 2, 2);
				progressBorder.graphics.endFill();
				progressBorder.x = i * 210;
				progressBorder.y = 84;
				this.footerSprite.addChild(progressBorder);
			}
		}

		public function showSkill(skill:ShamanSkillView):void
		{
			if (this.currentSkill && this.currentSkill.id == skill.id)
			{
				show();
				return;
			}

			this.currentSkill = skill;

			var data:Object = PerkShamanFactory.perkData[PerkShamanFactory.getClassById(this.currentSkill['id'])];

			this.nameField.text = data['name'];
			this.skillStateField.text = (data['active'] ? gls("активный") : gls("пассивный"));
			this.goldCost = (data['gold_cost'] as Array).slice();
			if (DiscountManager.haveDiscount(DiscountManager.SHAMAN_SKILL))
				for (var i:int = 0; i < this.goldCost.length; i++)
					this.goldCost[i] *= DiscountManager.DISCOUNT_SHAMAN_SKILL;

			if (this.skillImage)
				removeChild(this.skillImage);
			this.skillImage = new Bitmap(this.currentSkill.skillImage);
			this.skillImage.x = 21;
			this.skillImage.y = 38;
			addChild(this.skillImage);

			while (this.buttons.numChildren > 0)
				this.buttons.removeChildAt(0);

			this.buttonsArray = [];

			var buttonObject:Object;

			var coordX:int = 10;
			var isFree:Boolean = false;

			for (i = 0; i < ShamanTreeManager.SKILL_MAX_RATE; i++)
			{
				buttonObject = {};
				isFree = (i < 3);

				buttonObject['status_string'] = PerkShamanFactory.getDescriptionById(this.currentSkill.id, PerkShamanFactory.LEVEL_BONUS_DESCRIPTION, [isFree ? (i + 1) : 0, !isFree ? (i - 2) : 0]);

				var image:Sprite = new Sprite();
				image.addChild(new Bitmap(this.currentSkill.skillSmallImage));
				image.x = coordX;
				image.y = 15;
				this.buttons.addChild(image);
				buttonObject['image'] = image;

				var costSprite:Sprite = new Sprite();
				costSprite.x = image.x;
				costSprite.y = image.y + 45;
				costSprite.visible = false;
				this.buttons.addChild(costSprite);

				if (isFree)
				{
					var feathersIcon:ImageIconFeather = new ImageIconFeather();
					feathersIcon.x = 10;
					feathersIcon.scaleX = feathersIcon.scaleY = 0.6;
					costSprite.addChild(feathersIcon);
				}
				else
				{
					var coinsField:GameField = new GameField(String(this.goldCost[i - 3]), 0, 0, new TextFormat(GameField.DEFAULT_FONT, 14, 0x6D3500, true));
					coinsField.x = 9 - coinsField.width / 2;
					costSprite.addChild(coinsField);

					var coinsIcon:ImageIconCoins = new ImageIconCoins();
					coinsIcon.x = coinsField.x + coinsField.width + 2;
					coinsIcon.y = 2;
					coinsIcon.scaleX = coinsIcon.scaleY = 0.6;
					costSprite.addChild(coinsIcon);
				}

				buttonObject['image_status'] = new Status(buttonObject['image'], buttonObject['status_string']);
				buttonObject['image_status'].setStyle(this.style);
				buttonObject['image_status'].maxWidth = 200;

				buttonObject['cost'] = costSprite;

				var learnButton:SkillSunButton = new SkillSunButton();
				learnButton.x = image.x;
				learnButton.y = image.y;
				learnButton.scaleX = learnButton.scaleY = 0.8;
				learnButton.visible = false;
				learnButton.name = String(i);
				this.buttons.addChildAt(learnButton, 0);
				buttonObject['learn_button'] = learnButton;

				new Status(buttonObject['learn_button'], buttonObject['status_string']);

				if (!isFree)
				{
					var blockedSkillImage:BlockedSkillImage = new BlockedSkillImage();
					blockedSkillImage.x = image.x;
					blockedSkillImage.y = image.y;
					blockedSkillImage.visible = false;
					blockedSkillImage.mouseChildren = false;
					blockedSkillImage.mouseEnabled = false;
					blockedSkillImage.scaleX = blockedSkillImage.scaleY = 0.8;
					this.buttons.addChild(blockedSkillImage);

					var lockDetailImage:LockDetailImage = new LockDetailImage();
					blockedSkillImage.addChild(lockDetailImage);

					buttonObject['blocked'] = blockedSkillImage;
				}
				this.buttonsArray.push(buttonObject);

				coordX += (i == 1 || i == 4) ? 64 : (i == 2) ? 78 : 68;
			}

			updateSkill();

			show();
		}

		public function updateSkill():void
		{
			var paidAvailable:int = ShamanTreeManager.paidScoreAvailable(this.currentSkill.freeScore, this.currentSkill.paidScore);

			this.descriptionField.htmlText = HtmlTool.tag("body") + HtmlTool.span(PerkShamanFactory.getTotalDescription(this.currentSkill.id, [this.currentSkill.freeScore, paidAvailable]), "description") + HtmlTool.closeTag("body");

			this.scoreField.text = String(this.currentSkill.freeScore + this.currentSkill.paidScore) + "/" + String(ShamanTreeManager.SKILL_MAX_RATE);

			var coordX:int = this.x;
			var coordY:int = this.y;

			this.height = DEFAULT_HEIGHT + (this.descriptionField.height > DESCRIPTION_HEIGHT ? (this.descriptionField.height - DESCRIPTION_HEIGHT) : 0);
			this.background.height = this.height;

			this.x = coordX;
			this.y = coordY;

			this.footerSprite.y = this.height - 115;

			this.freeProgress.width = this.currentSkill.freeScore * PROGRESS_WIDTH / 3;
			this.paidProgress.width = paidAvailable * PROGRESS_WIDTH / 3;

			var isFree:Boolean = false;

			for (var i:int = 0; i < ShamanTreeManager.SKILL_MAX_RATE; i++)
			{
				isFree = (i < 3);

				if (!isFree)
					this.buttonsArray[i]['blocked'].visible = false;

				this.buttonsArray[i]['image_status'].setStatus(HtmlTool.tag("body") + this.buttonsArray[i]['status_string'] + HtmlTool.closeTag("body"));

				if ((isFree && (i >= this.currentSkill.freeScore)) || (!isFree && ((i - 3) >= this.currentSkill.paidScore)))
				{
					this.buttonsArray[i]['image'].filters = FiltersUtil.GREY_FILTER;
					this.levelsBackground["item" + String(i)].filters = FiltersUtil.GREY_FILTER;

					var isLearninig:Boolean = false;
					if (!this.currentSkill.blocked)
					{
						if (isFree && (i == this.currentSkill.freeScore) && ShamanTreeManager.getCurrentFeathers(ShamanTreeManager.currentBranch) > 0)
							isLearninig = true;
						else if (!isFree && ((i - 3) == this.currentSkill.paidScore) && ((i - 3) == paidAvailable))
						{
							if (i == 4)
								isLearninig = true;
							else if ((i - 3) < this.currentSkill.freeScore)
								isLearninig = true;
						}
					}

					this.buttonsArray[i]['image'].mouseChildren = !isLearninig;
					this.buttonsArray[i]['image'].mouseEnabled = !isLearninig;

					if (isLearninig)
					{
						this.buttonsArray[i]['learn_button'].visible = true;
						this.buttonsArray[i]['learn_button'].addEventListener(MouseEvent.CLICK, learnSkill);
						this.buttonsArray[i]['learn_button'].addEventListener(MouseEvent.MOUSE_OVER, onOver);
						this.buttonsArray[i]['learn_button'].addEventListener(MouseEvent.MOUSE_OUT, onOut);
						this.buttonsArray[i]['cost'].visible = true;
						this.buttonsArray[i]['cost'].filters = null;
					}
					else
					{
						this.buttonsArray[i]['learn_button'].visible = false;
						this.buttonsArray[i]['cost'].visible = true;
						this.buttonsArray[i]['cost'].filters = FiltersUtil.GREY_FILTER;

						var status:String = HtmlTool.tag("body") + this.buttonsArray[i]['status_string'];
						if (this.currentSkill.blocked)
							status += this.currentSkill.blockedReason;
						else if (isFree && (i == this.currentSkill.freeScore) && ShamanTreeManager.getCurrentFeathers(ShamanTreeManager.currentBranch) == 0)
							status += "<br /><br />" + HtmlTool.span(gls("Недостаточно перьев для изучения навыка."), "red");
						else
							status += "<br /><br />" + HtmlTool.span(getStatus(i), "red");
						status += HtmlTool.closeTag("body");
						this.buttonsArray[i]['image_status'].setStatus(status);
					}
				}
				else
				{
					this.buttonsArray[i]['learn_button'].visible = false;
					this.buttonsArray[i]['learn_button'].removeEventListener(MouseEvent.CLICK, learnSkill);
					this.buttonsArray[i]['learn_button'].removeEventListener(MouseEvent.MOUSE_OVER, onOver);
					this.buttonsArray[i]['learn_button'].removeEventListener(MouseEvent.MOUSE_OUT, onOut);

					this.buttonsArray[i]['image'].mouseChildren = true;
					this.buttonsArray[i]['image'].mouseEnabled = true;

					this.buttonsArray[i]['cost'].visible = false;

					this.levelsBackground["item" + String(i)].filters = null;
					this.buttonsArray[i]['image'].filters = null;

					if (!isFree && ((i - 3) >= paidAvailable))
					{
						this.buttonsArray[i]['blocked'].visible = true;

						this.buttonsArray[i]['image_status'].setStatus(HtmlTool.tag("body") + this.buttonsArray[i]['status_string'] + "<br /><br />" + HtmlTool.span(getStatus(i), "red") + HtmlTool.closeTag("body"));
					}
				}
			}
		}

		private function learnSkill(e:MouseEvent):void
		{
			GameSounds.play("click");
			var level:int = int(e.target.name);

			ShamanTreeManager.learnSkill(this.currentSkill.id, level, ((level >= 3) ? this.goldCost[level - 3] : 0));
		}

		private function onOver(e:MouseEvent):void
		{
			var level:int = int(e.target.name);
			this.buttonsArray[level]['image'].filters = null;
		}

		private function onOut(e:MouseEvent):void
		{
			var level:int = int(e.target.name);
			this.buttonsArray[level]['image'].filters = FiltersUtil.GREY_FILTER;
		}

		private function getStatus(level:int):String
		{
			switch (level)
			{
				case 1:
				case 3:
					return gls("Необходимо изучить 1-й уровень навыка.");
				case 2:
					return gls("Необходимо изучить 2-й уровень навыка.");
				case 4:
					return gls("Необходимо изучить 4-й уровень навыка.");
				case 5:
					return gls("Необходимо изучить все предыдущие уровни навыка.");
			}
			return "";
		}
	}
}
package views.shamanTree
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import game.gameData.ShamanTreeManager;
	import game.mainGame.perks.shaman.PerkShamanFactory;
	import statuses.Status;

	import utils.HtmlTool;
	import utils.StringUtil;

	public class ShamanSkillView extends Sprite
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
		]]>).toString();

		static private const FORMAT_WHITE:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 12, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
		static private const FORMAT_GREEN:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 12, 0x33FF00, true, null, null, null, null, TextFormatAlign.CENTER);
		static private const FORMAT_GOLD:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 12, 0xFFCC00, true, null, null, null, null, TextFormatAlign.CENTER);

		static private const GLOW_GREEN:Array = [new GlowFilter(0x33FF00, 1, 4, 4, 1.8)];
		static private const GLOW_GOLD:Array = [new GlowFilter(0xFFCC00, 1, 4, 4, 1.8)];

		private var data:Object;

		private var overGlow:DisplayObject;
		private var button:Sprite;

		private var isBlocked:Boolean;

		private var blockedSkillImage:BlockedSkillImage;

		private var skillId:int;
		private var freeLevel:int = 0;
		private var paidLevel:int = 0;
		private var position:int = 0;
		private var branchId:int = 0;

		private var scoreSprite:Sprite;
		private var scoreField:GameField;

		private var scoreBlocked:Shape;

		private var bitmapData:BitmapData = null;
		private var bitmapDataSmall:BitmapData = null;

		private var status:Status;

		public function ShamanSkillView(id:int, position:int, branchId:int):void
		{
			this.skillId = id;
			this.position = position;
			this.branchId = branchId;

			this.data = PerkShamanFactory.perkData[PerkShamanFactory.getClassById(id)];

			this.overGlow = new PerkOverGlow();
			this.overGlow.visible =	false;
			addChild(this.overGlow);

			var sprite:Sprite = new Sprite();

			var convertedImage:SimpleButton = new this.data['buttonClass']();
			sprite.addChild(convertedImage);

			var bmData:BitmapData = new BitmapData(sprite.width, sprite.height, true, 0x00000000);
			bmData.draw(sprite);

			this.button = new Sprite();
			this.button.addChild(new Bitmap(bmData));
			this.button.addEventListener(MouseEvent.CLICK, showDialogSkill);
			this.button.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.button.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			addChild(this.button);

			this.blockedSkillImage = new BlockedSkillImage();
			this.blockedSkillImage.mouseEnabled = false;
			this.blockedSkillImage.mouseChildren = false;
			addChild(this.blockedSkillImage);

			this.button.hitArea = this.blockedSkillImage;

			this.scoreSprite = new Sprite();
			this.scoreSprite.x = 8;
			this.scoreSprite.y = 38;
			this.scoreSprite.graphics.beginFill(0x462C0B);
			this.scoreSprite.graphics.drawRoundRect(0, 0, 35, 15, 15);
			this.scoreSprite.graphics.endFill();
			this.scoreSprite.mouseEnabled = false;
			this.scoreSprite.mouseChildren = false;
			addChild(this.scoreSprite);

			this.scoreBlocked = new Shape();
			this.scoreBlocked.x = 8;
			this.scoreBlocked.y = 38;
			this.scoreBlocked.graphics.beginFill(0xffffff, 0.5);
			this.scoreBlocked.graphics.drawRoundRect(0, 0, 35, 15, 15);
			this.scoreBlocked.graphics.endFill();
			this.scoreBlocked.visible = false;
			addChild(this.scoreBlocked);

			this.scoreField = new GameField("0/6", 0, -1, FORMAT_WHITE);
			this.scoreField.width = 35;
			this.scoreField.autoSize = TextFieldAutoSize.CENTER;
			this.scoreField.antiAliasType = AntiAliasType.NORMAL;
			this.scoreSprite.addChild(this.scoreField);

			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);
			this.status = new Status(this, "");
			this.status.setStyle(style);
			this.status.maxWidth = 200;
		}

		public function get id():int
		{
			return this.skillId;
		}

		public function get blocked():Boolean
		{
			return this.isBlocked;
		}

		public function get blockedReason():String
		{
			var reason:String = "";
			var feathers:int = ShamanTreeManager.getNeedFeathers(this.branchId, this.position);

			if (ShamanTreeManager.currentBranch != ShamanTreeManager.EMPTY && !ShamanTreeManager.isBranchBought(this.branchId))
				reason = "<br /><br />" + HtmlTool.span(gls("Чтобы выучить этот навык, купи профессию «{0}».", ShamanTreeManager.BRANCH_TYPES[this.branchId]), "red");
			else if (ShamanTreeManager.getCurrentFeathers(this.branchId) == 0 && feathers <= 0)
				reason = "<br /><br />" + HtmlTool.span(gls("Недостаточно перьев для изучения навыка."), "red");
			else
				reason = "<br /><br />" + HtmlTool.span(gls("Вложи ещё {0} {1} в профессию для изучения навыка.", feathers.toString(), StringUtil.word("перо", feathers)), "red");

			return reason;
		}

		public function get skillImage():BitmapData
		{
			if (!this.bitmapData)
			{
				var sprite:Sprite = new Sprite();

				var convertedImage:SimpleButton = new this.data['buttonClass']();
				convertedImage.scaleX = convertedImage.scaleY = 1.7;
				sprite.addChild(convertedImage);

				this.bitmapData = new BitmapData(sprite.width, sprite.height, true, 0x00000000);
				this.bitmapData.draw(sprite);
			}
			return this.bitmapData;
		}

		public function get skillSmallImage():BitmapData
		{
			if (!this.bitmapDataSmall)
			{
				var sprite:Sprite = new Sprite();

				var convertedImage:SimpleButton = new this.data['buttonClass']();
				convertedImage.scaleX = convertedImage.scaleY = 0.8;
				sprite.addChild(convertedImage);

				this.bitmapDataSmall = new BitmapData(sprite.width, sprite.height, true, 0x00000000);
				this.bitmapDataSmall.draw(sprite);
			}
			return this.bitmapDataSmall;
		}

		public function onOver(e:MouseEvent):void
		{
			this.overGlow.visible = true;
		}

		public function onOut(e:MouseEvent):void
		{
			this.overGlow.visible = false;
		}

		public function showDialogSkill(e:MouseEvent):void
		{
			if (this.branchId != ShamanTreeManager.currentBranch && ShamanTreeManager.currentBranch != ShamanTreeManager.EMPTY)
				return;

			ShamanTreeManager.showDialogSkill(this);
		}

		public function setClickable(value:Boolean):void
		{
			this.button.mouseChildren = value;
			this.button.mouseEnabled = value;

			this.blockedSkillImage.visible = (value ? this.isBlocked : true);

			this.scoreBlocked.visible = (!value ? this.scoreSprite.visible : false);

			if (!value)
				this.scoreSprite.filters = null;
		}

		public function setBlock(value:Boolean):void
		{
			this.isBlocked = value;
			this.blockedSkillImage.visible = this.isBlocked;

			this.scoreSprite.visible = !this.isBlocked;

			var statusString:String = HtmlTool.tag("body") + HtmlTool.span(this.data['name'], "bold") + "<br />" + PerkShamanFactory.getDescriptionById(this.id, PerkShamanFactory.DEFAULT_DESCRIPTION, null);
			if (this.isBlocked)
			{
				statusString += blockedReason;
			}
			statusString += HtmlTool.closeTag("body");
			this.status.setStatus(statusString);
		}

		public function setScore(freeLevel:int, paidLevel:int):void
		{
			this.freeLevel = freeLevel;
			this.paidLevel = paidLevel;

			if (this.paidLevel > 0 && !ShamanTreeManager.isPaidSkills)
				ShamanTreeManager.isPaidSkills = true;

			this.scoreField.text = String(this.freeLevel + this.paidLevel) + "/" + String(ShamanTreeManager.SKILL_MAX_RATE);

			if (freeLevel > 0)
			{
				if ((this.freeLevel + this.paidLevel) == ShamanTreeManager.SKILL_MAX_RATE)
				{
					this.scoreField.setTextFormat(FORMAT_GOLD);
					this.scoreSprite.filters = GLOW_GOLD;
				}
				else
				{
					this.scoreField.setTextFormat(FORMAT_GREEN);
					this.scoreSprite.filters = GLOW_GREEN;
				}
			}
			else
			{
				this.scoreField.setTextFormat(FORMAT_WHITE);
				this.scoreSprite.filters = null;
			}
		}

		public function get freeScore():int
		{
			return this.freeLevel;
		}

		public function get paidScore():int
		{
			return this.paidLevel;
		}
	}
}
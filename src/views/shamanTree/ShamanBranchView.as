package views.shamanTree
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import dialogs.Dialog;
	import game.gameData.ShamanTreeManager;
	import sounds.GameSounds;
	import statuses.Status;

	import com.greensock.TweenMax;

	import protocol.packages.server.structs.PacketLoginShamanInfo;

	import utils.HtmlTool;

	public class ShamanBranchView extends Sprite
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
		]]>).toString();

		static public const FORMAT_CAPTION:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 21, 0xFFCC00, null, null, null, null, null, "center");
		static public const FORMAT_FEATHER:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 19, 0x867754, null, null, null, null, null, "right");

		static private const BEGIN_X:int = 52;
		static private const BEGIN_Y:int = 43;

		static private const OFFSET_X:int = 67;
		static private const OFFSET_Y:int = 65;

		private var skills:Vector.<ShamanSkillView>;

		private var blocked:Boolean = true;
		private var branchId:int;

		private var branchTitleField:GameField;
		private var feathersField:GameField;

		private var spentFeathers:int = 0;

		private var resetButton:SimpleButton = null;
		private var buyButton:SimpleButton = null;

		private var style:StyleSheet;

		private var activeImage:DisplayObject = null;
		private var blockImage:DisplayObjectContainer = null;

		public function ShamanBranchView(branchId:int, perkIds:Array):void
		{
			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			this.branchId = branchId;

			this.activeImage = new ActiveBranchImage();
			addChild(this.activeImage);

			this.skills = new Vector.<ShamanSkillView>();

			var coordX:int = BEGIN_X + OFFSET_X;
			var coordY:int = BEGIN_Y;
			for (var i:int = 0; i < perkIds.length; i++)
			{
				if (i == perkIds.length - 1)
					coordX = BEGIN_X + OFFSET_X;

				var skill:ShamanSkillView = new ShamanSkillView(perkIds[i], i, this.branchId);
				skill.x = coordX;
				skill.y = coordY;
				addChild(skill);
				this.skills.push(skill);

				if (i == 0)
				{
					coordX = BEGIN_X;
					coordY += OFFSET_Y;
					continue;
				}

				coordX += OFFSET_X;
				if (coordX == BEGIN_X + 3 * OFFSET_X)
				{
					coordX = BEGIN_X;
					coordY += OFFSET_Y;
				}
			}

			this.branchTitleField = new GameField(ShamanTreeManager.BRANCH_TYPES[this.branchId], 40, 2, FORMAT_CAPTION);
			this.branchTitleField.filters = Dialog.FILTERS_CAPTION;
			this.branchTitleField.width = 200;
			this.branchTitleField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.branchTitleField);

			var statusTitle:Status = new Status(this.branchTitleField, "");
			statusTitle.setStyle(this.style);
			statusTitle.maxWidth = 220;
			statusTitle.setStatus(ShamanTreeManager.getStatusForBranch(this.branchId));

			var feathersSprite:Sprite = new Sprite();
			addChild(feathersSprite);

			this.feathersField = new GameField(String(Game.self.feathers), 250, 2, FORMAT_FEATHER);
			this.feathersField.autoSize = TextFieldAutoSize.RIGHT;
			feathersSprite.addChild(this.feathersField);

			var feathersIcon:ImageIconFeather = new ImageIconFeather();
			feathersIcon.x = 255;
			feathersIcon.y = this.feathersField.y + 1;
			feathersSprite.addChild(feathersIcon);

			var statusFeathers:Status = new Status(feathersSprite, "");
			statusFeathers.setStyle(style);
			statusFeathers.maxWidth = 290;
			statusFeathers.setStatus(HtmlTool.tag("body") + HtmlTool.span(gls("Перья"), "bold") + gls("<br />Шаман получает одно перо за каждый новый уровень<br/>Перья используются для изучения навыков шамана") + HtmlTool.closeTag("body"));
		}

		public function updateFeathers():void
		{
			this.feathersField.text = String(ShamanTreeManager.getCurrentFeathers(this.branchId));
		}

		public function setData(data:Vector.<PacketLoginShamanInfo>):void
		{
			this.spentFeathers = 0;
			var paidScores:int = 0;

			for (var i:int = 0; i < this.skills.length; i++)
			{
				var j:int = 0;

				for (; j < data.length; j++)
				{
					if (data[j].skillId != this.skills[i].id)
						continue;
					break;
				}

				if (j == data.length)
					this.skills[i].setScore(0, 0);
				else
				{
					this.skills[i].setScore(data[j].levelFree, data[j].levelPaid);
					this.spentFeathers += data[j].levelFree;
					paidScores += data[j].levelPaid;
				}
			}

			ShamanTreeManager.setSpentFeathers(this.branchId, this.spentFeathers, Math.floor(paidScores * 0.5));

			for (i = 0; i < this.skills.length; i++)
			{
				if (this.skills[i].freeScore > 0 || (ShamanTreeManager.getNeedFeathers(this.branchId, i) <= 0 && (ShamanTreeManager.getCurrentFeathers(this.branchId) > 0)))
				{
					this.skills[i].setBlock(false);
					continue;
				}
				this.skills[i].setBlock(true);
			}

			this.feathersField.text = String(ShamanTreeManager.getCurrentFeathers(this.branchId));

			if (this.spentFeathers == 0)
			{
				if (this.resetButton)
					this.resetButton.visible = false;
				return;
			}

			if (!this.resetButton)
			{
				this.resetButton = new ResetBranchButton();
				this.resetButton.x = 5;
				this.resetButton.y = 5;
				this.resetButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
				{
					GameSounds.play("click");
					if (branchId != ShamanTreeManager.currentBranch)
						return;

					ShamanTreeManager.resetBranch();
				});
				addChild(this.resetButton);

				var statusReset:Status = new Status(this.resetButton, "");
				statusReset.setStyle(this.style);
				statusReset.maxWidth = 200;
				statusReset.setStatus(HtmlTool.tag("body") + HtmlTool.span(gls("Сброс"), "bold") + gls("<br/>Вернуть все перья, потраченные на изучение навыков в этой профессии") + HtmlTool.closeTag("body"));
			}
			this.resetButton.visible = true;
		}

		public function setBought(value:Boolean):void
		{
			if (value)
			{
				if (this.buyButton)
				{
					removeChild(this.buyButton);
					this.buyButton = null;
				}

				if (this.blockImage)
				{
					TweenMax.to(this.blockImage, 0.5, {'autoAlpha': 0, 'onComplete': function():void
					{
						removeChild(blockImage);
						blockImage = null;
					}});
				}
				return;
			}

			for (var i:int = 0; i < this.skills.length; i++)
				this.skills[i].setBlock(true);

			if (!this.blockImage)
			{
				this.blockImage = new BlockWebImage();
				this.blockImage.y = 20;
				this.blockImage.mouseChildren = false;
				this.blockImage.mouseEnabled = false;
				addChild(this.blockImage);
			}
			this.blockImage.visible = true;

			if (!this.buyButton)
			{
				this.buyButton = new BuyBranchButton();
				this.buyButton.x = 5;
				this.buyButton.y = 5;
				this.buyButton.addEventListener(MouseEvent.CLICK, buyBranch);
				addChild(this.buyButton);
				new Status(this.buyButton, gls("Купить профессию"));
			}
			this.buyButton.visible = true;
		}

		public function setBlock(value:Boolean):void
		{
			this.blocked = value;

			this.activeImage.alpha = this.blocked ? 0 : 1;

			this.branchTitleField.alpha = this.blocked ? 0.5 : 1;

			for (var i:int = 0; i < this.skills.length; i++)
				this.skills[i].setClickable(!this.blocked);

			if (this.resetButton)
				this.resetButton.visible = !value && (this.spentFeathers > 0);
		}

		public function setFirst():void
		{
			this.skills[0].setBlock(false);
			this.activeImage.alpha = 0;

			if (this.blockImage)
				this.blockImage.visible = false;

			if (!this.buyButton)
				return;

			this.buyButton.visible = false;
		}

		private function buyBranch(e:MouseEvent):void
		{
			GameSounds.play("click");
			ShamanTreeManager.buyBranch(this.branchId);
		}
	}
}
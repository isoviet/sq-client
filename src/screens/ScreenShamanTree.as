package screens
{
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import buttons.ButtonScreenshot;
	import dialogs.Dialog;
	import dialogs.DialogShop;
	import events.GameEvent;
	import game.gameData.EducationQuestManager;
	import game.gameData.ShamanTreeManager;
	import game.gameData.VIPManager;
	import loaders.RuntimeLoader;
	import loaders.ScreensLoader;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;
	import views.shamanTree.ShamanBranchView;
	import views.shamanTree.ShamanExperienceView;

	import utils.HtmlTool;

	public class ScreenShamanTree extends Screen
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

		static public const FORMAT_LEVEL:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0x012A54, null, null, null, null, null, "center");

		static private var _instance:ScreenShamanTree;

		private var inited:Boolean = false;

		private var levelField:GameField;
		private var buttonShop:ButtonBase = null;

		private var experienceView:ShamanExperienceView;

		private var branches:Vector.<ShamanBranchView> = null;

		private var currentBranch:int = -1;

		public function ScreenShamanTree():void
		{
			super();

			_instance = this;
		}

		static public function get instance():ScreenShamanTree
		{
			return _instance;
		}

		static public function updateExperience():void
		{
			if (!_instance || !_instance.inited)
				return;

			_instance.levelField.text = String(Game.self['shaman_level']);
			_instance.experienceView.setData(Game.self['shaman_exp']);
		}

		override public function firstShow():void
		{
			show();
		}

		override public function show():void
		{
			super.show();

			if (!ScreensLoader.loaded)
				return;

			if (!this.inited)
			{
				init();
				this.inited = true;
			}

			for (var i:int = 0; i < this.branches.length; i++)
				this.branches[i].updateFeathers();

			EducationQuestManager.done(EducationQuestManager.SHAMAN_TREE);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			addChild(new ScreenShamanBackground);

			var field:GameField = new GameField(gls("Навыки шамана"), 0, 5, new TextFormat(GameField.PLAKAT_FONT, 21, 0xFFCC00));
			field.x = int((Config.GAME_WIDTH - field.textWidth) * 0.5);
			field.filters = Dialog.FILTERS_CAPTION;
			addChild(field);

			var buttonExit:ButtonCross = new ButtonCross();
			buttonExit.x = 870;
			buttonExit.y = 10;
			buttonExit.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				GameSounds.play(SoundConstants.BUTTON_CLICK);
				Screens.show(Screens.screenToComeback);
			});
			addChild(buttonExit);

			var screenshotButton:ButtonScreenshot = new ButtonScreenshot(true);
			screenshotButton.x = 840;
			screenshotButton.y = 10;
			addChild(screenshotButton);

			var image:ShamanLevelBackground = new ShamanLevelBackground();
			image.x = 15;
			image.y = 18;
			addChild(image);

			this.levelField = new GameField(String(Game.self['shaman_level']), 46, 35, FORMAT_LEVEL);
			this.levelField.width = 40;
			this.levelField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.levelField);

			var statusLevel:Status = new Status(this.levelField, "");
			statusLevel.setStyle(style);
			statusLevel.maxWidth = 290;
			statusLevel.setStatus(HtmlTool.tag("body") + HtmlTool.span(gls("Уровень шамана"), "bold") + gls("<br/>Шаман получает опыт за каждую белку, которой помог добраться до дупла<br/>Уровень шамана повышается, когда он наберёт достаточное количество очков опыта") + HtmlTool.closeTag("body"));

			this.experienceView = new ShamanExperienceView();
			this.experienceView.x = 125;
			this.experienceView.y = 38;
			addChild(this.experienceView);

			this.buttonShop = new ButtonBase(gls("Удвоить опыт шамана"));
			this.buttonShop.x = int((Config.GAME_WIDTH - this.buttonShop.width) * 0.5);
			this.buttonShop.y = 62;
			this.buttonShop.addEventListener(MouseEvent.CLICK, showShop);
			addChild(this.buttonShop);

			this.branches = new Vector.<ShamanBranchView>();
			var branch:ShamanBranchView = null;
			for (var i:int = 0; i < ShamanTreeManager.BRANCHES.length; i++)
			{
				branch = new ShamanBranchView(i, ShamanTreeManager.BRANCHES[i]);
				branch.x = 300 * i + 10;
				branch.y = 99;
				branch.name = i.toString();
				addChild(branch);
				branch.addEventListener(MouseEvent.CLICK, onBranch);
				branch.setData(Game.self['shaman_tree']);
				this.branches.push(branch);
			}

			VIPManager.addEventListener(GameEvent.VIP_START, onVIP);
			VIPManager.addEventListener(GameEvent.VIP_END, onVIP);

			ShamanTreeManager.updateFunction = updateTree;
			updateTree();
		}

		private function onVIP(event:GameEvent):void
		{
			this.buttonShop.visible = !VIPManager.haveVIP;
		}

		private function showShop(e:MouseEvent):void
		{
			RuntimeLoader.load(function():void
			{
				DialogShop.selectTape(DialogShop.VIP);
			});
		}

		private function onBranch(e:MouseEvent):void
		{
			var branchId:int = int(e.currentTarget.name);

			if (ShamanTreeManager.currentBranch == ShamanTreeManager.EMPTY || branchId == ShamanTreeManager.currentBranch)
				return;

			if (!ShamanTreeManager.isBranchBought(branchId))
			{
				ShamanTreeManager.buyBranch(branchId);
				return;
			}

			ShamanTreeManager.changeBranch(branchId);
		}

		private function updateTree():void
		{
			if (ShamanTreeManager.currentBranch != ShamanTreeManager.EMPTY)
				this.branches[ShamanTreeManager.currentBranch].setData(Game.self['shaman_skills']);

			if (ShamanTreeManager.currentBranch == this.currentBranch)
			{
				if (ShamanTreeManager.currentBranch != ShamanTreeManager.EMPTY)
					this.branches[this.currentBranch].setBlock(false);
				ShamanTreeManager.updateDialogSkill();
				return;
			}

			this.currentBranch = ShamanTreeManager.currentBranch;

			for (var i:int = 0; i < this.branches.length; i++)
			{
				this.branches[i].setBought(ShamanTreeManager.isBranchBought(i));

				if (ShamanTreeManager.currentBranch == ShamanTreeManager.EMPTY)
					this.branches[i].setFirst();
				else
					this.branches[i].setBlock(i != this.currentBranch);
			}

			ShamanTreeManager.updateDialogSkill();
		}
	}
}
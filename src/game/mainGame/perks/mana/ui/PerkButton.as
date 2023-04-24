package game.mainGame.perks.mana.ui
{
	import flash.events.Event;

	import dialogs.DialogRecord;
	import game.gameData.GameConfig;
	import game.mainGame.perks.mana.PerkFactory;
	import game.mainGame.perks.mana.PerkMana;
	import game.mainGame.perks.ui.ToolButton;
	import screens.ScreenEdit;
	import screens.Screens;
	import statuses.StatusIcons;
	import views.widgets.HotKeyView;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.RecorderCollection;

	import utils.FiltersUtil;

	public class PerkButton extends ToolButton
	{
		private var animGlow:AnimGlowGreenPerk = null;

		public function PerkButton(id:int):void
		{
			super(id);

			removeChild(this.costView);

			this.costView.visible = true;
			this.costView.textFilters = [];
			this.costView.color = 0;

			(this.status as StatusIcons).setPosition(0,0);
			(this.status as StatusIcons).updateIcons([this.costView]);

			this.animGlow = new AnimGlowGreenPerk();
			this.animGlow.x = 18;
			this.animGlow.y = 17;
			this.animGlow.play();
			addChild(this.animGlow);
		}

		override public function get iconClass():Class
		{
			return PerkFactory.getImageClass(this.id);
		}

		override public function get pekManaCost():int
		{
			return GameConfig.getSkillManaCost(this.id);
		}

		override public function clone():ToolButton
		{
			var answer:PerkButton = new PerkButton(this.id);
			answer.hero = this.hero;
			return answer;
		}

		override public function set hero(value:Hero):void
		{
			if (!checkHero(value))
				return;

			for each (var perk:PerkMana in value.perkController.perksMana)
			{
				if (perk.code != this.id)
					continue;
				this.perkInstance = perk;
				this.cost = this.pekManaCost;
				this.perkInstance.addEventListener("STATE_CHANGED", updateState);
			}
			updateState();
			updateView();
		}

		override public function onClick(e:Event = null):void
		{
			if (!checkClick())
				return;

			if (!showManaDialog())
			{
				if (this.cost == 0 && this.id == PerkFactory.SKILL_RESURECTION)
					Connection.sendData(PacketClient.ROUND_RESPAWN, PacketServer.RESPAWN_CLAN_TOTEM);
				else
					this.perkInstance.onUse();
			}

			if (this.perkInstance.active)
				this.gray = true;
		}

		override public function updateState(e:Event = null):void
		{
			if (!checkState())
				return;

			this.status.setStatus("<b>«" + PerkFactory.getName(this.id) + "»</b>\n" + PerkFactory.getDescription(this.id));

			var icons:Array = [];
			if(this.hotKeyText != "")
				icons.push(new HotKeyView(this.hotKeyText));
			icons.push(this.costView);
			(this.status as StatusIcons).updateIcons(icons);
		}

		public function get perk():Class
		{
			return PerkFactory.getPerkClass(this.id);
		}

		override protected function updateView():void
		{
			var filters:Array = [];

			this.animGlow.visible = this.glow;

			if (this.gray)
				filters = filters.concat(FiltersUtil.GREY_FILTER);
			this.button.filters = filters;
		}

		override protected function checkClick():Boolean
		{
			if ((Screens.active is ScreenEdit) && DialogRecord.recorder.isRecording)
				RecorderCollection.addDataClient(PacketClient.ROUND_SKILL, [this.perkInstance.code, !this.perkInstance.active, 0, ""]);

			return super.checkClick();
		}
	}
}
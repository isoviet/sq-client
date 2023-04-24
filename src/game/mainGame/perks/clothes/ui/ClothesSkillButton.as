package game.mainGame.perks.clothes.ui
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import dialogs.DialogDepletionMana;
	import footers.FooterGame;
	import game.gameData.GameConfig;
	import game.gameData.PowerManager;
	import game.mainGame.perks.IHotKey;
	import game.mainGame.perks.clothes.PerkClothes;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import game.mainGame.perks.ui.PerkCostView;
	import game.mainGame.perks.ui.ToolButton;
	import statuses.StatusIcons;
	import views.widgets.HotKeyView;

	import protocol.Connection;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundSkill;

	public class ClothesSkillButton extends ToolButton
	{
		protected var _freeCost:Boolean = true;

		public function ClothesSkillButton(perkId:int):void
		{
			super(perkId);

			this.button.scaleX = this.button.scaleY = 0.8;

			this.status.setStatus(gls("<B>«{0}»</B>\n{1}", PerkClothesFactory.getName(this.id), PerkClothesFactory.getDescription(this.id)));
			this.costView.visible = this.cost > 0 && !this._freeCost;

			setSector();

			Connection.listen(onPacket, [PacketRoundSkill.PACKET_ID, PacketRoomRound.PACKET_ID]);
		}

		override public function get iconOffset():Point
		{
			return new Point(20, 20);
		}

		override public function get iconClass():Class
		{
			return PerkClothesFactory.getImageClass(this.id);
		}

		override public function get pekManaCost():int
		{
			return GameConfig.getSkillManaCost(this.id);
		}

		override public function clone():ToolButton
		{
			var answer:ClothesSkillButton = new ClothesSkillButton(this.id);
			answer.hero = this.hero;
			return answer;
		}

		override public function set hero(value:Hero):void
		{
			if (!checkHero(value))
				return;

			if (this.perkInstance is IHotKey)
				Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);

			for each (var perk:PerkClothes in value.perkController.perksClothes)
			{
				if (perk.code != this.id)
					continue;

				this.perkInstance = perk;
				this.perkInstance.isSent = false;
				this.perkInstance.addEventListener("STATE_CHANGED", updateState);
				if (this.perkInstance is IHotKey)
				{
					Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
					this.status.setStatus(gls("<B>«{0}» ({1})</B>\n{2}", PerkClothesFactory.getName(this.id), PerkClothesFactory.getDescription(this.id)));
				}

				updateState();
				return;
			}

			this.gray = true;
		}

		override public function onClick(e:Event = null):void
		{
			if (!this.perkInstance || !this.perkInstance.available)
				return;

			if (this.perkInstance.isSent)
				return;

			if (!checkClick())
				return;

			if (!showManaDialog())
			{
				if (this.hero)
					this.hero.sendLocation();
				this.perkInstance.onUse();
			}

			if (this.perkInstance.active || !PowerManager.isEnoughMana(this.cost))
				this.gray = true;

			this.glow = this.perkInstance.active;
		}

		override public function updateState(e:Event = null):void
		{
			if (!checkState())
				return;

			super.updateState();

			this.status.setStatus("<b>«" + PerkClothesFactory.getName(this.id) + "»</b>\n" + PerkClothesFactory.getDescription(this.id));

			if (this.hotKeyText == "")
				return;
			var icons:Array = [];
			if(this.hotKeyText != "")
				icons.push(new HotKeyView(this.hotKeyText));
			icons.push(this.costView);
			(this.status as StatusIcons).updateIcons(icons);
		}

		public function dispose():void
		{
			this.perkInstance = null;
			this.status.remove();

			removeEventListener(MouseEvent.CLICK, onClick);
			Connection.forget(onPacket, [PacketRoundSkill.PACKET_ID, PacketRoomRound.PACKET_ID]);
		}

		public function set freeCost(value:Boolean):void
		{
			if (this._freeCost == value)
				return;

			this._freeCost = value;
			this.costView.visible = this.cost > 0 && !this._freeCost;
		}

		override protected function getCostView():PerkCostView
		{
			this.costView = new PerkCostView(ImageIconMana, 0.7);
			this.costView.x = 0;
			this.costView.y = 40;

			return this.costView;
		}

		override protected function setSector():void
		{
			super.setSector();

			this.sector.radius = 20;
			this.sector.x = this.sector.radius;
			this.sector.y = this.sector.radius;
		}

		override protected function showManaDialog():Boolean
		{
			if (!isEnoughtMana && !this.perkInstance.active && !this._freeCost)
			{
				DialogDepletionMana.show();
				return true;
			}
			return false;
		}

		protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var skill:PacketRoundSkill = packet as PacketRoundSkill;
					if (this.perkInstance == null || this.hero == null)
						return;
					if (skill.playerId != this.hero.id)
						return;
					if (skill.type != this.perkInstance.code)
						return;
					this.perkInstance.isSent = false;

					if (this._freeCost && skill.state == PacketServer.SKILL_ACTIVATE && this.pekManaCost > 0)
						FooterGame.setFreeClothesPerk(false);
					break;
				case PacketRoomRound.PACKET_ID:
					if ((packet as PacketRoomRound).type == PacketServer.ROUND_START)
						updateState();
					break;
			}
		}

		protected function onKey(e:KeyboardEvent):void
		{
			if (e.keyCode != (this.perkInstance as IHotKey).hotkey)
				return;
			onClick(null);
		}
	}
}
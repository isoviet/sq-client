package game.mainGame.entity.magic
{
	import flash.display.MovieClip;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.ISideObject;
	import game.mainGame.SideIconView;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import screens.ScreenGame;
	import views.GameBonusImageView;
	import views.GameBonusValueView;

	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkillAction;

	import utils.starling.StarlingAdapterSprite;

	public class GoldSack extends EnergyObject implements ISideObject
	{
		private var _isVisible: Boolean = false;

		static private const AWARD_TYPE:Array =
		[
			{'count': 3,	'image': ImageIconNut,		'text': gls("получил орешки")},
			{'count': 1,	'image': ImageIconCoins,	'text': gls("получил монетку")},
			{'count': 2,	'image': ImageIconMana,		'text': gls("получил ману")},
			{'count': 2,	'image': ImageIconEnergy,	'text': gls("получил энергию")},
			{						'text': gls("ничего не получил")}
		];

		public function GoldSack()
		{
			this.perkCode = PerkClothesFactory.LEPRECHAUN;
			this.messageId = ChatDeadServiceMessage.LEPRECHAUN_GOLD_SACK;

			super();
		}

		override protected function get animation():MovieClip
		{
			return new GoldSackView();
		}

		override protected function get beginAnimation():MovieClip
		{
			return new GoldSackBegin();
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundSkillAction.PACKET_ID:
					var packetAction:PacketRoundSkillAction = packet as PacketRoundSkillAction;
					if (packetAction.type != this.perkCode)
						return;

					if (packetAction.targetId != this.playerId)
						return;

					if (!this.gameInst)
						return;

					var hero:Hero = this.gameInst.squirrels.get(packetAction.playerId);
					var leprechaun:Hero = this.gameInst.squirrels.get(packetAction.targetId);
					hero.heroView.showGetBonusAnimation(new this.animation.constructor());
					if (packetAction.data >= 0)
					{
						ScreenGame.sendMessage(packetAction.playerId, AWARD_TYPE[packetAction.data]['text'], this.messageId);
						showLeprechaunAward(packetAction.data, hero);
						if (leprechaun != null && leprechaun != hero && !leprechaun.isDead)
							showLeprechaunAward(packetAction.data, leprechaun);
					}

					if (!this.gameInst.squirrels.isSynchronizing)
						return;

					this.gameInst.map.destroyObjectSync(this, true);
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function showLeprechaunAward(type:int, hero:Hero):void
		{
			if (!('count' in AWARD_TYPE[type]))
				return;

			var awardValueView:GameBonusValueView = new GameBonusValueView(AWARD_TYPE[type]['count'], hero.x, hero.y);
			Game.gameSprite.addChild(awardValueView);

			var awardImage:MovieClip = new AWARD_TYPE[type]['image'];
			awardImage.scaleX = awardImage.scaleY = Math.min(Number(20 / awardImage.width), Number(20 / awardImage.height));

			var acornImageView:GameBonusImageView = new GameBonusImageView(awardImage, awardValueView.x + int(awardValueView.width), awardValueView.y);
			Game.gameSprite.addChild(acornImageView);
		}

		public function get sideIcon():StarlingAdapterSprite
		{
			return new SideIconView(SideIconView.COLOR_PINK, SideIconView.ICON_GOLD_SACK);
		}

		public function get showIcon():Boolean
		{
			return true;
		}

		public function get isVisible():Boolean {
			return _isVisible;
		}

		public function set isVisible(value: Boolean): void {
			_isVisible = false;
		}
	}
}
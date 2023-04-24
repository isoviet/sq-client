package game.mainGame.perks
{
	import clans.Clan;
	import clans.PerkTotems;
	import clans.TotemsData;
	import game.gameData.ShamanTreeManager;
	import game.mainGame.perks.clothes.PerkClothes;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import game.mainGame.perks.dragon.DragonPerkFactory;
	import game.mainGame.perks.dragon.PerkDragon;
	import game.mainGame.perks.hare.HarePerkFactory;
	import game.mainGame.perks.hare.PerkHare;
	import game.mainGame.perks.mana.PerkFactory;
	import game.mainGame.perks.mana.PerkMana;
	import game.mainGame.perks.scrat.PerkCharacter;
	import game.mainGame.perks.shaman.PerkShaman;
	import game.mainGame.perks.shaman.PerkShamanFactory;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.structs.PacketLoginShamanInfo;
	import protocol.packages.server.structs.PacketRoundSkillsItemsCharactersSkills;

	public class PerkController
	{
		public var perksMana:Vector.<PerkMana> = new Vector.<PerkMana>();
		public var perksClothes:Vector.<PerkClothes> = new Vector.<PerkClothes>();
		public var perksHare:Vector.<PerkHare> = new Vector.<PerkHare>();
		public var perksCharacter:Vector.<PerkCharacter> = new Vector.<PerkCharacter>();
		public var perksDragon:Vector.<PerkDragon> = new Vector.<PerkDragon>;
		public var perksTotem:Vector.<PerkTotems> = new Vector.<PerkTotems>();
		public var perksShaman:Vector.<PerkShaman> = new Vector.<PerkShaman>();

		private var hero:Hero = null;
		private var clothesPerkLevel:Object = {};
		private var clothesPerkInited:Boolean = false;

		public function PerkController(hero:Hero):void
		{
			this.hero = hero;
		}

		public function getPerkLevel(id:int):int
		{
			if (id in clothesPerkLevel)
				return clothesPerkLevel[id];
			return -1;
		}

		public function initShamanPerk(shamanSkills:Vector.<PacketLoginShamanInfo>):void
		{
			for (var i:int = 0; i < shamanSkills.length; i++)
			{
				if (shamanSkills[i].levelFree == 0)
					continue;
				var paidAvailable:int = ShamanTreeManager.paidScoreAvailable(shamanSkills[i].levelFree, shamanSkills[i].levelPaid);
				this.perksShaman.push(new (PerkShamanFactory.getClassById(shamanSkills[i].skillId) as Class)(this.hero, [shamanSkills[i].levelFree, paidAvailable]));
			}
		}

		public function initManaPerk():void
		{
			if (!this.perksMana)
				this.perksMana = new Vector.<PerkMana>();

			for (var i:int = 0; i < PerkFactory.PERK_TOOLBAR.length; i++)
			{
				var perkClass:Class = PerkFactory.getPerkClass(PerkFactory.PERK_TOOLBAR[i]);
				var perk:PerkMana = new perkClass(this.hero);
				perk.code = PerkFactory.PERK_TOOLBAR[i];
				this.perksMana.push(perk);
			}
		}

		public function initDragonPerks():void
		{
			for each (var perkClass:Class in DragonPerkFactory.perkCollection)
			{
				var perk:PerkDragon = new perkClass(this.hero);
				perk.code = DragonPerkFactory.getId(perkClass);
				this.perksDragon.push(perk);
			}
		}

		public function initHarePerks():void
		{
			for each (var perkClass:Class in HarePerkFactory.perkCollection)
			{
				var perk:PerkHare = new perkClass(this.hero);
				perk.code = HarePerkFactory.getId(perkClass);
				this.perksHare.push(perk);
			}
		}

		public function initClothesPerks(ids:Vector.<PacketRoundSkillsItemsCharactersSkills>):void
		{
			if (this.clothesPerkInited)
				return;
			this.clothesPerkInited = true;

			for (var i:int = 0; i < ids.length; i++)
			{
				var perkClass:Class = PerkClothesFactory.getPerkClass(ids[i].skill);
				if (perkClass == null)
					continue;
				var perk:PerkClothes = new perkClass(this.hero);
				perk.perkLevel = ids[i].level;
				perk.code = ids[i].skill;
				this.perksClothes.push(perk);

				this.clothesPerkLevel[ids[i].skill] = ids[i].level;
			}
		}

		public function updateTotemPerk(clan:Clan):void
		{
			for (var i:int = 0; i < this.perksTotem.length; i++)
			{
				if (clan.totemsSlot.haveTotem(this.perksTotem[i].id))
					continue;

				this.perksTotem[i].dispose();
				this.perksTotem.splice(i, 1);
				i--;
			}

			for each (var slot:Object in clan.totemsSlot.slotData)
			{
				var perkTotemClass:Class = TotemsData.getPerkClass(slot['totem_id']);

				if (perkTotemClass == null)
					continue;

				var perkExist:Boolean = false;

				for each (var perk:PerkTotems in this.perksTotem)
				{
					if (perk.id != slot['totem_id'])
						continue;

					perkExist = true;
				}

				if (!perkExist)
				{
					var newPerk:PerkTotems = new perkTotemClass(this.hero, clan.totems.getTotemBonus(slot['totem_id']));
					this.perksTotem.push(newPerk);
				}
			}
		}

		public function resetRound():void
		{
			for each (var perk:Perk in this.perksMana)
				perk.resetRound();
			for each (perk in this.perksClothes)
				perk.resetRound();
			for each (perk in this.perksCharacter)
				perk.resetRound();
			for each (perk in this.perksHare)
				perk.resetRound();
			for each (perk in this.perksDragon)
				perk.resetRound();
			for each (var perkOld:PerkOld in this.perksShaman)
				perkOld.resetRound();
		}

		public function updatePerks(timeStep:Number):void
		{
			for each (var perk:Perk in this.perksMana)
				perk.update(timeStep);
			for each (perk in this.perksClothes)
				perk.update(timeStep);
			for each (perk in this.perksCharacter)
				perk.update(timeStep);
			for each (var perkOld:PerkOld in this.perksShaman)
				perkOld.update(timeStep);
			for each (perk in this.perksHare)
				perk.update(timeStep);
			for each (perk in this.perksDragon)
				perk.update(timeStep);
		}

		public function deactivateClothesPerks():void
		{
			for each (var perk:PerkClothes in this.perksClothes)
			{
				if (!perk.active)
					continue;
				Connection.sendData(PacketClient.ROUND_SKILL, perk.code, PacketServer.SKILL_DEACTIVATE, 0, "");
			}
		}

		public function deactivateManaPerks():void
		{
			for each (var perk:PerkMana in this.perksMana)
			{
				if (!perk.active)
					continue;
				Connection.sendData(PacketClient.ROUND_SKILL, perk.code, PacketServer.SKILL_DEACTIVATE, 0, "");
			}
		}

		public function dispose():void
		{
			for each (var perk:Perk in this.perksMana)
				perk.dispose();

			for each (perk in this.perksClothes)
				perk.dispose();

			for each (perk in this.perksCharacter)
				perk.dispose();

			for each (perk in this.perksHare)
				perk.dispose();

			for each (perk in this.perksDragon)
				perk.dispose();

			for each (var perkOld:PerkOld in this.perksShaman)
				perkOld.dispose();

			for each (var perkTotem:PerkTotems in this.perksTotem)
				perkTotem.dispose();

			this.perksHare = null;
			this.perksClothes = null;
			this.perksCharacter = null;
			this.perksMana = null;
			this.perksDragon = null;
			this.perksShaman = null;
			this.perksTotem = null;
		}

		public function get squirrelPerksAvailable():Boolean
		{
			return this.perksMana.length + this.perksClothes.length > 0;
		}
	}
}
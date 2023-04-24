package game.gameData
{
	import flash.text.TextFormat;

	import dialogs.Dialog;
	import dialogs.DialogInfo;
	import dialogs.shaman.DialogShamanBuyBranch;
	import dialogs.shaman.DialogShamanBuySkill;
	import dialogs.shaman.DialogShamanReset;
	import dialogs.shaman.DialogShamanSkill;
	import events.DiscountEvent;
	import game.mainGame.perks.shaman.PerkShamanFactory;
	import views.shamanTree.ShamanSkillView;

	import com.api.Player;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketBranches;
	import protocol.packages.server.PacketBuy;

	public class ShamanTreeManager
	{
		static public const SHAMAN_BRANCH_PRICE:int = 100;
		static public const SHAMAN_RESET_PRICE:int = 10;

		static public const MENTOR:int = 0;
		static public const LEADER:int = 1;
		static public const CREATOR:int = 2;
		static public const EMPTY:int = 3;

		static public const SKILL_MAX_RATE:int = 6;

		static public const BRANCH_TYPES:Array = [gls("Наставник"), gls("Вожак"), gls("Творец")];

		static public const LEVEL_NUMBERS:Array = [ShamanLevelUp0, ShamanLevelUp1, ShamanLevelUp2, ShamanLevelUp3, ShamanLevelUp4, ShamanLevelUp5, ShamanLevelUp6, ShamanLevelUp7, ShamanLevelUp8, ShamanLevelUp9];

		static public const BRANCHES:Array = [
			[PerkShamanFactory.PERK_BIG_ACORN,
				PerkShamanFactory.PERK_MADNESS, PerkShamanFactory.PERK_ADORATION, PerkShamanFactory.PERK_WALRUS,
				PerkShamanFactory.PERK_THIN_ICE, PerkShamanFactory.PERK_ICE_CUBE, PerkShamanFactory.PERK_RUNE,
				PerkShamanFactory.PERK_HIGH_FRICTION, PerkShamanFactory.PERK_SPEEDY_AURA, PerkShamanFactory.PERK_POINTER,
				PerkShamanFactory.PERK_LAGGING, PerkShamanFactory.PERK_INSPIRED, PerkShamanFactory.PERK_FRIEND,
				PerkShamanFactory.PERK_TELEPORT, PerkShamanFactory.PERK_SQUIRRELS_HAPPINESS, PerkShamanFactory.PERK_FAVORITE,
				PerkShamanFactory.PERK_MASS_IMMORTAL],
			[PerkShamanFactory.PERK_BIG_HEAD,
				PerkShamanFactory.PERK_CLOUD, PerkShamanFactory.PERK_SATIETY, PerkShamanFactory.PERK_SURRENDER,
				PerkShamanFactory.PERK_SLOWFALL, PerkShamanFactory.PERK_TELEKINESIS, PerkShamanFactory.PERK_FORTH_TELEPORT,
				PerkShamanFactory.PERK_CAPTAIN_HOOK, PerkShamanFactory.PERK_SPEEDY, PerkShamanFactory.PERK_LAZY,
				PerkShamanFactory.PERK_TIME_MASTER, PerkShamanFactory.PERK_RUNNING_CAST, PerkShamanFactory.PERK_PATTER,
				PerkShamanFactory.PERK_POCKET_TELEPORT, PerkShamanFactory.PERK_HEAVENS_GATE, PerkShamanFactory.PERK_CONCENTRATION,
				PerkShamanFactory.PERK_IMMORTAL],
			[PerkShamanFactory.PERK_DYNAMITE,
				PerkShamanFactory.PERK_HELIUM, PerkShamanFactory.PERK_WEIGHT, PerkShamanFactory.PERK_HELPER,
				PerkShamanFactory.PERK_LEAP, PerkShamanFactory.PERK_ONE_WAY_TICKET, PerkShamanFactory.PERK_TIMER,
				PerkShamanFactory.PERK_STRONGHOLD, PerkShamanFactory.PERK_SPIRITS, PerkShamanFactory.PERK_TIME_SLOWDOWN,
				PerkShamanFactory.PERK_STORM, PerkShamanFactory.PERK_GRAVITY, PerkShamanFactory.PERK_DESTROYER,
				PerkShamanFactory.PERK_DRAWING_MODE, PerkShamanFactory.PERK_PORTAL_MASTER, PerkShamanFactory.PERK_HOISTMAN,
				PerkShamanFactory.PERK_SAFE_WAY]
		];

		static private var _spentFeathers:Array = [0, 0, 0];
		static private var _spentIrrealFeathers:Array = [0, 0, 0];
		static private var _isPaidSkills:Boolean = false;

		static private var currentId:int = EMPTY;
		static private var boughtBranches:Array = [];

		static private var callback:Function = null;

		static private var dialogSkill:Dialog = null;
		static private var dialogReset:Dialog = null;
		static private var dialogFirstLearning:Dialog = null;
		static private var dialogBuyBranch:Dialog = null;
		static private var dialogBuyFirstLearning:Dialog = null;

		static private var newBranchId:int = EMPTY;
		static private var newSkillId:int = -1;

		static public function init():void
		{
			Connection.listen(onPacket, [PacketBranches.PACKET_ID, PacketBuy.PACKET_ID]);

			Game.self.addEventListener(PlayerInfoParser.SHAMAN_EXP | PlayerInfoParser.SHAMAN_SKILLS, onPlayerLoaded);

			DiscountManager.addEventListener(DiscountEvent.END, onDiscountEnd);
			DiscountManager.addEventListener(DiscountEvent.BONUS_START, onBonus);
			DiscountManager.addEventListener(DiscountEvent.BONUS_END, onBonus);
		}

		static public function get currentBranch():int
		{
			return currentId;
		}

		static public function isBranchBought(branchId:int):Boolean
		{
			return boughtBranches.indexOf(branchId) != -1;
		}

		static public function getCurrentFeathers(branchId:int):int
		{
			return Game.self.feathers - (branchId == EMPTY ? 0 : _spentFeathers[branchId]);
		}

		static public function getNeedFeathers(branchId:int, position:int):int
		{
			return getFeathersCount(position) - (_spentFeathers[branchId] + _spentIrrealFeathers[branchId]);
		}

		static public function setSpentFeathers(branchId:int, value:int, irrealValue:int):void
		{
			_spentFeathers[branchId] = value;
			_spentIrrealFeathers[branchId] = irrealValue;
		}

		static public function get isPaidSkills():Boolean
		{
			return _isPaidSkills;
		}

		static public function set isPaidSkills(value:Boolean):void
		{
			_isPaidSkills = value;
		}

		static public function paidScoreAvailable(freeScore:int, paidScore:int):int
		{
			var score:int = 0;

			switch (freeScore)
			{
				case 0:
					score = 0;
					break;
				case 1:
				case 2:
					score = 2;
					break;
				case 3:
					score = 3;
					break;
			}

			return Math.min(score, paidScore);
		}

		static public function buyBranch(branchId:int):void
		{
			if (!dialogBuyBranch)
				dialogBuyBranch = new DialogShamanBuyBranch();

			(dialogBuyBranch as DialogShamanBuyBranch).branch = branchId;
			dialogBuyBranch.show();
		}

		static public function resetBranch():void
		{
			if (!dialogReset)
				dialogReset = new DialogShamanReset();

			dialogReset.show();
		}

		static public function changeBranch(branchId:int):void
		{
			Connection.sendData(PacketClient.CHANGE_SHAMAN_BRANCH, branchId);
		}

		static public function learnSkill(id:int, level:int, gold_cost:int = 0):void
		{
			if (currentId == ShamanTreeManager.EMPTY)
			{
				for (var i:int = 0; i < ShamanTreeManager.BRANCHES.length; i++)
				{
					if (ShamanTreeManager.BRANCHES[i].indexOf(id) == -1)
						continue;

					newBranchId = i;
					newSkillId = id;

					if (dialogFirstLearning)
						dialogFirstLearning.hide();

					dialogFirstLearning = new DialogInfo(gls("Изучение навыка"), gls("Ты собираешься выучить 1-й уровень навыка «{0}», после чего тебе будет доступна только профессия «{1}».\n\nДругие профессии будут недоступны. Чтобы выучить навыки новой профессии, нужно её купить и создать дополнительный набор навыков. Все перья будут доступны для изучения навыков новой профессии.", PerkShamanFactory.perkData[PerkShamanFactory.getClassById(newSkillId)]['name'], BRANCH_TYPES[newBranchId]), true, selectBranch, 430, new TextFormat(null, 14, 0x1f1f1f));
					dialogFirstLearning.show();
					return;
				}
			}

			if (level < 3)
				Connection.sendData(PacketClient.LEARN_SHAMAN_SKILL, id);
			else
			{
				if (!ShamanTreeManager.isPaidSkills)
				{
					if (!dialogBuyFirstLearning)
						dialogBuyFirstLearning = new DialogShamanBuySkill();

					(dialogBuyFirstLearning as DialogShamanBuySkill).skill = id;
					(dialogBuyFirstLearning as DialogShamanBuySkill).cost = gold_cost;
					dialogBuyFirstLearning.show();
				}
				else
					Game.buyWithoutPay(PacketClient.BUY_SHAMAN_SKILL, gold_cost, 0, Game.selfId, id);
			}
		}

		static public function showDialogSkill(skill:ShamanSkillView):void
		{
			if (!dialogSkill)
				dialogSkill = new DialogShamanSkill();

			(dialogSkill as DialogShamanSkill).showSkill(skill);
		}

		static public function updateDialogSkill():void
		{
			if (!dialogSkill)
				return;

			(dialogSkill as DialogShamanSkill).updateSkill();
		}

		static public function set updateFunction(value:Function):void
		{
			callback = value;
		}

		static public function getStatusForBranch(branchId:int):String
		{
			switch (branchId)
			{
				case MENTOR:
					return gls("<body><span class='bold'>Профессия «Наставник»</span>\nЭта профессия позволяет шаману оказывать прямое воздействие на белок.</body");
				case LEADER:
					return gls("<body><span class='bold'>Профессия «Вожак»</span>\nЭта профессия усиливает шамана с помощью дополнительных навыков.</body");
				case CREATOR:
					return gls("<body><span class='bold'>Профессия «Творец»</span>\nЭта профессия даёт шаману навыки для воздействия на физические объекты.</body");
			}
			return "";
		}

		static private function onDiscountEnd(e:DiscountEvent):void
		{
			Logger.add("onDiscountEnd", e.id, DiscountManager.SHAMAN_SKILL);
			if (e.id != DiscountManager.SHAMAN_SKILL)
				return;
			Logger.add("onDiscountEnd2", dialogSkill == null);
			if (dialogSkill == null)
				return;
			if (dialogSkill.visible)
			{
				var skill:ShamanSkillView = (dialogSkill as DialogShamanSkill).currentSkill;
				dialogSkill.hide();
				showDialogSkill(skill);
			}
		}

		static private function onBonus(e:DiscountEvent):void
		{
			if (e.id != DiscountManager.SHAMAN_SKILL)
				return;
			if (!dialogReset)
				return;
			if (dialogReset.visible)
				resetBranch();
		}

		static private function selectBranch():void
		{
			if (newBranchId == ShamanTreeManager.EMPTY)
				return;

			Connection.sendData(PacketClient.CHANGE_SHAMAN_BRANCH, newBranchId);
			Connection.sendData(PacketClient.LEARN_SHAMAN_SKILL, newSkillId);
		}

		static private function getFeathersCount(position:int):int
		{
			if (position == 0)
				return 0;
			else if (position < 4)
				return 2;
			else if (position < 7)
				return 6;
			else if (position < 10)
				return 12;
			else if (position < 13)
				return 21;
			else if (position < 16)
				return 30;
			return 33;
		}

		static private function onPlayerLoaded(player:Player):void
		{
			if (player) {/*unused*/}

			if (callback != null)
				callback();
		}

		static private function onPacket(packet: AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketBranches.PACKET_ID:
					var branches: PacketBranches = packet as PacketBranches;

					if (currentId != EMPTY && currentId != branches.current && dialogSkill)
						dialogSkill.hide();

					if (dialogReset)
						dialogReset.hide();

					if (dialogBuyBranch)
						dialogBuyBranch.hide();

					currentId = branches.current;

					boughtBranches = [];
					if (branches.bought & 0x01)
						boughtBranches.push(MENTOR);
					if (branches.bought & 0x02)
						boughtBranches.push(LEADER);
					if (branches.bought & 0x04)
						boughtBranches.push(CREATOR);
					break;
				case PacketBuy.PACKET_ID:
					var buy: PacketBuy = packet as PacketBuy;

					if (buy.status != PacketServer.BUY_SUCCESS || buy.playerId != Game.selfId)
						break;
					if (buy.goodId == PacketClient.BUY_SHAMAN_BRANCH_RESET && dialogSkill)
						dialogSkill.hide();
					break;
			}
		}
	}
}
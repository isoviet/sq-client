package protocol.packages
{
	import protocol.packages.server.*;
	import flash.utils.ByteArray;

	public class ManagerPackets
	{
		private static var _instance: ManagerPackets = null;

		private var collections: Array = [
			/*  0 */		PacketMinType,
			/*  1 */		PacketHello,
			/*  2 */		PacketGuard,
			/*  3 */		PacketAdminInfo,
			/*  4 */		PacketAdminInfoClan,
			/*  5 */		PacketAdminMessage,
			/*  6 */		PacketSessionInfo,
			/*  7 */		PacketLogin,
			/*  8 */		PacketInfo,
			/*  9 */		PacketInfoNet,
			/*  10 */		PacketRoom,
			/*  11 */		PacketOnline,
			/*  12 */		PacketPlayWith,
			/*  13 */		PacketBan,
			/*  14 */		PacketBalance,
			/*  15 */		PacketFeathers,
			/*  16 */		PacketEnergyLimits,
			/*  17 */		PacketEnergy,
			/*  18 */		PacketMana,
			/*  19 */		PacketExperience,
			/*  20 */		PacketShamanExperience,
			/*  21 */		PacketExpirations,
			/*  22 */		PacketFriends,
			/*  23 */		PacketFriendsOnline,
			/*  24 */		PacketEvents,
			/*  25 */		PacketBuy,
			/*  26 */		PacketInvite,
			/*  27 */		PacketReturnedFriend,
			/*  28 */		PacketDailyQuests,
			/*  29 */		PacketLatency,
			/*  30 */		PacketRename,
			/*  31 */		PacketXsollaSignature,
			/*  32 */		PacketSmiles,
			/*  33 */		PacketBirthday,
			/*  34 */		PacketOffers,
			/*  35 */		PacketDailyBonusData,
			/*  36 */		PacketProduceInfo,
			/*  37 */		PacketStorageInfo,
			/*  38 */		PacketFlags,
			/*  39 */		PacketTraining,
			/*  40 */		PacketPromoBonus,
			/*  41 */		PacketBundles,
			/*  42 */		PacketBonuses,
			/*  43 */		PacketAwardCounters,
			/*  44 */		PacketCollections,
			/*  45 */		PacketDecorations,
			/*  46 */		PacketTrophies,
			/*  47 */		PacketHolidayBalance,
			/*  48 */		PacketHolidayLottery,
			/*  49 */		PacketRatingScores,
			/*  50 */		PacketRatingDivision,
			/*  51 */		PacketRatingTransition,
			/*  52 */		PacketRatingTop,
			/*  53 */		PacketGifts,
			/*  54 */		PacketGiftsTarget,
			/*  55 */		PacketGiftsAccept,
			/*  56 */		PacketDeferredBonus,
			/*  57 */		PacketDeferredBonusAccept,
			/*  58 */		PacketChatMessage,
			/*  59 */		PacketChatHistory,
			/*  60 */		PacketCollectionAssemble,
			/*  61 */		PacketCollectionExchange,
			/*  62 */		PacketCollectionPickup,
			/*  63 */		PacketClothesStorage,
			/*  64 */		PacketClothesCloseout,
			/*  65 */		PacketClothesWear,
			/*  66 */		PacketClothesExpired,
			/*  67 */		PacketClothesSlot,
			/*  68 */		PacketRoomJoin,
			/*  69 */		PacketRoomLeave,
			/*  70 */		PacketRoomRequestWorld,
			/*  71 */		PacketRoomRound,
			/*  72 */		PacketRoomPrivate,
			/*  73 */		PacketRoundHero,
			/*  74 */		PacketRoundCastBegin,
			/*  75 */		PacketRoundCastEnd,
			/*  76 */		PacketRoundNut,
			/*  77 */		PacketRoundHollow,
			/*  78 */		PacketRoundDie,
			/*  79 */		PacketRoundRespawn,
			/*  80 */		PacketRoundTeam,
			/*  81 */		PacketRoundFrags,
			/*  82 */		PacketRoundSynchronizer,
			/*  83 */		PacketRoundShaman,
			/*  84 */		PacketRoundBeasts,
			/*  85 */		PacketRoundSync,
			/*  86 */		PacketRoundWorld,
			/*  87 */		PacketRoundSkills,
			/*  88 */		PacketRoundSkill,
			/*  89 */		PacketRoundSkillAction,
			/*  90 */		PacketRoundSkillShaman,
			/*  91 */		PacketRoundCommand,
			/*  92 */		PacketRoundCompensation,
			/*  93 */		PacketRoundElement,
			/*  94 */		PacketRoundElements,
			/*  95 */		PacketRoundSmile,
			/*  96 */		PacketRoundZombie,
			/*  97 */		PacketMapsList,
			/*  98 */		PacketMapsMap,
			/*  99 */		PacketMapsId,
			/*  100 */		PacketMapsCheck,
			/*  101 */		PacketClanState,
			/*  102 */		PacketClanInfo,
			/*  103 */		PacketClanApplication,
			/*  104 */		PacketClanBalance,
			/*  105 */		PacketClanTransaction,
			/*  106 */		PacketClanMembers,
			/*  107 */		PacketClanPrivateRooms,
			/*  108 */		PacketClanJoin,
			/*  109 */		PacketClanLeave,
			/*  110 */		PacketClanSubstitute,
			/*  111 */		PacketClanTotemBonus,
			/*  112 */		PacketDiscountBonus,
			/*  113 */		PacketDiscountClothes,
			/*  114 */		PacketDiscountUse,
			/*  115 */		PacketBranches,
			/*  116 */		PacketTransfer,
			/*  117 */		PacketNyModeTake,
			/*  118 */		PacketNyModePlace,
			/*  119 */		PacketRequestPromo
		];

		public function ManagerPackets()
		{
		}

		public static function get instance(): ManagerPackets {
			if(_instance == null)
				_instance = new ManagerPackets();
			return _instance;
		}

		public function getPackageById(index: int, buff: ByteArray): AbstractServerPacket {
			return index < collections.length && index > -1 ? (new collections[index](buff) as AbstractServerPacket) : null;
		}

		public function createPackageById(index: int, buff: Array): AbstractServerPacket {
			if (index >= collections.length || index < 0)
				return null;

			var packet: AbstractServerPacket = new collections[index]();
			packet.read(buff);
			return packet;
		}

		public function getSize(): int {
			return collections.length;
		}
	}
}

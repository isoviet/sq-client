package game.gameData
{
	import clans.ClanManager;

	public class GameConfig
	{
		static private var config:Object;
		static public var loadAll:Boolean = true;

		static public function load():void
		{
			config = ConfigData.data;

			if (!loadAll)
				return;
			CONFIG::client
			{
				AwardManager.init();
				BundleManager.init();
				ClanManager.init();
				ClothesManager.init();
				CloseoutManager.init();
				ClothesData.init();
				OutfitData.init();
				DailyBonusManager.init();
				DailyQuestManager.init();
				DeferredBonusManager.init();
				DialogOfferManager.init();
				InteriorManager.init();
				EducationQuestManager.init();
				Experience.init();
				ExpirationsManager.init();
				HolidayManager.init();
				PowerManager.init();
				PromoManager.init();
				RatingManager.init();
				SettingsStorage.init();
				ShamanTreeManager.init();
				VIPManager.init();
				HotWeekendManager.init();
				EmotionManager.init();
			}
		}

		static public function getVIPCoinsPrice(id:int):int
		{
			if (!('coins_price' in VIP[id]))
				return 0;
			return int(VIP[id]['coins_price']);
		}

		static public function getVIPDuration(id:int):int
		{
			if (!('duration' in VIP[id]))
				return 0;
			return VIP[id]['duration'];
		}

		static public function getExperienceValue(level:int):int
		{
			if (level >= experience.length)
				return experience[experience.length - 1]['experience'];
			return experience[level]['experience'];
		}

		static public function getExperienceTitle(level:int):String
		{
			if (level >= experience.length)
				return experience[experience.length - 1]['title'];
			return experience[level]['title'];
		}

		static public function get maxLevel():int
		{
			return experience.length;
		}

		static public function get maxExperience():int
		{
			return experience[experience.length - 1]['experience'];
		}

		static public function get packageCount():int
		{
			return packages.length;
		}

		static public function getPackageCoinsPrice(id:int):int
		{
			var discount:Number = 1;
			CONFIG::client
			{
				discount = CloseoutManager.closeoutDiscount(id);
			}
			return packages[id]['coins_price'] * discount;
		}

		static public function getPackageMaxLevel(id:int):int
		{
			return packages[id]['max_level'];
		}

		static public function getPackageAccessories(id:int):Array
		{
			return packages[id]['accessories'];
		}

		static public function getPackageSkills(id:int):Array
		{
			var answer:Array = [];
			for (var perkId:String in packages[id]['skills'])
				answer.push(int(perkId));
			return answer;
		}

		static public function getPackageSkillLevel(id:int, perk:int):int
		{
			if (perk in packages[id]['skills'])
				return packages[id]['skills'][perk];
			return -1;
		}

		static public function get outfitCount():int
		{
			return outfits.length;
		}

		static public function getOutfitRentCoinsPrice(id:int):int
		{
			return outfits[id]['rent_coins_price'];
		}

		static public function getOutfitCharacter(id:int):int
		{
			return outfits[id]['character'];
		}

		static public function getOutfitPackages(id:int):Array
		{
			return outfits[id]['packages'];
		}

		static public function getEnergyCoinsPrice():int
		{
			return 5;
		}

		static public function getManaCoinsPrice():int
		{
			return 5;
		}

		static public function getManaRegenerationCoinsPrice(id:int):int
		{
			return id == 0 ? 49 : 239;
		}

		static public function get accessoryCount():int
		{
			return accessories.length;
		}

		static public function getAccessoryCoinsPrice(id:int):int
		{
			return accessories[id]['coins_price'];
		}

		static public function getAccessoryType(id:int):int
		{
			return accessories[id]['place'];
		}

		static public function getAccessoryCharacter(id:int):int
		{
			if ('character' in accessories[id])
				return accessories[id]['character'];
			return -1;
		}

		static public function getSmilesCoinsPrice(id:int):int
		{
			return smiles[id]['coins_price'];
		}

		static public function getSmilesElements(id:int):Array
		{
			return smiles[id]['elements'];
		}

		static public function getLeagueValue(id:int, type:int):int
		{
			return leagues[type][id]['min_scores'];
		}

		static public function getLeagueName(id:int, type:int):String
		{
			return leagues[type][id]['name'];
		}

		static public function getLeagueCount(type:int):int
		{
			if (type >= leagues.length)
				return 0;
			return (leagues[type] as Array).length;
		}

		static public function getCollectionRegularPrice(id:int):int
		{
			var discount:Number = 1.0;
			CONFIG::client
			{
				if (DiscountManager.haveDiscount(DiscountManager.COLLECTIONS))
					discount = DiscountManager.DISCOUNT_COLLECTIONS;
				if (DiscountManager.haveDiscount(DiscountManager.COLLECTIONS_NP))
					discount = DiscountManager.DISCOUNT_COLLECTIONS_NP;
			}
			return collections['regular_coins_price'][id] * discount;
		}

		static public function getCollectionTrophyPrice(id:int):Array
		{
			return collections['trophy_set'][id];
		}

		static public function getCollectionUniqueExperience(id:int):int
		{
			return collections['unique_experience'][id];
		}

		static public function getCollectionUniqueSet(id:int):Array
		{
			return collections['unique_set'][id];
		}

		static public function getDecorationCoinsPrice(id:int):int
		{
			return decorations[id]['coins_price']
		}

		static public function getDecorationNutsPrice(id:int):int
		{
			return decorations[id]['nuts_price']
		}

		static public function getDecorationType(id:int):int
		{
			return decorations[id]['type']
		}

		static public function getSkillManaCost(id:int):int
		{
			return skills[id];
		}

		static public function get itemFastCount():int
		{
			return 1;
		}

		static public function get itemSetCount():int
		{
			return 10
		}

		static public function getItemNutsPrice(id:int):int
		{
			if (id >= items.length)
				return 0;
			return items[id]['nuts_price'];
		}

		static public function getItemCoinsPrice(id:int):int
		{
			if (id >= items.length)
				return 0;
			return items[id]['coins_set_price'];
		}

		static public function getItemFastCoinsPrice(id:int):int
		{
			if (id >= items.length)
				return 0;
			return items[id]['fast_coins_price'];
		}

		static public function getItemFastCoinsCount(id:int):int
		{
			if (id >= items.length)
				return 0;
			return items[id]['fast_count'];
		}

		static public function get banList():Array
		{
			return bans['bans'];
		}

		static public function get shamanLevels():Array
		{
			return shaman['levels'];
		}

		static public function get shamanMaxLevel():int
		{
			return shaman['MAX_LEVEL'];
		}

		static private function get VIP():Array
		{
			return config['player']['vip'];
		}

		static private function get skills():Array
		{
			return config['player']['skills'];
		}

		static private function get experience():Array
		{
			return config['player']['levels'];
		}

		static private function get packages():Array
		{
			return config['clothes']['packages'];
		}

		static private function get accessories():Array
		{
			return config['clothes']['accessories'];
		}

		static private function get outfits():Array
		{
			return config['clothes']['outfits'];
		}

		static private function get smiles():Array
		{
			return config['smiles']['packages'];
		}

		static private function get leagues():Array
		{
			return ratings['leagues'];
		}

		static private function get ratings():Object
		{
			return config['ratings'];
		}

		static private function get collections():Object
		{
			return config['collections'];
		}

		static private function get decorations():Object
		{
			return config['interior'];
		}

		static private function get locations():Object
		{
			//all info
			return config['maps'];
		}

		static private function get items():Array
		{
			return config['items']['info'];
		}

		static private function get bans():Object
		{
			return config['bans'];
		}

		static private function get quests():Object
		{
			//award, info
			return config['quest'];
		}

		static private function get shaman():Object
		{
			//exp and skills
			return config['shaman'];
		}
	}
}
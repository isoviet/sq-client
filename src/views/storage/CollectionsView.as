package views.storage
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import buttons.ButtonTab;
	import buttons.ButtonTabGroup;
	import game.gameData.CollectionManager;
	import game.gameData.CollectionsData;
	import game.gameData.NotificationManager;
	import views.NotificationView;

	import utils.Counter;

	public class CollectionsView extends Sprite
	{
		static private const LOCATIONS_GRAPHICS:Array = [
			{'button': "ButtonLocation1",	'title': "TitleIslands"},
			{'button': "ButtonLocation7",	'title': "TitleBattle"},
			{'button': "ButtonLocation3",	'title': "TitleMarsh"},
			{'button': "ButtonLocation6",	'title': "TitleStorm"},
			{'button': "ButtonLocation8",	'title': "TitleHard"},
			{'button': "ButtonLocation4",	'title': "TitleDesert"},
			{'button': "ButtonLocation5",	'title': "TitleAnomaly"}
		];

		static private const GLOW_FILTER:Array = [new GlowFilter(0xFFFFFF, 1, 3, 3, 5)];

		static private var _instance:CollectionsView = null;

		private var buttonsCounters:Object = {};
		private var collectionSets:Object = null;

		private var exchangeSet:CollectionExchangeView = null;

		private var notifications:Object = {};

		public function CollectionsView():void
		{
			super();
			_instance = this;

			init();
		}

		static public function get inited():Boolean
		{
			return _instance != null;
		}

		static public function addToExchange(id:int):Boolean
		{
			return _instance.addExchangeItem(id);
		}

		static public function removeFromExchange(id:int):void
		{
			_instance.removeFromExchange(id);
		}

		static public function setExchangeItems(exchangeData:Array):void
		{
			_instance.setExchangeData(exchangeData);
		}

		static public function setExchangeItem(elementId:int, value:Boolean):void
		{
			if (_instance)
				_instance.setExchangeItem(elementId, value);
		}

		static public function setCollectionItems(commonData:Vector.<Counter>, uniqueData:Vector.<Counter>):void
		{
			_instance.setData(commonData, uniqueData);
		}

		static public function assembleComplete(success:Boolean, elementId:int):void
		{
			_instance.assembleComplete(success, elementId);
		}

		private function init():void
		{
			var buttonsGroup:ButtonTabGroup = new ButtonTabGroup();
			addChild(buttonsGroup);

			this.collectionSets = {};

			var locationSprite:Sprite;

			var counterFormat:TextFormat = new TextFormat(null, 16, 0x663300, true);
			counterFormat.align = TextFormatAlign.RIGHT;

			for (var i:int = 0; i < CollectionsData.locationsSets.length; i++)
			{
				var button:ButtonTab = new ButtonTab(getLocationButton(i));
				button.x = 45 + 120 * i;
				button.y = 90;
				this.notifications[i] = new NotificationView(button);

				locationSprite = new Sprite();
				locationSprite.y = 210;
				addChild(locationSprite);

				buttonsGroup.insert(button, locationSprite);

				var sprite:Sprite = new Sprite();
				sprite.mouseEnabled = false;
				sprite.graphics.beginFill(0xFFFFFF, 0.9);
				sprite.graphics.drawRoundRect(68, 56, 26, 26, 5, 5);
				button.addChild(sprite);

				var collectedCounter:GameField = new GameField("0", 68, 58, counterFormat);
				collectedCounter.filters = GLOW_FILTER;
				collectedCounter.width = 26;
				collectedCounter.autoSize = TextFieldAutoSize.CENTER;
				collectedCounter.mouseEnabled = false;
				button.addChild(collectedCounter);
				this.buttonsCounters[i] = collectedCounter;

				var locationSets:Array = CollectionsData.locationsSets[i]['set'];

				for (var j:int = 0; j < locationSets.length; j++)
				{
					var collectionSet:CollectionSetView = new CollectionSetView(locationSets[j]);
					collectionSet.x = 45 + 204 * j + int((4 - locationSets.length) * 102);
					collectionSet.addEventListener(Event.CHANGE, updateCounters);
					locationSprite.addChild(collectionSet);

					this.collectionSets[locationSets[j]] = {'set': collectionSet, 'location': i};
				}
			}

			this.exchangeSet = new CollectionExchangeView();
			this.exchangeSet.x = 60;
			this.exchangeSet.y = 545;
			addChild(this.exchangeSet);
		}

		private function assembleComplete(success:Boolean, elementId:int):void
		{
			(this.collectionSets[elementId]['set'] as CollectionSetView).assembleComplete(success);
		}

		private function setData(dataCommon:Vector.<Counter>, dataUnique:Vector.<Counter>):void
		{
			for each (var collectionSet:Object in this.collectionSets)
				(collectionSet['set'] as CollectionSetView).setData(dataCommon, dataUnique);
		}

		private function setExchangeData(data:Array):void
		{
			this.exchangeSet.setData(data);
		}

		private function setExchangeItem(elementId:int, value:Boolean):void
		{
			(this.collectionSets[CollectionsData.regularData[elementId]['collection']]['set'] as CollectionSetView).setExchange(elementId, value);
		}

		private function addExchangeItem(elementId:int):Boolean
		{
			return this.exchangeSet.addItem(elementId);
		}

		private function removeFromExchange(elementId:int):void
		{
			this.exchangeSet.removeItem(elementId);
		}

		private function updateCounters(e:Event):void
		{
			var locationId:int = this.collectionSets[(e.target as CollectionSetView).collectionId]['location'];
			var locationSets:Array = CollectionsData.locationsSets[locationId]['set'];

			if ((e.target as CollectionSetView).checkCollected())
				NotificationDispatcher.show(NotificationManager.COLLECTION);

			var totalCount:int = 0;

			for (var i:int = 0; i < locationSets.length; i++)
			{
				var collectionSet:Array = CollectionsData.uniqueData[locationSets[i]]['set'];
				for each (var id:int in collectionSet)
				{
					if (!("icon" in CollectionsData.regularData[id]))
						continue;
					totalCount += CollectionManager.regularItems[id].count;
				}
			}

			this.buttonsCounters[locationId].text = totalCount.toString();

			updateNotifications();
		}

		private function updateNotifications():void
		{
			var locationId:String;
			var locations:Object = {};
			for (var id:String in this.collectionSets)
			{
				locationId = this.collectionSets[id]['location'];

				locations[locationId] = (this.collectionSets[id]['set'] as CollectionSetView).checkCollected() || locations[locationId];
			}

			for (locationId in locations)
				this.notifications[locationId].active = locations[locationId];

			if (!CollectionManager.checkAnyCollected())
				NotificationDispatcher.hide(NotificationManager.COLLECTION);
		}

		private function getLocationButton(id:int):SimpleButton
		{
			var buttonClass:Class = getDefinitionByName(LOCATIONS_GRAPHICS[id]['button']) as Class;
			var upState:Sprite = new Sprite();
			upState.addChild(new buttonClass());

			var overState:Sprite = new Sprite();
			overState.addChild(new buttonClass());
			overState.addChild(new ButtonLocationFrame());

			var downState:Sprite = new Sprite();
			downState.addChild(new buttonClass());
			downState.addChild(new ButtonLocationFrame());

			return new SimpleButton(upState, overState, downState);
		}
	}
}
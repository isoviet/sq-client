package mobile.view.locations
{
	import chat.ChatCommon;
	import dialogs.DialogManager;
	import events.GameEvent;
	import game.userInterfaceView.mobile.SidebarsView;
	import menu.MenuProfile;
	import screens.ScreenLocation;
	import screens.ScreenStarling;
	import screens.Screens;

	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;
	import utils.starling.utils.StarlingConverter;

	public class MapLocations extends StarlingAdapterSprite
	{
		private var listCards:Array = [
			{
				img: new StarlingAdapterMovie(new LocationIsland, false),
				id: Locations.ISLAND_ID,
				bground: StarlingConverter.convertToImage(new BgLocationIsland(),0, 1, 1, null, false, true),
				imgPreview: StarlingConverter.convertToImage(new PreviewIsland(),0, 1, 1, null, false, true),
				barColor: 0x8EC8FF
			},
			{
				img: new StarlingAdapterMovie(new LocationSwamp, false),
				id: Locations.SWAMP_ID,
				bground: StarlingConverter.convertToImage(new BgLocationSwamp(),0, 1, 1, null, false, true),
				imgPreview: StarlingConverter.convertToImage(new PreviewSwamp(),0, 1, 1, null, false, true),
				barColor: 0x021B7C
			},
			{
				img: new StarlingAdapterMovie(new LocationsSchool, false),
				id: Locations.SCHOOL_ID,
				bground: StarlingConverter.convertToImage(new BgLocationIsland,0, 1, 1, null, false, true),
				imgPreview: StarlingConverter.convertToImage(new PreviewSchool(),0, 1, 1, null, false, true),
				barColor: 0x8EC8FF
			},
			{
				img: new StarlingAdapterMovie(new LocationTest, false),
				id: Locations.HARD_ID,
				bground: StarlingConverter.convertToImage(new BgLocationTest,0, 1, 1, null, false, true),
				imgPreview: StarlingConverter.convertToImage(new PreviewTest(),0, 1, 1, null, false, true),
				barColor: 0x000548
			},
			{
				img: new StarlingAdapterMovie(new LocationDesert, false),
				id: Locations.DESERT_ID,
				bground: StarlingConverter.convertToImage(new BgLocationDesert(),0, 1, 1, null, false, true),
				imgPreview: StarlingConverter.convertToImage(new PreviewDesert(),0, 1, 1, null, false, true),
				barColor: 0x8EC8FF
			},
			{
				img: new StarlingAdapterMovie(new LocationAnomal, false),
				id: Locations.ANOMAL_ID,
				bground: StarlingConverter.convertToImage(new BgLocationAnomal,0, 1, 1, null, false, true),
				imgPreview: StarlingConverter.convertToImage(new PreviewAnomal(),0, 1, 1, null, false, true),
				barColor: 0x12174F
			},
			{
				img: new StarlingAdapterMovie(new LocationStorm, false),
				id: Locations.STORM_ID,
				bground: StarlingConverter.convertToImage(new BgLocationStorm,0, 1, 1, null, false, true),
				imgPreview: StarlingConverter.convertToImage(new PreviewStorm(),0, 1, 1, null, false, true),
				barColor: 0x32B6E0
			},

			{
				img: new StarlingAdapterMovie(new LocationWildPlace, false),
				id: Locations.WILD_ID,
				bground: StarlingConverter.convertToImage(new BgLocationWild,0, 1, 1, null, false, true),
				imgPreview: StarlingConverter.convertToImage(new PreviewWild(),0, 1, 1, null, false, true),
				barColor: 0x1E0202
			},
			{
				img: new StarlingAdapterMovie(new LocationBattle, false),
				id: Locations.BATTLE_ID,
				bground: StarlingConverter.convertToImage(new BgLocationBattle,0, 1, 1, null, false, true),
				imgPreview: StarlingConverter.convertToImage(new PreviewBattle(),0, 1, 1, null, false, true),
				barColor: 0x76BDE2
			}
		];

		private var _listLocations: Vector.<LocationItem> = new Vector.<LocationItem>();
		private var _listLocationsView: ListLocations = null;

		private var _onChangeLocation: Function = null;
		private var _changedLocation: int = 0;
		private var _unlockedLocs: Array = null;
		private var _scrollPoints: ScrollScreenPoints = new ScrollScreenPoints();
		private var _layerBackground: Sprite = new Sprite();
		private var _callBackPlay: Function = null;
		private var _selectedIndex: int = 0;

		public function MapLocations(unlockedLocs: Array, onChangeLocation: Function, callBackPlay: Function)
		{
			_onChangeLocation = onChangeLocation;
			_unlockedLocs = unlockedLocs;
			_callBackPlay = callBackPlay;

			_layerBackground.addChild(listCards[0].bground);

			this.addChildStarling(_layerBackground);
			createListOfLocations();

			resize();

			SidebarsView.getInstance().drawBarsLocations(listCards[0].barColor);
			ScreenStarling.instance.addChild(this.getStarlingView());

			DialogManager.dispatcher.addEventListener(GameEvent.CHANGED, onLockStarlingLayer);
			ChatCommon.listen(GameEvent.CHANGED, onLockStarlingLayer);
			MenuProfile.listen(GameEvent.SHOWED, onLockStarlingLayer);
		}

		private function onLockStarlingLayer(event:GameEvent):void
		{
			if(Screens.active is ScreenLocation)
			{
				if((DialogManager.isEnyDialogShowed || ChatCommon.isShowed || MenuProfile.isShowing()) && Starling.current.isStarted)
					Starling.current.stop();
				else if(!DialogManager.isEnyDialogShowed && !ChatCommon.isShowed && !MenuProfile.isShowing() && !Starling.current.isStarted)
					Starling.current.start();
			}
		}

		private function onTapPlay(e: TouchEvent): void
		{
			if (_onChangeLocation != null)
				_onChangeLocation(listCards[_changedLocation].id);
		}

		public function dispose(): void
		{
			for(var i: int, len: int = _listLocations.length; i < len; i++)
				_listLocations[i].dispose();

			_listLocationsView.dispose();

			_listLocations = null;
			_listLocationsView = null;
			this.getStarlingView().removeFromParent(true);
		}

		public function show(): void
		{
			for(var i: int = 0, len: int = _listLocations.length; i < len; i++)
				_listLocations[i].refresh();

			ScreenStarling.instance.addChild(this.getStarlingView());
			//this.getStarlingView().visible = true;
			updateCost();
			updateLevel();
		}

		public function hide(): void
		{
			//this.getStarlingView().visible = false;
			ScreenStarling.instance.removeChild(this.getStarlingView());
		}

		private function resize(): void
		{
		}

		private function createListOfLocations(): void
		{
			var card: LocationItem = null;
			var objectInfoLocation: Object = null;

			for (var i: int = 0, len: int = listCards.length; i < len; i++)
			{
				objectInfoLocation = listCards[i];

				card =  new LocationItem(
					objectInfoLocation.id,
					objectInfoLocation.img,
					objectInfoLocation.imgPreview,
					LocationPreviewTip.location(objectInfoLocation.id).title,
					LocationPreviewTip.location(objectInfoLocation.id).description,
					0,
					0,
					Locations.getLocation(objectInfoLocation.id).level,
					_callBackPlay
				);

				_listLocations.push(card);
				card.locked = _unlockedLocs.length && _unlockedLocs.indexOf(listCards[i].id) > -1;
				_scrollPoints.appendPoint(card.locked ? PointScroll.STATE_UNLOCKED : PointScroll.STATE_LOCKED);
			}
			_listLocationsView = new ListLocations(_listLocations, onChange, onScroll);
			_listLocationsView.alignPivot();
			this.getStarlingView().addChild(_listLocationsView);

			_listLocationsView.x = Config.GAME_WIDTH / 2;
			_listLocationsView.y = Config.GAME_HEIGHT / 2;

			_scrollPoints.alignPivot();
			this.getStarlingView().addChild(_scrollPoints);
			_scrollPoints.y = Config.GAME_HEIGHT / 2 + _listLocationsView.height / 2 + 20;
			_scrollPoints.x = _listLocationsView.bounds.x + _listLocationsView.bounds.width / 2;
		}

		public function updateLevel(): void
		{
			var location:Location = null;
			var card: LocationItem = null;

			for (var i: int = 0, len: int = _listLocations.length; i < len; i++)
			{
				card = _listLocations[i];
				location = Locations.getLocation(card.id);
				if (location)
					card.setValueLevel(location.level);
			}
		}

		public function updateCost(): void
		{
			var location:Location = null;
			var card: LocationItem = null;

			for (var i: int = 0, len: int = _listLocations.length; i < len; i++)
			{
				card = _listLocations[i];
				location = Locations.getLocation(card.id);
				if (location)
					card.setValueEnergy(location.cost);
			}
		}

		public function updateOnline(online:Vector.<int>):void
		{
			var card: LocationItem = null;

			for (var i: int = 0, len: int = _listLocations.length; i < len; i++)
			{
				card = _listLocations[i];
				card.setValueOnLine(online[card.id] ? online[card.id] : 0);
			}
		}

		public function updateLocationUnlock(unlockedLocs: Array): void
		{
			_unlockedLocs = unlockedLocs;

			for(var i: int = 0, len: int = _listLocations.length; i < len; i++)
			{
				_listLocations[i].locked =
					!(_unlockedLocs.length && _unlockedLocs.indexOf(_listLocations[i].id) > -1);
			}
		}

		private function onChange(index: int): void
		{
			var state: int = 0;
			changedLocation = index;

			_listLocations[index].activate();
			for(var i: int = 0, len: int = _listLocations.length; i < len; i++)
			{
				if (index == i)
					state = PointScroll.STATE_ACTIVE;
				else
					state = _unlockedLocs.length &&
						_unlockedLocs.indexOf(_listLocations[i].id) > -1 ?
							PointScroll.STATE_UNLOCKED : PointScroll.STATE_LOCKED;

				_scrollPoints.changeState(i, state);
				if (index != i)
					listCards[i].bground.alpha = 0;
			}

			SidebarsView.getInstance().refreshColorBarsLocations(listCards[index].barColor);
			_selectedIndex = index;

			listCards[index].bground.alpha = 1;
			listCards[index].bground.alignPivot(HAlign.LEFT, VAlign.TOP);
			_layerBackground.addChild(listCards[index].bground);
		}

		private function onScroll(value: Number, index: int): void
		{
			if (index == _selectedIndex)
				return;

			if (!_layerBackground.contains(listCards[index].bground) ||
				_layerBackground.getChildIndex(listCards[index].bground) < _layerBackground.numChildren)
				_layerBackground.addChildAt(listCards[index].bground, _layerBackground.numChildren);

			listCards[index].bground.alpha = value * 0.9;
			SidebarsView.getInstance().drawBarsLocations(listCards[index].barColor);

			for (var i: int = 0, len: int = _listLocations.length; i < len; i++)
				_listLocations[i].deactivate();
		}

		public function get changedLocation():int
		{
			return _changedLocation;
		}

		public function get locationID():int
		{
			return listCards[_changedLocation].id;
		}

		public function set changedLocation(value:int):void
		{
			if(_changedLocation == value)
				return;
			_changedLocation = value;
			dispatchEvent(new GameEvent(GameEvent.CHANGED));
		}
	}
}
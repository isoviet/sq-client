package game.mainGame.perks.ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;

	import game.gameData.GameConfig;
	import game.gameData.SettingsStorage;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import game.mainGame.perks.clothes.ui.ClothesSkillButton;
	import game.mainGame.perks.mana.PerkFactory;
	import game.mainGame.perks.mana.PerkMana;
	import game.mainGame.perks.mana.PerkReborn;
	import game.mainGame.perks.mana.ui.PerkButton;
	import game.mainGame.perks.shaman.PerkShamanFactory;
	import game.mainGame.perks.shaman.ui.ShamanSkillButton;

	public class FastPerksBar extends ToolBar
	{
		static private const PERK_CLOTHES_BUTTON:int = 0;
		static private const PERK_MANA_BUTTON:int = 1;
		static private const PERK_SHAMAN_BUTTON:int = 2;

		static public const MAX_BUTTONS:int = 3;
		static private const BUTTON_OFFSET:Number = 43;
		static private const V_OFFSET:Number = 8;
		static private var _instance:FastPerksBar;

		private var background:Sprite = new Sprite();
		private var buttonImage:Sprite = new Sprite();
		private var button:ToolButton;

		private var localData:Object = null;
		private var currentVisible:Boolean = false;
		private var tryRemove:Boolean = false;

		private var freeCost:Boolean;
		private var freeRebornCost:Boolean;
		private var freePerkCost:Boolean;

		public function FastPerksBar():void
		{
			super();

			_instance = this;

			var image:FastBarBackground = new FastBarBackground();
			image.x = -55;
			image.y = -100;
			this.background.addChild(image);

			addChildAt(this.background, 0);
			addChild(this.buttonImage);
		}

		static public function startDraging(button:ToolButton, point:Point):void
		{
			_instance.startDraging(button, point);
		}

		static public function getInstance():FastPerksBar
		{
			return _instance;
		}

		static public function load():void
		{
			_instance.load();
		}

		static public function set hero(value:Hero):void
		{
			for each (var button:ToolButton in _instance.buttons)
			{
				button.hero = value;

				if (button is ShamanSkillButton)
					(button as ShamanSkillButton).updateDescr();
			}
		}

		override public function addButton(button:ToolButton):void
		{
			var buttonName:String = this.buttons.length.toString();
			button.y = -(this.buttons.length) * BUTTON_OFFSET - V_OFFSET + ((button is ClothesSkillButton) ? 2 : 0);
			if (button is ClothesSkillButton)
				(button as ClothesSkillButton).freeCost = this.freeCost;
			if (button is PerkButton && (button as PerkButton).perk == PerkReborn)
				button.cost = this.freeRebornCost ? 0 : GameConfig.getSkillManaCost(PerkFactory.SKILL_RESURECTION);
			if (button is PerkButton && ((button as PerkButton).perk is PerkMana))
				button.cost = this.freePerkCost ? 0 : GameConfig.getSkillManaCost(PerkFactory.SKILL_RESURECTION);

			super.addButton(button);
			this.buttonSprite.x = -47;

			save(buttonName, button);

			updateHotKeysStatuses();

			var global:Point = button.parent ? button.parent.localToGlobal(new Point(button.x, button.y)) : new Point(0,0);
			button.getStatus().setPosition(global.x - button.getStatus().width - 30, global.y);
		}

		public function setFreeCost(value:Boolean):void
		{
			this.freeCost = value;
			for each (var button:ToolButton in this.buttons)
			{
				if (!(button is ClothesSkillButton))
					continue;
				(button as ClothesSkillButton).freeCost = value;
			}
		}

		public function toggleFreeRespawn(value:Boolean):void
		{
			this.freeRebornCost = value;
			for each (var button:ToolButton in this.buttons)
			{
				if (!(button is PerkButton))
					continue;
				if ((button as PerkButton).perk != PerkReborn)
					continue;
				button.cost = value ? 0 : button.pekManaCost;
			}
		}

		public function toggleFreeCast(value:Boolean):void
		{
			this.freePerkCost = value;
			for each (var button:ToolButton in this.buttons)
			{
				if (!(button is PerkButton))
					continue;
				if (!((button as PerkButton).perk is PerkMana))
					continue;
				button.cost = value ? 0 : button.pekManaCost;
			}
		}

		public function startDraging(button:ToolButton, point:Point):void
		{
			if (this.buttonSprite.contains(button))
				tryRemove = true;
			else
			{
				if (this.buttons.length == MAX_BUTTONS)
					return;
				for (var i:int = 0; i < this.buttons.length; i++)
				{
					if (button.id != this.buttons[i].id)
						continue;
					return;
				}
			}

			this.button = button;

			var buttonIcon:DisplayObject = new this.button.iconClass();
			buttonIcon.width = buttonIcon.height = 36;
			buttonIcon.x = this.button.iconOffset.x * buttonIcon.scaleX;
			buttonIcon.y = this.button.iconOffset.y * buttonIcon.scaleY;

			this.buttonImage.addChild(buttonIcon);
			this.buttonImage.x = this.globalToLocal(point).x;
			this.buttonImage.y = this.globalToLocal(point).y;
			this.buttonImage.visible = false;
			this.buttonImage.startDrag();

			this.currentVisible = this.visible;

			Game.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			Game.stage.addEventListener(MouseEvent.MOUSE_UP, stopDraging);
		}

		override protected function get hotKeys():Array
		{
			return [Keyboard.R, Keyboard.F, Keyboard.G];
		}

		override protected function get needVisible():Boolean
		{
			return false;
		}

		private function removeButton():void
		{
			var index:int = this.buttons.indexOf(this.button);
			this.buttons.splice(index, 1);
			this.buttonSprite.removeChild(this.button);
			var len:int = Math.min(MAX_BUTTONS, this.buttons.length);

			this.localData = [];

			for (var i:int = 0; i < len; i++)
			{
				this.localData[i] = buttonToObject(this.buttons[i]);
				this.buttons[i].y = -i * BUTTON_OFFSET - V_OFFSET + ((this.buttons[i] is ClothesSkillButton) ? 2 : 0);
			}

			save();
			updateHotKeysStatuses();
		}

		private function save(buttonName:String = null, button:ToolButton = null):void
		{
			if (!this.localData)
				return;

			if (buttonName in this.localData)
				return;

			if (button != null)
				this.localData[buttonName] = buttonToObject(button);

			SettingsStorage.save(SettingsStorage.HOT_KEYS, this.localData);
		}

		private function load():void
		{
			if (this.localData != null)
				return;
			this.localData = SettingsStorage.load(SettingsStorage.HOT_KEYS);

			for (var i:int = 0; i < MAX_BUTTONS; i++)
			{
				var buttonName:String = i.toString();
				if (!(buttonName in this.localData))
					continue;
				var button:ToolButton = objectToButton(this.localData[buttonName]);
				if (button == null)
				{
					delete this.localData[buttonName];
					SettingsStorage.save(SettingsStorage.HOT_KEYS, this.localData);
					continue;
				}
				addButton(button);
			}
		}

		private function onMove(e:MouseEvent):void
		{
			if (this.buttonImage.visible)
				return;
			this.visible = true;
			this.buttonImage.visible = true;
			Game.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
		}

		private function stopDraging(e:MouseEvent):void
		{
			Game.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			Game.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDraging);

			if (this.tryRemove)
			{
				if (!this.buttonImage.hitTestObject(this.background))
					removeButton();
				this.tryRemove = false;
			}
			else
			{
				if (this.buttonImage.hitTestObject(this.background))
					addButton(this.button.clone());
				else
					this.visible = this.currentVisible;
			}

			this.buttonImage.stopDrag();
			while (this.buttonImage.numChildren > 0)
				this.buttonImage.removeChildAt(0);
		}

		private function objectToButton(buttonObject:Object):ToolButton
		{
			if (!("perk" in buttonObject) || !("class" in buttonObject))
				return null;

			var perkId:int = int(buttonObject['perk']);

			switch (buttonObject['class'])
			{
				case PERK_CLOTHES_BUTTON:
					if (perkId >= PerkClothesFactory.MAX_TYPE || perkId <= 0)
						return null;
					return new ClothesSkillButton(perkId);
				case PERK_MANA_BUTTON:
					if (perkId >= PerkFactory.MAX_TYPE || perkId <= 0)
						return null;
					return new PerkButton(perkId);
					break;
				//case PERK_SHAMAN_BUTTON:
				//	if (perkId >= PerkShamanFactory.perkCollection.length)
				//		return null;
				//	return new ShamanSkillButton(perkId);
				//	break;
			}

			return null;
		}

		private function buttonToObject(button:ToolButton):Object
		{
			var buttonObject:Object = {};

			switch ((button as Object).constructor as Class)
			{
				case ClothesSkillButton:
					buttonObject['class'] = PERK_CLOTHES_BUTTON;
					buttonObject['perk'] = button.id;
					break;
				case PerkButton:
					buttonObject['class'] = PERK_MANA_BUTTON;
					buttonObject['perk'] = button.id;
					break;
				case ShamanSkillButton:
					buttonObject['class'] = PERK_SHAMAN_BUTTON;
					buttonObject['perk'] = button.id;
					break;
			}
			return buttonObject;
		}
	}
}
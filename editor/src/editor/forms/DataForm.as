package editor.forms
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.ByteArray;

	import fl.containers.ScrollPane;
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;

	import editor.EditorField;
	import editor.FormUtils;
	import editor.Formats;

	public class DataForm extends Sprite
	{
		static public const PROFILE:int = 0;
		static public const COINS:int = 1;
		static public const NUTS:int = 2;
		static public const ENERGY:int = 3;
		static public const MANA:int = 4;
		static public const EXPERIENCE:int = 5;
		static public const MODERATOR_STATUS:int = 6;
		static public const EDITOR_STATUS:int = 7;
		static public const DAILY_BONUS:int = 8;
		static public const FLAGS:int = 9;
		static public const TRAINING:int = 10;
		static public const BAN:int = 11;
		static public const EXPIRATIONS:int = 12;
		static public const PACKAGES:int = 13;
		static public const ACCESSORIES:int = 14;
		static public const QUESTS:int = 15;
		static public const GIFTS:int = 16;
		static public const EXCHANGE:int = 17;
		static public const COLLECTIONS:int = 18;
		static public const SHAMAN_ITEMS:int = 19;
		static public const TOTEMS:int = 20;
		static public const SMILES:int = 21;
		static public const DISCOUNTS:int = 22;
		static public const INTERIOR:int = 23;
		static public const SHAMAN:int = 24;
		static public const DAILY_UNIQUE:int = 25;
		static public const SETTINGS:int = 26;
		static public const DEFERRED_BONUSES:int = 27;
		static public const HOLIDAY:int = 28;
		static public const CLAN:int = 29;
		static public const AMUR:int = 30;

		static public const NAMES:Array = ["Профиль", "Монеты", "Орехи", "Энергия", "Мана", "Опыт",
			"Модератор", "Редактор", "Ежедневный бонус", "Флаги", "Обучение", "Бан", "Временные бонусы",
			"Костюмы", "Аксессуары", "Квесты", "Подарки", "Обмен", "Коллекции", "Предметы шамана", "Тотемы",
			"Смайлы", "Акции", "Мебель", "Дерево шамана", "Ежедневные флаги", "Настройки", "Отложенные бонусы",
			"Праздник", "Клан", "Амур"];

		static public var CLASSES:Array = null;

		static public const WIDTH:int = 475;

		protected var fields:Vector.<TextField> = new <TextField>[];
		protected var checks:Vector.<CheckBox> = new <CheckBox>[];
		protected var combos:Vector.<ComboBox> = new <ComboBox>[];

		protected var lastX:int = 0;
		protected var lastY:int = 0;

		protected var _changed:Boolean = false;
		protected var _type:int = 0;
		protected var maxHeight:int = 0;

		protected var spriteView:Sprite = new Sprite();
		protected var scrollPane:ScrollPane = null;

		static public function getDataForm(type:int):DataForm
		{
			if (!CLASSES)
				CLASSES = [null, DataFormCoins, DataFormNuts, DataFormEnergy,
					DataFormMana, DataFormExp, DataFormModerator, DataFormEditor, DataFormDailyBonus, DataFormFlag,
					DataFormTraining, DataFormBan, DataFormExpirations, DataFormPackages, DataFormAccessories,
					DataFormQuest, DataFormGift, DataFormExchange, DataFormCollections, DataFormItems, DataFormTotems,
					DataFormSmiles, DataFormDiscounts, DataFormDecorations, DataFormShaman, DataFormDailyUnique,
					DataFormSettings, DataFormDeferredBonus, DataFormHoliday, null, DataFormAmur];
			var formClass:Class = CLASSES[type];
			return new formClass() as DataForm;
		}

		public static function normalizedComponent(component:Sprite):void
		{
			for (var i:int = 0; i < component.numChildren; i++)
			{
				component.getChildAt(i).height = component.height;
				component.getChildAt(i).width = component.width;
			}
		}

		public function DataForm(type:int, maxHeight:int = 0)
		{
			this._type = type;
			this.maxHeight = maxHeight;

			init();
		}

		public function load(data:ByteArray):void
		{}

		public function save():ByteArray
		{
			return null;
		}

		public function get type():int
		{
			return this._type;
		}

		public function get isClan():Boolean
		{
			return false;
		}

		public function get changed():Boolean
		{
			return this._changed;
		}

		public function set changed(value:Boolean):void
		{
			if (this.changed == value)
				return;
			this._changed = value;

			this.graphics.clear();
			this.graphics.lineStyle(2, this.changed ? 0xFFCC33 : 0);
			this.graphics.drawRoundRect(-5, -5, this.width + 10, this.height + 10, 5);
		}

		protected function init():void
		{
			if (this.maxHeight != 0)
			{
				this.scrollPane = new ScrollPane();
				this.scrollPane.setSize(WIDTH - 10, this.maxHeight);
				this.scrollPane.source = this.spriteView;
				addChild(this.scrollPane);
			}
			else
				addChild(this.spriteView);

			drawItems();

			this.graphics.beginFill(0x000000, 0);
			this.graphics.lineStyle(2, 0);
			this.graphics.drawRoundRect(-5, -5, this.width + 10, this.height + 10, 5);

			if (this.scrollPane)
				this.scrollPane.update();
		}

		protected function drawItems():void
		{
			for (var i:int = 0; i < this.fieldList.length; i++)
				addField(this.fieldList[i], this.fieldWidth);

			for (i = 0; i < this.checkList.length; i++)
				addCheck(this.checkList[i]);

			for (i = 0; i < this.comboList.length; i++)
				addCombo(this.comboList[i][0], this.comboList[i][1]);
		}

		override public function get width():Number
		{
			return this.maxHeight != 0 ? WIDTH - 10 : super.width;
		}

		override public function get height():Number
		{
			return this.maxHeight != 0 ? this.maxHeight : super.height;
		}

		protected function get fieldList():Array
		{
			return [];
		}

		protected function get checkList():Array
		{
			return [];
		}

		protected function get comboList():Array
		{
			return [];
		}

		protected function addField(title:String, width:int, enabled:Boolean = true):void
		{
			var sprite:Sprite = new Sprite();
			sprite.addChild(new EditorField(title, 0, 0, Formats.FORMAT_EDIT));

			var field:TextField = new TextField();
			field.selectable = enabled;
			field.mouseEnabled = enabled;
			field.addEventListener(Event.CHANGE, onChange);
			if (this.fieldTitleWidth == 0)
				FormUtils.setTextField(field, sprite, sprite.width + 2, 0, width, 18, 100, true);
			else
				FormUtils.setTextField(field, sprite, this.fieldTitleWidth, 0, width, 18, 100, true);

			if (this.lastX + sprite.width > WIDTH)
			{
				this.lastX = 0;
				this.lastY += 25;
			}

			sprite.x = this.lastX;
			sprite.y = this.lastY;
			this.spriteView.addChild(sprite);

			this.lastX += sprite.width + this.fieldOffset;

			this.fields.push(field);
		}

		protected function get fieldWidth():int
		{
			return 100;
		}

		protected function get fieldTitleWidth():int
		{
			return 0;
		}

		protected function get fieldOffset():int
		{
			return 5;
		}

		protected function addCheck(title:String):void
		{
			var sprite:Sprite = new Sprite();
			sprite.addChild(new EditorField(title, 0, 0, Formats.FORMAT_EDIT));

			var checkBox:CheckBox = new CheckBox();
			checkBox.label = "";
			if (this.checkTitleWidth == 0)
				checkBox.x = sprite.width + 2;
			else
				checkBox.x = this.checkTitleWidth;
			checkBox.selected = false;
			checkBox.addEventListener(Event.CHANGE, onChange);
			sprite.addChild(checkBox);
			checkBox.width = 20;
			normalizedComponent(checkBox);

			if (this.lastX + sprite.width > WIDTH)
			{
				this.lastX = 0;
				this.lastY += 25;
			}

			sprite.x = this.lastX;
			sprite.y = this.lastY;
			this.spriteView.addChild(sprite);

			this.lastX += sprite.width + this.checkOffset;

			this.checks.push(checkBox);
		}

		protected function get checkTitleWidth():int
		{
			return 0;
		}

		protected function get checkOffset():int
		{
			return 5;
		}

		protected function addCombo(title:String, data:DataProvider):void
		{
			var sprite:Sprite = new Sprite();
			sprite.addChild(new EditorField(title, 0, 0, Formats.FORMAT_EDIT));

			var comboBox:ComboBox = new ComboBox();
			comboBox.addEventListener(Event.CHANGE, onChange);
			if (this.comboTitleWidth == 0)
				FormUtils.setComboBox(comboBox, sprite, data, sprite.width + 2, 0, this.comboWidth);
			else
				FormUtils.setComboBox(comboBox, sprite, data, this.comboTitleWidth, 0, this.comboWidth);
			normalizedComponent(comboBox);
			normalizedComponent(comboBox.textField);

			if (this.lastX + sprite.width > WIDTH)
			{
				this.lastX = 0;
				this.lastY += 25;
			}

			sprite.x = this.lastX;
			sprite.y = this.lastY;
			this.spriteView.addChild(sprite);

			this.lastX += sprite.width + this.comboOffset;

			this.combos.push(comboBox);
		}

		protected function get comboWidth():int
		{
			return 200;
		}

		protected function get comboTitleWidth():int
		{
			return 0;
		}

		protected function get comboOffset():int
		{
			return 5;
		}

		protected function onChange(e:Event):void
		{
			this.changed = true;
		}
	}
}
package dialogs
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;

	import fl.containers.ScrollPane;

	import buttons.ButtonBase;
	import game.mainGame.gameEditor.SquirrelCollectionEditor;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import game.mainGame.gameRecord.Recorder;

	import by.blooddy.crypto.serialization.JSON;

	public class DialogRecord extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body{
				font-family: "Droid Sans";
				font-size: 13px;
				color: #4A1901;
			}
			a {
				text-decoration: none;
				font-weight: bold;
			}
			a:hover {
				text-decoration: underline;
			}
			]]>).toString();

		static private const FORMAT_DEFAULT:TextFormat = new TextFormat(null, 12, 0x000000, true);

		static private var _instance:DialogRecord = null;

		static public var recorder:Recorder = new Recorder();

		private var style:StyleSheet;

		private var fileLoad:FileReference = new FileReference();
		private var fileReference:FileReference = new FileReference();

		private var scrollPane:ScrollPane;
		private var sprite:Sprite;

		private var buttonRecord:ButtonBase = null;
		private var buttonImport:ButtonBase = null;
		private var buttonExport:ButtonBase = null;
		private var buttonAdding:ButtonBase = null;

		private var replayField:GameField;

		private var game:SquirrelGameEditor;

		private var records:Array = [];

		private var isAdding:Boolean = false;

		public function DialogRecord()
		{
			super("");

			init();
		}

		static public function show(game:SquirrelGameEditor):void
		{
			if (_instance == null)
				_instance = new DialogRecord();

			_instance.game = game;
			_instance.show();
		}

		private function init():void
		{
			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			this.replayField = new GameField(gls("ПОВТОР"), 0, 0, new TextFormat(null, 25, 0xff0000, true));
			this.replayField.x = ((Game.stage.stageWidth / 2) - (this.replayField.width / 2));
			this.replayField.y = ((Game.stage.stageHeight / 2) - (this.replayField.height / 2));
			this.replayField.visible = false;
			Game.gameSprite.addChild(this.replayField);

			this.sprite = new Sprite();
			this.scrollPane = new ScrollPane();
			this.scrollPane.x = 10;
			this.scrollPane.y = 90;
			this.scrollPane.setSize(505, 280);
			this.scrollPane.source = this.sprite;
			addChild(this.scrollPane);

			this.buttonRecord = new ButtonBase(gls("Записать"));
			this.buttonRecord.x = 5;
			this.buttonRecord.y = 380;
			this.buttonRecord.addEventListener(MouseEvent.CLICK, onRecord);
			addChild(this.buttonRecord);

			this.buttonImport = new ButtonBase(gls("Импорт"));
			this.buttonImport.x = 110;
			this.buttonImport.y = 380;
			this.buttonImport.addEventListener(MouseEvent.CLICK, onAllImport);
			addChild(this.buttonImport);

			this.buttonAdding = new ButtonBase(gls("Добавить"));
			this.buttonAdding.x = 215;
			this.buttonAdding.y = 380;
			this.buttonAdding.addEventListener(MouseEvent.CLICK, onAddingImport);
			addChild(this.buttonAdding);

			this.buttonExport = new ButtonBase(gls("Экспорт"));
			this.buttonExport.x = 320;
			this.buttonExport.y = 380;
			this.buttonExport.addEventListener(MouseEvent.CLICK, onAllExport);
			addChild(this.buttonExport);

//			clear();

			updateList();

			place();

			this.width = 580;
			this.height = 450;
		}

		private function onAddingImport(e:MouseEvent):void
		{
			this.isAdding = true;

			onAllImport(e);
		}

		private function onAllExport(e:MouseEvent):void
		{
			var data:ByteArray = new ByteArray();
			data.position = 0;
			data.writeUTF(by.blooddy.crypto.serialization.JSON.encode(records));

			this.fileReference.save(by.blooddy.crypto.serialization.JSON.encode(records), "all.action");
		}

		private function onExport(e:MouseEvent):void
		{
//			recorder.stopRecord();

			var index:int = (e.currentTarget as GameField).userData;

			/*var data:ByteArray = new ByteArray();
			data.position = 0;
			data.writeUTF(by.blooddy.crypto.serialization.JSON.encode(records[index]));

			this.fileReference.save(data, index + ".action");*/
			this.fileReference.save(by.blooddy.crypto.serialization.JSON.encode(records[index]), index + ".action");
		}

		private function onAllImport(e:MouseEvent):void
		{
			FullScreenManager.instance().fullScreen = false;

			this.fileLoad.browse();
			this.fileLoad.addEventListener(Event.SELECT, onSelect);
		}

		private function onSelect(e:Event):void
		{
			this.fileLoad.load();
			this.fileLoad.addEventListener(Event.COMPLETE, onLoaded);
		}

		private function onLoaded(e:Event):void
		{
			this.fileLoad.data.position = 0;

			var data:Array = by.blooddy.crypto.serialization.JSON.decode(this.fileLoad.data.readUTF());

			if (this.isAdding)
				this.records = this.records.concat(data);
			else
				this.records = data;

			updateList();
		}

		private function onRecord(e:MouseEvent):void
		{
			if (recorder.isRecording)
			{
				recorder.stopRecord();
				this.game.onEdit();
				this.records.push(recorder.actions);
				toggleButton();
				updateList();
				return;
			}

			recorder.actions = [];
			recorder.startRecord();
			toggleButton();
			this.game.onTest();
			hide();
		}

		private function updateList():void
		{
			while (this.sprite.numChildren > 0)
				this.sprite.removeChildAt(0);

			for (var i:int = 0; i < this.records.length; i++)
			{
				this.sprite.addChild(new GameField((i + 1).toString(), 0, i * 20, FORMAT_DEFAULT));
				this.sprite.addChild(new GameField(this.game.mapNumber.toString(), 50, i * 20, FORMAT_DEFAULT));

				var fieldReplay:GameField = this.sprite.addChild(new GameField(gls("<body><a class='name' href='event:replay'>Проиграть</a></body>"), 150, i * 20, this.style)) as GameField;
				fieldReplay.userData = i;
				fieldReplay.addEventListener(MouseEvent.CLICK, onReplay);

				var fieldContinue:GameField = this.sprite.addChild(new GameField(gls("<body><a class='name' href='event:continue'>Продолжить</a></body>"), 240, i * 20, this.style)) as GameField;
				fieldContinue.userData = i;
				fieldContinue.addEventListener(MouseEvent.CLICK, onContinue);

				var fieldExport:GameField = this.sprite.addChild(new GameField(gls("<body><a class='name' href='event:export'>Экспорт</a></body>"), 330, i * 20, this.style)) as GameField;
				fieldExport.userData = i;
				fieldExport.addEventListener(MouseEvent.CLICK, onExport);

				var fieldDelete:GameField = this.sprite.addChild(new GameField(gls("<body><a class='name' href='event:delete'>Удалить</a></body>"), 400, i * 20, this.style)) as GameField;
				fieldDelete.userData = i;
				fieldDelete.addEventListener(MouseEvent.CLICK, onDelete);
			}

			if (!this.records.length)
				this.sprite.addChild(new GameField(gls("Нет записей"), 200, 100, FORMAT_DEFAULT));

			this.scrollPane.update();
		}

		private function onDelete(e:MouseEvent):void
		{
			if (this.records.length == 1)
				this.records = [];
			else
				this.records.splice((e.currentTarget as GameField).userData, 1);

			updateList();
		}

		private function onContinue(e:MouseEvent):void
		{
			/*var index:int = (e.currentTarget as GameField).userData;
			recorder.actions = [records[index][records.length - 1]];
			recorder.whenStopReplay(onStopContinue);
			recorder.startReplay();*/

			recorder.actions = records[(e.currentTarget as GameField).userData];
			recorder.whenStopReplay(onStopContinue);
			recorder.startReplay();

			this.game.onTest();
			this.game.header.onTest();
			hide();
		}

		private function onStopContinue():void
		{
			(this.game.squirrels as SquirrelCollectionEditor).selfHeroId = (this.game.squirrels as SquirrelCollectionEditor).selfHeroId;

			this.replayField.visible = false;

			recorder.actions = [];
			recorder.startRecord();
			toggleButton();
		}

		private function toggleButton():void
		{
			if (recorder.isRecording)
				this.buttonRecord.field.text = gls("Остановить");
			else
				this.buttonRecord.field.text = gls("Записать");
		}

		private function onReplay(e:MouseEvent):void
		{
			recorder.actions = records[(e.currentTarget as GameField).userData];
			recorder.whenStopReplay(onStopReplay);
			recorder.startReplay();

			this.game.onTest();
			this.game.header.onTest();
			hide();

			this.replayField.visible = true;
		}

		private function onStopReplay():void
		{
			this.game.onEdit();
			this.game.header.onEdit();
			this.show();

			this.replayField.visible = false;
		}
	}
}
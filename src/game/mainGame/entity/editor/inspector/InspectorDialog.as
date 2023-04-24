package game.mainGame.entity.editor.inspector
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	import fl.containers.ScrollPane;

	import dialogs.Dialog;
	import events.EditNewElementEvent;
	import game.mainGame.GameMap;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.editor.ClickButton;
	import game.mainGame.entity.editor.Helper;
	import game.mainGame.entity.editor.PlanetBody;
	import game.mainGame.entity.editor.PlatformGroundBody;
	import game.mainGame.entity.editor.PlatformOilBody;
	import game.mainGame.entity.editor.Pusher;
	import game.mainGame.entity.editor.RectGravity;
	import game.mainGame.entity.editor.ScriptedTimer;
	import game.mainGame.entity.editor.Sensor;
	import game.mainGame.entity.joints.IRatio;
	import game.mainGame.entity.joints.JointDistance;
	import game.mainGame.entity.joints.JointPrismatic;
	import game.mainGame.entity.joints.JointRevolute;
	import game.mainGame.entity.quicksand.Quicksand;
	import game.mainGame.entity.simple.BalloonBody;
	import game.mainGame.entity.simple.BeamEmitter;
	import game.mainGame.entity.simple.BoostZone;
	import game.mainGame.entity.simple.Bouncer;
	import game.mainGame.entity.simple.BubblesEmitter;
	import game.mainGame.entity.simple.BungeeHarpoon;
	import game.mainGame.entity.simple.Centrifuge;
	import game.mainGame.entity.simple.Conveyor;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.entity.simple.HomingGun;
	import game.mainGame.entity.simple.Hydrant;
	import game.mainGame.entity.simple.NutsDisintegrator;
	import game.mainGame.entity.simple.Tornado;
	import game.mainGame.entity.simple.Trap;
	import game.mainGame.entity.simple.Wheel;
	import game.mainGame.entity.water.Water;

	import avmplus.getQualifiedClassName;

	public class InspectorDialog extends Dialog
	{
		static private const SORT_ORDER:Array = [
			DisplayObject,
			IGameObject,
			GameBody,
			JointRevolute,
			JointDistance,
			JointPrismatic,
			IRatio,
			Sensor,
			Helper,
			ISizeable,
			GameMap,
			Quicksand,
			Water,
			PlatformGroundBody,
			ScriptedTimer,
			BalloonBody,
			ClickButton,
			PlanetBody,
			Pusher,
			RectGravity,
			ILifeTime,
			Tornado,
			Bouncer,
			Wheel,
			BoostZone,
			BubblesEmitter,
			Trap,
			BungeeHarpoon,
			PlatformOilBody,
			Centrifuge,
			NutsDisintegrator,
			HomingGun,
			Conveyor,
			Hydrant,
			BeamEmitter
		];

		static private var alias:Dictionary = null;

		static private var listeners:Vector.<Function> = new Vector.<Function>();

		private var scrollPane:ScrollPane = new ScrollPane();
		private var scrollSprite:Sprite = new Sprite();
		private var inspectObject:*;
		private var lastInspector:Inspector;

		public function InspectorDialog(inspectObject:*):void
		{
			super(gls("Свойства объекта"));

			if (InspectorDialog.alias == null)
				fillAliases();

			scrollPane.setSize(290, 400);
			scrollPane.source = scrollSprite;
			addChild(scrollPane);
			this.scrollPane.update();

			inspect(inspectObject);
			place();
			this.width = 320;
			this.height = 450;

			show();

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		}

		static public function addChangeListener(listener:Function):void
		{
			listeners.push(listener);
		}

		static public function removeChangeListener(listener:Function):void
		{
			for (var i:int = 0; i < listeners.length; i++)
				if (listeners[i] == listener)
					listeners.splice(i, 1);
		}

		override public function hide(e:MouseEvent = null):void
		{
			while (this.scrollSprite.numChildren > 0)
			{
				(this.scrollSprite.getChildAt(0) as Inspector).removeEventListener(EditNewElementEvent.CHANGE, dispatch);
				this.scrollSprite.removeChildAt(0);
			}

			this.lastInspector = null;

			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			super.hide(e);
		}

		public function inspect(object:*):void
		{
			this.inspectObject = object;

			for each (var objectClass:* in SORT_ORDER)
			{
				if (!(object is objectClass))
					continue;

				if (!(objectClass in alias))
					continue;

				addInspector(new (alias[objectClass] as Class) as Inspector);

				if (object is ITerminal && (getQualifiedClassName(object) == getQualifiedClassName(objectClass)))
					break;
			}
			this.scrollPane.update();
		}

		private function addInspector(inspector:Inspector):void
		{
			if (this.lastInspector)
				inspector.y = this.lastInspector.y + this.lastInspector.widgetsHeight + 10;

			inspector.inspectObject = this.inspectObject;
			inspector.addEventListener(EditNewElementEvent.CHANGE, dispatch);
			this.lastInspector = inspector;

			this.scrollSprite.addChild(inspector);
			this.scrollPane.update();
		}

		private function dispatch(e:EditNewElementEvent):void
		{
			for each(var listener:Function in listeners)
				listener(e.className);
		}

		private function fillAliases():void
		{
			InspectorDialog.alias = new Dictionary();
			InspectorDialog.alias[DisplayObject] = DisplayObjectInspector;
			InspectorDialog.alias[IGameObject] = IGameObjectInspector;
			InspectorDialog.alias[GameBody] = GameBodyInspector;
			InspectorDialog.alias[JointRevolute] = JointRevoluteInspector;
			InspectorDialog.alias[JointDistance] = JointDistanceInspector;
			InspectorDialog.alias[JointPrismatic] = JointPrismaticInspector;
			InspectorDialog.alias[IRatio] = IRatioInspector;
			InspectorDialog.alias[Sensor] = SensorInspector;
			InspectorDialog.alias[Helper] = HelperInspector;
			InspectorDialog.alias[ISizeable] = ISizeableInspector;
			InspectorDialog.alias[GameMap] = GameMapInspector;
			InspectorDialog.alias[Water] = WaterInspector;
			InspectorDialog.alias[PlatformGroundBody] = PlatformInspector;
			InspectorDialog.alias[ScriptedTimer] = ScriptedTimerInspector;
			InspectorDialog.alias[BalloonBody] = BalloonInspector;
			InspectorDialog.alias[ClickButton] = ClickButtonInspector;
			InspectorDialog.alias[PlanetBody] = PlanetBodyInspector;
			InspectorDialog.alias[Pusher] = PusherInspector;
			InspectorDialog.alias[RectGravity] = RectGravityInspector;
			InspectorDialog.alias[ILifeTime] = ILifeTimeInspector;
			InspectorDialog.alias[Quicksand] = QuicksandInspector;
			InspectorDialog.alias[Tornado] = TornadoInspector;
			InspectorDialog.alias[Bouncer] = BouncerInspector;
			InspectorDialog.alias[Wheel] = WheelInspector;
			InspectorDialog.alias[BoostZone] = BoostZoneInspector;
			InspectorDialog.alias[BubblesEmitter] = BubblesEmitterInspector;
			InspectorDialog.alias[Trap] = TrapInspector;
			InspectorDialog.alias[BungeeHarpoon] = BungeeHarpoonInspector;
			InspectorDialog.alias[PlatformOilBody] = PlatformOilBodyInspector;
			InspectorDialog.alias[Centrifuge] = CentrifugeInspector;
			InspectorDialog.alias[NutsDisintegrator] = DisintegratorInspector;
			InspectorDialog.alias[HomingGun] = HomingGunInspector;
			InspectorDialog.alias[Conveyor] = ConveyorInspector;
			InspectorDialog.alias[Hydrant] = HydrantInspector;
			InspectorDialog.alias[BeamEmitter] = BeamEmitterInspector;
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (!e.ctrlKey || e.keyCode != Keyboard.Q)
				return;

			hide();
		}
	}
}
package game.mainGame
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Vec2;

	import dialogs.DialogInfo;
	import events.LearningEvent;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.gameNet.GameMapNet;
	import screens.ScreenEdit;
	import screens.ScreenLearning;
	import screens.ScreenSchool;

	import hscript.HScript;

	import interfaces.IDispose;

	import luaAlchemy.LuaAlchemy;

	public class ScriptUtils implements IDispose
	{
		static public const LUA_SCRIPT:String = "LUA_SCRIPT";
		static public const HAXE_SCRIPT:String = "HAXE_SCRIPT";

		private var game:SquirrelGame;
		private var lua:LuaAlchemy;

		public function ScriptUtils(game:SquirrelGame):void
		{
			this.game = game;
			this.lua = game.scripts;
			initLua();
		}

		public function dispose():void
		{
			this.game = null;

			//Functions
			this.lua.setGlobal("addObject", null);
			this.lua.setGlobal("addObjectVec", null);
			this.lua.setGlobal("getObject", null);

			this.lua.setGlobal("getPosition", null);
			this.lua.setGlobal("setPosition", null);
			this.lua.setGlobal("setPositionVec", null);

			this.lua.setGlobal("getObjectId", null);
			this.lua.setGlobal("getObjectTypeName", null);

			this.lua.setGlobal("getAngle", null);
			this.lua.setGlobal("setAngle", null);

			this.lua.setGlobal("build", null);

			this.lua.setGlobal("vector", null);

			this.lua.close();
			this.lua = null;
		}

		public function execute(script:String, self:*, vars:Object, scriptLanguage:String = LUA_SCRIPT):void
		{
			if (scriptLanguage == LUA_SCRIPT)
			{
				this.lua.setGlobal("this", self);
				this.lua.setGlobal("Analytics", Analytics);
				for (var key:String in vars)
				{
					this.lua.setGlobal(key, vars[key]);
				}

				var output:Array = this.lua.doString(script);
				if (output[0] != true && Game.editor_access == 1)
					new DialogInfo(gls("Ошибка скрипта в объекте\n{0}", self.name), "\n" + output.join("\n")).show();

				this.lua.setGlobal("this", null);
				for (key in vars)
				{
					this.lua.setGlobal(key, null);
				}
				return;
			}

			if (scriptLanguage == HAXE_SCRIPT)
			{
				vars['self'] = self;
				vars['Analytics'] = Analytics;
				vars = globalVars(vars);
				try{
					HScript.ExecuteHaXeScript(script, vars);
				}
				catch (e:Error)
				{
					if (Game.editor_access == 1)
						new DialogInfo(gls("Ошибка скрипта в объекте\n{0}", self.name), "\n" + e.message);
				}
			}
		}

		public function get isSync():Boolean
		{
			if (!(this.game.map is GameMapNet))
				return true;

			return (this.game.map as GameMapNet).syncCollection.doSync || this.game.squirrels.isSynchronizing;
		}

		private function globalVars(add:Object):Object
		{
			var vars:Object = {};
			vars["removeObject"] = this.removeObject;
			vars["addObject"] = this.addObject;
			vars["addObjectVec"] = this.addObjectVec;

			vars["getPosition"] = this.getPosition;
			vars["setPosition"] = this.setPosition;
			vars["setPositionVec"] = this.setPositionVec;

			vars["getObject"] = this.getObject;
			vars["getObjectId"] = this.getObjectId;
			vars["getObjectTypeName"] = this.getObjectTypeName;

			vars["getAngle"] = this.getAngle;
			vars["setAngle"] = this.setAngle;

			vars["showMessage"] = this.showMessage;

			vars["allowPerk"] = this.allowPerk;

			vars["build"] = this.build;

			vars["vector"] = this.vector;

			vars["createSquirrel"] = this.createSquirrel;
			vars["createShaman"] = this.createShaman;
			vars["getSquirrel"] = this.getSquirrel;
			vars["killSquirrel"] = this.killSquirrel;

			vars["addHintArrow"] = this.addHintArrow;
			vars["removeHintArrow"] = this.removeHintArrow;

			vars["dispatch"] = this.dispatch;

			vars["P2M"] = Game.PIXELS_TO_METRE;
			vars["PI"] = Math.PI;
			vars["R2D"] = Game.R2D;
			vars["D2R"] = Game.D2R;
			vars["b2Vec2"] = b2Vec2;

			for (var key:String in add)
				vars[key] = add[key];

			return vars;
		}

		private function initLua():void
		{
			//Functions
			this.lua.setGlobal("removeObject", this.removeObject);
			this.lua.setGlobal("addObject", this.addObject);
			this.lua.setGlobal("addObjectVec", this.addObjectVec);

			this.lua.setGlobal("getPosition", this.getPosition);
			this.lua.setGlobal("setPosition", this.setPosition);
			this.lua.setGlobal("setPositionVec", this.setPositionVec);

			this.lua.setGlobal("getObject", this.getObject);
			this.lua.setGlobal("getObjectId", this.getObjectId);
			this.lua.setGlobal("getObjectTypeName", this.getObjectTypeName);

			this.lua.setGlobal("getAngle", this.getAngle);
			this.lua.setGlobal("setAngle", this.setAngle);

			this.lua.setGlobal("showMessage", this.showMessage);

			this.lua.setGlobal("allowPerk", this.allowPerk);

			this.lua.setGlobal("build", this.build);

			this.lua.setGlobal("vector", this.vector);

			this.lua.setGlobal("createSquirrel", this.createSquirrel);
			this.lua.setGlobal("createShaman", this.createShaman);
			this.lua.setGlobal("getSquirrel", this.getSquirrel);
			this.lua.setGlobal("killSquirrel", this.killSquirrel);

			this.lua.setGlobal("addHintArrow", this.addHintArrow);
			this.lua.setGlobal("removeHintArrow", this.removeHintArrow);

			this.lua.setGlobal("dispatch", this.dispatch);

			this.lua.setGlobal("setGlobal", this.lua.setGlobal);

			// Const
			this.lua.setGlobal("P2M", Game.PIXELS_TO_METRE);
			this.lua.setGlobal("PI", Math.PI);
		}

		private function showMessage(caption:String, text:String):void
		{
			new DialogInfo(caption, text).show();
		}

		private function removeObject(object:*):void
		{
			this.game.map.removeObject(object);
		}

		public function allowPerk(id:int, enabled:Boolean, onEdit:Boolean = false):void
		{
			if (enabled)
			{
				ScreenEdit.allowedPerks[id] = true;
				if (!onEdit)
				{
					ScreenSchool.allowedPerks[id] = true;
					ScreenLearning.allowedPerks[id] = true;
				}
			}
			else
			{
				delete ScreenEdit.allowedPerks[id];
				delete ScreenSchool.allowedPerks[id];
				delete ScreenLearning.allowedPerks[id];
			}

			if (Hero.self && Hero.self.perkController.perksMana.length > 0)
				Hero.self.perkController.perksMana[id].dispatchEvent(new Event("STATE_CHANGED"));
		}

		private function createSquirrel(id:int, x:Number, y:Number):Hero
		{
			this.game.squirrels.add(id);
			this.game.squirrels.get(id).position = new b2Vec2(x / Game.PIXELS_TO_METRE, y / Game.PIXELS_TO_METRE);
			this.game.squirrels.get(id).setController(null);
			this.game.squirrels.get(id).reset();
			this.game.squirrels.get(id).show();
			return this.game.squirrels.get(id);
		}

		private function createShaman(id:int, x:Number, y:Number):Hero
		{
			createSquirrel(id, x, y).shaman = true;
			return this.game.squirrels.get(id);
		}

		private function getSquirrel(id:int):Hero
		{
			return this.game.squirrels.get(id);
		}

		private function killSquirrel(id:int):void
		{
			this.game.squirrels.get(id).kill();
		}

		private function addObject(id:*, posX:Number, posY:Number, angle:Number, build:Boolean = true):IGameObject
		{
			return this.game.map.addObject(id, posX, posY, angle, build);
		}

		private function addObjectVec(id:*, vec:b2Vec2, angle:Number, build:Boolean = true):IGameObject
		{
			return this.game.map.addObject(id, vec.x, vec.y, angle, build);
		}

		private function getObject(name:String):IGameObject
		{
			if (this.game == null || this.game.map == null)
				return null;

			return this.game.map.getByName(name);

		}

		private function getPosition(name:String):b2Vec2
		{
			var vector:b2Vec2 = getObject(name).position.Copy();
			vector.Multiply(Game.PIXELS_TO_METRE);
			return vector;
		}

		private function setPosition(name:String, posX:Number, posY:Number, delay:Boolean = true):void
		{
			if (delay)
				setTimeout(setPosition, 0, name, posX, posY, false);

			var object:IGameObject = getObject(name);

			if (object == null)
				return;

			var newPos:b2Vec2 = new b2Vec2(posX, posY);
			newPos.Multiply(1 / Game.PIXELS_TO_METRE);
			object.position = newPos;
		}

		private function setPositionVec(name:String, vec:b2Vec2, delay:Boolean = true):void
		{
			if (delay)
				setTimeout(setPositionVec, 0, name, vec, false);

			var newPos:b2Vec2 = vec.Copy();
			newPos.Multiply(1 / Game.PIXELS_TO_METRE);
			getObject(name).position = newPos;
		}

		private function getAngle(name:String):Number
		{
			return getObject(name).angle / Game.D2R;
		}

		private function setAngle(name:String, angle:Number):void
		{
			getObject(name).angle = angle * Game.D2R;
		}

		private function vector(x:Number = 0, y:Number = 0):b2Vec2
		{
			return new b2Vec2(x, y);
		}

		private function getObjectId(object:IGameObject):int
		{
			return EntityFactory.getId(object);
		}

		private function getObjectTypeName(object:IGameObject):String
		{
			return EntityFactory.getName(object);
		}

		private function build(object:IGameObject):void
		{
			object.build(this.game.world);
		}

		private function addHintArrow(name:String, posX:Number, posY:Number, angle:Number):void
		{
			this.game.addHintArrow(name, new Point(posX, posY), angle);
		}

		private function removeHintArrow(name:String):void
		{
			this.game.removeHintArrow(name);
		}

		private function dispatch(step:int):void
		{
			this.game.dispatchEvent(new LearningEvent(step));
		}
	}
}
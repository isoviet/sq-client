package game.mainGame.gameBattleNet
{
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import game.mainGame.CastItem;
	import game.mainGame.CastItems;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.IShoot;
	import game.mainGame.entity.IShootBattle;
	import game.mainGame.events.CastEvent;
	import game.mainGame.gameNet.CastNet;

	import protocol.PacketClient;

	public class CastBattleNet extends CastNet
	{
		static private const CAST_TIME:int = 25;

		private var timerReload:Timer = new Timer(300, 1);

		public function CastBattleNet(game:SquirrelGame):void
		{
			super(game);
			this.timer.delay = CAST_TIME;
			if (this.castHint.parentStarling)
				this.castHint.removeFromParent();
		}

		override protected function onCastStart(e:MouseEvent):Boolean
		{
			if (!game || !game.squirrels)
				return false;

			if (this.castObject is IShoot)
			{
				if ((this.timerReload && this.timerReload.running) || (this.aimCursor && !this.aimCursor.visible))
					return false;

				var itemClass:Class = EntityFactory.getEntity(EntityFactory.getId(this.castObject));
				if (itemClass == null)
					return false;

				var self:Hero = game.squirrels.get(Game.selfId);
				if (self == null || self.castItems == null)
					return false;

				var item:CastItem = game.squirrels.get(Game.selfId).castItems.getItem(itemClass, CastItem.TYPE_ROUND);
				if (item == null || item.count <= 0)
					return false;
			}
			return super.onCastStart(e);
		}

		override protected function onCastComplete(e:TimerEvent = null):void
		{
			sendPacket(PacketClient.ROUND_CAST_END, 1);
			if (this.castObject is IShootBattle)
			{
				this.timerReload.delay = (this.castObject as IShootBattle).reloadTime;
				this.timerReload.reset();
				this.timerReload.start();
			}

			this.casting = false;

			if (this.castObject != null && Hero.self != null)
				Hero.self.castStop(true);

			var itemClass:Class = EntityFactory.getEntity(EntityFactory.getId(this.castObject));
			if (itemClass == null)
				return;
			var selfItems:CastItems = game.squirrels.get(Game.selfId).castItems;
			var item:CastItem = selfItems.getItem(itemClass, CastItem.TYPE_ROUND);
			if (item.count == 1)
			{
				if (selfItems.items.length != 0)
					for each (var castItem:CastItem in selfItems.items)
					{
						if (item == castItem)
							continue;
						if (castItem.type != CastItem.TYPE_ROUND)
							continue;
						if (castItem.count <= 0)
							continue;
						onObjectSelect(new CastEvent(CastEvent.SELECT, castItem.itemClass));
						return;
					}
				//dropObject();
			}
		}

		override protected function updateSquirrelCastItems(id:int):void
		{
			if (!Hero.self || !Hero.self.castItems)
				return;
			var isAmmo:Boolean = CastItemsData.isAmmo(id);
			Hero.self.castItems.add(new CastItem(CastItemsData.getClass(id), isAmmo ? CastItem.TYPE_ROUND : CastItem.TYPE_SQUIRREL, -1));

			if (isAmmo || !Game.selfCastItems)
				return;

			Game.selfCastItems[id] = Math.max(Game.selfCastItems[id] - 1, 0);
		}
	}
}
package game.gameData
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import events.GameEvent;
	import game.gameData.VIPManager;
	import views.FriendGiftBonusView;

	import protocol.Connection;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketEnergy;
	import protocol.packages.server.PacketEnergyLimits;
	import protocol.packages.server.PacketMana;

	import utils.DateUtil;

	public class PowerManager
	{
		static private const TIME:int = 60;

		static private var _maxEnergy:int = 0;
		static private var _maxMana:int = 0;
		static private var _currentEnergy:int = 0;
		static private var _currentMana:int = 0;

		static private var timeLeft:int = TIME;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static public function init():void
		{
			Connection.listen(onPacket, [PacketEnergy.PACKET_ID, PacketMana.PACKET_ID, PacketEnergyLimits.PACKET_ID]);

			EnterFrameManager.addPerSecondTimer(onTimer);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function get isFullEnergy():Boolean
		{
			return currentEnergy >= maxEnergy;
		}

		static public function get isManaEnergy():Boolean
		{
			return currentMana >= maxMana;
		}

		static public function isEnoughEnergy(locationId:int):Boolean
		{
			if (ExpirationsManager.haveExpiration(ExpirationsManager.BIRTHDAY_2015) || ExpirationsManager.haveExpiration(ExpirationsManager.HOT_WEEKEND))
				return true;
			return currentEnergy >= Locations.getLocation(locationId).cost;
		}

		static public function isEnoughMana(cost:int):Boolean
		{
			if (DiscountManager.freeMana)
				return true;
			return currentMana >= cost;
		}

		static public function get maxEnergy():int
		{
			return _maxEnergy;
		}

		static public function get maxMana():int
		{
			return _maxMana;
		}

		static public function get currentMana():int
		{
			return DiscountManager.freeMana ? Math.max(_currentMana, maxMana) : _currentMana;
		}

		static public function get currentEnergy():int
		{
			return _currentEnergy;
		}

		static public function get durationString():String
		{
			return DateUtil.formatTime(timeLeft);
		}

		static private function onTimer():void
		{
			if (timeLeft <= 0)
			{
				timeLeft = TIME;

				if (!isFullEnergy)
				{
					var delta:int = VIPManager.haveVIP && (currentEnergy + 2 <= maxEnergy) ? 2 : 1;
					_currentEnergy += delta;
					dispatcher.dispatchEvent(new GameEvent(GameEvent.ENERGY_CHANGED, {'value': currentEnergy, 'delta': delta, 'reason': 0}));
				}
			}
			timeLeft--;

			dispatcher.dispatchEvent(new Event(Event.CHANGE));
		}

		static private function onPacket(packet: AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketEnergy.PACKET_ID:
					var energy: PacketEnergy = packet as PacketEnergy;

					if (energy.reason == PacketServer.REASON_FRIEND_GIFT)
						FriendGiftBonusView.energy = energy.energy - _currentEnergy;

					var lastValue:int = _currentEnergy;
					_currentEnergy = energy.energy - FriendGiftBonusView.energy;

					dispatcher.dispatchEvent(new GameEvent(GameEvent.ENERGY_CHANGED, {'value': currentEnergy, 'delta': currentEnergy - lastValue, 'reason': energy.reason}));
					break;
				case PacketMana.PACKET_ID:
					var manaInfo: PacketMana = packet as PacketMana;

					if (manaInfo.reason == PacketServer.REASON_FRIEND_GIFT)
						FriendGiftBonusView.mana = manaInfo.mana - _currentMana;

					lastValue = _currentMana;
					_currentMana = manaInfo.mana - FriendGiftBonusView.mana;

					dispatcher.dispatchEvent(new GameEvent(GameEvent.MANA_CHANGED, {'value': currentMana, 'delta': currentMana - lastValue, 'reason': manaInfo.reason}));
					break;
				case PacketEnergyLimits.PACKET_ID:
					var energyLimits: PacketEnergyLimits = packet as PacketEnergyLimits;
					_maxEnergy = energyLimits.energy;
					_maxMana = energyLimits.mana;

					dispatcher.dispatchEvent(new GameEvent(GameEvent.MAX_POWERS_CHANGED));
					break;
			}
		}
	}
}
package com.api
{
	import flash.events.Event;

	public class FriendEvent extends Event
	{
		static public const INFO_LOADED:String = "FriendEvent.infoLoaded";
		static public const REQUEST_INFO:String = "FriendEvent.requestInfo";
		static public const PHOTO_LOADED:String = "FriendEvent.photoLoaded";

		public var friend:Friend;

		public function FriendEvent(name:String, friend:Friend):void
		{
			super(name);

			this.friend = friend;
		}
	}
}
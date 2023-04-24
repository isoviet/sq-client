package tape
{
	import tape.events.TapeDataEvent;

	public class TapeInviteFriendsView extends TapeView
	{
		private var preloaderMovie:MoviePreload;

		private var mini:Boolean = false;

		public function TapeInviteFriendsView(mini:Boolean = false):void
		{
			this.mini = mini;

			super(mini ? 5 : 2, mini ? 1 : 4, 0, 0, mini ? 0 : 20, 20, mini ? 60 : 258, 50);

			setData(new TapeInviteFriendsData(mini));
			this.data.addEventListener(TapeDataEvent.UPDATE, hidePreloader);
			if (this.mini)
				this.data.addEventListener(TapeDataEvent.UPDATE, onUpdate);

			this.preloaderMovie = new MoviePreload();
			this.preloaderMovie.scaleX = this.preloaderMovie.scaleY = 2;
			this.preloaderMovie.x = 230;
			this.preloaderMovie.y = 100;
			if (!this.mini)
				addChild(this.preloaderMovie);
		}

		public function getInviteIds():Array
		{
			return this.selfData.getInviteIds();
		}

		public function selectAll():void
		{
			this.selfData.selectAll();
		}

		private function get selfData():TapeInviteFriendsData
		{
			return this.data as TapeInviteFriendsData;
		}

		private function onUpdate(e:TapeDataEvent):void
		{
			this.x = (5 - this.data.objects.length) * 30;
		}

		private function hidePreloader(e:TapeDataEvent):void
		{
			this.data.removeEventListener(TapeDataEvent.UPDATE, hidePreloader);
			this.preloaderMovie.visible = false;
		}

		override protected function placeButtons():void
		{}

		override protected function updateButtons():void
		{}
	}
}
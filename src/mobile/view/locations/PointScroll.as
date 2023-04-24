package mobile.view.locations
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	import utils.starling.utils.StarlingConverter;

	public class PointScroll extends Sprite
	{
		public static const ANIMATION_SPEED: Number = 0.2;

		public static const STATE_ACTIVE: int = 0;
		public static const STATE_LOCKED: int = 1;
		public static const STATE_UNLOCKED: int = 2;

		public static var textureOfPointActive: Texture = null;
		public static var textureOfPointLocked: Texture = null;
		public static var textureOfPointUnlocked: Texture = null;

		private var imgActive: Image = null;
		private var imgLocked: Image = null;
		private var imgUnlocked: Image = null;

		private var lastImage: Image = null;
		private var nowImage: Image = null;
		private var lastState: int = -1;

		public function PointScroll(state: int = STATE_LOCKED)
		{
			if (!textureOfPointActive)
				textureOfPointActive = StarlingConverter.getTexture(new ScrollPointActive(), 0, 1, 1, false, '', false, true);

			if (!textureOfPointLocked)
				textureOfPointLocked = StarlingConverter.getTexture(new ScrollPointDisabled(), 0, 1, 1, false, '', false, true);

			if(!textureOfPointUnlocked)
				textureOfPointUnlocked = StarlingConverter.getTexture(new ScrollPointEnabled(), 0, 1, 1, false, '', false, true);

			imgActive = new Image(textureOfPointActive);
			imgLocked = new Image(textureOfPointLocked);
			imgUnlocked = new Image(textureOfPointUnlocked);

			imgActive.alignPivot();
			imgLocked.alignPivot();
			imgUnlocked.alignPivot();

			imgActive.alpha = 0;
			imgLocked.alpha = 0;
			imgUnlocked.alpha = 0;

			this.addChild(imgActive);
			this.addChild(imgLocked);
			this.addChild(imgUnlocked);

			changeState(state);
		}

		public function changeState(state: int): void
		{
			if (lastState == state)
				return;

			if (lastImage)
				lastImage.alpha = 1;

			lastState = state;

			switch (state)
			{
				case STATE_ACTIVE:
					nowImage = imgActive;
					break;
				case STATE_LOCKED:
					nowImage = imgLocked;
					break;
				case STATE_UNLOCKED:
					nowImage = imgUnlocked;
					break;
			}

			EnterFrameManager.removeListener(onAnimateChoice);
			EnterFrameManager.addListener(onAnimateChoice);
		}

		public function onAnimateChoice(): void
		{
			if (lastImage)
				lastImage.alpha -= ANIMATION_SPEED;

			nowImage.alpha += ANIMATION_SPEED;

			if (nowImage.alpha >= 1) {
				EnterFrameManager.removeListener(onAnimateChoice);
				lastImage = nowImage;
			}
		}
	}
}
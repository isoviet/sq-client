package
{
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import feathers.controls.Label;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextRenderer;

	public class StarlingLabel extends Label {
		private var textField: GameField;
		private var renderFormat: TextFormat;

		public function StarlingLabel(value: String, x: Number, y: Number, renderer: TextFieldTextRenderer) {
			super();
			renderFormat = renderer.textFormat;
			textField = new GameField(value, x, y, renderer.textFormat);
			this.x = x;
			this.y = y;

			this.textRendererProperties.align = TextFormatAlign.CENTER;
			this.applyRenderer(renderer);

			this.text = value;
		}

		override public function dispose(): void {
			textField = null;
			super.dispose();
		}

		public function applyRenderer(renderer: TextFieldTextRenderer): void {
			this.textRendererFactory = function():ITextRenderer {
			  return renderer;
			};
		}

		override public function set text(value: String): void {
			super.text = value;
			if (!textField)
				textField = new GameField(value, x, y, renderFormat);
			textField.text = value as String;
			super.validate();
		}

		public function get textHeight(): int {
			return  textField ? textField.textHeight : 0;
		}

		public function get textWidth(): int {
			return textField ? textField.textWidth : 0;
		}

		override public function get width(): Number {
			return textField.width;
		}
		override public function get height(): Number {
			return textField.height;
		}

		override public function set width(value: Number): void {
			super.width = value;
			textField.width = value;
		}

		override public function set height(value: Number): void {
			super.height = value;
			textField.height = value;
		}
	}
}
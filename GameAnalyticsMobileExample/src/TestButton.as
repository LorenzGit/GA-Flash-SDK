package 
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TestButton extends Sprite
	{
		private var textField:TextField;

		private var matrix:Matrix = new Matrix();

		public function TestButton(text:String)
		{
			super();

			init(text)
		}

		private function init(text:String):void
		{
			var padding:int = 10;
			var textFormat:TextFormat = new TextFormat("Arial", 20, 0xFFFFFF)

			textField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.defaultTextFormat = textFormat;
			textField.mouseEnabled = false;
			textField.x = textField.y = padding;
			textField.text = text;
			addChild(textField);

			matrix.createGradientBox(width, height, (Math.PI / 180) * 90, 0, 00);

			graphics.clear();
			graphics.beginGradientFill(GradientType.LINEAR, [0x163756, 0x163756], [1, 1], [1, 255], matrix);
			graphics.drawRoundRect(0, 0, padding * 3 + textField.textWidth, padding * 3 + textField.textHeight, 5, 5);
			graphics.endFill();
		}
	}
}

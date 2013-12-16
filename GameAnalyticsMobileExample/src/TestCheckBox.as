package
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TestCheckBox extends Sprite
	{
		private var _selected:Boolean;
		private var textField:TextField;
		private var selection:Sprite;

		public function TestCheckBox(text:String)
		{
			super();
			init(text);
		}

		private function init(text:String):void
		{
			var textFormat:TextFormat = new TextFormat("Arial", 20, 0x163756)

			textField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.defaultTextFormat = textFormat;
			textField.mouseEnabled = false;
			textField.x = 30;
			textField.text = text;
			addChild(textField);

			graphics.clear();
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 20, 20);
			graphics.endFill();

			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(1, 1, 18, 18);
			graphics.endFill();

			selection = new Sprite();
			//selection.visible = false;
			selection.graphics.lineStyle(1, 0x000000);
			selection.graphics.beginFill(0x000000);
			selection.graphics.moveTo(2, 2);
			selection.graphics.lineTo(18, 18);
			selection.graphics.moveTo(2, 18);
			selection.graphics.lineTo(18, 2);
			selection.graphics.endFill();

			textField.y = int((20 - textField.height) / 2)

			addChild(selection);
		}

		public function set selected(value:Boolean):void
		{
			_selected = value;
			selection.visible = value;
		}

		public function get selected():Boolean
		{
			return _selected;
		}
	}
}

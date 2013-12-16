package com.gameanalytics
{
	import flash.events.Event;

	public class GALogEvent extends Event
	{
		public static const LOG:String = "GA_LOG_EVENT";

		public var text:String;

		public function GALogEvent(type:String, text:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);

			this.text = text;
		}

		override public function clone():Event
		{
			return new GALogEvent(type, text, bubbles, cancelable);
		}
	}
}

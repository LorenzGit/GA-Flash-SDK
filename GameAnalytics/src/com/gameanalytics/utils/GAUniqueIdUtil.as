package com.gameanalytics.utils
{

	public class GAUniqueIdUtil
	{
		public function GAUniqueIdUtil()
		{
		}

		public static function createUnuqueId():String
		{
			var chars:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
			var num_chars:Number = chars.length - 1;
			var randomString:String = "";

			for (var i:Number = 0; i < 35; i++)
			{
				if (i == 8 || i == 13 || i == 18 || i == 23)
					randomString += "-";
				else
					randomString += chars.charAt(Math.floor(Math.random() * num_chars));
			}

			return randomString;
		}
	}
}

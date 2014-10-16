package net.gltd.gtms.utils
{
	import mx.controls.DateField;
	import mx.formatters.DateFormatter;

	public class DateRFC2822
	{
		public function DateRFC2822()
		{
		}
		public static function getStringDate(fromDate:Date=null):String {
			if (fromDate == null)fromDate = new Date();
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "EEE, DD MMM YYYY HH:NN:SS";
			var dtString:String = dateFormatter.format(fromDate);
				
			var tz:String = fromDate.toString();
			tz = tz.slice(tz.length - 10,tz.length-5);

			if (dtString.indexOf(fromDate.fullYear+" 24") > -1){
				dtString = dtString.slice(0, dtString.indexOf(fromDate.fullYear+" 24") + 5)+"00"+dtString.slice(dtString.indexOf(fromDate.fullYear+" 24") + 7,dtString.length);
			}
			
			return dtString + " " + tz;
			
		}
		public static function getDate(str:String):Date {	
		//	str = "Tue, 22 May 2012 20:00:00 +0000"
			var siedemnasta:Date = new Date ();
			var dt:Date = new Date();
			
			dt.time = Date.parse(str) ;

			return dt;
		}
			
	}
}
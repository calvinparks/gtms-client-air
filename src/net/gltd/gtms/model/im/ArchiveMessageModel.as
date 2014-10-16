package net.gltd.gtms.model.im
{
	import org.igniterealtime.xiff.data.Message;

	public class ArchiveMessageModel
	{
		public		var withId				:String,
						messages			:Array,
						xmlObject			:Object;
						
						
						
		private		var _startDate			:Date,	
						_startDateString	:String;
						
						
		public function ArchiveMessageModel(startDate:String, withId:String=null)
		{
			this.id = startDate;
			this.withId = withId;
		}
		public function get id():String {
			return _startDateString;
		}
		public function get startDate():Date{
			return _startDate;
		}
		public function set id(s:String):void {
			_startDateString = s;
			 
			var a:Array = s.slice(0,s.indexOf("T")).split("-");
			var t:Array = s.slice( s.indexOf("T")+1, s.indexOf(".") ).split(":");
			_startDate = new Date();
			_startDate.fullYear = a[0];
			_startDate.month = a[1] - 1;
			_startDate.date = a[2];
			_startDate.minutes = t[1];
			_startDate.seconds = t[2];
			_startDate.hours = t[0];
		}
	}
}
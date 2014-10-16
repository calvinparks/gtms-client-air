package net.gltd.gtms.model.im
{
	[Bindable]
	public class ShowStatusModel
	{
		
		public var ico				:Class;
		public var nickname			:String;
		public var show				:String;
		public var statusMsg		:String;
		public var displayOnList	:Boolean;
		public var dynamic			:Boolean;
		
		
		public function ShowStatusModel(nickname:String,ico:Class,show:String,statusMsg:String,displayOnList:Boolean,dynamic:Boolean)
		{
			this.nickname = nickname;
			this.ico = ico;
			this.show = show;
			this.statusMsg = statusMsg;
			this.displayOnList = displayOnList;
			this.dynamic = dynamic;
		}
	}
}
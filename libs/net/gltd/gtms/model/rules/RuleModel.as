package net.gltd.gtms.model.rules
{
	import mx.collections.ArrayCollection;

	public class RuleModel
	{
		private 	var _id					:String,
						_label				:String,
						_actionType			:String,
						_system				:String,
						_subsystem			:String,
						_type				:String,
						_override			:Boolean,
						_value				:String,
						_actionURL			:String,
						_urlType			:String,
						_buttonLabel		:String;
						
		public		var	empty				:Boolean = true,
						parameters			:ArrayCollection = new ArrayCollection([]);
						
		public function RuleModel(id:String,label:String=null)
		{
			this.id = id;
			this.label = label;
		}
		
		public function set id(s:String):void {
			_id = s;
		}
		[Bindable]
		public function get id():String {
			return _id;	
		}
		
		public function set label(s:String):void {
			_label = s;
		}
		[Bindable]
		public function get label():String {
			return _label;	
		}
		
		public function set actionURL(s:String):void {
			_actionURL = s;
		}
		public function get actionURL():String {
			return _actionURL;	
		}
		public function set urlType(s:String):void {
			_urlType = s;
		}
		public function get urlType():String {
			return _urlType;
		}
		
		
		
		public function set actionType(s:String):void {
			_actionType = s;
		}
		public function get actionType():String {
			return _actionType;	
		}
		
		
		public function set system(s:String):void {
			_system = s;
		}	
		public function get system():String {
			return _system;	
		}
		
		public function set subsystem(s:String):void {
			_subsystem = s;
		}	
		public function get subsystem():String {
			return _subsystem;	
		}

		
		public function set type(s:String):void {
			_type = s;
		}	
		public function get type():String {
			return _type;	
		}
		
		public function set override(s:Boolean):void {
			_override = s;
		}	
		public function get override():Boolean {
			return _override;	
		}
		public function set triggerEvent(s:String):void {
			_value = s;
		}	
		public function get triggerEvent():String {
			return _value;	
		}
		
		public function set buttonLabel(s:String):void {
			_buttonLabel = s;
		}	
		public function get buttonLabel():String {
			return _buttonLabel;	
		}
		
		
		
		
		
	}
}
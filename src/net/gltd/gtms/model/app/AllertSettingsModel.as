package net.gltd.gtms.model.app
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class AllertSettingsModel extends EventDispatcher
	{
		
		
		
		[Bindable]
		public var		label		:String;
		public var		name		:String;
		
		public var		_sound		:Boolean;
		public var		_popup		:Boolean;
		public var		_window		:Boolean
		public var		_time		:uint;
		public var		_changed	:Boolean = false;
		
		[Bindable]
		public var		soundEnabled:Boolean;
		[Bindable]
		public var		popupEnabled:Boolean;
		[Bindable]
		public var		windowEnabled:Boolean;
		
		public function AllertSettingsModel(name:String,label:String,sound:Boolean,popup:Boolean,window:Boolean,time:uint, popupenabled:Boolean,soundenabled:Boolean,windowenabled:Boolean)
		{
			this._time	= time;
			this._sound	= sound;
			this._popup	= popup;
			this._window = window;
			this.name	= name;
			this.label	= label;
			
			this.soundEnabled = soundenabled;
			this.popupEnabled = popupenabled;
			this.windowEnabled = windowenabled;
		}
		
		public function set sound(b:Boolean):void {
			_sound = b;
			changed = true;
		}
		[Bindable]
		public function get sound():Boolean {
			return _sound
		}
		
		public function set popup(b:Boolean):void {
			_popup = b;
			changed = true;
		}
		[Bindable]
		public function get popup():Boolean {
			return _popup
		}
		public function set window(b:Boolean):void {
			_window = b;
			changed = true;
		}
		[Bindable]
		public function get window():Boolean {
			return _window
		}
		
		public function set time(t:uint):void {
			_time = t;
			changed = true;
		}
		[Bindable]
		public function get time():uint {
			return _time
		}
		
		public function set changed(b:Boolean):void {
			_changed = b;
			dispatchEvent(new Event(Event.CHANGE));
			_changed = false;
			
		}
		[Bindable]
		public function get changed():Boolean {
			return _changed
		}
	}
}
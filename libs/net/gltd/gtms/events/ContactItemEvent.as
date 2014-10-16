package net.gltd.gtms.events
{
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.events.ToolTipEvent;
	
	import org.igniterealtime.xiff.core.UnescapedJID;
	
	
	
	public class ContactItemEvent extends Event
	{
		public static var CLICK:String = "onItemClick"
		public static var RIGHT_CLICK:String = "onItemRightClick";
		public static var MOUSE_DOWN:String = "onMouseDown";
		public static var TOOL_TIP:String = "onToolTip";
		public static var RENAME:String = "onRename";
		
		public var id:String;
		public var toolTip:ToolTipEvent;
		public var action:String;
		public var data:String;
		public var item:*;
		public var mouseEvent:MouseEvent;
		
		public var stageXY:Point;
		public function ContactItemEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
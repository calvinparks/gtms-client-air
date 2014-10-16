package net.gltd.gtms.events.muc
{
	import net.gltd.gtms.model.muc.ChannelModel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ChannelItemEvent extends Event
	{
		
		public	static	const		EVENT_FOLLOW			:String = "onFollow",
									EVENT_UNFOLLOW			:String = "onUnFollow",
									EVENT_SHOWCONTEXT		:String = "onShowContextMenu",
									EVENT_FAV				:String = "onFavChange";
		
		public			var			id						:String,
									item					:*,
									mouseEvent				:MouseEvent,
									boolVar					:Boolean;
		public function ChannelItemEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
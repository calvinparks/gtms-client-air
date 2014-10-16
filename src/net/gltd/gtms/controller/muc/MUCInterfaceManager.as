package net.gltd.gtms.controller.muc
{
	import net.gltd.gtms.controller.muc.MUCXMPPManager;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.model.muc.ChannelModel;
	import net.gltd.gtms.model.xmpp.DiscoItemModel;
	import net.gltd.gtms.utils.FilterArrayCollection;
	
	import flash.events.EventDispatcher;
	
	public class MUCInterfaceManager extends EventDispatcher
	{
		
		[Bindable][Embed(source="../assets/muc_icons/channel_gray_ico.png")]							
		public	static		var		channelIco			:Class;		
	
		[Bindable][Embed(source="../assets/muc_icons/stream_gray_ico.png")]							
		public	static		var		streamIco			:Class;	
		
		[Bindable][Embed(source="../assets/muc_icons/stream_ico.png")]							
		public	static		var		streamEnabledIco	:Class;	
		
		[Bindable][Embed(source="../assets/muc_icons/fav.png")]							
		public	static		var		favoriteIco			:Class;
		
		[Bindable][Embed(source="../assets/muc_icons/fav_red.png")]							
		public	static		var		favoriteRedIco		:Class;
		
		[Bindable][Embed(source="../assets/muc_icons/lock.png")]							
		public	static		var		lockIco				:Class;	
		
		[Inject]
		public	var		iqsManager						:MUCXMPPManager;
		
		[Inject]
		public	var		mucManager						:MUCManager;
		
		//public	var		items						:FilterArrayCollection;
		private	static  var		_items					:FilterArrayCollection;
		private	static  var		_muc					:MUCManager;
		private	var		_channels_enabled				:Boolean,
						_streams_enabled				:Boolean;
		
						
		[Init]
		public function init():void {
			_muc = mucManager;
		}
		
						
		[MessageHandler (selector="onDisconnected")]
		public function logout(event:ConnectionEvent):void {
			_channels_enabled = false;
			_streams_enabled = false;
			items = null;
		}
		
		public function set services(s:Vector.<DiscoItemModel>):void {
			iqsManager.channelServices = s;	
		}
		public function get services():Vector.<DiscoItemModel> {
			return iqsManager.channelServices;
		}
		public function set channels_enabled(b:Boolean):void {
			if (b && !_channels_enabled)mucManager.initChannelTab();
			_channels_enabled = b;
		}
		public function get channels_enabled():Boolean {
			return  _channels_enabled;
		}
		public function set streams_enabled(b:Boolean):void {
			if (b && !_streams_enabled)mucManager.initStremsTab();
			_streams_enabled = b;
		}
		public function get streams_enabled():Boolean {
			return  _streams_enabled;
		}
		public static function GoToChannel(channelID:String,messageID:String):void {
			try {
				var channel:ChannelModel = Channels().getItemByID(channelID) as ChannelModel;
				channel.gotoMessageId = messageID;
				_muc.openChannel( channel );
			}catch (error:Error){
				
			}
		}
		
		public static function Channels():FilterArrayCollection {
			return _items;
		}
		public function set items(ac:FilterArrayCollection):void {
			_items = ac;
		}
		public function get items():FilterArrayCollection {
			return _items;
		}
		
		
	}
	
}
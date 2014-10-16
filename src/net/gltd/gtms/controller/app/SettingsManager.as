package net.gltd.gtms.controller.app
{
	import net.gltd.gtms.model.app.AllertSettingsModel;
	
	import flash.data.EncryptedLocalStore;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	
	
	public dynamic class SettingsManager extends EventDispatcher
	{
		
		public	static	const	DEFAULT_CHAT_COLOR			:uint					= 0x696969,
								DEFAULT_CHAT_FONT_SIZE		:uint					= 12,
								
								DEFAULT_RECONNECT_TIME		:uint					= 5000,
								DEFAULT_IDLE_TIME			:uint					= 180000,
								DEFAULT_PORT				:uint					= 5222,
								DEFAULT_CONN_TYPE			:uint					= 1,
								DEFAULT_CONN_COMPRESS		:Boolean				= false,
								DEFAULT_ALLERTS				:Array					= [
									new AllertSettingsModel("notificationError","System Error",false,false,false,10000,true,true,false),
									new AllertSettingsModel("notificationContact","Contact (Connected / Disconnected)",true,true,false,10000,true,true,false),
									new AllertSettingsModel("notificationIM","New Message",true,true,true,15000,true,true,true),
									new AllertSettingsModel("notificationMUC","MUC (auto join)",true,true,true,15000,true,true,true),
									new AllertSettingsModel("notificationStreams","Stream Message",true,true,true,15000,true,true,true)
									];
		
		[Bindable]
		public	static	var		CHAT_COLOR					:uint;
		[Bindable] 
		public	static	var		CHAT_FONT_SIZE				:uint;
		 
		private	static	var		_IDLE_TIME					:uint;
		
		private	static	var		_RECONNECT_TIME				:uint;

		[Bindable]			
		public	static	var		RECONNECT_TIME_SECONDS		:int;
		
		[Bindable]			
		public	static	var		IDLE_TIME_SECONDS			:int = 5;
		
		
		private	static	var		_ALLERTS					:Object;
		
		[Bindable]		
		public	static	var		DEFAULT						:Boolean;
		
		/**		{label:"XMPP Connection",value:0},
				{label:"XMPP TLS Connection",value:1},
				{label:"XMPP BOSH Connection",value:2},
		,**/
		[Bindable]
		public	static	var		connectionType				:uint;
	
		private	static	var		_connectionCompress			:Boolean;
		
		[Bindable]
		public	static	var		connectionPort				:uint;
		
		
		//public	static	var		windowPosition				:Object = {};
		
		
		
		public static function set ALLERTS(a:Object):void {
			_ALLERTS = a;
			GlobalSettings.ALLERTS = a;
		}
		[Bindable]
		public static function get ALLERTS():Object {
			return _ALLERTS;
		}
		
		public static function Restore():void {
			CHAT_COLOR 		= DEFAULT_CHAT_COLOR;
			CHAT_FONT_SIZE	= DEFAULT_CHAT_FONT_SIZE;
			RECONNECT_TIME	= DEFAULT_RECONNECT_TIME;
			IDLE_TIME		= DEFAULT_IDLE_TIME;
			
			ALLERTS = {};
			for (var i:uint = 0; i<DEFAULT_ALLERTS.length; i++){ 
				var m:AllertSettingsModel = new AllertSettingsModel( DEFAULT_ALLERTS[i].name, DEFAULT_ALLERTS[i].label,  DEFAULT_ALLERTS[i].sound,  DEFAULT_ALLERTS[i].popup, DEFAULT_ALLERTS[i].window, DEFAULT_ALLERTS[i].time, DEFAULT_ALLERTS[i].popupEnabled, DEFAULT_ALLERTS[i].soundEnabled, DEFAULT_ALLERTS[i].windowEnabled)
				ALLERTS[m.name] =  m ;
			}
			
			SettingsManager.connectionPort = SettingsManager.DEFAULT_PORT;
			SettingsManager.connectionCompress = SettingsManager.DEFAULT_CONN_COMPRESS;
			SettingsManager.connectionType = SettingsManager.DEFAULT_CONN_TYPE;
		}
		
		public function SettingsManager()
		{
			ALLERTS = {};
			for (var i:uint = 0; i<DEFAULT_ALLERTS.length; i++){
				var m:AllertSettingsModel = new AllertSettingsModel( DEFAULT_ALLERTS[i].name, DEFAULT_ALLERTS[i].label,  DEFAULT_ALLERTS[i].sound,  DEFAULT_ALLERTS[i].popup, DEFAULT_ALLERTS[i].window, DEFAULT_ALLERTS[i].time, DEFAULT_ALLERTS[i].popupEnabled, DEFAULT_ALLERTS[i].soundEnabled, DEFAULT_ALLERTS[i].windowEnabled)
				ALLERTS[m.name] = m;
			}
			try {
				var bytes:ByteArray;
				bytes = EncryptedLocalStore.getItem("isDefault");
				if (bytes!=null){
					DEFAULT = bytes.readBoolean();
				}else {
					DEFAULT = true;
				}
				
				
				bytes = EncryptedLocalStore.getItem("chatColor");
				if (bytes!=null){
					CHAT_COLOR = bytes.readInt();
				}else {
					CHAT_COLOR = DEFAULT_CHAT_COLOR;
				}
				
				bytes = EncryptedLocalStore.getItem("chatFontSize");
				if (bytes!=null){
					CHAT_FONT_SIZE = bytes.readInt();
				}else {
					CHAT_FONT_SIZE = DEFAULT_CHAT_FONT_SIZE;
				}
				
				bytes = EncryptedLocalStore.getItem("reconnectTime");
				if (bytes!=null){
					RECONNECT_TIME = bytes.readInt();
				}else {
					RECONNECT_TIME = DEFAULT_RECONNECT_TIME;
				}
				
				bytes = EncryptedLocalStore.getItem("idleTime");
				if (bytes!=null){
					IDLE_TIME = bytes.readInt();
				}else {
					IDLE_TIME = DEFAULT_IDLE_TIME;
				}
				for (var ind:String in ALLERTS){
					bytes = EncryptedLocalStore.getItem(ind+"Sound");
					if (bytes!=null){
						ALLERTS[ind].sound = bytes.readBoolean()
					}
					bytes = EncryptedLocalStore.getItem(ind+"Popup");
					if (bytes!=null){
						ALLERTS[ind].popup = bytes.readBoolean()
					}
					bytes = EncryptedLocalStore.getItem(ind+"Time");
					if (bytes!=null){
						ALLERTS[ind].time = bytes.readInt()
					}
					bytes = EncryptedLocalStore.getItem(ind+"Window");
					if (bytes!=null){
						ALLERTS[ind].window = bytes.readBoolean()
					}
				
				}
				bytes = EncryptedLocalStore.getItem("connCompress");
				if (bytes!=null){
					connectionCompress = bytes.readBoolean()
				}else {
					connectionCompress = DEFAULT_CONN_COMPRESS;
				}
	
				bytes = EncryptedLocalStore.getItem("connType");
				if (bytes!=null){
					connectionType = bytes.readInt()
				}else {
					connectionType = DEFAULT_CONN_TYPE;
				}
				
				bytes = EncryptedLocalStore.getItem("connPort");
				if (bytes!=null){
					connectionPort = bytes.readInt()
				}else {
					connectionPort = DEFAULT_PORT;
				}
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
		}
		public static function set IDLE_TIME(n:int):void {
			_IDLE_TIME = n;
			IDLE_TIME_SECONDS =  Math.max(5,_IDLE_TIME/1000);
			FlexGlobals.topLevelApplication.dispatchEvent(new Event("idleChanged"));
			
		}
		[Bindable]
		public static function get IDLE_TIME():int {
			return _IDLE_TIME;
		}
		
		public static function set RECONNECT_TIME(n:int):void {
			_RECONNECT_TIME = n;
			RECONNECT_TIME_SECONDS = _RECONNECT_TIME/1000;
		}
		[Bindable]
		public static function get RECONNECT_TIME():int {
			return _RECONNECT_TIME;
		}
		[Bindable]
		public static function get connectionCompress():Boolean {
			return _connectionCompress;
		}
		public static function set connectionCompress(n:Boolean):void {
			_connectionCompress = n;
		}
		
		public static function setWindowPosition(n:String,p:Point):void {
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(p.x+"x"+p.y);
			EncryptedLocalStore.setItem("windowPos"+n,ba);
		}
		public static function getWindowPosition(n:String):Point {
			try {
				var ba:ByteArray = EncryptedLocalStore.getItem("windowPos"+n);
				if (ba==null)return null;
				var s:Array = ba.readUTFBytes( ba.length ).split("x");
				return new Point( Number(s[0]),Number(s[1]) );
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
			return new Point(Screen.mainScreen.bounds.width/2 - 100,Screen.mainScreen.bounds.height/2 - 80);
		}
		
	}
}
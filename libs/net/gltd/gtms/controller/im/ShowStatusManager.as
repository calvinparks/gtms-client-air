package net.gltd.gtms.controller.im
{
	import net.gltd.gtms.model.im.ShowStatusModel;
	
	import flash.events.EventDispatcher;
	
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	
	public class ShowStatusManager extends EventDispatcher
	{
		
		private static	var		_keys				:Object;
		private static 	var 	_showCollection		:Vector.<ShowStatusModel>;
		
	
		public function init():void {
			_keys = {};
			_showCollection = new Vector.<ShowStatusModel>();	
			addShow(["unavailable","offline"],"Unavailable",im_unavailable,Presence.TYPE_UNAVAILABLE,null,false);
			addShow([Presence.SHOW_CHAT],"Free To Chat",im_free_chat,Presence.SHOW_CHAT,"Free To Chat",true);
			addShow(["available","online"],"Available",im_available,null,"Available",true);
			addShow([Presence.SHOW_AWAY],"Away",im_away,Presence.SHOW_AWAY,"Away",true);
			addShow(["onphone"],"On Phone",on_phone,Presence.SHOW_DND,"On Phone",true);
			addShow([Presence.SHOW_XA],"Extended Away",im_away,Presence.SHOW_XA,"Extended Away",true);
			addShow(["ontheroad"],"On The Road",on_road,Presence.SHOW_DND,"On The Road",true);
			addShow([Presence.SHOW_DND],"Do Not Disturb",im_dnd,Presence.SHOW_DND,"Do Not Disturb",true);
			addShow(["awayduetoidle"],"Away due to Idle",im_away,Presence.SHOW_AWAY,"Away due to Idle",false);	
			addShow(["imcomposing"],"IMComposing",im_composing,null,null,false,true);
			addShow(["immessage"],"IMMessage",im_message,null,null,false,true);
			
			
		}
		public function addShow(key:Array,nickname:String,ico:Class,show:String,statusMsg:String=null,displayOnList:Boolean=false,dynamic:Boolean=false):void {
			var s:ShowStatusModel = new ShowStatusModel(nickname,ico,show,statusMsg,displayOnList,dynamic);
	
			var ind:uint = _showCollection.push(s) -1;
			for (var i:uint = 0; i<key.length; i++){
			_keys[key[i]] = ind;
			}
		}
		public function get showCollection():Vector.<ShowStatusModel> {
			return _showCollection;
		}
		public static function getShow(key:String, getDefauld:Boolean = false):ShowStatusModel {
			if (_keys == null)return null;
			if ( _keys[key] == undefined){
				if (getDefauld)	return _showCollection[0];
				return null;
			}
			return _showCollection[ _keys[key] ];
		}
		public static function getIco(key:String, getDefault:Boolean = false):Class {
			var m:ShowStatusModel = getShow(key,getDefault);
			if (m == null) return null
			if (m.dynamic){
			//	m.statusMsg = presenceManager.status;
			//	m.show = presenceManager.show;
			}
			return m.ico;
		}
		public static function getShowIco(r:RosterItemVO):Class{
			var key:String; 
			var ico:Class;

			if ( r.status != null){
				key = r.status.replace(/\ /g,'');
				key = key.toLowerCase();
				ico = getIco(key);
			}
			if (ico == null || (r.status == null && r.show != null)){
				ico = getIco( r.show );
			}
			 try { 
				if (ico == null || (ico == _showCollection[ _keys["unavailable"] ].ico && r.online) ){
					ico = getIco("available");
				}
			 }catch (error:Error){
				 trace ("bład w show");
			 }
			return ico;
		}
		
		[Bindable] 
		public var im_available:Class;
		
		[Bindable] 
		public var im_away:Class;
		
		[Bindable] 
		public var im_dnd:Class;
		
		[Bindable] 
		public var im_free_chat:Class;
		
		[Bindable] 
		public var im_unavailable:Class;
		
		[Bindable] 
		public var on_phone:Class;
		
		[Bindable] 
		public var on_road:Class;
		
		[Bindable] 
		public var on_video:Class;
		
		[Bindable] 
		public var im_composing:Class;
		
		[Bindable] 
		public var im_message:Class;
		
		
	}
}
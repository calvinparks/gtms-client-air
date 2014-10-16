package net.gltd.gtms.model.contact.singl{

	import net.gltd.gtms.events.ContactEvent;
	import net.gltd.gtms.model.contact.BuddyModel;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.im.RosterItemVO;

	
	public class buddiesHolder extends EventDispatcher {

		public static  	var dH:buddiesHolder;
		
		private 		var _buddiesLength			:uint,
							_buddies				:ArrayCollection,
							_buddiesIndexes			:Object,
							_deletedBuddies			:Object,
							_waintingMessages		:Object;
							
							
		public			var inited					:Boolean = false;
		public 			var	connections				:ArrayCollection;
		
		public static function getInstance(): buddiesHolder {
			if (dH == null) {
				dH = new buddiesHolder(arguments.callee);
			}
			return dH;

		}
		public static function destroy():void {
			dH = null;
		}

		public function kill():void {
			
			for (var i:uint = 0; i<length;i++){
				_buddies.getItemAt(i).kill();
			}
			_buddies.removeAll();
			_buddies = null;
			
			_buddiesIndexes = null;
			_deletedBuddies = null;
			_waintingMessages = null;
			connections = null;
			inited = false;
		}
		public function buddiesHolder(caller:Function=null) {
			if (caller != buddiesHolder.getInstance) {
				throw new Error("SINGELTON use -> getInstance()");
			}else {
			
				resetBuddies();
			}
			if (buddiesHolder.dH != null) {
				throw new Error("Error");
			}
		}	
		public function resetBuddies():void {
			_buddiesLength = 0;
			_buddies = new ArrayCollection();
			connections = new ArrayCollection();
			_buddiesIndexes = {};
			_deletedBuddies = {};
			_waintingMessages = {};
			inited = false;
		}
		public function set connection(c:RosterItemVO):void {
			connections.addItem(c);
		}
		public function removeConnection(jid:String):void {
			try {
				for (var i:uint = 0; i<connections.length;i++){
					if (connections.getItemAt(i).jid.bareJID == jid){
						connections.removeItemAt(i);
					}
				}
			}catch (error:Error){
				
			}
		}
		 
		public function set buddy(bd:BuddyModel):void {
			
			if (_waintingMessages[bd.id]){
				for (var m:uint = 0; m < _waintingMessages[bd.id].length; m++){
					try {
						bd.pushMessage(_waintingMessages[bd.id][m]);
					}catch (error:Error){}
				}
				delete _waintingMessages[bd.id];
			}
			_buddies.addItem(bd);
			_buddiesIndexes[bd.id] = _buddiesLength;
			_buddiesLength++;
			
			var e:ContactEvent = new ContactEvent(ContactEvent.ON_SET_BUDDY);
			e.id = bd.id;
			dispatchEvent(e);
			
		}
		public function removeBuddie(id:String):Boolean {
			try {
				_deletedBuddies[id] = _buddies.removeItemAt(_buddiesIndexes[id]);
				_buddiesIndexes = {}
				for (var i:uint = 0; i< _buddies.length;i++){
					_buddiesIndexes[_buddies.getItemAt(i).id] = i
				}
				_buddiesLength--;
					trace ("remove buddy id",id);
			}catch (err:Error){
				return false;
			}
			return true;
		}
		public function isExist(id:String):Boolean {
			try {
				return _buddiesIndexes[id] > -1;
			}catch (er:Error){
				
			}
			return false
		}
		public function get length():uint {
			return _buddiesLength;
		}
		public function getBuddy(id:*):BuddyModel {
			try {
				if (id is int){
					return _buddies.getItemAt((id as int)) as BuddyModel;
				}else {
					if (_buddiesIndexes[id.toString()] == undefined)return null;
					return _buddies.getItemAt(_buddiesIndexes[id.toString()]) as BuddyModel;
				}
				
			}catch (err:Error){
		
			}
			return null;
		}
		public function get buddies():ArrayCollection {
			return _buddies;
		}
		/*	public function pushMessage(jid:String,msg:MessageModel):void {
		try{
		_buddies.getItemAt(_buddiesIndexes[jid]).pushMessage(msg)
		}catch (er:Error) {
		if (_waintingMessages[jid] == undefined || _waintingMessages[jid] == null){
		_waintingMessages[jid] = []
		}
		_waintingMessages[jid].push ( msg );
		}
		}*/
	}
}
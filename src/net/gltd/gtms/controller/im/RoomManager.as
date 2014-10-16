package net.gltd.gtms.controller.im
{
	import net.gltd.gtms.GUI.UEM.UEM;
	import net.gltd.gtms.GUI.UEM.UEMfeature;
	import net.gltd.gtms.controller.muc.MUCXMPPManager;
	import net.gltd.gtms.controller.xmpp.Connection;
	import net.gltd.gtms.events.ChatEvent;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.model.contact.singl.buddiesHolder;
	import net.gltd.gtms.utils.StringUtils;
	import net.gltd.gtms.view.im.chat.Chat;
	
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.conference.InviteListener;
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.conference.RoomOccupant;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.muc.MUC;
	import org.igniterealtime.xiff.data.muc.MUCExtension;
	import org.igniterealtime.xiff.data.muc.MUCOwnerExtension;
	import org.igniterealtime.xiff.data.muc.MUCUserExtension;
	import org.igniterealtime.xiff.events.InviteEvent;
	import org.igniterealtime.xiff.events.RoomEvent;

	[Event(name="onRoomJoin",type="net.gltd.gtms.events.ChatEvent")]
	[ManagedEvents("onRoomJoin")]
	
	public class RoomManager extends EventDispatcher
	{
		
		private			var		conferenceServer	:String,
								rooms				:Array = [],
								roomsKeys			:Object = {},
								_listener			:InviteListener; 

		[Inject][Bindable]
		public			var		conn				:Connection;
		
		[Inject][Bindable]
		public			var		muc					:MUCXMPPManager;
		
	
		
		[MessageHandler (selector="onLoginSuccess")]
		public	function onLogin(event:ConnectionEvent):void {
			_listener = new InviteListener(conn.connection);
			_listener.addEventListener(InviteEvent.INVITED, onInvited);
		}
		[MessageHandler (selector="onDisconnected")]
		public	function onDisconnected(event:ConnectionEvent):void {
			if (_listener!=null)_listener.removeEventListener(InviteEvent.INVITED, onInvited);
			rooms = [];
			roomsKeys = {};
			conferenceServer = null;
		}
		
		[MessageHandler (selector="onOpenRoom")]
		public	function getRoom(event:ChatEvent):void {
			if (event.room != null){
				for (var i:uint = 0; i<event.recipients.length; i++){
					var doInvite:Boolean = true;
					for (var j:uint = 0; j<event.room.length; j++){
						if ( (event.room.getItemAt(j) as RoomOccupant).jid.bareJID == event.recipients[i].bareJID){
							doInvite = false;
							break;
						}
					}
					if (doInvite){
						event.room.invite(event.recipients[i],event.inviteMessage)
					}
				}
					
			}else {
				createNewRoom(event.recipients,event.roomName,event.inviteMessage);	
			}
		}
		
		
		public function joinRoom(room:Room):void {
			muc.joinRoom(room.roomJID,null,null,false,room,room.roomName,true); 
		}
		
		[MessageHandler (selector="onJoinViaMuc")]
		public function joinViaMUC(event:ChatEvent):void {
			joinRoom(event.room);
		}
		
		private function createNewRoom(recipients:Array,roomName:String = null, inviteMessage:String = ""):void {
			var roomDisplayName:String = roomName;
			try {
				if (conferenceServer == null)conferenceServer = conn.disco.getDiscoByName("Public Chatrooms").jid.bareJID;
			}catch (error:Error){
				return;
			}
			if (roomName == null || roomName.length==0){
				roomName = conn.connection.jid.node+"_conference";
			}
		
	
			roomName = roomName.replace(/ /g, '_')+"_"+StringUtils.generateRandomString(1,"qwertyuiopasddfghjklzxcvbnm")+StringUtils.generateRandomString(2,"1234567890")+rooms.length;
			
			if (roomDisplayName == null || roomDisplayName.length==0){
				roomDisplayName = roomName;
			}
			
			
			var room:Room = muc.joinRoom(new UnescapedJID(roomName+"@"+conferenceServer),null,null,false,null,roomDisplayName,true)
			room.label = roomDisplayName;
			var iq:IQ = new IQ(room.roomJID.escaped,IQ.TYPE_SET,null,extensionCallBack,extensionCallBack);
			 
			var mucext:MUCOwnerExtension = new MUCOwnerExtension();
			var xml:String = <x xmlns="jabber:x:data" type="submit">
					<field var="muc#roomconfig_roomname" label="Room Name"><value>{roomDisplayName}</value></field>
					</x>;
			
			mucext.xml.appendChild(new XML(xml));
		 //	mucext.xml.appendChild(xml);

			iq.addExtension(mucext);
			//iq.xml.appendChild(mucext.xml);
 
		
			
			conn.send( iq );
			 
				
			roomsKeys[roomName] = rooms.push(room) - 1;
			for (var i:uint = 0; i< recipients.length;i++){
				room.invite(recipients[i],inviteMessage);
			}
			room.grant(Room.AFFILIATION_MEMBER,recipients);
			
	
			
			
		} 
		private function extensionCallBack(iq:IQ):void {
			trace ("extensionCallBack",iq.xml);
		}
	
		public function leaveRoom(room:Room):void {
			room.leave();
		}
		private function onRoom(e:RoomEvent):void { 
			if (e.type == RoomEvent.ROOM_JOIN){
				var che:ChatEvent = new ChatEvent(ChatEvent.ROOM_JOIN);
				che.room = e.currentTarget as Room;
				dispatchEvent(che);
				e.currentTarget.removeEventListener(RoomEvent.ROOM_JOIN, onRoom);
			}
			 
			
		}
		private function onInvited(e:InviteEvent):void {
			if (e.type == InviteEvent.INVITED){
				var nickname:String;
				try {
					nickname = buddiesHolder.getInstance().getBuddy(e.from.bareJID).nickname;
				}catch (error:Error){
					nickname = e.from.node;
				}
				var room:Room = e.room;
				
				var title:String = UIphrases.INVITE_EVENT_TITLE;
				var message:String;
				if (e.reason != null && e.reason.length > 0) message = e.reason;
				else message = UIphrases.getPhrase(UIphrases.INVITE_EVENT_MESSAGE,{nickname:nickname});
				var features:Array = [
					new UEMfeature(UIphrases.INVITE_EVENT_BUTTON_ACCEPT,joinRoom,[room]),
					new UEMfeature(UIphrases.INVITE_EVENT_BUTTON_DECLINE,leaveRoom,[room])
				]
				var owner:String = room.roomJID.bareJID + "Room";
				UEM.newUEM(owner,title,message,features,null,0);
			}
			
		}
	}
}
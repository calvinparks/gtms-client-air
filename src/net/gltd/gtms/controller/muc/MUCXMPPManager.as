package net.gltd.gtms.controller.muc
{
	import net.gltd.gtms.GUI.UEM.UEM;
	import net.gltd.gtms.GUI.window.CustomWindow;
	import net.gltd.gtms.controller.im.ChatMessageManager;
	import net.gltd.gtms.controller.xmpp.Connection;
	import net.gltd.gtms.events.ArchiveEvent;
	import net.gltd.gtms.events.ChatEvent;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.events.muc.MUC_UI_Event;
	import net.gltd.gtms.model.dataHolder;
	import net.gltd.gtms.model.muc.ChannelDetails;
	import net.gltd.gtms.model.muc.ChannelModel;
	import net.gltd.gtms.model.muc.StreamModel;
	import net.gltd.gtms.model.muc.xmlamapper.Feature;
	import net.gltd.gtms.model.muc.xmlamapper.Field;
	import net.gltd.gtms.model.muc.xmlamapper.Fields;
	import net.gltd.gtms.model.muc.xmlamapper.Identity;
	import net.gltd.gtms.model.xmpp.DiscoItemModel;
	import net.gltd.gtms.utils.FilterArrayCollection;
	import net.gltd.gtms.utils.StringUtils;
	import net.gltd.gtms.view.muc.PasswordProtectedContent;
	
	import flash.display.Screen;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.messaging.Channel;
	import mx.rpc.xml.SimpleXMLDecoder;
	
	import org.igniterealtime.xiff.bookmark.BookmarkManager;
	import org.igniterealtime.xiff.bookmark.BookmarkPrivatePayload;
	import org.igniterealtime.xiff.bookmark.GroupChatBookmark;
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.Extension;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.data.muc.MUC;
	import org.igniterealtime.xiff.data.muc.MUCExtension;
	import org.igniterealtime.xiff.data.muc.MUCOwnerExtension;
	import org.igniterealtime.xiff.data.muc.MUCUserExtension;
	import org.igniterealtime.xiff.events.BookmarkChangedEvent;
	import org.igniterealtime.xiff.events.BookmarkRetrievedEvent;
	import org.igniterealtime.xiff.events.MessageEvent;
	import org.igniterealtime.xiff.events.RoomEvent;
	import org.igniterealtime.xiff.privatedata.PrivateDataManager;
	import org.spicefactory.lib.xml.XmlObjectMapper;
	import org.spicefactory.lib.xml.mapper.XmlObjectMappings;
	
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.components.Window;
	
	
	[Event(name="onRoomJoin",type="net.gltd.gtms.events.ChatEvent")]
	[Event(name="onUserOpenStream",type="net.gltd.gtms.events.UserEvent")]
	[Event(name="onContactAddedGetArchive",type="net.gltd.gtms.events.ArchiveEvent")]
	[ManagedEvents("onRoomJoin, onUserOpenStream, onContactAddedGetArchive")]
	public class MUCXMPPManager extends EventDispatcher
	{
		[Inject][Bindable]
		public	var		connection					:Connection;
	 
		[Inject][Bindable]
		public	var		mucManager					:MUCManager;
		
		
		[Inject][Bindable]
		public	var		streamsManager				:StreamsManager;
		
		
		[Inject][Bindable]
		public	var		mucInterfaceManager			:MUCInterfaceManager;
		
		[Inject][Bindable]
		public	var		chatMessageManager			:ChatMessageManager;
		
		
		private	var		_services					:Vector.<DiscoItemModel> = new Vector.<DiscoItemModel>(),
						_streamsServices			:FilterArrayCollection = new FilterArrayCollection(),
			
						_servicesRefs				:Object = {},
						_inited						:Boolean = false,
						_initedStreams				:Boolean = false,
						_initTimeot					:int,
						_initTimeot2				:int,
						_xmlDecoder					:SimpleXMLDecoder = new SimpleXMLDecoder(),
						
						_bookmarkManager			:BookmarkManager,
		
		
						xNS							:XmlObjectMappings,
						xom							:XmlObjectMapper,
						
		
						_getSubscriptionsFirstTime	:Boolean = true;
						
		[Init]
		public function init_muc():void {
			
			
		}
		private function initXMLmapper():void {
			xNS = new XmlObjectMappings("jabber:x:data")
				.choiceId("x", Fields).mappedClasses(Field);
			
			xom = new XmlObjectMappings("http://jabber.org/protocol/disco#info", null,ChannelDetails)
				.mappedClasses(net.gltd.gtms.model.muc.ChannelDetails)
				.mappedClasses(net.gltd.gtms.model.muc.xmlamapper.Identity)
				.mappedClasses(net.gltd.gtms.model.muc.xmlamapper.Feature)
				.mergedMappings(xNS)
				.build();
		}
		public	static	var	muc_dictionary:Object = {muc_public:"Public room in Multi-User Chat",
			muc_semianonymous:"Semi-anonymous room in Multi-User Chat",
			muc_temporary:"Temporary room in Multi-User Chat",
			muc_unmoderated:"Unmoderated room in Multi-User Chat",
			muc_unsecured:"Unsecured room in Multi-User Chat",
			muc_persistent:"Persistent room in Multi-User Chat",
			muc_passwordprotected:"Password-protected room in Multi-User Chat",
			muc_open:"Open room in Multi-User Chat ",
			muc_nonanonymous:"Non-anonymous room in Multi-User Chat",
			muc_moderated:"Members-only room in Multi-User Chat",
			muc_hidden:"Hidden room in Multi-User Chat"};
	
		[MessageHandler (selector="onLoginSuccess")]
		public function login(event:ConnectionEvent):void {

			setTimeout(initXMLmapper,300); 
			_inited = false;
			_initedStreams = false;
			_getSubscriptionsFirstTime = true
		
			mucInterfaceManager.items = new FilterArrayCollection();
			mucInterfaceManager.items.addEventListener(CollectionEvent.COLLECTION_CHANGE, onItemsCollChange);

			var pdm:PrivateDataManager = new PrivateDataManager(connection.connection);
		
			_bookmarkManager = new BookmarkManager(pdm); 
			_bookmarkManager.addEventListener(BookmarkChangedEvent.GROUPCHAT_BOOKMARK_ADDED,onBookMarkChange);
			_bookmarkManager.addEventListener(BookmarkChangedEvent.GROUPCHAT_BOOKMARK_REMOVED,onBookMarkChange);
			_bookmarkManager.addEventListener(BookmarkRetrievedEvent.BOOKMARK_RETRIEVED,onBookmarkRetrieved);
			_bookmarkManager.fetchBookmarks(); 
			
			 connection.connection.addEventListener(MessageEvent.MESSAGE,onMessage);
	 
			 
		}
		
		[MessageHandler (selector="onMUCChangeProp")]
		public function onMUCChangeProp(event:ChatEvent):void {
			try {
				var m:* = mucInterfaceManager.items.getItemByID( event.id );
				if (!m || !event.newProp)return;
				for (var ind:String in event.newProp){
					if (m.hasOwnProperty(ind)){
						m[ind] = event.newProp[ind]
					}
				}
			}catch (error:Error){
				trace (error.getStackTrace());
			}
			
			
		}
		
		public function pubsub(node:String, subid:String, subscriber:String= null, unsubscribe:Boolean=false):void {
			var pubsubValue:String;
			if (unsubscribe == true) pubsubValue = "unsubscribe";
			else pubsubValue = "subscribe";
			var service:EscapedJID = new EscapedJID("pubsub."+connection.jid.domain);
			
			var pubsub:XMLNode = new XMLNode(1,"pubsub");
			pubsub.attributes.xmlns="http://jabber.org/protocol/pubsub";
			var subscribe:XMLNode = new XMLNode(1,pubsubValue);
			if (subscriber==null)subscriber= connection.jid.bareJID;
			subscribe.attributes.jid = subscriber;
			if (subid!=null) subscribe.attributes.subid = subid;
			subscribe.attributes.node = node;
			
			pubsub.appendChild( subscribe );
			
			var iq:IQ = new IQ(service,"set",("iq_"+StringUtils.generateRandomString(4)+"_"+node),pubsubResponse);
			iq.xml.appendChild( new XML( pubsub ) );
			
			connection.send(iq);
				
		}
		
		public function getSubscriptions():void {
			var service:EscapedJID = new EscapedJID("pubsub."+connection.jid.domain);
			
			var pubsub:XMLNode = new XMLNode(1,"pubsub");
			pubsub.attributes.xmlns="http://jabber.org/protocol/pubsub";
			
			var subscriptions:XMLNode = new XMLNode(1,"subscriptions");
			pubsub.appendChild( subscriptions );
			
			var iq:IQ = new IQ(service,"get",null,getSubscriptionsCallBack);
			iq.xml.appendChild( new XML(pubsub) );
			connection.send( iq );
		}
		
		private function pubsubResponse(iq:IQ):void {
			var ind:int;
			try {
				var obj:Object = _xmlDecoder.decodeXML( new XMLDocument(iq.xml).firstChild );
				 ind = mucInterfaceManager.items.getIndexByKey("interest", obj.pubsub.subscription.node );
				if (ind > -1){
					(mucInterfaceManager.items.getItemAt( ind ) as StreamModel).subscription = obj.pubsub.subscription	
				}
			}catch (error:Error){
				var id:String =  iq.id.split("_").pop() ;
				ind = mucInterfaceManager.items.getIndexByKey("id",id);
				if (ind > -1){
					(mucInterfaceManager.items.getItemAt( ind ) as StreamModel).subscription = null;
				}
				//getSubscriptions();
			}
		}
		
		private function getSubscriptionsCallBack(iq:IQ):void {
			try {
				var obj:Object = _xmlDecoder.decodeXML( new XMLDocument(iq.xml).firstChild );
				var subscriptions:Array;
				if (!obj.pubsub.subscriptions.subscription is Array) subscriptions = [obj.pubsub.subscriptions.subscription];
				else subscriptions = obj.pubsub.subscriptions.subscription;
				for (var i:uint = 0; i<subscriptions.length; i++){
					if(new EscapedJID(subscriptions[i].jid).bareJID != connection.jid.bareJID) continue;
					try {
						var ind:int = mucInterfaceManager.items.getIndexByKey("interest", subscriptions[i].node );
						if (ind > -1){
							(mucInterfaceManager.items.getItemAt( ind ) as StreamModel).subscription = subscriptions[i];
							if (_getSubscriptionsFirstTime){
								openStream( (mucInterfaceManager.items.getItemAt( ind ) as StreamModel) );
							}
						}
					}catch (error:Error){
						trace (error.getStackTrace());
					}
				}
			}catch (error:Error){
				
			}
			_getSubscriptionsFirstTime = false;
		}
		
		private function onMessage(event:MessageEvent):void {
		
			try {
				if ( connection.disco.getDiscoByJID(event.data.from.bareJID).category == "pubsub" ){
	
					var obj:Object = _xmlDecoder.decodeXML( new XMLDocument(event.data.xml).firstChild );
					obj = obj.event
					var items:Array;
					if (!(obj.items.item is Array)) items = [obj.items.item];
					else items = obj.items.item;
					var streamID:String = obj.items.node;
					var hasMessages:Boolean = false;			
					var stream:StreamModel = mucInterfaceManager.items.getItemByID(streamID.split("_").pop()) as StreamModel;
					for (var i:uint = 0; i<items.length;i++){
						if (items[i].hasOwnProperty("message")){
							if ( items[i].message.body == undefined ||  items[i].message.body == null) continue;
							var streamMessage:Message = new Message();
							streamMessage.from = new EscapedJID(items[i].message.from);
							streamMessage.body = items[i].message.body;
							streamMessage.id = items[i].message.id;
							streamMessage.type = items[i].message.type;
							streamMessage.to = new EscapedJID(items[i].message.to);
							try {
								streamMessage.subject = ( mucInterfaceManager.items.getItemByID(streamMessage.from.bareJID) as ChannelModel).name;
							}catch (error:Error){
								streamMessage.subject = streamMessage.from.bareJID;
							}
							hasMessages = true;
							stream.pushMessage( streamMessage );
						}
						
					}
					if (hasMessages){
						openStream(stream);
					}
					
				}
				
			}catch (error:Error){
				
			}
			
			
			if (event.data.type != Message.TYPE_GROUPCHAT) return;
			try {
				if ( event.data.xml.hasOwnProperty("subject") ) {
					mucInterfaceManager.items.getItemByID( event.data.from.bareJID )['info'] = event.data.xml.child('subject');
					
				}
			}catch (error:Error){
				trace (error.getStackTrace());
			}
		}
		
		private function openStream(stream:StreamModel):void {
			var eu:UserEvent = new UserEvent(UserEvent.USER_OPEN_STREAM);
			eu.data = stream;
			eu.userAction = false;
			dispatchEvent(eu);	
		}
		
		[MessageHandler (selector="onDisconnected")]
		public function logout(event:ConnectionEvent):void {
			_bookmarkManager.removeEventListener(BookmarkChangedEvent.GROUPCHAT_BOOKMARK_ADDED,onBookMarkChange);
			_bookmarkManager.removeEventListener(BookmarkChangedEvent.GROUPCHAT_BOOKMARK_REMOVED,onBookMarkChange);
			_bookmarkManager.removeEventListener(BookmarkRetrievedEvent.BOOKMARK_RETRIEVED,onBookmarkRetrieved);
			
			_services = new Vector.<DiscoItemModel>();
			_streamsServices = new FilterArrayCollection();
			clearTimeout(_initTimeot);
			clearTimeout(_initTimeot2);

		}
	
		[MessageHandler (selector="onNewServiceItem")]
		public function onNewServiceItem(event:ConnectionEvent):void {
			
			if ( connection.disco.getDiscoByCategory("conference") ){
				channelServices = connection.disco.getDiscoByCategory("conference");
			}
			if ( connection.disco.getDiscoByName("chatstream") ){
				setStreamsServices ( connection.disco.getDiscoByName("chatstream") );
			}
			
		}
		
		public function askForDetails(jid:EscapedJID,callBack:Function):void {
			var iq:IQ = new IQ(jid,IQ.TYPE_SET,null,askReponse(callBack),askReponse(callBack));
			var muc:MUCOwnerExtension = new MUCOwnerExtension();
			iq.xml.appendChild(	muc.xml );
			connection.send( iq );	
		}
		public function askReponse(callBack:Function):Function {
			return function (iq:IQ):void {
				var obj:Object;
				obj = _xmlDecoder.decodeXML( new XMLDocument( iq.xml ).firstChild );
				if (iq.type == IQ.TYPE_ERROR){
					if (obj.error){
						var errorTitle:String ="";
						errorTitle = (mucInterfaceManager.items.getItemByID( iq.from.bareJID ) as ChannelModel).name;
						var errorMessage:String = "";
						if (  obj.error.type == "auth" )errorMessage+= "Authentication "
						errorMessage += "Error "+obj.error.code;
						UEM.newUEM(iq.from.bareJID+"error",errorTitle,errorMessage);
					}
					return;
				}
				callBack(obj,iq);
			}
		}
		[MessageHandler (selector="onCreateNewChannel")]
		public function onCreateNewChannel(event:MUC_UI_Event):void {
			try {
				
				var roomJID:EscapedJID;
				
				if ( event.itemJID  != null) roomJID = event.itemJID;
				else roomJID = new EscapedJID(event.itemName.toLowerCase() + "@" + event.service.toString()+"/"+connection.connection.username );
				var mucExt:MUCExtension = new MUCExtension();
				if (event.fieldmap['muc#roomconfig_passwordprotectedroom'][0]==true){
					mucExt.password = event.fieldmap['muc#roomconfig_roomsecret'][0];
				}
				
				var room:Room = joinRoom(new UnescapedJID(roomJID.bareJID),mucExt,null,false,null,event.itemName,false);
				setTimeout(room.changeSubject,800,event.subject);
				
				var iq:IQ = new IQ(new EscapedJID(roomJID.bareJID),IQ.TYPE_SET,null,createCallBack(event.callBack),createCallBack(event.callBack));
				iq.addExtension(  event.extension );
				connection.send( iq );
		
			}catch (error:Error){
				trace (error.getStackTrace())
			}
		}
	
		private function createCallBack(callBack:Function):Function {
			return function(iq:IQ):void {
				var m:Message = new Message(iq.from  );
				m.type = Message.TYPE_GROUPCHAT;
				var mucExt:MUCUserExtension = new MUCUserExtension();
				if (iq.type == IQ.TYPE_ERROR){
					mucExt.xml.appendChild(<status code='171'/>);
					connection.send( m)
					return;
				}
				
				mucExt.xml.appendChild(<status code='170'/>);
				m.xml.appendChild( mucExt.xml );
				connection.send(m);
				var presence:Presence = new Presence(null,iq.from);
				presence.xml.appendChild( (new MUCExtension()).xml );

				connection.send( presence );
				getItemsFor(new EscapedJID(iq.from.domain));
				
				if (callBack!=null)callBack.apply(null,[iq]);
				
			}
		}
		
		public function get bookmarkManager():BookmarkManager {
			return _bookmarkManager;
		}
		public function set channelServices(s:Vector.<DiscoItemModel>):void {
			if (!_inited || (s.length != _services.length)){
				_inited = true;
				_initTimeot = setTimeout(initChannels,2500);
			}
			_services = s;	
		}
		public function get channelServices():Vector.<DiscoItemModel> {
			return _services;
		}
		public function setStreamsServices(s:DiscoItemModel):void {
			var l:uint = _streamsServices.length;
			_streamsServices.addItem( s );
			if (!_initedStreams || (l != _streamsServices.length)){
				_initedStreams = true;
				_initTimeot2 = setTimeout(streamsManager.init,4000);
			}
		}
		public function get streamsServices():FilterArrayCollection {
			return _streamsServices;
		}
	
		public function initChannels():void {
			for (var i:uint = 0; i<channelServices.length;i++){
				getItemsFor(channelServices[i].jid);	
			}
			if (channelServices.length > 0 && !mucInterfaceManager.channels_enabled)mucInterfaceManager.channels_enabled = true;
		
		}
		private function getItemsFor(jid:EscapedJID):void {
			var iq:IQ = getServiceItems(jid,"items",getResponse,getResponse);
			connection.send(iq);
		}
		public function getServiceItems(service:EscapedJID,action:String,callBack:Function=null,errorCallBack:Function=null):IQ {
			var iq:IQ = new IQ(service,"get",null,callBack,errorCallBack);
			var queryNode:XMLNode = new XMLNode(1,"query");
			queryNode.attributes.xmlns = "http://jabber.org/protocol/disco#"+action;
			iq.xml.appendChild( new XML(queryNode));
			return iq;
		}
		private function getResponse(iq:IQ):void {
			try {
				var obj:Object = _xmlDecoder.decodeXML(new XMLDocument(iq.xml).firstChild );
				if (obj.query == null || obj.query.item == null ) return;
				var it:ChannelModel;
				var jid:String;
				if ( obj.query.item is Array ){
					for (var i:uint=0; i<obj.query.item.length; i++){
						jid = obj.query.item[i].jid;
						if (!jid) jid = obj.query.item[i].name;
						if ( mucInterfaceManager.items.getItemIndexByID(jid) == -1){
							it =  new ChannelModel(obj.query.item[i].name,jid,ChannelModel.KIND_CHANNEL) ;
							mucInterfaceManager.items.addItem( it );
						}else {
							it = mucInterfaceManager.items.getItemByID(jid) as ChannelModel;
						}
						try {
							if ( obj.query.item[i].name.indexOf("_") > -1 && it.name.indexOf("_") == -1 ) {

							}else it.name = obj.query.item[i].name;
						}catch (erro:Error){
							it.name = obj.query.item[i].name;
						}
						it.kind = ChannelModel.KIND_CHANNEL;
						if (it.room && it.room.subject) it.info = it.room.subject;
						 
					
			
						
						//mucInterfaceManager.items.addItem(it);
					}
				}else {
					jid = obj.query.item.jid;
					if (!jid) jid = obj.query.item.name;
					
					if (mucInterfaceManager.items.getItemIndexByID(jid) == -1){
						it =  new ChannelModel(obj.query.item.name,jid,ChannelModel.KIND_CHANNEL) ;
						mucInterfaceManager.items.addItem( it );
					}else {
						it = mucInterfaceManager.items.getItemByID(jid) as ChannelModel;
						it.name = obj.query.item.name;
						it.kind = ChannelModel.KIND_CHANNEL;
						if (it.room && it.room.subject) it.info = it.room.subject;
						
					}
				}
				mucInterfaceManager.items.refresh();
				
			}catch (error:Error){
				trace (error.getStackTrace());
			}
		
		}
		public function getDetails(jid:EscapedJID):void {
			
			var iq:IQ = getServiceItems(jid,"info",getItemInfoResponse,getItemInfoResponse);
			connection.send( iq );
		}
		private function setNewRoom(jid:UnescapedJID,name:String=null):Room {
			try {
				var tmpRoom:Room;
				if (jid != null){
					try {
						tmpRoom = (mucInterfaceManager.items.getItemByID(jid.bareJID) as ChannelModel).room;
					}catch (error:Error){
					
					}
				}
				if (tmpRoom==null){
					tmpRoom = new Room(connection.connection);
					if (name!=null&&name.length>0)tmpRoom.roomName = name;
					tmpRoom.roomJID = jid;
					if (name!=null&&name.length>0)tmpRoom.label = name;
				}
				return tmpRoom;
			}catch (error:Error){
				
			}
			return null;
		}
		public function onRoom(event:RoomEvent):void {
		
			if (event.type == RoomEvent.ROOM_JOIN){
				var che:ChatEvent = new ChatEvent(ChatEvent.ROOM_JOIN);
				che.room = event.currentTarget.room as Room;
				dispatchEvent(che);
			}
			
			
		
		}
		
		private function getItemInfoResponse(iq:IQ):void {
			try {
				if( iq.type == IQ.TYPE_ERROR) return
				var callsxml:XML = new XML ((iq.xml.children() as XMLList).toXMLString());
				var item:ChannelDetails = xom.mapToObject(callsxml) as ChannelDetails;
				(mucInterfaceManager.items.getItemByID( iq.from.bareJID ) as ChannelModel).details = item;
			}catch (error:Error){
				trace (error.getStackTrace());
			}	
		}
		private function onItemsCollChange(event:CollectionEvent):void {
			
			if (event.kind != CollectionEventKind.ADD)return
			
			if (event.items[0].kind == ChannelModel.KIND_CHANNEL || event.items[0].kind == ChannelModel.KIND_PRIVATE_ROOM){
				
				var iq:IQ = getServiceItems(event.items[0].jid,"info",getItemInfoResponse,getItemInfoResponse);
				connection.send(iq);
				if (event.items[0] is ChannelModel){
					var channel:ChannelModel = 	(event.items[0] as ChannelModel);
					channel.clickFunction = mucManager.channelItemClick;
					channel.addEventListener(RoomEvent.ROOM_JOIN,onRoom);
				}
				/*var ae:ArchiveEvent = new ArchiveEvent(ArchiveEvent.CADDED_GET_LIST);
				ae.forJID = (event.items[0] as ChannelModel).jid;
				dispatchEvent(ae);*/
				return
				
			}
			
			
			if (event.items[0] is StreamModel && event.items[0].kind == StreamModel.KIND_STREAM){
				(event.items[0] as StreamModel).clickFunction = mucManager.streamItemClick;
				
				return
			}
		 
			
			
		}

		private function onBookMarkChange(event:BookmarkChangedEvent):void {
			try {
				if (event.type == BookmarkChangedEvent.GROUPCHAT_BOOKMARK_REMOVED){
					(mucInterfaceManager.items.getItemByID(event.groupchatBookmark.jid.bareJID) as ChannelModel).bookmark = null;
				}else {
					(mucInterfaceManager.items.getItemByID(event.groupchatBookmark.jid.bareJID) as ChannelModel).bookmark = event.groupchatBookmark;
				}
			}catch (error:Error){
				trace (error.getStackTrace())
			}    
		}
		private function onBookmarkRetrieved(event:BookmarkRetrievedEvent):void {
			try {
				for (var i:uint = 0; i<_bookmarkManager.bookmarks.groupChatBookmarks.length;i++){
					try {
						var item:GroupChatBookmark = (_bookmarkManager.bookmarks.groupChatBookmarks[i] as GroupChatBookmark);
						var m:ChannelModel;
						if (mucInterfaceManager.items.getItemIndexByID(item.jid.bareJID) == -1){
							m = new ChannelModel(item.name,item.jid.bareJID,ChannelModel.KIND_CHANNEL);
							mucInterfaceManager.items.addItem( m );
						}else {
							m = mucInterfaceManager.items.getItemByID(item.jid.bareJID) as ChannelModel;
							
						}
						m.bookmark = item;
						if (!m.askedAboutJoin){
							m.askedAboutJoin = true;
							if (item.autoJoin){
								var muc:MUCExtension;
								var password:String;
								try {
									password = item.password;
								}catch (nopass:Error){
									
								}
								if (password != null && password.length > 0){
									muc = new MUCExtension();
									muc.password = item.password;
								}
								joinRoom(new UnescapedJID(item.jid.bareJID),muc,null,true);
							}
						}
					}catch (error1:Error){
						trace (error1.getStackTrace());
					}
				}
			}catch (error:Error){
				trace (error.getStackTrace());
			}
			
			 
		}
		
		public function joinRoom(jid:UnescapedJID,muc:MUCExtension=null,presences:Array=null,autoJoin:Boolean=false,_room:Room=null,roomName:String=null,notChannel:Boolean=false):Room {
			if (muc == null){
				muc = new MUCExtension();
				try {
					if (mucInterfaceManager.items.getItemIndexByID(jid.bareJID) > -1 &&  (mucInterfaceManager.items.getItemByID(jid.bareJID) as ChannelModel) ){
						var a:Array = (mucInterfaceManager.items.getItemByID(jid.bareJID) as ChannelModel).details.feature;
						for (var i:uint = 0; i< a.length; i++){
							if (a[i].feature == "muc_passwordprotected"){
								if (muc.password == null){
									getPasswordWindow(jid);
									return null;
								}
							}
						}
					}
				}catch (error:Error){
				
				}
			}
			try {
				var room:Room;
				if (_room!=null)room = _room;
				else room = setNewRoom(jid,roomName);
				var his:XMLNode = new XMLNode(1,"history");
				if (chatMessageManager.recipientList.getItemIndexByID( room.roomJID.bareJID.toLowerCase() ) > -1){
					his.attributes.maxchars = "0";
				}else {
					his.attributes.since='1970-01-01T00:00:00Z';
				}
				muc.xml.appendChild(new XML(his));
				room.joinWithExplicitMUCExtension(true, muc, presences);
				var channel:ChannelModel;
				try {
					channel = mucInterfaceManager.items.getItemByID(room.roomJID.bareJID.toLowerCase()) as ChannelModel;
				}catch (error:Error){
					
				}
				if (channel == null) {
					var kind:String;
					if (notChannel==true)kind = ChannelModel.KIND_PRIVATE_ROOM;
					else kind = ChannelModel.KIND_CHANNEL;
					channel = new ChannelModel(room.label,room.roomJID.bareJID,kind);
					mucInterfaceManager.items.addItem( channel );
				}
				
				if (channel.room == null)channel.initRoom ( room );
			
				if (autoJoin)ChatMessageManager.AutoJoinList[jid.bareJID] = true;
				else {
					if (ChatMessageManager.AutoJoinList[jid.bareJID] == true) delete ChatMessageManager.AutoJoinList[jid.bareJID];
				}
			}catch(mucError:Error){
				trace (mucError.getStackTrace());
			}

			
			return room;
		}
		public function getPasswordWindow(jid:UnescapedJID):void {
			var title:String = "Password Required";
			if (jid!=null)title += " - "+jid.toString();
			var window:Window = dataHolder.getInstance().getWindow(title,true,"none",395,195,true,false,true,false);
			window.alwaysInFront = true;
			var sp:PasswordProtectedContent = new PasswordProtectedContent();
			sp.jid = jid;
			window['_container'].bottom += 35;
			window['_container'].addElement(sp);
			var bt:Button = new Button();
			
			bt.label = "OK";
			bt.bottom = -35;
			bt.right = 5;
			sp.addElement(bt);
			bt.addEventListener(MouseEvent.CLICK,onEnterPassword);
			
		}
		private function onEnterPassword(event:MouseEvent):void {
			var muc:MUCExtension = new MUCExtension();
			muc.password = ((event.currentTarget as Button).owner as PasswordProtectedContent)._pass.text;
			if (muc.password == null || muc.password.length == 0)return;
			var jid:UnescapedJID =  ((event.currentTarget as Button).owner as PasswordProtectedContent).jid;
			joinRoom(jid,muc);
			((event.currentTarget as Button).owner as PasswordProtectedContent).parentApplication['close']();
		}
		
		
		public static function onChangeSubject(room:Room):void {
			var w:CustomWindow = new CustomWindow();
			w.maximizable = false;
			w.closeable = true;
			w.minimizable = false;
			w.resizable = false;
			w.title = "Change "+room.roomName + " subject";
			w.width = 310;
			w.height = 130;
			
			w.open(true);
			var tf:TextInput = new TextInput();
			tf.text = room.subject;
			tf.left = 10;
			tf.right = 10;
			tf.top = 14;
			w._container.addElement(tf);
			
			w._container.bottom += 30;
			
			var bt:Button = new Button();
			bt.label = "Save";
			bt.addEventListener(MouseEvent.CLICK,changeSubject(room, tf))
			bt.right = 8;
			bt.bottom = 4;
			w.addElement(bt);	
			w.move(Screen.mainScreen.bounds.width/2 - w.width/2, Screen.mainScreen.bounds.height/2 - w.height/2 - 20);
			
		}
		private static function changeSubject(room:Room,f:TextInput):Function {
			return function(event:MouseEvent):void {
				room.changeSubject(f.text);
				((event.currentTarget as Button).owner as Window).close();
			}
		};
		
	}
	
}
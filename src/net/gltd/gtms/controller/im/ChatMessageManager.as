package net.gltd.gtms.controller.im
{
	import net.gltd.gtms.GUI.UEM.UEM;
	import net.gltd.gtms.GUI.UEM.UEMfeature;
	import net.gltd.gtms.GUI.contextMenu.ContextMenu;
	import net.gltd.gtms.GUI.contextMenu.ContextMenuItem;
	import net.gltd.gtms.GUI.window.CustomWindow;
	import net.gltd.gtms.controller.app.SettingsManager;
	import net.gltd.gtms.controller.muc.MUCInterfaceManager;
	import net.gltd.gtms.controller.xmpp.Connection;
	import net.gltd.gtms.controller.xmpp.RosterManager;
	import net.gltd.gtms.events.ArchiveEvent;
	import net.gltd.gtms.events.ChatEvent;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.SoundAlertEvent;
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.model.dataHolder;
	import net.gltd.gtms.model.contact.BuddyModel;
	import net.gltd.gtms.model.contact.IMBuddyModel;
	import net.gltd.gtms.model.contact.singl.buddiesHolder;
	import net.gltd.gtms.model.im.MessageModel;
	import net.gltd.gtms.model.im.RoomModel;
	import net.gltd.gtms.model.im.StreamMessagesModel;
	import net.gltd.gtms.model.muc.ChannelModel;
	import net.gltd.gtms.model.muc.StreamModel;
	import net.gltd.gtms.model.rules.RuleModel;
	import net.gltd.gtms.model.rules.singl.rulesHolder;
	import net.gltd.gtms.utils.FilterArrayCollection;
	import net.gltd.gtms.utils.StringUtils;
	import net.gltd.gtms.view.im.chatv2.ChatV2Content;

	
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.IUITextField;
	import mx.core.mx_internal;
	import mx.events.AIREvent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.managers.PopUpManager;
	import mx.rpc.xml.SimpleXMLDecoder;
	
	import spark.components.CheckBox;
	
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.events.MessageEvent;
	import org.igniterealtime.xiff.events.RoomEvent;
	

	
	[Event(name="onPresenceUpdate",type="net.gltd.gtms.events.ContactEvent")]
	[Event(name="onOpenRoom",type="net.gltd.gtms.events.ChatEvent")]
	[Event(name="onAlertSound",type="net.gltd.gtms.events.SoundAlertEvent")]
	[Event(name="onGetList",type="net.gltd.gtms.events.ArchiveEvent")]
	[Event(name="onGetConversation",type="net.gltd.gtms.events.ArchiveEvent")]
	[Event(name="onReciveNewMessage",type="net.gltd.gtms.events.ChatEvent")]
	[ManagedEvents("onPresenceUpdate, onOpenRoom, onAlertSound, onGetList, onGetConversation, onReciveNewMessage")]
	
	public class ChatMessageManager extends EventDispatcher
	{
		[Inject][Bindable]
		public			var		conn				:Connection;

		[Bindable]
		public			var		recipientList		:FilterArrayCollection;
		
		private			var		_chatV2				:ChatV2Content,
								_tryCounter			:uint = 0,
								_dh					:dataHolder,
								
								_newMessage			:Message,
								
								_windows			:FilterArrayCollection = new FilterArrayCollection(),
								
								thisSessionAlerts	:Array;
		
		public	static	var		AutoJoinList		:Object = {};

		[Init]
		public function init():void {
		}
		
		[MessageHandler (selector="onLoginSuccess")]
		public function onLogin(event:ConnectionEvent):void {
			_dh = dataHolder.getInstance();
			thisSessionAlerts = [];
			recipientList	= new FilterArrayCollection();
			recipientList.ignoreCaseSensitivity = true;
			recipientList.addEventListener(CollectionEvent.COLLECTION_CHANGE,onCollChange,false,0,true);
			conn.connection.addEventListener(MessageEvent.MESSAGE,onMessage,false,0,true);
			
		}
		[MessageHandler (selector="onDisconnected")]
		public function onLogout(event:UserEvent):void {
			recipientList.removeEventListener(CollectionEvent.COLLECTION_CHANGE,onCollChange);
			conn.connection.removeEventListener(MessageEvent.MESSAGE,onMessage);
			_tryCounter = 0;
			recipientList.removeAll();
			recipientList = null;
			try {
				_dh.ignoreMessageSubjects = [];

			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
		}
		[MessageHandler (selector="onUserStartChat")]
		public function onUserStartChat(event:UserEvent):void {
			setChat(event.recipientJID.bareJID,event.recipientJID);
			initWindow(true,event.recipientJID.bareJID)
		}  
		[MessageHandler (selector="onUserStartGroupChat")]
		public function onUserStartGroupChat(event:UserEvent):void {
			setRoom(event.data);
			initWindow(true,event.recipientJID.bareJID);
		}  
		[MessageHandler (selector="onUserOpenStream")]
		public function onUserOpenStream(event:UserEvent):void { 
			setStream(event.data);
			if (event.userAction == true || SettingsManager.ALLERTS["notificationStreams"].window == true) initWindow(event.userAction,event.data.id);
		} 
		[MessageHandler (selector="onBroadcastMessage")]
		public function onBroadcastMessage(event:ChatEvent):void { 
			event.message.from = null;
			for (var i:uint = 0; i <event.recipients.length; i++){
				try {
					if (!event.incOffline && !event.recipients[i].roster.online)continue;
					event.message.to = event.recipients[i].roster.jid.escaped;
					conn.send(event.message);
					var mm:MessageModel = setChat(event.message.to.bareJID, event.message.to.unescaped);
					mm.pushMessage( event.message, false );
					
				}catch (error:Error){
					MLog.Log(error.getStackTrace());
				}
			}
				
		}
		
		
		
		
		[MessageHandler (selector="onRoomJoin")]
		public function onRoomJoin(event:ChatEvent):void {
			setRoom ( event.room );
			if (AutoJoinList[event.room.roomJID.bareJID] == true && SettingsManager.ALLERTS["notificationMUC"].window == false) return;
			initWindow(true,event.room.roomJID.bareJID);
		}
		
		private function onMessage(event:MessageEvent):void {
			try {
				if ( dataHolder.getInstance().ignoreMessageSenders[event.data.from.bareJID] == "notachat" )return;
			}catch (errrr:Error){
				
			}
			try {
				if (event.data.from.bareJID == conn.jid.domain && event.data.body!=null){
					for (var j:uint= 0; j<thisSessionAlerts.length;j++){
						if (thisSessionAlerts[j].subject == event.data.subject && thisSessionAlerts[j].body == event.data.body) return;
					}
					//setChat(event.data.from.bareJID,event.data.from.unescaped);
					//setTimeout(initWindow,100,false,event.data.from.bareJID);
					
					var a:Alert = Alert.show(event.data.body,event.data.subject);
					a.explicitWidth = FlexGlobals.topLevelApplication.nativeWindow.width - 30;
		
					setTimeout(function():void {
						var textField:IUITextField = IUITextField(a.mx_internal::alertForm.mx_internal::textField) as IUITextField;
						var textFormat:TextFormat = new TextFormat();
						textFormat.align = "center";
						textField.width = a.explicitWidth - 40;
						textField.x = -3;
						textField.setTextFormat(textFormat);
						/*
						var ds:CheckBox = new CheckBox();
						ds.label = "Do not show this message again!"
						a.addElement( ds );*/
						
					//	PopUpManager.addPopUp(a,a,FlexGlobals.topLevelApplication.nativeWindow);	
					},90);
					
					thisSessionAlerts.push( {body:event.data.body,subject:event.data.subject} );
				}
			}catch (erServer:Error){
				MLog.Log(erServer.getStackTrace());
			}
			try {
				if (event.data.type == Message.TYPE_ERROR){
					if(SettingsManager.ALLERTS["notificationError"].popup == true){
						UEM.newUEM("ErrorMessage"+event.data.id,event.data.subject,event.data.body,null,null,SettingsManager.ALLERTS["notificationError"].time);
					}
					if ( SettingsManager.ALLERTS["notificationError"].sound == true){
						dispatchSound()
					}
					return
				}
			}catch (erError:Error){
				MLog.Log(erError.getStackTrace());
			}
			
			if (!RosterManager.RosterIsReady){
				if (++_tryCounter < 40)	setTimeout(onMessage,400,event.clone());
				return;
			}
			
			var m:Message = event.data;
			
			try {
				for (var i:uint = 0; i<_dh.ignoreMessageSubjects.length;i++){
					if (m.subject.toLowerCase().indexOf(_dh.ignoreMessageSubjects[i].toLowerCase()) > -1)return;
				}
			}catch (eS:Error){
				MLog.Log(eS.getStackTrace());
			}
		if (!buddiesHolder.getInstance().isExist(m.from.bareJID) && m.type != Message.TYPE_GROUPCHAT) return;
			
			if (m.type != Message.TYPE_GROUPCHAT){
				if (m.state == Message.STATE_COMPOSING){
					(buddiesHolder.getInstance().getBuddy(m.from.bareJID) as IMBuddyModel).composing = true;
					if (m.type == Message.TYPE_HEADLINE){
						(buddiesHolder.getInstance().getBuddy(m.from.bareJID) as IMBuddyModel).setComposingTimer();
					}
				}
				if ( m.state == Message.STATE_ACTIVE || m.state == Message.STATE_PAUSED){
					(buddiesHolder.getInstance().getBuddy(m.from.bareJID) as IMBuddyModel).composing = false;
				}
			}

			if (m.body == null)return;
			try {
				
				var meve:ChatEvent = new ChatEvent(ChatEvent.RECIVE_NEW_MESSAGE);
				meve.jid = m.from;
				meve.message = m;
				dispatchEvent(meve);

			
				try {
					if (m.body.indexOf("Please join my video conference at")>-1 &&  (_dh.makeVideoCall!=null || _dh.flashVideoEnabled)){
						return;
					}
				}catch (errPJ:Error){
					MLog.Log(errPJ.getStackTrace());
				}
				if (m.type == Message.TYPE_GROUPCHAT){
					//pushRoomMessage(m);
					setTimeout(pushRoomMessage,400,m);
					if(SettingsManager.ALLERTS["notificationMUC"].window == true){
						setTimeout(initWindow,300,false,m.from.bareJID);
					}
				}else {
					setChat( m.from.bareJID, m.from.unescaped );
					(recipientList.getItemByID( m.from.bareJID ) as MessageModel).pushMessage(m);
					if ( dataHolder.getInstance().ignoreMessageSenders[m.from.bareJID] == true )return;
					if(SettingsManager.ALLERTS["notificationIM"].window == true){
						setTimeout(initWindow,100,false,m.from.bareJID);
					}
				}
					
					 
				notify( m );
				
			
				
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
		}
		private function onSendMessage(event:ChatEvent):void {
			conn.send(event.message);
		}
		
		private function setChat(id:String,jid:UnescapedJID):MessageModel {
			if	(recipientList.keys[id] == undefined){
				var mm:MessageModel = new MessageModel( id, jid );
				recipientList.addItem( mm );
				return mm;
			}
			try {
				return recipientList.getItemByID(id) as MessageModel;
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
			return null
		
		}
		private function setStream(model:StreamModel):void {
			if	(recipientList.keys[model.id] == undefined){
				try {
					var mm:StreamMessagesModel = new StreamMessagesModel( model );
					mm.uemReadHandeler = uemReadHandeler;
					mm.dispatchSound = dispatchSound;
					recipientList.addItem( mm );
				}catch (ero:Error){
					MLog.Log(ero.getStackTrace());
				}
			}
		}
		
		private function setRoom(room:Room):RoomModel {
			var id:String = room.roomJID.bareJID;
			if	(recipientList.getItemIndexByID(id) == -1){
				var mm:RoomModel = new RoomModel( room );
				recipientList.addItem( mm );
				return mm;
			}else {
				recipientList.getItemByID(id).rejoin(room);
			
			}
			return recipientList.getItemByID(id) as RoomModel;
		}
		private function pushRoomMessage(m:Message):void {
			try {
				var id:String = StringUtils.removeChar(m.from.bareJID,"-");
				var model:RoomModel;
				for (var i:uint = 0; i < recipientList.length; i++){
					if (recipientList.getItemAt(i).id.toLowerCase() == id.toLowerCase()){
						model = recipientList.getItemAt(i) as RoomModel;
						break
					}
				}
				if (model == null){
					var room:Room = new Room(conn.connection);
					room.roomJID = m.from.unescaped;
					model = setRoom( room ); 
				}
				model.pushMessage( m );
				 
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
		}

		private function showWindowMenu(event:MouseEvent):void {

			var label:String;
			if ((event.currentTarget.owner as CustomWindow).windowManager.isSticky){
				label  = "Unstick Window";
			}else {
				label = "Stick Window";
			}
			var contextList:Vector.<ContextMenuItem> = new Vector.<ContextMenuItem>();
			
			contextList.push( new ContextMenuItem(label,null,true,false,(event.currentTarget.owner as CustomWindow).windowManager.stickAction));
			ContextMenu.ShowMenu(event,contextList);
	
		}
		private function createWindow(forItem:String=null):Object {
			var stick:String = "none";
		//if (forItem == null) stick = "right";
			var mw:CustomWindow = dataHolder.getInstance().getWindow("",true,stick,650,420,true,true,true,true) as CustomWindow;
			if (forItem==null)mw.name = "mainChatWindow";
			
			mw.id = "chatWindow"+StringUtils.generateRandomString(5);
			mw.minWidth = 390;
			mw.minHeight = 380;
			mw.contentBackgrouond = false;
			
			
			try {
				var ic:Class = mw.styleManager.getMergedStyleDeclaration('.chatLogo').getStyle('icon');
				if (ic!=null)mw.imgSource = ic;
			}catch (erImg:Error){
				mw.imgSource = null;
				
			}
			mw.open(true);
			var	x:int;
			var y:int;
			var p:Point = SettingsManager.getWindowPosition(mw.name);
			if (p != null){
				x = Math.min(p.x, Screen.mainScreen.bounds.width-mw.width);
				y = Math.min(p.y, Screen.mainScreen.bounds.height-mw.height); 
				mw.move(x,y);	
			}else {
				if (!mw.windowManager.isSticky){
					y = Math.max(0, -90 + Screen.mainScreen.bounds.height/2 - mw.height/2 + _windows.length*30);
					y = Math.min(y, (Screen.mainScreen.bounds.height - mw.height -15));
						
					x = Math.max(0, -90+Screen.mainScreen.bounds.width/2 - mw.width/2 + _windows.length*30);
					x = Math.min(x, (Screen.mainScreen.bounds.width -mw.width));
						
					mw.move(x, y);
				}else {
					if (!FlexGlobals.topLevelApplication._topAppControls.windowManager.isMax){
						mw.height = FlexGlobals.topLevelApplication.nativeWindow.height - 40;
					}else {
						mw.height = 560;
					}
					
				}
			}
			mw._titleBar.addEventListener(MouseEvent.RIGHT_CLICK,showWindowMenu);
			mw._container.bottom += 35;
			mw.addEventListener(AIREvent.WINDOW_ACTIVATE,onChatWindowActive)
			mw.addEventListener(Event.CLOSE,onWinClose);
			var chat:ChatV2Content = new ChatV2Content();
			chat.id = mw.id;
			chat.addEventListener(ChatEvent.OPEN_ROOM,onOpenRoom);
			if (forItem == null){
				chat.setChats( recipientList.source, recipientList);
			}else {
				chat.defaultContent = false;
				chat.setChats([recipientList.getItemByID(forItem)], recipientList )
			}
			mw._container.addElement( chat );
			
			return { window:mw, chat:chat, id:mw.id,ownerId:forItem };
			
		}
		private function windowIsActive(id:String):Boolean {
			for (var i:uint = 0; i< _windows.length; i++){
				for (var j:uint =0; j<(_windows.getItemAt(i).chat.chatsCollection as FilterArrayCollection).length; j++)
				{
					if ( (_windows.getItemAt(i).chat.chatsCollection as FilterArrayCollection).getItemAt(j).id.toLowerCase() == id.toLowerCase()) {
						if ( _windows.getItemAt(i).window.nativeWindow != null &&  _windows.getItemAt(i).window.nativeWindow.active && _windows.getItemAt(i).chat.selectedItemId == id) return true;
						return false;
					}
				}
				//Error in XIFF message - in message is always in lowerCase
				
				/*
				if ( (_windows.getItemAt(i).chat.chatsCollection as FilterArrayCollection).getItemIndexByID(id) > -1 ){
				
				}*/
			}
			return false
		}
		private function idExistInWindow(id:String):int{
			for (var i:uint = 0; i< _windows.length; i++){
				for (var j:uint =0; j<(_windows.getItemAt(i).chat.chatsCollection as FilterArrayCollection).length; j++)
				{
					if ( (_windows.getItemAt(i).chat.chatsCollection as FilterArrayCollection).getItemAt(j).id.toLowerCase() == id.toLowerCase()) {
						return i;
					}
				}
			}
			return -1;
		}
		private function initWindow(fromClick:Boolean,id:String):void {
			try {
				if (!fromClick && idExistInWindow(id) > -1){
					return
				}
				var i:uint=0
				var window:CustomWindow
				var chat:ChatV2Content;
				var noWindows:Boolean = _windows.length == 0;
				
				if (noWindows){
					_windows.addItem( createWindow() )
				}else {
					var wid:String;
					if (recipientList.getItemIndexByID(id) > -1) wid =  recipientList.getItemByID(id).windowid;
					var wnr:int = _windows.getItemIndexByID(wid);
					
					if (wid != null && wnr > -1 ) {
						i = wnr;
					}else {
						for (i = 0; i<_windows.length;i++){
							if (_windows.getItemAt(i).chat.defaultContent == true){
								try {
									for (var df:uint = 0; df<recipientList.length;df++){
										if (recipientList.getItemAt(df).id.toLowerCase() == id.toLowerCase()){
											_windows.getItemAt(i).chat.chatsCollection.addItem( recipientList.getItemAt(df) );
											break;
										}
									}
								}catch (error:Error){
									trace (error.getStackTrace());
								}
								break;
							}
						}
						if (i == _windows.length)_windows.addItem( createWindow() )
					}
				}
				try {
					window = _windows.getItemAt(i).window;
					chat =  _windows.getItemAt(i).chat;
				}catch (e:Error){
					var o:Object =  createWindow() ;
					window = o.window;
					chat = o.chat;
					_windows.addItem( o );
				}
				if (fromClick || noWindows){
					chat.selectedItemId = id;
					window.activate();
				} 	
				
				
			}catch (error:Error){
				MLog.Log(error.getStackTrace());	
			}
			
			
		}
		private function onChatWindowActive(event:AIREvent):void {
			try {
				var chat:ChatV2Content = _windows.getItemByID(event.currentTarget.id).chat;
				if (chat.selectedItemId)recipientList.getItemByID(chat.selectedItemId).markUser(false);
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
		}
		private function openNewMessage():void {
			if (conn.connection.loggedIn == false || conn.connection.active == false ) return;
			initWindow(true, _newMessage.from.bareJID); 
		}
		private function notify(m:Message, group:Boolean=false):void {
			if (windowIsActive(m.from.bareJID)) return;
			if ( (SettingsManager.ALLERTS["notificationIM"].sound == true && m.type == Message.TYPE_CHAT) || (SettingsManager.ALLERTS["notificationMUC"].sound == true && m.type == Message.TYPE_GROUPCHAT)){
				dispatchSound()
			}
			_newMessage = m;
			var features:Array = [];
			features.push( new UEMfeature(UIphrases.IM_MSG_EVENT_BUTTON_READ,uemReadHandeler,[m.from.bareJID]) );
			dataHolder.getInstance().sysNotify(openNewMessage);
			var settingsObjectKey:String;
			if ( (SettingsManager.ALLERTS["notificationIM"].popup == true && m.type == Message.TYPE_CHAT) || (SettingsManager.ALLERTS["notificationMUC"].popup == true && m.type == Message.TYPE_GROUPCHAT)){
				if (m.type == Message.TYPE_GROUPCHAT)settingsObjectKey = "notificationMUC"
				else settingsObjectKey = "notificationIM";
				var title:String;
				var msg:String = m.body;
				if (msg == null)return;
				try {
					if ( m.type == Message.TYPE_GROUPCHAT) title = (MUCInterfaceManager.Channels().getItemByID(m.from.bareJID) as ChannelModel).label;
					else title = buddiesHolder.getInstance().getBuddy(m.from.bareJID).nickname;
				}catch (error:Error){
					title = m.from.node;
				}
				
				if (msg.length > 66){
					msg.slice(0,66)+"...";
				}
				
				try {
					if (rulesHolder.getInstance().triggerEventsObject.hasOwnProperty(  Main.RULE.value ) ){
						var obj:RuleModel = rulesHolder.getInstance().triggerEventsObject[Main.RULE.value][m.type] as RuleModel;
						if (obj != null && (obj.subsystem == null || obj.subsystem == "*" || obj.subsystem.toLowerCase() == m.from.domain.toLowerCase() )){
							var whoScope:Array = []
							var bd:BuddyModel = buddiesHolder.getInstance().getBuddy(m.from.bareJID);
							whoScope.push(bd)
							if (bd.hasOwnProperty("links")){
								for (var li:uint = 0; li< bd["links"].length;li++){
									whoScope.push( buddiesHolder.getInstance().getBuddy( bd["links"][li] ) );
								}
							} 
							var vars:Object = {};
							var addedParams:uint = 0;
							var allow:Boolean = true;
							for (var i:uint = 0; i<obj.parameters.length;i++){
								var paramString:String;
								if (obj.parameters.getItemAt(i).type == "lookup"){
									paramString = rulesHolder.getInstance().lookup(whoScope,obj.parameters.getItemAt(i).value);
								}
								else if (obj.parameters.getItemAt(i).type == "string"){
									paramString =  obj.parameters.getItemAt(i).value
								}
								else if (obj.parameters.getItemAt(i).type == "eventVariable"){
									try {
										paramString=m[obj.parameters.getItemAt(i).value];
									}catch (erLo:Error){
										trace (erLo.getStackTrace())
									}
								}
								if (paramString!=null){
									vars[obj.parameters.getItemAt(i).param] = paramString;
									addedParams++;
								}else {
									if (obj.parameters.getItemAt(i).required)allow=false
								}
							}
							
							if (allow){
								if (obj.type == "auto"){
									navigateToURL( rulesHolder.getInstance().getURL(obj,vars),"_blank" );
								}else if (obj.type == "button"){
									var urlR:URLRequest = rulesHolder.getInstance().getURL(obj,vars);
									features.push( new UEMfeature(obj.buttonLabel,navigateToURL,[urlR]) );
								}
							}else {
								UEM.newUEM("ErrorMessage"+obj.id,"Rules "+obj.label,"Item do not match criteria!",[new UEMfeature("Add Contact",rulesHolder.getInstance().addContact,[whoScope]),new UEMfeature("Link Contacts",rulesHolder.getInstance().addContact,[whoScope])]);
							}
						}
					}
				}catch (error:Error){
					trace ( error.getStackTrace() );
				}
				UEM.newUEM(m.from.bareJID+"_"+settingsObjectKey+"_IMUEM",title,msg,features,null,SettingsManager.ALLERTS[settingsObjectKey].time);
			}
		}
		public function uemReadHandeler(from:String):void {
			initWindow(true,from);
		}
		public function dispatchSound():void {
			dispatchEvent(new SoundAlertEvent(SoundAlertEvent.ALERT_SOUND))
		}
		private function onOpenRoom(event:ChatEvent):void {
			var roomEvent:ChatEvent = new ChatEvent(ChatEvent.OPEN_ROOM)
			roomEvent.recipients = event.recipients;
			roomEvent.room = event.room;
			roomEvent.roomName = event.roomName;
			roomEvent.inviteMessage = event.inviteMessage;
			dispatchEvent( roomEvent );
		}
		
		private function onCollChange(event:CollectionEvent):void {
			if (event.kind == CollectionEventKind.ADD){
				if (event.items[0].type == StreamModel.KIND_STREAM)return;
				event.items[0].addEventListener(ChatEvent.SEND_MESSAGE,onSendMessage,false,0,true);
				event.items[0].addEventListener(ChatEvent.SEPARATED_WINDOW,onOpenInNewWindow,false,0,true);
				event.items[0].addEventListener(ChatEvent.REMOVE_CHAT,onRemoveChatFromList,false,0,true);
				event.items[0].addEventListener(ArchiveEvent.GET_CONVERSATION,onGetArchiveConversation,false,0,true);
				if (event.items[0].type == 'im'){
					dispatchEvent(  new ArchiveEvent(ArchiveEvent.GET_LIST,(event.items[0] as MessageModel).jid.escaped) );
				}
				
				recipientList.refresh();
				
			}else if (event.kind == CollectionEventKind.REMOVE){
				if (event.items[0].type == StreamModel.KIND_STREAM)return;
				event.items[0].removeEventListener(ChatEvent.SEND_MESSAGE,onSendMessage);
				event.items[0].removeEventListener(ChatEvent.SEPARATED_WINDOW,onOpenInNewWindow);
				event.items[0].removeEventListener(ChatEvent.REMOVE_CHAT,onRemoveChatFromList);
				
				if (event.items[0].hasOwnProperty(ArchiveEvent.GET_CONVERSATION)){
					event.items[0].removeEventListener(ArchiveEvent.GET_CONVERSATION,onGetArchiveConversation);
				}
			
				recipientList.refresh();
			}
			
			 
		}
		private function onGetArchiveConversation(event:ArchiveEvent):void {
			dispatchEvent( event.clone() );
		}
		private function onRemoveChatFromList(event:ChatEvent):void {
			recipientList.removeByID( event.id );
		}
		private function onOpenInNewWindow(event:ChatEvent):void {
			if (event.obj == true){
				setTimeout(initWindow,500,true,event.id);
				return;
			}
			var o:Object = createWindow(event.id);
			_windows.addItem( o );
			o.chat.selectedItemId = event.id;
			var db:BuddyModel = buddiesHolder.getInstance().getBuddy(event.id);
			if (db!=null)o.window.title = "Chat with "+db.nickname;
			
			
		}
		private function onWinClose(event:Event):void {
			try {
				
				var chat:ChatV2Content = _windows.getItemByID(event.currentTarget.id).chat;
				var window:CustomWindow = _windows.getItemByID(event.currentTarget.id).window;

				window.addEventListener(AIREvent.WINDOW_ACTIVATE,onChatWindowActive)
				window.addEventListener(Event.CLOSE,onWinClose);
				chat.removeAll();
				chat.removeEventListener(ChatEvent.OPEN_ROOM,onOpenRoom);
				window._container.removeElement(chat)
				chat = null;
				window = null;
				_windows.removeByID(event.currentTarget.id);
				if (_windows.length == 1) _windows.getItemAt(0).chat.defaultContent = true;
				
			}catch (err:Error){
				MLog.Log(err.getStackTrace());
			}
		}
	}
}
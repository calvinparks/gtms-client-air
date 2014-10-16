/*
** RosterManager.as , package net.gltd.gtms.controller.xmpp **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 12, 2012 
*
*
*/ 
package net.gltd.gtms.controller.xmpp
{
	import net.gltd.gtms.GUI.UEM.UEM;
	import net.gltd.gtms.GUI.contextMenu.ContextMenuItem;
	import net.gltd.gtms.GUI.window.CustomWindow;
	import net.gltd.gtms.controller.app.SettingsManager;
	import net.gltd.gtms.controller.im.ContactListManager;
	import net.gltd.gtms.events.ChatEvent;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.ContactEvent;
	import net.gltd.gtms.events.SoundAlertEvent;
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.model.contact.BuddyModel;
	import net.gltd.gtms.model.contact.GroupModel;
	import net.gltd.gtms.model.contact.IMBuddyModel;
	import net.gltd.gtms.model.contact.singl.buddiesHolder;
	import net.gltd.gtms.model.contact.singl.groupHolder;
	import net.gltd.gtms.model.dataHolder;
	import net.gltd.gtms.utils.FilterArrayCollection;
	import net.gltd.gtms.utils.NumberFormatter;
	import net.gltd.gtms.view.im.chat.InviteList;
	import net.gltd.gtms.view.im.chatv2.ArchiveContent;
	import net.gltd.gtms.view.im.contactList.BuddyItemRenderer;
	
	import flash.display.Screen;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.System;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.conference.RoomOccupant;
	import org.igniterealtime.xiff.core.AbstractJID;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.data.im.RosterGroup;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.events.PropertyChangeEvent;
	import org.igniterealtime.xiff.events.RosterEvent;
	import org.igniterealtime.xiff.im.Roster;
	import org.igniterealtime.xiff.vcard.VCard;
	
	import spark.collections.SortField;
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.SkinnableContainer;
	import spark.components.TextArea;
	import spark.components.TextInput;
	
	
	[Event(name="onContactAdded",type="net.gltd.gtms.events.ContactEvent")]
	[Event(name="onChangeGroup",type="net.gltd.gtms.events.ContactEvent")]
	[Event(name="onGroupAdded",type="net.gltd.gtms.events.ContactEvent")]
	[Event(name="onRosterComplete",type="net.gltd.gtms.events.ContactEvent")]
	[Event(name="onRemoveContact",type="net.gltd.gtms.events.ContactEvent")]
	[Event(name="onAddRoster",type="net.gltd.gtms.events.UserEvent")]
	[Event(name="onPresenceUpdate",type="net.gltd.gtms.events.ContactEvent")]
	[Event(name="onShowChanged",type="net.gltd.gtms.events.ContactEvent")]
	[Event(name="onOpenRoom",type="net.gltd.gtms.events.ChatEvent")]
	[Event(name="onBroadcastMessage",type="net.gltd.gtms.events.ChatEvent")]
	[Event(name="onAlertSound",type="net.gltd.gtms.events.SoundAlertEvent")]
	[Event(name="onShowInGroups",type="net.gltd.gtms.events.ContactEvent")]
	[Event(name="onContactUpdated",type="net.gltd.gtms.events.ContactEvent")]
	
	[ManagedEvents("onContactAdded,onGroupAdded,onRemoveContact,onRosterComplete,onAddRoster,onPresenceUpdate,onOpenRoom,onAlertSound,onChangeGroup,onShowChanged,onShowInGroups,onContactUpdated,onBroadcastMessage")]
	
	public class RosterManager extends EventDispatcher
	{
		
		private			var				_roster					:Roster,
										_bh						:buddiesHolder,
										_gh						:groupHolder,
										_dh						:dataHolder,
										_itemRenderer			:ClassFactory = new ClassFactory(BuddyItemRenderer);
		
		
		[Inject][Bindable]
		public 			var				conn					:Connection;
		
		[Inject][Bindable]
		public			var				presence				:PresenceManager;
		[Inject][Bindable]
		public			var				contact					:ContactListManager;
		
		public	static	const			offlineContactsGroup	:String = "Offline";
										
		public	static	var				RosterIsReady			:Boolean = false;
		public	static	var				CreateMultiItemsList	:Function;
		private			var				numberFormatter			:NumberFormatter = NumberFormatter.getInstance(); 
		
		private			var				addContactGroups		:Object = {};
		[Init]
		public function init():void {
		
			
		}
		[MessageHandler (selector="onDisconnected")]
		public function onDisconnected(event:ConnectionEvent):void {
			try {
				_roster.removeEventListener(RosterEvent.ROSTER_LOADED, onRoster)
				_roster.removeEventListener(RosterEvent.USER_ADDED, onRoster)
				_roster.removeEventListener(RosterEvent.USER_REMOVED,onRoster)
		
				_roster.removeEventListener(RosterEvent.USER_AVAILABLE,onOnlineChange);
				_roster.removeEventListener(RosterEvent.USER_UNAVAILABLE,onOnlineChange);
				
				_roster.removeEventListener(RosterEvent.SUBSCRIPTION_DENIAL, onSubscription)
				_roster.removeEventListener(RosterEvent.SUBSCRIPTION_REQUEST, onSubscription)
				_roster.removeEventListener(RosterEvent.SUBSCRIPTION_REVOCATION, onSubscription)
				_roster.removeEventListener(RosterEvent.USER_SUBSCRIPTION_UPDATED, onSubscription)
				_roster.clearSource();
				_roster = null;
				VCard.clearCache();
				RosterIsReady = false;
				_showInGroups = false;
				addContactGroups = {};
				for (var i:uint = 0;i<_bh.length;i++){
					_bh.getBuddy(i).removeEventListener(PropertyChangeEvent.CHANGE,userChange);
				}
				for (i=0; i<vcardTimers.length; i++){
					clearTimeout(vcardTimers[i]);
				}
				vcardTimers = [];
				_bh = null;
				_gh = null;
				_dh = null;
				System.gc();
			}catch (error:Error){trace (error.getStackTrace())};
		}
		[MessageHandler (selector="onConnectionSucces")]
		public function connected(event:ConnectionEvent):void {
			_bh						= buddiesHolder.getInstance(),
			_gh						= groupHolder.getInstance();
			_dh						= dataHolder.getInstance()
		
			if (offlineContactsGroup !=null){
				var addedGroup:int = _gh.setGroup(offlineContactsGroup, IMBuddyModel.GROUP_KIND, _itemRenderer, [showOffline], true );
				addGroup(_gh.getGroup(addedGroup),addedGroup,1000000,"id");
			}
			
			CreateMultiItemsList = createMultiMenuItems
			_addCounter = 0;
			vcardCounter = 0;
			_roster = new Roster(conn.connection);
			_roster.addEventListener(RosterEvent.ROSTER_LOADED, onRoster);
			_roster.addEventListener(RosterEvent.USER_ADDED, onRoster);
			_roster.addEventListener(RosterEvent.USER_REMOVED,onRoster);
				
			_roster.addEventListener(RosterEvent.USER_AVAILABLE,onOnlineChange);
			_roster.addEventListener(RosterEvent.USER_UNAVAILABLE,onOnlineChange);
				
	
			_roster.addEventListener(RosterEvent.SUBSCRIPTION_DENIAL, onSubscription);
			_roster.addEventListener(RosterEvent.SUBSCRIPTION_REQUEST, onSubscription);
			_roster.addEventListener(RosterEvent.SUBSCRIPTION_REVOCATION, onSubscription)
			_roster.addEventListener(RosterEvent.USER_SUBSCRIPTION_UPDATED, onSubscription);
			
		
		//	_roster.fetchRoster();
			
			
		}
		[MessageHandler (selector="onSendSubscriptionDeny")]
		public function onSendSubscriptionDeny(event:ContactEvent):void {
			_roster.denySubscription(event.data.jid);
			try {
				_roster.removeItem(event.data.jid);
			}catch(error:Error){
				
			}
		}
		[MessageHandler (selector="onSendSubscriptionRequest")]
		public function onSendSubscriptionRequest(event:ContactEvent):void {
			event.data.address = numberFormatter.stripSpaces(event.data.address);
		
			var jidE:EscapedJID = new EscapedJID( AbstractJID.escapedNode (  event.data.address ) +  "@" + event.data.network , true)
			var jidU:UnescapedJID = jidE.unescaped; 
			
			
			if (event.data.group == null){
				event.data.group = "General";
			} 
			
			
			if (!addContactGroups[jidU.bareJID] ){
				addContactGroups[jidU.bareJID]  = {subscribe:0};
			}
			
			addContactGroups[jidU.bareJID].nickname = event.data.nickname;
			addContactGroups[jidU.bareJID].groupname = event.data.group;
			addContactGroups[jidU.bareJID].subscribe++;
		
			var subscribePresence:Presence = new Presence(jidE, null, Presence.TYPE_SUBSCRIBE);
			var subscribedPresence:Presence = new Presence(jidE, null,  Presence.TYPE_SUBSCRIBED);
			if 	(addContactGroups[jidU.bareJID].subscribe < 2){
				conn.send( subscribePresence );
			}
			
			if 	(addContactGroups[jidU.bareJID].subscribe == 2 || event.data.request == false){
				conn.send( subscribedPresence );
			}
			
			
		
			
			
		}
		[MessageHandler (selector="onSubscribed")]
		public function onSubscribed(event:ContactEvent):void {
			try {
				if (event.from.domain != conn.jid.domain){
					
						if (event.from.domain=="workgroup."+conn.jid.domain){
							_roster.removeItem(RosterItemVO.get(event.from.unescaped,false));
							return;
						}
					
				}
			}catch (fpErr:Error){
				trace (fpErr.getStackTrace());
			}
			
			
			if (addContactGroups[event.from.bareJID] != undefined){
				try {
					var rosterItem:RosterItemVO = RosterItemVO.get(event.from.unescaped,false);
				 
					if (addContactGroups[event.from.bareJID].nickname!=null && addContactGroups[event.from.bareJID].nickname.length>0){
						
						try {
							rosterItem.nickname = addContactGroups[event.from.bareJID].nickname;
							_bh.getBuddy(rosterItem.jid.bareJID).nickname = rosterItem.nickname;
						}catch (error:Error){
							
						}
					}
					var newGroupName:String = addContactGroups[event.from.bareJID].groupname;
					var oldGroupName:String = _roster.getContainingGroups(rosterItem)[0].label;
	
					if (oldGroupName == newGroupName)return;
					
					
					var cte:ContactEvent = new ContactEvent(ContactEvent.ON_CHANGE_GROUP);
					cte.id = event.from.bareJID;
					cte.actionType = ContactEvent.GROUP_ACTION_MOVE_TO;
					
					cte.newGroupName = newGroupName;
					cte.oldGroupName = oldGroupName;
					cte.create = (_roster.getGroup(newGroupName) == null);
				
					setTimeout(dispatchEvent,700,cte);
					
				 
					// ContactEvent.GROUP_ACTION_REMOVE_FROM
				
				
				}catch (error:Error){
					trace (error.getStackTrace());
				}
				
				try {
					delete addContactGroups[event.from.bareJID];
				}catch (error:Error){
					trace (error.getStackTrace());
				}
				
				
			}
			var ctEv:ContactEvent = new ContactEvent(ContactEvent.CONTACT_UPDATED);
			ctEv.id = event.from.bareJID;
			setTimeout(dispatchEvent,1500,ctEv);
		}
		
		private function onSubscription(event:RosterEvent):void { 
			if (!RosterIsReady){
				setTimeout(onSubscription,4000,event);
				return;
			} 
			if (event.type == RosterEvent.USER_SUBSCRIPTION_UPDATED){
				trace ("USER_SUBSCRIPTION_UPDATED")
			}
			if (event.type == RosterEvent.SUBSCRIPTION_DENIAL){
				trace ("SUBSCRIPTION_DENIAL")
			}
			if (event.type == RosterEvent.SUBSCRIPTION_REVOCATION){
				trace ("SUBSCRIPTION_REVOCATION");
			}
			if (event.type == RosterEvent.SUBSCRIPTION_REQUEST){
				trace ("SUBSCRIPTION_REQUEST");
				var uE:UserEvent = new UserEvent(UserEvent.ADD_ROSTER);
				uE.actionType = UserEvent.SubscriptionTypeRequest;
				uE.recipientJID = event.jid;
				dispatchEvent(uE);
			}
		}
		
		private function onOnlineChange(event:RosterEvent):void {
			var e:ContactEvent = new ContactEvent(ContactEvent.SHOW_CHANGED);
			e.id = event.jid.bareJID;
			dispatchEvent( e );
		}
		private function onRoster(event:RosterEvent):void {
			var _t:String = event.type;
			if (_t == RosterEvent.USER_ADDED){
				try {
					 createBuddy(event.data as RosterItemVO);
				}catch (error:Error){
					trace (error.getStackTrace());
				}
				return;
			}
			if (_t == RosterEvent.ROSTER_LOADED){
				_roster.setPresence(presence.show,presence.status,1);
				rosterReady();
				return;
			}
			if (_t == RosterEvent.USER_REMOVED){
				try {
					if (event.jid.bareJID.indexOf("@") == -1){
						_bh.removeConnection ( event.jid.bareJID );
						return
					}
					var removeEvent:ContactEvent = new ContactEvent(ContactEvent.REMOVE_CONTACT);
					removeEvent.id = event.jid.bareJID;
					dispatchEvent(removeEvent);
					
					//conn.send(new Presence(event.jid.escaped,conn.jid.escaped,Presence.TYPE_UNSUBSCRIBED));
					
				}catch (error:Error){
					
				}
			
				
				
			}
		}
		private var _addCounter:uint = 0;
		private function createBuddy(r:RosterItemVO,cnt:uint=0):void {
			if (r.jid.bareJID.indexOf("@") == -1){
				_bh.connection = r;
				return
			}
			if (r.jid.domain != conn.jid.domain){
				try {
					if (r.jid.domain=="workgroup."+conn.jid.domain){
						_roster.removeItem(r);
						return;
					}
				}catch (fpErr:Error){
					trace (fpErr.getStackTrace());
				}
			}
		
		
		
			var groups:Array = [];
			
			var tmp:Array = _roster.getContainingGroups(r);
			var gLabel:String;
			for (var i:uint = 0; i<tmp.length; i++){
				try {
					gLabel = (tmp[i] as RosterGroup).label;
					var addedGroup:int = _gh.setGroup( gLabel, IMBuddyModel.GROUP_KIND, _itemRenderer, [showOnline] );
					if (gLabel == "Transports") _gh.getGroup(addedGroup).displayOnList = false;
					if (addedGroup > -1){
						var gr:GroupModel = _gh.getGroup(addedGroup);
						addGroup(gr,addedGroup,1000*_gh.groups.length);
					}
					groups.push( gLabel );
				}catch (error:Error){trace (error.getStackTrace())}

			}
			groups.push( offlineContactsGroup );
			var bd:IMBuddyModel;
			if (_bh.isExist(r.jid.bareJID)){
				bd = _bh.getBuddy(r.jid.bareJID) as IMBuddyModel;
				bd.groups = new ArrayCollection(groups);
			}else {
				bd = new IMBuddyModel(r.jid.bareJID,r,groups);	
			}
			bd.renderMenuItemsFunction = createMenuItems;
			bd.clickFunction = contact.itemIMMouseHandler;
			_bh.buddy = bd;

			
			bd.addEventListener(PropertyChangeEvent.CHANGE,userChange);
			if (bd.roster.pending)bd.status = "Pending...";
			
			
			bd.vCard = new VCard();
			if (++vcardCounter < 12){
				bd.vCard= VCard.getVCard(conn.connection,bd.roster.jid);
			}else {
				vcardTimers.push(setTimeout(function(  ):void {
					bd.vCard= VCard.getVCard(conn.connection,bd.roster.jid);
				},15000 + Math.floor(vcardCounter%12)*3000 ));
			}
		
			if (RosterIsReady){
				var contactEvent:ContactEvent = new ContactEvent(ContactEvent.CONTACT_ADDED);
				contactEvent.id = bd.id;
				setTimeout(dispatchEvent,1100,contactEvent);
			}
		}
		private var vcardCounter:uint = 0;
		private var vcardTimers:Array = [];
		private function addGroup(group:GroupModel, collNumber:int, sortKey:Number=NaN, sorfFieldName:String="id"):void {
			group.sortKey = sortKey;
			group.sortField = new SortField(sorfFieldName);
			group.renderMenuItemsFunction = createGroupMenuItems;
			var grEvent:ContactEvent = new ContactEvent(ContactEvent.GROUP_ADDED);
			grEvent.groupId = collNumber;
			dispatchEvent(grEvent);
			
		}

		
		private function showPresenceUEM(roster:RosterItemVO,online:Boolean):void {
			
			var title:String = roster.nickname;
			var message:String;
			if (online){
				var status:String = roster.status;
				if (status.length > 25){
					status = status.slice(0,25)+"...";
				}
				message = UIphrases.getPhrase(UIphrases.IM_EVENT_COME_ONLINE,{status:status});
			}
			else message = UIphrases.getPhrase(UIphrases.IM_EVENT_COME_OFFLINE);
			var owner:String = roster.jid.bareJID + "IM";
			
		
			UEM.newUEM(owner,title,message,null,new Point(UEM.defaultWidth,UEM.smallHeight),SettingsManager.ALLERTS["notificationContact"].time);
			
		}
		private function userChange(e:PropertyChangeEvent):void {
			if (e.name != "online")return;
			dispatchEvent( new ContactEvent(ContactEvent.PRESENCE_UPDATE))
			if (e.newValue)	presence.sendMyPresenceTo(e.currentTarget.roster.jid.escaped);
			if (e.currentTarget.roster.jid.toString().indexOf("@") == -1 || !RosterIsReady)return;
			
			
			try {
				var timerDelay:uint = 15;
				if (e.currentTarget.roster.jid.domain != conn.connection.domain)timerDelay = 32
				if (Math.abs(getTimer() - _bh.getBuddy(e.currentTarget.roster.jid.bareJID).creationDate)/1000 < timerDelay) return;
			}catch (error:Error){
				
			}
			if (SettingsManager.ALLERTS["notificationContact"].popup)showPresenceUEM(e.currentTarget.roster as RosterItemVO, e.newValue);
			if (SettingsManager.ALLERTS["notificationContact"].sound)dispatchEvent(new SoundAlertEvent(SoundAlertEvent.ALERT_SOUND));
		
			
		}
		private function rosterReady():void {
			
			setTimeout(function ():void{
				var cEvent:ContactEvent = new ContactEvent(ContactEvent.ROSTER_COMPLETE);
				dispatchEvent(cEvent);
				RosterIsReady = true;
				
				
			},800);
			

			
		}
		public function showOffline(bd:*):Boolean {
			try {
				return (!bd.roster.online) && !_showInGroups; 
			}catch (error:Error){
				
			}
			return true
		}
		public function showOnline(bd:IMBuddyModel):Boolean {
			try {
				return bd.roster.online || _showInGroups;
			}catch (error:Error){
				
			}
			return true
		}
		
		/////////
		
		private var 	newGroup						:Object,
						newName							:Object,
						_window							:CustomWindow,
						_boradcastMessage				:Object,
						_selectedGroup					:GroupModel,
						_showInGroups					:Boolean = false;
						
		private const	MENU_GROUP_GROUPCHAT_ACTION		:String = "startGroupChat",
						MENU_GROUP_BROADCAST_ACTION		:String = "broadcastMessage";
		
		private function createGroupMenuItems(gr:GroupModel,grName:String=null):Vector.<ContextMenuItem>	{
			if (grName==null)grName = gr.groupName;
			var menuItems:Vector.<ContextMenuItem> = new Vector.<ContextMenuItem>();	
			
			menuItems.push( new ContextMenuItem('Start Group Chat','assets/_ico/grchat.png',!gr.virtual,false,groupMenuAction,[gr,MENU_GROUP_GROUPCHAT_ACTION],null) )
			menuItems.push( new ContextMenuItem(UIphrases.getPhrase(UIphrases.BROADCAST_WINDOW_TITLE,{groupName:grName}),'assets/_ico/chat.png',!gr.virtual,false,groupMenuAction,[gr,MENU_GROUP_BROADCAST_ACTION],null) )
			
			var singLabel:String;
			if (!gr.noneExist){
				if (!gr.virtual){
					if (_showInGroups){
						singLabel = "Hide Offline Contacts";
					}else {
						singLabel = "Show Offline Contacts";
					}
				}else {
					if (_showInGroups){
						singLabel = "Hide Offline Contacts";
					}else {
						singLabel = "Show In Groups";
					}
					
				}
				try {
					for (var i:uint = 0; i<_dh.globalGroupMenuItems.length;i++){
						var tmp:ContextMenuItem = (_dh.globalGroupMenuItems[i] as ContextMenuItem)
						var dit:ContextMenuItem = new ContextMenuItem(tmp.label,tmp.icon,tmp.enabled,tmp.lineBefore,tmp.callBack,[gr],tmp.subMenu,tmp.icon2);
						menuItems.push( dit );
					}
				}catch (error:Error){
					
				}
				menuItems.push(new ContextMenuItem(singLabel,null,true,true,showInGroups,[],null) );
				
				 
			
			}
			return menuItems;
		}
		private function createMultiMenuItems( multiItems:Vector.<BuddyModel>=null):Vector.<ContextMenuItem>{
			var existGroup:GroupModel = _gh.getGroup(multiItems[0].groups[0]+multiItems[0].groupKind);
			var tmpGr:GroupModel = new GroupModel("...", multiItems[0].groupKind,null,null,false);
			tmpGr.noneExist = true;
			var a:Array = [];
			for (var i:uint = 0; i<multiItems.length;i++){
				a.push( multiItems[i] );
			}
			tmpGr.itemCollection = new FilterArrayCollection( a  )
			var groupItems:Vector.<ContextMenuItem> = existGroup.renderMenuItemsFunction(tmpGr);

			try {
				for (i = 0; i<_dh.globalGroupMenuItems.length;i++){
					var tmp:ContextMenuItem = (_dh.globalGroupMenuItems[i] as ContextMenuItem)
					var dit:ContextMenuItem = new ContextMenuItem(tmp.label,tmp.icon,tmp.enabled,tmp.lineBefore,tmp.callBack,[tmpGr],tmp.subMenu,tmp.icon2);
					groupItems.push( dit );
				}
			}catch (error:Error){
				
			}
			
			if (multiItems[0] is IMBuddyModel) groupItems.push(new ContextMenuItem("Copy To",null,true,false,null,null,getGroupsForMulti(multiItems,ContactEvent.GROUP_ACTION_COPY_TO)) )	;
				
			
			
			return groupItems;
			
		}
		private function createMenuItems(bd:IMBuddyModel,gName:String=""):Vector.<ContextMenuItem>	{
			var menuItems:Vector.<ContextMenuItem> = new Vector.<ContextMenuItem>();	

			menuItems.push( new ContextMenuItem("Chat",ContextMenuItem.CHAT_ICO,true,false,contact.startChat,[bd.roster.jid]) );
			
			menuItems.push( new ContextMenuItem("View Chat Transcripts",ContextMenuItem.CHAT_ICO,true,false,viewTranscripts,[bd.roster.jid],null) );
			menuItems.push( new ContextMenuItem("View Profile",ContextMenuItem.PROFILE_ICO,true,false,contact.viewProfile,[bd.id],null) );
			
			
		//	var utils:Array = []
			menuItems.push(new ContextMenuItem("Copy To",null,true,false,null,null,getGroupsFor(bd,ContactEvent.GROUP_ACTION_COPY_TO)) )	
	
			var removeItems:Array = [];
			if (gName!=null && gName.length > 0){
				if (_gh.getGroup(gName+IMBuddyModel.GROUP_KIND).virtual == false){
					menuItems.push(new ContextMenuItem("Move To",null,true,false,null,null,getGroupsFor(bd,ContactEvent.GROUP_ACTION_MOVE_TO,gName)) )
					if (_roster.getContainingGroups(bd.roster).length > 1){
						removeItems.push( new ContextMenuItem("from: "+gName,null,true,false,changeGroup,[bd.id,ContactEvent.GROUP_ACTION_REMOVE_FROM,null,gName],null) )
					}
				}
			}
			if (removeItems.length > 0){
				removeItems.push( new ContextMenuItem("contact: "+bd.nickname,null,true,false,removeContact,[bd.id]) )
				menuItems.push( new ContextMenuItem("Remove",null,true,false,null,null,removeItems) );
			}else {
				menuItems.push( new ContextMenuItem("Remove "+bd.nickname,null,true,false,removeContact,[bd.id]) )
				
			}
			menuItems.push(new ContextMenuItem("Rename",null,true,false,renameContact,[bd.id]) )
			
			//menuItems.push( new ContextMenuItem("Utilities",ContextMenuItem.UTILITIES_ICO,true,false,null,[bd.roster.jid],utils) );
			
	
			
			return menuItems;
			
		}
		private var transcriptsWindow:CustomWindow;
		private var transcriptsContent:ArchiveContent;
		private function viewTranscripts(jid:UnescapedJID):void {
			
			if (transcriptsWindow != null && transcriptsWindow.closed == false) {
				transcriptsContent.select( jid.bareJID );
				transcriptsWindow.activate();
				transcriptsWindow.orderToFront();
				return
			}
			transcriptsWindow= dataHolder.getInstance().getWindow("Chat Transcript Viewer",true,"none",670,500,true,true,true,true,"transcriptViewer") as CustomWindow;
			transcriptsContent= new ArchiveContent();
			transcriptsContent.selected = jid.bareJID;
			transcriptsWindow._container.addElement( transcriptsContent );
			
		}
		private function getGroupsForMulti(bds:Vector.<BuddyModel>,paramType:String,gName:String=null):Array {
			var groupsMenuItems:Array = [];
			groupsMenuItems.push( new ContextMenuItem("Create New",null,true,false,null,null,null) )
			for (var i:uint = 0; i< _gh.groups.length; i++){
				if (_gh.groups[i].groupKind != IMBuddyModel.GROUP_KIND)continue;
				if (_gh.groups[i].virtual) continue;
				var contain:Boolean = false;
			//
				groupsMenuItems.push(new ContextMenuItem(_gh.groups[i].groupName,null,!contain, groupsMenuItems.length == 1,recursiveChangeGroup,[bds,paramType,_gh.groups[i].groupName,gName],null));
			}
			return groupsMenuItems
		}
		private function recursiveChangeGroup(bds:Vector.<BuddyModel>,type:String,newGroupName:String=null,oldGroupName:String=null,create:Boolean=false):void {
			for (var i:uint = 0; i<bds.length;i++){
				changeGroup(bds[i].id,type,newGroupName,oldGroupName,create);
			}
			
		}
	
		private function getGroupsFor(bd:IMBuddyModel,paramType:String,gName:String=null):Array {
			var groupsMenuItems:Array = [];
			groupsMenuItems.push( new ContextMenuItem("Create New",null,true,false,createNewGroup,[bd.id,paramType,gName],null) )
			for (var i:uint = 0; i< _gh.groups.length; i++){
				if (_gh.groups[i].groupKind != bd.groupKind)continue;
				if (_gh.groups[i].virtual) continue;
				var contain:Boolean = false;
				for (var j:uint = 0; j < bd.groups.length; j++){
					if (bd.groups[j] == _gh.groups[i].groupName){
						contain = true;
					}
				}
				groupsMenuItems.push(new ContextMenuItem(_gh.groups[i].groupName,null,!contain, groupsMenuItems.length == 1,changeGroup,[bd.id,paramType,_gh.groups[i].groupName,gName],null));
			}
			return groupsMenuItems
		}
		private function removeContact(id:String):void {
			var bd:IMBuddyModel = _bh.getBuddy(id) as IMBuddyModel; 
			_roster.removeContact(bd.roster);
			conn.send( new Presence(bd.roster.jid.escaped,null,Presence.TYPE_UNSUBSCRIBE) );
		}
		private function renameContact(id:String):void {
			 if (_window != null && !_window.closed) _window.close();
			 
			_window = new CustomWindow();
			_window.alwaysInFront = true;
			_window.maximizable = false;
			_window.minimizable = false;
			_window.closeable = true;
			_window.width = FlexGlobals.topLevelApplication.nativeWindow.width - 50;
			_window.height = 158;
			_window.open(true);
			_window.move( FlexGlobals.topLevelApplication.nativeWindow.x+25,
					FlexGlobals.topLevelApplication.nativeWindow.y+150);
			_window.title = "Rename "+_bh.getBuddy(id).nickname;
			var lab:Label = new Label();
			lab.text = "Rename:";
			lab.left = lab.right = 10;
			lab.top = 12;
			
			var input:TextInput = new TextInput();
			input.left = input.right = 10;
			input.top = 32;
			input.text = _bh.getBuddy(id).nickname;
			input.addEventListener(FlexEvent.ENTER,onRename,false,0,true);
			
			
			
			_window._container.addElement(lab);
			_window._container.addElement(input);
			
			var rename:Button = new Button();
			rename.label = "Rename";
			_window._container.addElement(rename);
			rename.bottom = 10;
			rename.right = 10;
			rename.addEventListener(MouseEvent.CLICK,onRename,false,0,true);
			
			newName = {name:"",id:id}				
			BindingUtils.bindProperty(  newName, 'name',input, 'text', true );
			
			input.selectAll();
			input.setFocus();
		}
		private function onRename(event:*):void {
			(_bh.getBuddy(newName.id) as IMBuddyModel).nickname = newName.name;
			_roster.updateContactName((_bh.getBuddy(newName.id) as IMBuddyModel).roster, newName.name);
			_window.close();
		}
		
		
		private function changeGroup(id:String,type:String,newGroupName:String=null,oldGroupName:String=null,create:Boolean=false):void {
			var event:ContactEvent = new ContactEvent(ContactEvent.ON_CHANGE_GROUP);
			event.id = id;
			event.actionType = type;
			
			event.newGroupName = newGroupName;
			event.oldGroupName = oldGroupName;
			event.create = create;
			
			dispatchEvent(event)
		}
		[MessageHandler (selector="onChangeGroup")]
		public function onChangeGroup(event:ContactEvent):void {
			
			var id:String = event.id;
			var type:String = event.actionType;
			
			var newGroupName:String = event.newGroupName;
			var oldGroupName:String = event.oldGroupName;
			var create:Boolean = event.create;
	
			var roster:RosterItemVO = (_bh.getBuddy(id) as IMBuddyModel).roster;
			if (type == ContactEvent.GROUP_ACTION_CREATE){
				create = true;
			}
			try {
				
				if (type == ContactEvent.GROUP_ACTION_MOVE_TO){
					_roster.getGroup(oldGroupName).removeItem(roster);
					_bh.getBuddy(id).groups.removeItemAt(_bh.getBuddy(id).groups.getItemIndex(oldGroupName));
					_bh.getBuddy(id).groups.addItem(newGroupName);
					var oldGroup:GroupModel = _gh.getGroup(oldGroupName+IMBuddyModel.GROUP_KIND);
					for (var ii:uint = 0; ii<oldGroup.itemCollection.source.length;ii++){
						try {
							if (oldGroup.itemCollection.source[ii].id == id){
								if (ii == 0){
									oldGroup.itemCollection.source.shift();
								}else if (ii == oldGroup.itemCollection.source.length-1){
									oldGroup.itemCollection.source.pop();
								}else {
									oldGroup.itemCollection.source = oldGroup.itemCollection.source.slice(0,ii).concat( oldGroup.itemCollection.source.slice(ii+1,oldGroup.itemCollection.source.length) );
								}
								break;
							}
						}catch (error5:Error){
							trace (error5.message)
						}
					}
					oldGroup.itemCollection.refresh();
					var newsource:Array = [];
					for (ii = 0; ii<oldGroup.itemCollection.source.length;ii++){
						if (oldGroup.itemCollection.source[ii].id != id)newsource.push(oldGroup.itemCollection.source[ii]);
					}
					oldGroup.itemCollection.source = newsource;
					oldGroup.itemCollection.refresh();
				//	for (var 
				//	oldGroup.itemCollection.removeByID(id);
				} else if (type == ContactEvent.GROUP_ACTION_REMOVE_FROM){
					_roster.getGroup(oldGroupName).removeItem(roster);
					var oldGroup2:GroupModel  = _gh.getGroup(oldGroupName+IMBuddyModel.GROUP_KIND);
					oldGroup2.itemCollection.removeByID(id);
					_bh.getBuddy(id).groups.removeItemAt(_bh.getBuddy(id).groups.getItemIndex(oldGroupName));
				}  
				var tmpA:Array = [];
				if (type != ContactEvent.GROUP_ACTION_REMOVE_FROM){
					var group:RosterGroup;
					if (create ||  _roster.getGroup(newGroupName) == null){
						group = new RosterGroup(newGroupName);
						_roster.addItem(group);
					}else {
						group = _roster.getGroup(newGroupName) as RosterGroup;
					}
					var grIndex:int = _gh.setGroup( newGroupName, IMBuddyModel.GROUP_KIND, _itemRenderer, [showOnline] );
					if (grIndex > -1){
						addGroup(_gh.getGroup(newGroupName+IMBuddyModel.GROUP_KIND),grIndex, 1000*_gh.groups.length);
					}
					_gh.getGroup(newGroupName+IMBuddyModel.GROUP_KIND).setItem( _bh.getBuddy(id) );
					
				
					tmpA.push(group.label);
					
					if (type == ContactEvent.GROUP_ACTION_COPY_TO){
						_bh.getBuddy(id).groups.addItem(newGroupName);
					}
				}
				
				
				for (var i:uint = 0; i<_roster.getContainingGroups(roster).length;i++){
					tmpA.push(_roster.getContainingGroups(roster)[i].label);
				}
				_roster.updateContactGroups(roster,tmpA);	
				
				var ctEv:ContactEvent = new ContactEvent(ContactEvent.CONTACT_UPDATED);
				ctEv.id = id; 
				dispatchEvent(ctEv);
			}catch (error:Error){
				trace(error.getStackTrace());
			}
		}
		
		private function onAddGroup(event:*):void {
			changeGroup(newGroup.id,newGroup.type,newGroup.name,newGroup.oldGroup,true);
			_window.close()
		}
		
		private function createNewGroup(id:String,type:String,gName:String):void {
			if (_window != null && !_window.closed)_window.close()
			_window = new CustomWindow();
			_window.alwaysInFront = true;
			_window.minimizable = false;
			_window.maximizable = false;
			_window.closeable = true;
			_window.name = "addNewGroup";
			_window.width = 296;
			_window.height = 162;
			_window.title = UIphrases.ADD_NEW_GROUP_TITLE;
			_window.open(true);

			var lb:Label = new Label();
			lb.text = UIphrases.ADD_NEW_GROUP_LABEL;
			lb.left = 10
			lb.top = 12;
			lb.right = 10;
			
			var field:TextInput = new TextInput();
			field.left = field.right = 10;
			field.top = 33;
			field.addEventListener(FlexEvent.ENTER,onAddGroup,false,0,true);
			
			
			_window._container.addElement(lb);
			_window._container.addElement(field);
			
			var save:Button = new Button();
			save.label = UIphrases.ADD_NEW_GROUP_SAVE_LABEL
			save.bottom = 10;
			save.right = 10;
			save.addEventListener(MouseEvent.CLICK,onAddGroup);
			
			_window._container.addElement(save);
			
			newGroup = {name:"",type:type,id:id,oldGroup:gName}
			BindingUtils.bindProperty(  newGroup, 'name',field, 'text', true );
		}
		
		private function groupMenuAction(group:GroupModel,action:String):void {
			_selectedGroup = group;
			switch(action)
			{
				case MENU_GROUP_BROADCAST_ACTION:
				{
					
					if (_window != null && !_window.closed)_window.close();
					_window = new CustomWindow();
					_window.title = UIphrases.getPhrase(UIphrases.BROADCAST_WINDOW_TITLE,{groupName:group.groupName})
					_window.maximizable = true;
					_window.width = 430;
					_window.height = 290;
					_window.alwaysInFront = true;
					_window.contentBackgrouond = true;
					_window.open();
					_window.move(Screen.mainScreen.bounds.width/2 - _window.width/2,Screen.mainScreen.bounds.height/2 - _window.height/2);
					
					var container:SkinnableContainer = new SkinnableContainer();
					container.percentHeight = 100;
					container.percentWidth = 100;
					container.left = container.right = container.bottom = 3;
					container.top  = 1;
					container.setStyle("styleName","_broadcastMessageBox");
					_window._container.addElement(container);
					_window._container.bottom = 47;
					
					
					var txt:TextArea = new TextArea();
					txt.setStyle("borderVisible",false);
					txt.setStyle("color",0x000000);
					txt.setStyle("backgroundAlpha",0);
					txt.setStyle("contentBackgroundAlpha",0);
					txt.percentWidth = 100;
					txt.percentHeight = 100;
					container.addElement(txt);
					
					var hbox:HGroup = new HGroup();
					hbox.right = 10;
					hbox.bottom = 10;
					
					var chbox:CheckBox = new CheckBox();
					chbox.label = "Include offline contacts";
					chbox.left = 12;
					chbox.bottom = 12;
					_window.addElement(chbox)
					
					var cancel:Button = new Button();
					cancel.label = UIphrases.CANCEL_LABEL;
					hbox.addElement(cancel);
					cancel.addEventListener(MouseEvent.CLICK,onButtonCancel,false,0,true);
					
					var send:Button = new Button();
					send.label = UIphrases.BROADCAST_SEND_LABEL;
					send.addEventListener(MouseEvent.CLICK,onBroadcast,false,0,true);
					
				
					hbox.addElement(send);

					_window.addElement(hbox);
					
					_boradcastMessage = {text:"",incluse_chbox:false};
					BindingUtils.bindProperty(  _boradcastMessage, 'text',txt, 'text', true );
					BindingUtils.bindProperty(  _boradcastMessage, 'incluse_chbox',chbox, 'selected', true );
					
					
					break;
				}
				case MENU_GROUP_GROUPCHAT_ACTION:
				{
					onOpenGroupRoom()
					break;
				}
			}
			
		}
		private function onOpenGroupRoom():void {
			var recipients:Array = [];
			try {
				for (var i:uint = 0; i <_selectedGroup.itemCollection.source.length; i++){
					recipients.push( _selectedGroup.itemCollection.source[i].roster.jid );
				}
		
				
				onInvite(recipients);
			}catch (error:Error){
			
			}
		}
		private function onButtonCancel(event:MouseEvent):void {
			_window.close();
		}
		private function onBroadcast(event:MouseEvent):void {
			var m:Message	= new Message( );
			m.body 			= _boradcastMessage.text;
			m.type			= Message.TYPE_CHAT;
			
			var recipients:Array = _selectedGroup.itemCollection.source;
			var e:ChatEvent = new ChatEvent(ChatEvent.BROADCAST_MESSAGE);
			e.recipients = recipients;
			e.incOffline = _boradcastMessage.incluse_chbox;
			e.message = m;
			dispatchEvent( e );
			/*
			
			for (var i:uint = 0; i <_selectedGroup.itemCollection.source.length; i++){
				try {
					var m:Message	= new Message((_selectedGroup.itemCollection.source[i] as IMBuddyModel).roster.jid.escaped );
					m.body 			= _boradcastMessage.text;
					m.type			= Message.TYPE_CHAT;
					conn.send(m);
				}catch (error:Error){
					
				}
			}*/
			
			
			_window.close();
		}
		private function showInGroups():void {
			_showInGroups = !_showInGroups;
			for (var i:uint = 0;i<_gh.groups.length;i++){
				_gh.groups[i].itemCollection.refresh();
			}
			dispatchEvent(new ContactEvent(ContactEvent.SHOW_INGROUPS));
			
			//dispatchEvent(new ContactEvent(ContactEvent.PRESENCE_UPDATE));
		}
		///////
		
		/*
		var chatEvent:ChatEvent = new ChatEvent(ChatEvent.OPEN_ROOM);
		chatEvent.recipients = recipients;
		dispatchEvent(chatEvent);
		*/
		
		private var _inviteWindow:CustomWindow;
		private var _inviteList:InviteList;
		
		private function onInvite(recipients:Array):void {
			if (_inviteWindow == null || _inviteWindow.closed){
				_inviteWindow = new CustomWindow();
				_inviteWindow.maximizable = false;
				_inviteWindow.closeable = true;
				_inviteWindow.minimizable = true;
				_inviteWindow.resizable = true;
				
				_inviteWindow.title = "Invite People To Chat"
			//	if (event.currentTarget is List)_inviteWindow.title+= event.roomName;
			//	else _inviteWindow.title+=event.currentTarget.label;
				
				_inviteWindow.width = 420;
				_inviteWindow.height =140;
				_inviteWindow.open(true);
				_inviteWindow.move(Screen.mainScreen.bounds.width/2 - _inviteWindow.width/2, Screen.mainScreen.bounds.height/2 - _inviteWindow.height/2 - 20);
				_inviteWindow._container.bottom = 43;
				
				var saveButton:Button = new Button();
				saveButton.label = " Create Group Chat ";
				_inviteWindow.addElement(saveButton);
				saveButton.bottom = 8;
				saveButton.right = 10;
				
				saveButton.addEventListener(MouseEvent.CLICK,doInvite);
				
				_inviteList = new InviteList();
				_inviteList._list.visible = _inviteList._list.includeInLayout = false; 
				_inviteList.occupants = recipients;
				_inviteWindow._container.addElement(_inviteList);
				
				
			}else {
				
			}
			/*
			if (event.room){// || _chats.selectedChild is RoomNavigatorContent){
				saveButton.label = "Invite";
				var room:Room;
				room = event.room;
				//room = (_chats.selectedChild as RoomNavigatorContent).model.room;
				
				_inviteList.room = room;
				_inviteList.occupants = [];
				for (var i:uint = 0; i<room.length;i++){
					_inviteList.occupants.push( (room.getItemAt(i) as RoomOccupant).jid.bareJID )
				}
			}else {
				_inviteList.selectedIds = [event.id];
			}
			*/
			_inviteList.init();
		}
		protected function doInvite(event:MouseEvent):void {
			var recipients:Array = _inviteList.occupants;
			
			var chatEvent:ChatEvent = new ChatEvent(ChatEvent.OPEN_ROOM);
			chatEvent.recipients = recipients;
			
			chatEvent.room = _inviteList.room;
			chatEvent.roomName = _inviteList._roomName.text;
			chatEvent.inviteMessage = _inviteList._inviteMessage.text;
			
			dispatchEvent(chatEvent);
			
			_inviteList.onRemove();
			_inviteWindow.close();
			
			/*
			
			var chatEvent:ChatEvent = new ChatEvent(ChatEvent.OPEN_ROOM);
			chatEvent.recipients = recipients;
			chatEvent.room = _inviteList.room;
			chatEvent.roomName = _inviteList._roomName.text;
			chatEvent.inviteMessage = _inviteList._inviteMessage.text;
			dispatchEvent(chatEvent);
			
			_inviteList.onRemove();
			_inviteWindow.close();*/
		}
		
		
		
		
	}
}
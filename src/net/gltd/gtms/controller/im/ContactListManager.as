/*
** ContactsManager.as , package net.gltd.gtms.controller.im **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 13, 2012 
*
*
*/ 
package net.gltd.gtms.controller.im
{
	import net.gltd.gtms.GUI.contextMenu.ContextMenu;
	import net.gltd.gtms.controller.xmpp.Connection;
	import net.gltd.gtms.controller.xmpp.RosterManager;
	import net.gltd.gtms.events.ArchiveEvent;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.ContactEvent;
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.model.contact.BuddyModel;
	import net.gltd.gtms.model.contact.GroupModel;
	import net.gltd.gtms.model.contact.IMBuddyModel;
	import net.gltd.gtms.model.contact.singl.buddiesHolder;
	import net.gltd.gtms.model.contact.singl.groupHolder;
	import net.gltd.gtms.model.dataHolder;
	import net.gltd.gtms.model.xmpp.DiscoItemModel;
	import net.gltd.gtms.utils.FilterArrayCollection;
	import net.gltd.gtms.view.im.IMcontactsList;
	import net.gltd.gtms.view.im.contactList.BuddyItemRenderer;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.setTimeout;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.rpc.xml.SimpleXMLDecoder;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	
	[Event(name="onUserStartChat",type="net.gltd.gtms.events.UserEvent")]
	[Event(name="onShowProfile",type="net.gltd.gtms.events.UserEvent")]
	[Event(name="onContactAddedGetArchive",type="net.gltd.gtms.events.ArchiveEvent")]
	[Event(name="onSendSubscriptionRequest",type="net.gltd.gtms.events.ContactEvent")]
	[ManagedEvents("onUserStartChat,onShowProfile,onContactAddedGetArchive,onSendSubscriptionRequest")]

	public class ContactListManager extends EventDispatcher
	{
		
		private		var		_view				:IMcontactsList,
							_bh					:buddiesHolder,
							_gh					:groupHolder,
							_dh					:dataHolder,
							_refreshTickAllow	:Boolean,
							_refreshTimer		:Timer,
							_gropDropAllowItems	:Object = {},
							_searchValue		:String = "",
							_showInGroups		:Boolean = false,
							
							inited				:Boolean = false,
							
							_xmlDecoder			:SimpleXMLDecoder = new SimpleXMLDecoder();

	// 	[Bindable]
	//	public		var		displayGroups	:ArrayCollection = new ArrayCollection();
		[Bindable][Inject]
		public		var		conn			:Connection;
							
		[Bindable]
		public		var		displayItems	:FilterArrayCollection;
		
		[Bindable]
		private		var		searchCollection:ArrayCollection;
	
		[Observe]
		public function observe(view:IMcontactsList=null):void {
			_view = view;
			_searchValue ="";
		}
		private function onCollChange(event:CollectionEvent):void {
			try {

			}catch (error:Error){
				trace(error.getStackTrace());
			}
		}
		//[MessageHandler (selector="onConnectionSucces")]
		public function init():void {
			if (_bh==null)_bh = buddiesHolder.getInstance();
			if (_gh==null)_gh = groupHolder.getInstance();
			if (_dh==null)_dh = dataHolder.getInstance();

			initArray(null)
			
			_refreshTickAllow = false;
			_refreshTimer = new Timer(2000);
			_refreshTimer.addEventListener(TimerEvent.TIMER,refershTick,false,0,true);
			_refreshTimer.start();
			inited = true;
		}
		private function initArray(source:Array):void {
			displayItems = new FilterArrayCollection(source)
			//displayItems.addEventListener(CollectionEvent.COLLECTION_CHANGE,onCollChange);
			var dataSortField:SortField = new SortField();
			dataSortField.name = "sortKey";
			dataSortField.numeric = true;
			
			var dataSortField2:SortField = new SortField("id");
			
			var dataSort:Sort = new Sort();
			dataSort.fields = [dataSortField,dataSortField2];
			
			displayItems.sort = dataSort;			
			displayItems.filterFunction = itemsDisplayFilter;
			
			searchCollection = new ArrayCollection();
			var sort:Sort= new Sort();
			var sortField:SortField = new SortField("exist",false);
			sort.fields = [sortField];
			searchCollection.sort = sort;
		}
		
		[MessageHandler (selector="onDisconnected")]
		public function onDisconnected(event:ConnectionEvent):void {
			try {
				_refreshTimer.removeEventListener(TimerEvent.TIMER,refershTick);
				_refreshTimer.stop();
				_refreshTimer = null;
				displayItems.sort = null;			
				displayItems.filterFunction = null;
				displayItems.removeAll();
				displayItems = null;
				_showInGroups = false;
				setTimeout(function():void {
					_gh.kill();
					_bh.kill()
					if (_view)_view.kill();
					
					
					buddiesHolder.destroy();
					groupHolder.destroy();
					_bh	= null;
					_gh = null;
					
				},100);
				
				inited = false;
				
				
			}catch (error:Error){
				trace(error.getStackTrace());
			}
			
			
		}
		
		[MessageHandler (selector="onRosterComplete")]
		public function rosterComplete(event:ContactEvent):void {
			if (!inited)init();
			
			for (var i:uint = 0; i<_bh.length;i++){
				if (_bh.getBuddy(i) is IMBuddyModel)createItem(_bh.getBuddy(i).id);
			}
			//_refreshTickAllow = true;
			refershTick(null);
		}
		[MessageHandler (selector="onContactAdded")]
		public function contactAdded(event:ContactEvent):void {
			if (!inited)init();
			createItem(event.id);
			refershTick(null);
			if (searchCollection.length>0 && searchDircetoryString!=null && searchDircetoryString.length > 0){
				searchDircetory(searchDircetoryString); 
			}
		}
		[MessageHandler (selector="onContactUpdated")]
		public function onContactUpdated(event:ContactEvent):void {
			if (!inited)init(); 
			removeitem(event.id);
			createItem(event.id);
			refershTick(null);
		}
		private function removeitem(bdId:String):void {
			var ind:int = displayItems.getIndexByKey("itemID",bdId);
			if (ind<0)return;
			displayItems.removeItemAt(ind); 
			removeitem(bdId);
		}
		private function createItem(bdId:String):void {
			var bd:BuddyModel = _bh.getBuddy(bdId);
			
			if (bd.clickFunction == null)bd.clickFunction = itemIMMouseHandler;
			var gr:GroupModel;
			var sk:Number;
			var k:uint =0;
			if (bd is IMBuddyModel){
				var ae:ArchiveEvent = new ArchiveEvent(ArchiveEvent.CADDED_GET_LIST);
				ae.forJID = (bd as IMBuddyModel).roster.jid.escaped;
				dispatchEvent(ae);
			}
			
		
			
			for (var i:uint = 0; i < bd.groups.length;i++){
				try {
					gr = _gh.getGroup(bd.groups[i]+bd.groupKind);
					gr.setItem(bd); 
					sk = gr.sortKey+1; 
					var obj:Object = {
						data:bd,
						sortKey:sk,
						type:"item",
						myGroupIsHide:!gr.visible,
						id:bd.id+bd.kind+sk,
						itemID:bd.id,
						representative: (i == 0),
						group:gr.groupName,
						groupSortKey:gr.sortKey,
						groupKind:gr.groupKind,
						label:bd.nickname
					}
						
					displayItems.addItem(obj);
					
					if ( bd.groups.length > 2 ){
						if (k==0) obj.displayOnList = true;
						else obj.displayOnList = false;
						k++;
					}
					
					
				}catch (error:Error){
					trace (error.getStackTrace())
					trace(error.getStackTrace());
				}
			}
		}
		public function groupVisibleChange(gropup:GroupModel,visible:Boolean):void  {
			gropup.visible = visible;
			for (var j:uint = 0; j < displayItems.source.length; j++){
				if ( Math.floor(displayItems.source[j].sortKey/1000) * 1000 == gropup.sortKey ){
					displayItems.source[j].myGroupIsHide = !gropup.visible;
				}
			}

			refershTick(null);
		}
		
		[MessageHandler (selector="onShowInGroups")]
		public function onShowInGroups(event:ContactEvent):void {
			
			_showInGroups = !_showInGroups;
			refershTick(null);
			
		}
		
		[MessageHandler (selector="onShowChanged")]
		public function onShowChanged(event:ContactEvent):void {
			refershTick(null);

		}
		
		
		[MessageHandler (selector="onGroupAdded")]
		public function groupAdded(event:ContactEvent):void {
			if (!inited)init()
			var group:GroupModel = _gh.getGroup(event.groupId);
			group.clickFunction = groupClick;
			if (!group.displayOnList)return;
		
			var filterKey:String;
			var filterValue:*;
			
			if ( group.groupKind  == IMBuddyModel.GROUP_KIND ){
				filterKey = "online"
				if (group.groupName == "Offline") filterValue = false;
				else filterValue = true;
			}
		
			displayItems.addItem({
				data:group,
				sortKey:group.sortKey,
				type:"group",
				id:group.id+group.sortKey+group.kind,
				label:group.nickname,
				filterKey:filterKey,
				filterValue:filterValue 
			});
			
		
			_refreshTickAllow = true;
		}
		
		
		[MessageHandler (selector="onRemoveContact")]
		public function removeContat(event:ContactEvent):void {
			var bd:BuddyModel = _bh.getBuddy(event.id);
			for (var i:uint = 0; i<bd.groups.length;i++){
				_gh.getGroup(bd.groups.getItemAt(i)+bd.groupKind).itemCollection.removeByID(bd.id);
			}
	
			for (i=0;i<displayItems.length;i++){
				try {
					if (displayItems.getItemAt(i).data.id == bd.id){
						displayItems.removeItemAt(i);
					
					}
				}catch (error:Error){
					trace(error.getStackTrace());
				}
			}
			displayItems.refresh();
			_bh.removeBuddie(bd.id);
			
			_refreshTickAllow = true;
			
			if (searchCollection.length>0 && searchDircetoryString!=null && searchDircetoryString.length > 0){
				searchDircetory(searchDircetoryString); 
			}
		}
		[MessageHandler (selector="onPresenceUpdate")]
		public function refresh(event:ContactEvent):void {
			_refreshTickAllow = true;
		}
		public function serchCont(obj:Object):Boolean {
			try {
				return obj.searchScope.toLowerCase().indexOf(_searchValue) > -1;
			}catch (error:Error){
				trace(error.getStackTrace());
			}
			return true;	
		}
		private var searchDircetoryTimer:uint;
		private var searchDircetoryString:String;
		private function searchDircetory(str:String):void {
			searchDircetoryString = str;
			var discoItem:DiscoItemModel = conn.disco.getDiscoByName("User Search");
			if (discoItem==null)return;
			var iq:IQ = new IQ(discoItem.jid,IQ.TYPE_SET,null,searchCallBack,searchCallBackError);
			var queryNode:XMLNode = new XMLNode(1,"query");
			queryNode.attributes.xmlns="jabber:iq:search";
			var xml:XMLDocument = new XMLDocument('<x type="submit" xmlns="jabber:x:data"><field var="search"><value>'+str+'</value></field><field type="hidden" var="FORM_TYPE"><value>jabber:iq:search</value></field><field var="Username"><value>1</value></field><field var="Name"><value>1</value></field><field var="Email"><value>1</value></field></x>');
			queryNode.appendChild( xml.firstChild );
			iq.xml.appendChild( new XML(queryNode) );
			conn.send( iq );
			
		}
		public function onSerachBar(str:String):void {
			
			if (_dh.searchBarOption=="Directory" && str.length > 0){
				if (_view._contactList.dataProvider != searchCollection)_view._contactList.dataProvider = searchCollection;
				_searchValue = "";
				clearInterval(searchDircetoryTimer)
				searchDircetoryTimer = setTimeout(searchDircetory,550,str);	
				return;
			}
			if (_view._contactList.dataProvider != displayItems)_view._contactList.dataProvider = displayItems;
			_searchValue = str;
			refershTick(null);
		}
		private function searchCallBack(iq:IQ):void {
		
			var obj:Object = _xmlDecoder.decodeXML ( new XMLDocument(iq.xml).firstChild );
			
			
			var items:Array;
			try {
				if (obj.query.x.item is Array) items = obj.query.x.item;
				else items = [ obj.query.x.item ];
				
				var source:Array = [];
				for (var i:uint = 0; i<items.length; i++){
					var item:Object = {};
					for (var j:uint = 0; j< items[i].field.length; j++){
						if ( items[i].field[j]['var'] == "Name" ) {
							item.nickname = items[i].field[j]['value'];
						}else if ( items[i].field[j]['var'] == "jid" ) {
							item.jid = items[i].field[j]['value'];
						}
					}
					var bd:IMBuddyModel = _bh.getBuddy( item.jid ) as IMBuddyModel;
					var label:String = item.nickname;
					var exist:Boolean = true;
					if (bd==null){
						bd = new IMBuddyModel(item.jid,null,[]);
					
						bd.clickFunction = addContact;
						if (label==null){
							label+=item.jid;
						}else {
							label+=" - "+item.jid;
						}
					
						bd.nickname = label;
						exist = false;
					}
					
					source.push( {data:bd,nickname:label,id:item.jid,exist:exist} );
					
				}
				searchCollection.source = source;
				/*if (searchCollection.length > 0){
					_view._contactList.dataProvider = searchCollection;
				}else {
					_view._contactList.dataProvider = displayItems;
				}*/
			}catch (error:Error){
				trace(error.getStackTrace());
			//	_view._contactList.dataProvider = displayItems;
			}
			
		}
		private function addContact(event:MouseEvent):void {
			//var p:Presence = new Presence(new EscapedJID(event.currentTarget.data.id),null,Presence.TYPE_SUBSCRIBE);
			//conn.send(p);
			var to:EscapedJID = new EscapedJID(event.currentTarget.data.id)
			var e:ContactEvent = new ContactEvent(ContactEvent.ADD_ROSTER);
			e.data = {
				address	:to.node,
				network	:to.domain,
				group	:null,
				nickname:null,
				request	:true
			}
			dispatchEvent(e);
			
		}
		private function searchCallBackError(iq:IQ):void {
			searchCollection.refresh();
		}
		private function refershTick(e:TimerEvent):void {
			try {
				if (!_refreshTickAllow && e != null)return;
					_refreshTickAllow = false;	 
					displayItems.refresh();
			}catch (error9:Error){
				trace(error9.getStackTrace());
			}
			try {
				//_view._contactList.validateDisplayList();
				//_view._contactList.validateProperties();
			}catch (error:Error){
				trace(error.getStackTrace());
			}
			
			
		}
		private function itemsDisplayFilter(c:*):Boolean {
		
			var _else:Boolean = ( _dh.rosterFilter=="" || c['data'].kind == _dh.rosterFilter ) &&  serchCont(c['data']);
			if (_searchValue!="") {
				return _else && c.representative;
			}
			
			if (c.data is GroupModel){
				return c.data.itemCollection.length > 0 && _else;
			}else {
				_else = _else && !c.myGroupIsHide;
			
				if (c.groupKind == IMBuddyModel.GROUP_KIND){
					if (c.group == "Offline") return (c.data.roster.online == false && !_showInGroups) && _else;
					return (c.data.roster.online == true || _showInGroups) && _else;
				}
			}
			return _else;
		}
		private function groupLengthFilter(c:*):Boolean {
			return c.itemCollection.length > 0;
		}
		public function itemIMMouseHandler(event:MouseEvent):void {
			try {
				if (event.type == MouseEvent.DOUBLE_CLICK){
					startChat(event.currentTarget.data.roster.jid);
				}else if (event.type == MouseEvent.RIGHT_CLICK){
					if (_view._contactList.selectedItems.length > 1){
						var bda:Vector.<BuddyModel> = new Vector.<BuddyModel>();
						var allow:Boolean;
						for (var i:uint = 0; i<_view._contactList.selectedItems.length;i++){
							if ( _view._contactList.selectedItems[i]['data'] is  GroupModel)continue;
							allow = true;
							for (var j:uint = 0; j<bda.length;j++){
								if (bda[j] ==  _view._contactList.selectedItems[i]['data']){
									allow = false
									break;
								}
							}
							if (allow)bda.push( _view._contactList.selectedItems[i]['data'] );
						}
						if (bda.length > 1){
							ContextMenu.ShowMenu(event,RosterManager.CreateMultiItemsList(bda));
							return;
						}
			
						
					}
					var bd:BuddyModel = _bh.getBuddy( event.currentTarget.data.id ) as BuddyModel;
					var gName:String;
					try {
						gName = event.currentTarget.group;
					}catch (error:Error){
						gName = ""
					}
					ContextMenu.ShowMenu(event,bd.renderMenuItemsFunction(bd,gName));
				}
			}catch (error:Error){
				trace(error.getStackTrace());
			}
		}
		
		public function viewProfile(contactID:String):void {
			var uE:UserEvent = new UserEvent(UserEvent.SHOW_PROFILE);
			uE.recipientID = contactID;
			uE.actionType = UserEvent.ProfileTypeView;
			dispatchEvent(uE);
		}
		public function startChat(jid:UnescapedJID):void {
			var userEvent:UserEvent = new UserEvent(UserEvent.USER_START_CHAT);
			userEvent.recipientJID = jid;
			dispatchEvent(userEvent);	
		}
		public function setGroupDropItem(item:String):void {
			_gropDropAllowItems[item] = true;	
		}
		public function getGroupDropItem(item:String):Boolean{
			return _gropDropAllowItems[item]
		}
		public function groupClick(event:MouseEvent,group:GroupModel):void {
			try {
				if (event.type == MouseEvent.RIGHT_CLICK){
					ContextMenu.ShowMenu(event,group.renderMenuItemsFunction(group));
				}
			}catch (error:Error){
				trace(error.getStackTrace());
			}
		}
	}
}
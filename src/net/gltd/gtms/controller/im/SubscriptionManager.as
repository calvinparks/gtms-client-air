package net.gltd.gtms.controller.im
{
	import net.gltd.gtms.GUI.window.CustomWindow;
	import net.gltd.gtms.controller.xmpp.Connection;
	import net.gltd.gtms.events.ContactEvent;
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.model.app.ApplicationTab;
	import net.gltd.gtms.model.contact.IMBuddyModel;
	import net.gltd.gtms.model.contact.singl.buddiesHolder;
	import net.gltd.gtms.model.contact.singl.groupHolder;
	import net.gltd.gtms.model.dataHolder;
	import net.gltd.gtms.view.im.profile.AddRosterContent;
	
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.im.Roster;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.ToggleButton;
	
	[Event(name="onAddRoster",type="net.gltd.gtms.events.UserEvent")]
	[Event(name="onSendSubscriptionRequest",type="net.gltd.gtms.events.ContactEvent")]
	[Event(name="onSendSubscriptionDeny",type="net.gltd.gtms.events.ContactEvent")]
	[ManagedEvents("onSendSubscriptionRequest,onSendSubscriptionDeny, onAddRoster")]
	
	
	
	
	public class SubscriptionManager extends EventDispatcher
	{
		[Embed(source="../assets/skins/main_tabs_ico/main_add_roster_contact.png")]
		public		var	addContactIco	:Class;
		
		
		private		var windows			:ArrayCollection = new ArrayCollection(),
						addWindow		:CustomWindow,
						mButton			:ApplicationTab;
		
		
						
		[Inject][Bindable]
		public		var	conn			:Connection;
		[Init]
		public function init():void {
			mButton = new ApplicationTab(addContactIco,"Add Roster Contact",onTabClick);
			mButton.id = "addRosterContact";
		}
		private function onTabClick():void {
			var uEvent:UserEvent = new UserEvent(UserEvent.ADD_ROSTER);
			if (mButton.selected){
				uEvent.actionType	= UserEvent.SubscriptionTypeAdd;
			}else {
				uEvent.actionType	= UserEvent.TypeClose;
			}
			dispatchEvent(uEvent);
		}
		[MessageHandler (selector="onAddRoster")]
		public function onRosterAdd(event:UserEvent):void { 
			try {
				if (event.actionType == UserEvent.TypeClose){
					if (addWindow!=null && !addWindow.closed)addWindow.close();
					return;
				}else {
					
					var window:CustomWindow = dataHolder.getInstance().getWindow("Add Roster Contact",true,"none",460,260,true,false,true,false,"addContactWindow") as CustomWindow;
					window.id = "addContactWindow";
				
					window.addEventListener(Event.CLOSE,onWinClose);
					
					var content:AddRosterContent = new AddRosterContent();
					content.subscriptionType = event.actionType;
					window._container.addElement(content);
					
					content.networksCollection.addItem({label:conn.connection.domain,id:conn.connection.jid});
					if (event.actionType == UserEvent.SubscriptionTypeRequest){
						content.jid = event.recipientJID;
						
					}else {
					
						try {
							for(var j:uint = 0; j<buddiesHolder.getInstance().connections.length;j++){
								content.networksCollection.addItem({label:buddiesHolder.getInstance().connections.getItemAt(j).jid});
							}
						}catch (error:Error){}
						addWindow = window;
					}
	//window.title = "Add Roster Contact";
					
					var bt:Button = new Button();
					bt.addEventListener(MouseEvent.CLICK,onSave);
					bt.label = UIphrases.SAVE_LABEL
					bt.right = 12;
					bt.bottom = 8;
					window._container.addElement(bt);
					
					if (event.actionType == UserEvent.SubscriptionTypeRequest){
						var bt2:Button = new Button();
						bt2.addEventListener(MouseEvent.CLICK,onDeny);
						bt2.label = UIphrases.DENY_LABEL
						bt2.right = 78;
						bt2.bottom = 8;
						window._container.addElement(bt2);
					}
					var gh:groupHolder = groupHolder.getInstance();
					content._network.selectedIndex = 0;
					for (var i:uint = 0; i<gh.groups.length; i++){
						if (gh.groups[i].groupKind == IMBuddyModel.GROUP_KIND && !gh.groups[i].virtual){
							content.groupCollection.addItem(gh.groups[i]);
						}
					}
					content._group.selectedIndex = 0;
					windows.addItem({window:window,content:content});
				}
			}catch (error:Error){
				trace (error.getStackTrace());
			}
		}
		private function onSave(event:MouseEvent):void {
			
			var content:AddRosterContent;
			var network:String;
			var group:String;
			var addres:String;
			var nickname:String;
			var request:Boolean;
		
			for (var i:uint = 0; i< windows.length;i++){
				if (windows.getItemAt(i).window == (event.currentTarget as Button).parentApplication){
					content = windows.getItemAt(i).content
					break;
				}
			}
			if (content._network.selectedIndex == -1){
				network = content.networksCollection.getItemAt(0).label;
			}else if (content._network.selectedIndex < -1){
				network = content._network.selectedItem;
			}else {
				network = content._network.selectedItem.label;
			}
			
			if (content._group.selectedIndex == -1){
				if (content.groupCollection.length>0)group = content.groupCollection.getItemAt(0).groupName;
			}else if (content._group.selectedIndex < -1){
				group = content._group.selectedItem;
			}else {
				group = content._group.selectedItem.groupName;
			}
			if (content.subscriptionType == UserEvent.SubscriptionTypeAdd){
				request = true;
			}else {
				request = false;
			}
			addres = content._address.text;
			nickname = content._nickname.text;
			if (nickname == null || nickname.length == 0){
				nickname =  new UnescapedJID(addres).node;//addres;
			}
		
			var e:ContactEvent = new ContactEvent(ContactEvent.ADD_ROSTER);
			e.data = {
				address	:addres,
				network	:network,
				group	:group,
				nickname:nickname,
				request	:request
			}
			dispatchEvent(e);
			windows.getItemAt(i).window.close();
			
		}
		private function onDeny(event:MouseEvent):void {
			var content:AddRosterContent;
			for (var i:uint = 0; i< windows.length;i++){
				if (windows.getItemAt(i).window == (event.currentTarget as Button).parentApplication){
					content = windows.getItemAt(i).content
					break;
				}
			}
			var e:ContactEvent = new ContactEvent(ContactEvent.DENY);
			e.data = {
				jid:content.jid
			}
			dispatchEvent(e);
			windows.getItemAt(i).window.close();
		}
		private function onWinClose(event:Event):void {
			if (event.currentTarget == addWindow){
				addWindow = null;
				mButton.selected = false;
				return;
			}
			for (var i:uint = 0; i< windows.length;i++){
				if (windows.getItemAt(i).window == event.currentTarget){
					windows.removeItemAt(i);
					return;
				}
			}
		
		}
	}
}
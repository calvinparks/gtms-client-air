/*
** MainTabs.as , package net.gltd.gtms.controller.im **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.1 
*	 Created: Jun 13, 2012 
*
*
*/ 
package net.gltd.gtms.controller.im
{
	import net.gltd.gtms.controller.app.ApplicationTabController;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.model.app.ApplicationTab;
	import net.gltd.gtms.view.app.MainTabs;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import spark.components.HGroup;
	import spark.components.ToggleButton;

	[Event(name="onUserLogout",type="net.gltd.gtms.events.UserEvent")]
	[Event(name="onShowProfile",type="net.gltd.gtms.events.UserEvent")]
	[Event(name="onAddRoster",type="net.gltd.gtms.events.UserEvent")]
	[Event(name="onShowSettings",type="net.gltd.gtms.events.UserEvent")]
	[ManagedEvents("onUserLogout,onShowProfile,onAddRoster,onShowSettings")]
	
	public class MainTabsManager extends EventDispatcher
	{

		private			var		 _tabs			:MainTabs,
								 _bottomTabs	:HGroup;
		private			var		 _dynTabsColl	:Object = {},
								 _atc			:ApplicationTabController,
								 _tO			:uint;
		
		[Init]
		public function preInit():void {
		 	_atc =  ApplicationTabController.getInstance();	
			_atc.addEventListener(UserEvent.TAB_ADDED,onTabAdded,false,0,true);
			_atc.addEventListener(UserEvent.TAB_REMOVED,onTabRemoved,false,0,true);
		}
		
		[Observe]
		public function init(tabs:MainTabs):void {
			_tabs = tabs;
			//_tO = setTimeout(init2,550);
			init2()
		}
		private function init2():void {
			for (var i:uint = 0; i< _atc.tabs.length; i++){
				addTab(_atc.tabs.getItemAt(i) as ApplicationTab);
			}
			
			_tabs.settings.addEventListener(MouseEvent.CLICK,onUtils,false,0,true);
			_tabs.logout.addEventListener(MouseEvent.CLICK,onLogout,false,0,true);
			
		}
		public function set bottomTabs(hg:HGroup):void {
			_bottomTabs = hg;
		}
		[MessageHandler (selector="onDisconnected")]
		public function onDisconnected(event:ConnectionEvent):void {
			_tabs = null;
			_bottomTabs = null;
			clearTimeout(_tO);
		}
		public function onTabRemoved(event:UserEvent):void {
			try {
				if (event.menuButton.scope == "bottom"){
					_bottomTabs.removeElement(event.menuButton);
				}else {
					_tabs._buttonsContainer.removeElement(event.menuButton);
				}
			}catch (error:Error){
				
			}
		}
		private function onTabAdded(event:UserEvent):void {
			addTab(event.menuButton);
		}
		private function addTab(tab:ApplicationTab,c:uint=0):void {
			try {
				if (tab.scope == "bottom"){ 
					if (_bottomTabs == null){
						if (c < 10)setTimeout(addTab,300,tab,++c)
					}else {
						_bottomTabs.addElement(tab); 
					}
				}else {
					_tabs._buttonsContainer.addElement(tab);
				}
			}catch (error:Error){ 
			}
		}
		// buttons Action
		private function onLogout(event:MouseEvent):void {
			dispatchEvent( new UserEvent(UserEvent.USER_LOGOUT) );
		}
		private function onExButton(event:MouseEvent):void {
			event.currentTarget.callBack(event.currentTarget as ToggleButton);
		}
		private function onUtils(event:MouseEvent):void {
			var uEvent:UserEvent;
				if (_tabs.settings.selected){
					uEvent = new UserEvent(UserEvent.SHOW_SETTINGS);
					uEvent.actionType	= UserEvent.TypeOpen;
				}else {
					uEvent = new UserEvent(UserEvent.SHOW_SETTINGS);
					uEvent.actionType	= UserEvent.TypeClose;
				}
			
			if (uEvent==null)return
			uEvent.menuButton	= event.currentTarget 
			dispatchEvent(uEvent);
		}
	}
}
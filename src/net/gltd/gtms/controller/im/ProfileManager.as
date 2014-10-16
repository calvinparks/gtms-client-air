/*
** ProfileManager.as , package net.gltd.gtms.controller.im **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 24, 2012 
*
*
*/ 
package net.gltd.gtms.controller.im
{
	import net.gltd.gtms.GUI.window.CustomWindow;
	import net.gltd.gtms.controller.app.SettingsManager;
	import net.gltd.gtms.controller.xmpp.Connection;
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.model.app.ApplicationTab;
	import net.gltd.gtms.model.contact.BuddyModel;
	import net.gltd.gtms.model.contact.IMBuddyModel;
	import net.gltd.gtms.model.contact.singl.buddiesHolder;
	import net.gltd.gtms.utils.StringUtils;
	import net.gltd.gtms.view.im.profile.ProfileContent;
	
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	
	import org.igniterealtime.xiff.events.VCardEvent;
	import org.igniterealtime.xiff.vcard.VCard;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.ToggleButton;
	
	[Event(name="onShowProfile",type="net.gltd.gtms.events.UserEvent")]
	[ManagedEvents("onShowProfile")]
	
	public class ProfileManager extends EventDispatcher{
		
		[Embed(source="../assets/skins/main_tabs_ico/main_Edit_Profile.png")]
		public	var			editProfileIco		:Class;
		
		
		[Inject][Bindable]
		public	var			conn				:Connection;
		
		private var			mButton				:ApplicationTab,
							currentWindow		:String,
							windows				:ArrayCollection,
							myProfle			:CustomWindow,
							myProfileContent	:ProfileContent,
							refreshNr			:int;				
		
		[Init]
		public function init():void {
			windows = new ArrayCollection();
			mButton = new ApplicationTab(editProfileIco,"Edit Profile",onTabClick);
			
			
		}
		private function onTabClick():void {
			var uEvent:UserEvent = new UserEvent(UserEvent.SHOW_PROFILE);
			if (mButton.selected){
				uEvent.actionType	= UserEvent.ProfileTypeEdit;
			}else {
				uEvent.actionType	= UserEvent.TypeClose;
			}
			dispatchEvent(uEvent);
		}
		[MessageHandler (selector="onShowProfile")]
		public function showProfile(event:UserEvent):void {
			try {
				if (event.actionType == UserEvent.TypeClose){
					if (myProfle!=null)	myProfle.close();
					return;
				}
				if (event.actionType == UserEvent.ProfileTypeView){
					for (var i:uint = 0; i< windows.length; i++){
						if (windows.getItemAt(i).window.name == "win"+event.recipientID){
							(windows.getItemAt(i).window as CustomWindow).activate();
							return;
						}
						
					}
				}
				var vcard:VCard;
				var nickname:String;
				var content:ProfileContent = new ProfileContent();
				var window:CustomWindow;
				
				window = new CustomWindow();
				window.id = "profilew"+StringUtils.generateRandomString(4);
			
				window.width = 400;
				window.height = 500;
				window.contentBackgrouond = false;
				window.open(true);
				
				
				window.addEventListener(Event.CLOSE,onWindowClose);
				currentWindow = event.recipientID;
				
				
				currentWindow = event.recipientID;
				
				var hbtBox:HGroup = new HGroup();
				hbtBox.right = 10;
				hbtBox.bottom = 10
				window.addElement(hbtBox);
				
				if (event.actionType == UserEvent.ProfileTypeEdit){
					
					window.name = "showprofile";
					
					
					content.editable = true;
					window.title = UIphrases.getPhrase( UIphrases.WINDOW_PROFILE_TITLE_EDIT, {nickname:nickname} );
				
					var cancelButton:Button = new Button();
					cancelButton.label = UIphrases.CANCEL_LABEL;
					hbtBox.addElement(cancelButton);
					cancelButton.addEventListener(MouseEvent.CLICK,onCloseClick);
					
					var saveButton:Button = new Button();
					saveButton.addEventListener(MouseEvent.CLICK,onSave)
					saveButton.label = UIphrases.SAVE_LABEL;
					hbtBox.addElement(saveButton);
					

					myProfle = window;
					myProfileContent = content;
					
					content.init(conn.myProfile.vcard, conn.myProfile.avatar);
				}else {
					try {
						nickname = buddiesHolder.getInstance().getBuddy(event.recipientID).nickname;
						vcard = (buddiesHolder.getInstance().getBuddy(event.recipientID) as IMBuddyModel).vCard;
					}catch (error:Error){
						nickname = event.recipientID;
						vcard = new VCard();
						
					}
					content.init(vcard);
					content.editable = false;
					content.jid =  (buddiesHolder.getInstance().getBuddy(event.recipientID) as IMBuddyModel).roster.jid;
					window.title = UIphrases.getPhrase( UIphrases.WINDOW_PROFILE_TITLE_VIEW, {nickname:nickname} );
				
					var refreshButton:Button = new Button();
					refreshButton.label = UIphrases.REFRESH_LABEL;
					hbtBox.addElement(refreshButton);
					refreshButton.addEventListener(MouseEvent.CLICK,onRefresh);
					
					
					var closeButton:Button = new Button();
					closeButton.label = UIphrases.CLOSE_LABEL;
					hbtBox.addElement(closeButton);
					closeButton.addEventListener(MouseEvent.CLICK,onCloseClick);
					
					
					
					window.name = "win"+event.recipientID;
					windows.addItem({window:window,content:content});
				}
				
				var p:Point = SettingsManager.getWindowPosition(window.name);
				var x:int;
				var y:int;
				if (p != null){
					x = Math.min(p.x, Screen.mainScreen.bounds.width-window.width);
					y = Math.min(p.y, Screen.mainScreen.bounds.height-window.height); 
				}else {
					x = (-130+(windows.length*22))+Screen.mainScreen.bounds.width/2 - window.width/2;
					y = Screen.mainScreen.bounds.height/2 - window.height/2;
				}
				
				window.move(x,y);
				
				window._container.addElement(content);
			}catch(error:Error){
				trace(error.getStackTrace())
			}
			
		}
		protected function onRefresh(event:MouseEvent):void {
			for (var i:uint = 0; i< windows.length; i++){
				if (windows.getItemAt(i).window == (event.currentTarget as Button).parentApplication){
					VCard.clearCache();
					refreshNr = i;
					var tmpVCard:VCard = VCard.getVCard(conn.connection,windows.getItemAt(i).content.jid);
					tmpVCard.addEventListener(VCardEvent.LOADED,onRefreshVcardLoaded);
			//		bd.vCard.dispatchEvent( new VCardEvent(VCardEvent.LOADED,bd.vCard,true,true) );
			//		
				
					return;
				}
			}
		}
		private function onRefreshVcardLoaded(event:VCardEvent):void {
			try {
				event.currentTarget.removeEventListener(VCardEvent.LOADED,onRefreshVcardLoaded);
				
				
				var bd:IMBuddyModel = buddiesHolder.getInstance().getBuddy(event.vcard.jid.bareJID) as IMBuddyModel;
				windows.getItemAt(refreshNr).content.init(	event.vcard	);
				
				bd.vCard.homeAddress = event.vcard.homeAddress
				bd.vCard.homeTelephone =  event.vcard.homeTelephone
					
				bd.vCard.workAddress =  event.vcard.workAddress
				bd.vCard.workTelephone =  event.vcard.workTelephone
				
				bd.vCard.name = event.vcard.name
				bd.vCard.nickname =  event.vcard.nickname
				
				bd.vCard.email =  event.vcard.email
				bd.vCard.photo =  event.vcard.photo
				
				bd.vCard.organization =  event.vcard.organization
				
				bd.vCard.url =  event.vcard.url
				
				bd.vCard.dispatchEvent( new VCardEvent(VCardEvent.LOADED,event.vcard,true,true) );
				//bd.vCard = event.vcard;
			}catch (er:Error){};
			
		}
		protected function onWindowClose(event:Event):void {
			event.currentTarget.removeEventListener(Event.CLOSE,onWindowClose);
			if ((myProfle != null && myProfle == event.currentTarget) && (mButton != null)){
				mButton.selected = false;
				myProfle = null;
				return
			}
			for (var i:uint = 0; i< windows.length; i++){
				if (windows.getItemAt(i).window == event.currentTarget){
					windows.removeItemAt(i)
					return;
				}
				
			}
			
		}
		protected function onSave(event:MouseEvent):void {
			var vcard:VCard = myProfileContent.save();
			if (vcard == null)return;
			vcard.addEventListener(VCardEvent.SAVED,onVcard);
			vcard.addEventListener(VCardEvent.SAVE_ERROR,onVcard);
			vcard.saveVCard(conn.connection);
			
				
		}
		private function onVcard(event:VCardEvent):void {
			event.currentTarget.removeEventListener(VCardEvent.SAVED,onVcard);
			event.currentTarget.removeEventListener(VCardEvent.SAVE_ERROR,onVcard);
			if (event.type == VCardEvent.SAVED){
				myProfle.close();
			}
			
		}
		protected function onCloseClick(event:MouseEvent):void {
			((event.currentTarget as Button).parentApplication as CustomWindow).close()
		}
	}
}
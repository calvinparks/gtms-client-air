/*
** UserEvent.as , package net.gltd.gtms.events **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.1 
*	 Created: Jun 12, 2012 
*
*
*/ 
package net.gltd.gtms.events
{
	import net.gltd.gtms.model.xmpp.LoginModel;
	
	import flash.events.Event;
	
	import org.igniterealtime.xiff.core.UnescapedJID;
	
	public class UserEvent extends Event
	{
		public	static	const		USER_LOGIN				:String = "onUserLogin",
									USER_LOGOUT				:String	= "onUserLogout",
									
									USER_START_CHAT			:String = "onUserStartChat",
									USER_CLOSE_CHAT			:String = "onUserCloseChat",
									USER_START_GROUP_CHAT	:String = "onUserStartGroupChat",
									USER_OPEN_STREAM		:String = "onUserOpenStream",
		
									SHOW_PROFILE			:String = "onShowProfile",
									ADD_ROSTER				:String = "onAddRoster",
									SHOW_SETTINGS			:String = "onShowSettings",
									
									TAB_ADDED				:String = "onTabAdded",
									TAB_REMOVED				:String = "onTabRemoved",
									
									NEW_DYNAMIC_ITEM		:String = "onNewDynamicItem",
		
		
									ProfileTypeView			:String = "view",
									ProfileTypeEdit			:String = "edit",
									SubscriptionTypeAdd		:String	= "add",
									SubscriptionTypeRequest	:String = "request",
									TypeClose				:String = "close",
									TypeOpen				:String = "open",
									TypeAdd					:String = "add",
									TypeRemove				:String = "remove";
		
		public	var					loginData				:LoginModel,
									recipientID				:String,
									recipientJID			:UnescapedJID,
									actionType				:String,
									menuButton				:*,
									dynamicItem				:*,
									data					:*,
									dynamicItemTarget		:String,
									userAction				:Boolean = true;
									
									
									
									
								
		public function UserEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		public override function clone():Event {
			var e:UserEvent 	=		new UserEvent(this.type, this.bubbles, this.cancelable);
			e.loginData			=		loginData;
			e.recipientID		=		recipientID;
			e.recipientJID		=		recipientJID;
			e.actionType		=		actionType;
			e.menuButton		=		menuButton;
			e.dynamicItem		= 		dynamicItem;
			e.data				= 		data;
			e.dynamicItemTarget = 		dynamicItemTarget;
			e.userAction		= 		userAction;
			return e;
		}
	}
}
/*
** MessageEvent.as , package net.gltd.gtms.events **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 20, 2012 
*
*
*/ 
package net.gltd.gtms.events
{
	import flash.events.Event;
	
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.Message;
	
	public class ChatEvent extends Event
	{
		public	static	const	NEW_MESSAGE			:String = "onNewMessage",
								SEND_MESSAGE		:String = "onSendMessage",
								USER_INVITE			:String = "onUserInvite",
								USER_CHANGE_SUBJECT	:String = "onUserChangesubject",
								OPEN_ROOM			:String = "onOpenRoom",
								ROOM_JOIN			:String = "onRoomJoin",
								CHAT_CLOSED			:String = "onChatClosed",
								SEPARATED_WINDOW	:String = "onOpenInSeparatedWindow",
								MOVE_BACK			:String = "onMoveIntoDefaultWindow",
								BROADCAST_MESSAGE	:String = "onBroadcastMessage",
								REMOVE_CHAT			:String = "onRemoveChat",
								RECIVE_NEW_MESSAGE	:String = "onReciveNewMessage",
								CHANGE_MUC_PROPERTY	:String = "onMUCChangeProp",
								JOIN_VIA_MUC		:String = "onJoinViaMuc";
							
									
		
		public			var		message				:Message,
								recipients			:Array,
								jid					:EscapedJID,
								room				:Room,
								obj					:Object,
								inviteMessage		:String = "",
								roomName			:String,
								id					:String,
								newProp				:Object,
								incOffline			:Boolean;
			
		public function ChatEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
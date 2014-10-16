/*
** ContactEvent.as , package net.gltd.gtms.events **  
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
package net.gltd.gtms.events
{
	import net.gltd.gtms.model.contact.BuddyModel;
	import net.gltd.gtms.model.contact.GroupModel;
	
	import flash.events.Event;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	
	public class ContactEvent extends Event
	{
		public static		const	CONTACT_ADDED				:String	=	"onContactAdded",
									CONTACT_UPDATED				:String	=	"onContactUpdated",
									GROUP_ADDED					:String =	"onGroupAdded",
									REMOVE_CONTACT				:String = 	"onRemoveContact",
									PRESENCE_UPDATE				:String =	"onPresenceUpdate",
									SHOW_CHANGED				:String =	"onShowChanged",
									SHOW_INGROUPS				:String =	"onShowInGroups",
									ROSTER_COMPLETE				:String =	"onRosterComplete",
									ADD_ROSTER					:String	=	"onSendSubscriptionRequest",
									DENY						:String =	"onSendSubscriptionDeny",
									ON_SET_BUDDY				:String =	"onSetBuddy",
									ON_CHANGE_GROUP				:String =	"onChangeGroup",
									GROUP_VISIBLE_CHANGE		:String =	"onGroupVisibleChange",
									SUBSCRIBED					:String = 	"onSubscribed";
									
									
		public static		const	GROUP_ACTION_MOVE_TO			:String = "moveTo",
									GROUP_ACTION_COPY_TO			:String = "copyTo",
									GROUP_ACTION_REMOVE_FROM		:String = "removeFrom",
									GROUP_ACTION_CREATE				:String = "createGroup";
									
		
		public				var		id							:String,
									groupId						:uint,
									contact						:BuddyModel,
									gropup						:GroupModel,
									data						:Object,
									
									newGroupName				:String,
									oldGroupName				:String,
									create						:Boolean,
									visible						:Boolean,
									actionType					:String,
									doNotUpdate					:Boolean = false,
									from						:EscapedJID;
									
									
									
		public function ContactEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
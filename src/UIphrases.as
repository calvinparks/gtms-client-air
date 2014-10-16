/*
** UIphrases.as , package **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 21, 2012 
*
*
*/ 

package
{
	public dynamic class UIphrases
	{
		public	static	const	INVITE_EVENT_TITLE				:String = "Accept Chat Invitation ?",
								INVITE_EVENT_MESSAGE			:String	= "{nickname} has invited you to chat room.",
								INVITE_EVENT_BUTTON_ACCEPT		:String = "Accept",
								INVITE_EVENT_BUTTON_DECLINE		:String = "Decline",
								
								IM_EVENT_COME_ONLINE            :String = "has come online: {status}",
								IM_EVENT_COME_OFFLINE           :String = "has gone offline",
								
								IM_MSG_EVENT_BUTTON_READ		:String = "Read",
								
								ROOM_USER_ENTER					:String = "{nickname} entered the room.",
								ROOM_USER_LEFT					:String = "{nickname} left the room.",
								ROOM_USER_BANNED				:String = "{nickname} has been banned.",
								ROOM_USER_KICK					:String = "{nickname} has been kicked.",
								ROOM_USER_CHANGE_SUBJECT		:String = '{nickname} changed the subject to "{subject}"',
								ROOM_PRIVILEGES_CHANGED			:String = '{nickname} has been granted administrator privileges',

								
							
		
		
								WINDOW_PROFILE_TITLE_EDIT		:String = "Edit Profile",
								WINDOW_PROFILE_TITLE_VIEW		:String	= "View {nickname} Profile",
								
								CLOSE_LABEL						:String = "Close",
								SAVE_LABEL						:String = "Save",
								DENY_LABEL						:String = "Deny",
								APPLY_LABEL						:String = "Apply Changes",
								RESET_LABEL						:String = "Reset",
								CANCEL_LABEL					:String = "Cancel",
								REFRESH_LABEL					:String = "Refresh",
								
								ADD_GROUP_INFO					:String = "To create a new Group, click in the fileld above, type a name and press Enter.",
								ADD_ROSTER_LABEL				:String = "Save Contact",
								
								ADD_NEW_GROUP_TITLE				:String = "Add New Group",
								ADD_NEW_GROUP_LABEL				:String = "Group Name:",
								ADD_NEW_GROUP_SAVE_LABEL		:String = "Add",
								
								BROADCAST_WINDOW_TITLE			:String = "Broadcast Message To {groupName}",
								BROADCAST_SEND_LABEL			:String = "Send",
								
								RESTORE_DEFAULT_LABEL			:String = "Restore Default",
								
								OPEN_IN_SEPARATE_WINDINDOW		:String = "Float Chat Window",
								BACK_TO_MAIN_WINDOW				:String = "Anchor Chat Window";
		
		
		public static	function getPhrase(msg:String,keys:Object=null):String  {
			if (keys == null) return msg;
			try {
				for (var ind:String in keys){
					if (msg.indexOf("{"+ind+"}") > -1){
						msg = msg.replace("{"+ind+"}",keys[ind]);
						if (msg.indexOf("{"+ind+"}") > -1){
							var o:Object = {}
							o[ind] = keys[ind]
							msg = getPhrase(msg,o);
						}
					}
				}
			}catch (error:Error){
				trace (error.getStackTrace());
			}
			return msg
			
		}
							
	}
}
/*
** RoomModel.as , package net.gltd.gtms.model.im **  
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
package net.gltd.gtms.model.im
{
	import net.gltd.gtms.controller.muc.MUCInterfaceManager;
	import net.gltd.gtms.events.ArchiveEvent;
	import net.gltd.gtms.model.muc.ChannelModel;
	import net.gltd.gtms.utils.StringUtils;
	
	import flash.events.Event;
	
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.events.RoomEvent;
	
	
	public class RoomModel extends MessageModel
	{
		[Bindable]
		public var	room			:Room;
		
		public var	channel			:ChannelModel;

				 		
		
		public var hasListener	:Boolean = false;
		public function RoomModel(room:Room)
		{
			this.room = room;
			var idS:String = StringUtils.removeChar( room.roomJID.bareJID ,"-");
			super( idS, room.roomJID,"room");
			
			getChannel();
			
		}
		
		private function getChannel():ChannelModel {
			try {
				channel = MUCInterfaceManager.Channels().getItemByID( room.roomJID.bareJID, true ) as ChannelModel;
			}catch (error:Error){
				
			}
			return null;
		}
	/*	public override function get id():String {
			return channel.id;
		}*/
		[Bindable]
		public override function get label():String {
			getChannel();
			if (channel!=null && channel.label) return channel.label;
			//return room.label;
			return room.nickname;
		}
		public override function set label(s:String):void {
			super.label = s;
		}
		public function rejoin(_room:Room):void {
			this.room = _room; 
	 
		}
		public override function contain(searchString:String):Boolean {
			if ( (label+description).toLowerCase().indexOf(searchString) > -1) return true;
			for (var i:uint = 0; i<readed.length;i++){
				if (readed[i].body.toLowerCase().indexOf(searchString) > -1){
					return true
				}
			}
			return false
		}
		
		 
		protected override function get archiveChatIndex():int {
			dispatchEvent(new Event("heightChanged"));
			return (channel.archiveList.length)-(++currentArchiveChat);
		}
		public override function getNewArchiveConversation():void { 
			return
			var index:int = archiveChatIndex; 
			if (index < 0) return;
			archiveStart = channel.archiveList[index].start;
			dispatchEvent(new ArchiveEvent(ArchiveEvent.GET_CONVERSATION,jid.escaped,archiveStart));
		}
		
		 
		[Bindable]
		public override function get archiveBeforeValueHeight():Number {
			if (archiveBeforeValue > 0) _archiveBeforeValueHeight = Math.max( 0,Math.min(120,4*(channel.archiveList.length-currentArchiveChat)) );
			else _archiveBeforeValueHeight = 0;
			return _archiveBeforeValueHeight
		}
		public override function set archiveBeforeValueHeight(n:Number):void {
			_archiveBeforeValueHeight = n;
		}
		
		
	}
}
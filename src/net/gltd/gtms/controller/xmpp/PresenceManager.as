/*
** PresenceManager.as , package net.gltd.gtms.controller.xmpp **  
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
package net.gltd.gtms.controller.xmpp
{
	import net.gltd.gtms.controller.app.SettingsManager;
	import net.gltd.gtms.controller.im.ShowStatusManager;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.ContactEvent;
	import net.gltd.gtms.model.contact.IMBuddyModel;
	import net.gltd.gtms.model.contact.singl.buddiesHolder;
	import net.gltd.gtms.model.dataHolder;
	import net.gltd.gtms.model.im.ShowStatusModel;
	import net.gltd.gtms.view.im.IMStatus;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.events.PresenceEvent;
	
	
	[Event(name="onPresenceUpdate",type="net.gltd.gtms.events.ContactEvent")]
	[Event(name="onSubscribed",type="net.gltd.gtms.events.ContactEvent")]
	[ManagedEvents("onPresenceUpdate,onSubscribed")]
	
	
	public class PresenceManager extends EventDispatcher
	{
		
		
		[Inject][Bindable]
		public 			var				conn					:Connection;
		
		private			var				_show					:String,
										_statusMsg				:String,
										_view					:IMStatus,
										
										_bh						:buddiesHolder,
										_dh						:dataHolder,
										
										_showBeforeIdle			:String,
										_statuBeforeIdle		:String;
		
		
		
		[Init]
		public function init():void { 
		}
		[Observe]
		public function observe(view:IMStatus):void {
			_view = view;
		}
		[MessageHandler (selector="onConnectionSucces")]
		public function connected(event:ConnectionEvent):void {
			//conn.connection.addEventListener(PresenceEvent.PRESENCE,onPresence,false,0,true);
			_dh = dataHolder.getInstance();
			_bh = buddiesHolder.getInstance();
		}
		private function onPresence(event:PresenceEvent):void {
		///	dispatchEvent( new ContactEvent(ContactEvent.PRESENCE_UPDATE));
			var sp:Presence;
			for (var i:uint = 0; i<event.data.length;i++){
				var p:Presence = event.data[i] as Presence;
				if (p.type == Presence.TYPE_UNAVAILABLE){
					try {
						(_bh.getBuddy(p.from.bareJID) as IMBuddyModel).roster.online = false;
					}catch (error:Error){
					}
				}
				if (p.type == Presence.TYPE_SUBSCRIBE){
				
				}
				if (p.type == Presence.TYPE_SUBSCRIBED){
					var e:ContactEvent = new ContactEvent(ContactEvent.SUBSCRIBED);
					e.from = p.from;
					dispatchEvent( e );
					conn.send( new Presence (p.from,null, null, show,status) )
					
				}
			}
			
		}
		[MessageHandler (selector="onDisconnected")]
		public function logout(event:ConnectionEvent):void {
			NativeApplication.nativeApplication.removeEventListener(Event.USER_IDLE,onIdle);
		}
		[MessageHandler (selector="onLoginSuccess")]
		public function login(event:ConnectionEvent):void {
			try {
				NativeApplication.nativeApplication.idleThreshold = SettingsManager.IDLE_TIME_SECONDS;
				FlexGlobals.topLevelApplication.addEventListener("idleChanged",onIdleChanged)
				
				NativeApplication.nativeApplication.addEventListener(Event.USER_IDLE,onIdle);
				conn.connection.addEventListener(PresenceEvent.PRESENCE,onPresence,false,0,true);
			}catch (error:Error ){trace (error.getStackTrace());}
		}
		private function onIdleChanged(event:Event):void {
			NativeApplication.nativeApplication.removeEventListener(Event.USER_IDLE,onIdle);
			NativeApplication.nativeApplication.idleThreshold = SettingsManager.IDLE_TIME_SECONDS;
			NativeApplication.nativeApplication.addEventListener(Event.USER_IDLE,onIdle);
		}
		private function onAppPresence(e:Event):void {
			NativeApplication.nativeApplication.removeEventListener(Event.USER_PRESENT,onAppPresence);
			sendPresence(_showBeforeIdle,_statuBeforeIdle,null);
			_view.setDOstatus( new ShowStatusModel("tmp",null,show,status,false,false) )
		}
		private function onIdle(e:Event):void {
			if (show == null){
				_showBeforeIdle = show;
				_statuBeforeIdle = status;
				
				var mm:ShowStatusModel = ShowStatusManager.getShow("awayduetoidle");
				var s:String = mm.show;
				var m:String = mm.statusMsg;
				sendPresence(s,m,null);
				_view.setDOstatus(mm);
				
				NativeApplication.nativeApplication.addEventListener(Event.USER_PRESENT,onAppPresence);
			}
		}
		public function sendPresence(show:String=null,statusMsg:String=null,type:String=null,sv:Boolean=true):void {
			this.show = show;
			this.status = statusMsg;
			 
			conn.send( new Presence(new EscapedJID(conn.connection.server), new EscapedJID(conn.jid.bareJID), type,show,status) ); 
		}
		public function sendMyPresenceTo (recipient:EscapedJID):void {
			conn.send( new Presence(recipient,conn.connection.jid.escaped,null,show,status) ); 
			//conn.send( new Presence(recipient,conn.jid.escaped,null,null,null) );
		}
		
		public function get show():String {
			return _show;
		}
		public function get status():String{
			return _statusMsg;
		}
		
		public function set show(s:String):void {
			_show = s;
			_dh.myShow = s;
		}
		public function set status(s:String):void{
			_statusMsg = s;
			_dh.myStatus = s;
		}
	}
}
/*
** Connection.as , package net.gltd.gtms.controller.xmpp **  
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
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.model.dataHolder;
	import net.gltd.gtms.model.im.MyProfile;
	import net.gltd.gtms.oauth.GSSAPI;
	import net.gltd.interfaces.IConnection;
	import com.hurlant.crypto.hash.MD5;
	import com.hurlant.crypto.tls.TLSConfig;
	import com.hurlant.crypto.tls.TLSEngine;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.igniterealtime.xiff.auth.Anonymous;
	import org.igniterealtime.xiff.auth.DigestMD5;
	import org.igniterealtime.xiff.auth.External;
	import org.igniterealtime.xiff.auth.Plain;
	import org.igniterealtime.xiff.auth.SASLAuth;
	import org.igniterealtime.xiff.auth.XFacebookPlatform;
	import org.igniterealtime.xiff.auth.XOAuth2;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.core.XMPPTLSConnection;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.data.XMPPStanza;
	import org.igniterealtime.xiff.events.ConnectionSuccessEvent;
	import org.igniterealtime.xiff.events.DisconnectionEvent;
	import org.igniterealtime.xiff.events.LoginEvent;
	import org.igniterealtime.xiff.vcard.VCard;
	
	
	[Event(name="onLoginSuccess",type="net.gltd.gtms.events.ConnectionEvent")]
	[Event(name="onDisconnected",type="net.gltd.gtms.events.ConnectionEvent")]
	[Event(name="onConnectionSucces",type="net.gltd.gtms.events.ConnectionEvent")]
	[Event(name="init",type="flash.events.Event")]
	[ManagedEvents("onLoginSuccess, onDisconnected, onConnectionSucces, init")]
	
	
	public class Connection extends EventDispatcher implements IConnection
	{
		
		public	static	const	CONNECTION_TYPE_HTTP			:String = "http",
								CONNECTION_TYPE_HTTPS			:String = "https",
								CONNECTION_TYPE_MEDIA			:String = "rtmp",
								CONNECTION_TYPE_SOCKET			:String = "socket";
		
		private			var		_conn							:XMPPConnection;
								
		 
		[Inject][Bindable]
		public			var		disco							:DiscoManager;
		
		[Bindable]
		public			var		myProfile						:MyProfile = new MyProfile();
		
		[Init]
		public function preInit():void {
			dataHolder.getInstance().connection = this;
		}
		
		public function init(conn:XMPPConnection):void
		{
		
			
			_conn = conn;
			
			
			_conn.enableSASLMechanism( External.MECHANISM, External );
			_conn.enableSASLMechanism( Plain.MECHANISM, Plain );
			_conn.enableSASLMechanism( XFacebookPlatform.MECHANISM, XFacebookPlatform);
			_conn.enableSASLMechanism(DigestMD5.MECHANISM, DigestMD5);
			_conn.enableSASLMechanism(XOAuth2.MECHANISM, XOAuth2);
		
			
			
			
			
			_conn.disableSASLMechanism("GSSAPI");
			
			_conn.addEventListener(LoginEvent.LOGIN, onLoginHandler,false,0,true);
			_conn.addEventListener(ConnectionSuccessEvent.CONNECT_SUCCESS,onConnectionSucces,false,0,true);
			_conn.addEventListener(DisconnectionEvent.DISCONNECT,onDisconnect,false,0,true);
			
			dispatchEvent( new Event(Event.INIT));
		}
		public function removeConnection():void {
			_conn.removeEventListener(LoginEvent.LOGIN, onLoginHandler);
			_conn.removeEventListener(ConnectionSuccessEvent.CONNECT_SUCCESS,onConnectionSucces);
			_conn.removeEventListener(DisconnectionEvent.DISCONNECT,onDisconnect);
			_conn = null; 
			
		}
		
		public function send(o:XMPPStanza):void {
			_conn.send(o);
		}
		public function get connection():XMPPConnection{
			return _conn;
		}
		public function get jid():UnescapedJID {
			return connection.jid;
		}
		
		
		
		
		
		/// EVENTS
		private function onLoginHandler(e:LoginEvent):void {
			_conn.send( new Presence(null,_conn.jid.escaped,Presence.TYPE_SUBSCRIBED))
			dispatchEvent( new ConnectionEvent(ConnectionEvent.LOGIN_SUCCESS) );
			myProfile.vcard = VCard.getVCard(connection,connection.jid);
			myProfile.jid = connection.jid;
		
		}
		private function onConnectionSucces(e:ConnectionSuccessEvent):void {
			dispatchEvent( new ConnectionEvent(ConnectionEvent.CONNECTION_SCUCCESS) )
		}
		private function onDisconnect(e:DisconnectionEvent):void {
			//removeConnection();
			dispatchEvent( new ConnectionEvent(ConnectionEvent.DISCONNECTED) );
			myProfile.kill();
			
		}
	}
}
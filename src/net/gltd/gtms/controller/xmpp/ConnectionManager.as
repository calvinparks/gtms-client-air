/*
** ConnectionManager.as , package net.gltd.gtms.controller.app **  
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
	import net.gltd.gtms.GUI.UEM.UEM;
	import net.gltd.gtms.controller.app.SettingsManager;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.SoundAlertEvent;
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.model.rules.singl.rulesHolder;
	import net.gltd.gtms.model.xmpp.LoginModel;
	import com.hurlant.crypto.cert.X509CertificateCollection;
	import com.hurlant.crypto.tls.TLSConfig;
	import com.hurlant.crypto.tls.TLSEngine;
	
	import flash.events.DNSResolverEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.dns.AAAARecord;
	import flash.net.dns.ARecord;
	import flash.net.dns.DNSResolver;
	import flash.net.dns.MXRecord;
	import flash.net.dns.SRVRecord;
	import flash.system.Security;
	import flash.utils.Timer;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.auth.SASLAuth;
	import org.igniterealtime.xiff.auth.XOAuth2;
	import org.igniterealtime.xiff.core.XMPPBOSHConnection;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.core.XMPPTLSConnection;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.data.auth.AuthExtension;
	import org.igniterealtime.xiff.events.DisconnectionEvent;
	import org.igniterealtime.xiff.events.IQEvent;
	import org.igniterealtime.xiff.events.IncomingDataEvent;
	import org.igniterealtime.xiff.events.OutgoingDataEvent;
	import org.igniterealtime.xiff.events.XIFFErrorEvent;
	
	[Event(name="onLoginSuccess",type="net.gltd.gtms.events.ConnectionEvent")]
	[Event(name="onLoginError",type="net.gltd.gtms.events.ConnectionEvent")]
	[Event(name="onConnectionTimeout",type="net.gltd.gtms.events.ConnectionEvent")]
	[Event(name="onDisconnected",type="net.gltd.gtms.events.ConnectionEvent")]
	[Event(name="onConnectionSucces",type="net.gltd.gtms.events.ConnectionEvent")]
	[Event(name="onUserLogin",type="net.gltd.gtms.events.UserEvent")]
	[Event(name="onAlertSound",type="net.gltd.gtms.events.SoundAlertEvent")]
	[ManagedEvents("onLoginSuccess,onLoginError, onConnectionTimeout, onDisconnected, onConnectionSucces, onUserLogin, onAlertSound")]
	
	
	
	public class ConnectionManager extends EventDispatcher
	{
	
		
		
		[Inject][Bindable]
		public			var		connection						:Connection;
		[Inject][Bindable]
		public			var		presence						:PresenceManager;
		
		[Bindable]
		public			var		conn							:XMPPConnection;
		
		public			var		connectionType					:String = Connection.CONNECTION_TYPE_SOCKET;
							
								
								
		private			var		timeoutTimer					:Timer,
								keepAliveTimer					:Timer = new Timer(20000),
								userDoLogout					:Boolean,
								reconnectTimer					:Timer,
								streamType						:uint,
								logedIn							:Boolean = false,
								loginData						:LoginModel;
				
		
		
		[Init]
		public function init():void
		{
			setupConnection();
			if (!keepAliveTimer.hasEventListener(TimerEvent.TIMER))keepAliveTimer.addEventListener(TimerEvent.TIMER, checkKeepAlive);
		}
		private var currentType:int;
		private function setupConnection():void {
			switch (SettingsManager.connectionType) {
				case 2:
					conn = new XMPPBOSHConnection();
					break;
				case 1:
					conn = new XMPPTLSConnection();
					var c:TLSConfig = new TLSConfig(TLSEngine.CLIENT);
					
					c.trustSelfSignedCertificates = false;
					c.trustAllCertificates = true;
					c.ignoreCommonNameMismatch = true;
				
					(conn as XMPPTLSConnection).config = c;
					(conn as XMPPTLSConnection).tls = true;
					
					break;
				default:
					conn = new XMPPConnection();
					
			}
			conn.compress = SettingsManager.connectionCompress;
			currentType = SettingsManager.connectionType;
			//connectionType = SettingsManager.connectionType;
			
			
			connection.init(conn);
	 
			
		}
		
		
		[MessageHandler (selector="onUserLogin")]
		public function login(event:UserEvent):void {
			
			//if (currentType!=SettingsManager.connectionType || conn.compress != SettingsManager.connectionCompress)
			setupConnection();
			 
			conn.username 	=	event.loginData.username;
			conn.password 	=	event.loginData.password;
			conn.server		=	event.loginData.server;
			conn.resource	=	event.loginData.profile;
			if (conn.username.indexOf("@") > -1){
				conn.domain = conn.username.split("@")[1];
				conn.username = conn.username.split("@")[0];
			} 
			if (conn.domain == "gmail.com") conn.disableSASLMechanism(XOAuth2.MECHANISM);
			
			conn.port		= 	SettingsManager.connectionPort;
			
			_srvTryCounter  = 0;
	
			connect();
		
		}
		
		private var _srvTryCounter:uint = 0
		private function lookupSRV():void {
			if (_srvTryCounter>0)return
			var r:DNSResolver = new DNSResolver();
			r.addEventListener(DNSResolverEvent.LOOKUP,onResolveDNS)
			r.addEventListener(ErrorEvent.ERROR,onDNSError);
			r.lookup("_xmpp-server._tcp."+conn.server,SRVRecord);
			_srvTryCounter++;

		}
		
		private function onDNSError(event:ErrorEvent):void {
			loginErrorHandler( event.text );
		}
		
		private function onResolveDNS(event:DNSResolverEvent):void {
			conn.server	= event.resourceRecords[0].target;
			connect();
			
		}
		[MessageHandler (selector="onUserLogout")]
		public function logout(event:UserEvent):void {
			presence.sendPresence(null,null,Presence.TYPE_UNAVAILABLE);
			userDoLogout = true;
			conn.disconnect();
			
		}
		private function connect():void {
			this.streamType = streamType;
			
			//Security.loadPolicyFile("xmlsocket://" + conn.server + ":" + 5229);
		
			
			conn.addEventListener(IncomingDataEvent.INCOMING_DATA,onIncomingData,false,0,true);
			conn.addEventListener(OutgoingDataEvent.OUTGOING_DATA,onOutgoingData,false,0,true);
			conn.addEventListener(XIFFErrorEvent.XIFF_ERROR,xiffErrorHandler,false,0,true);

			if (timeoutTimer != null && timeoutTimer.running){
				timeoutTimer.stop();
				timeoutTimer.removeEventListener(TimerEvent.TIMER,onTimesout);
			}
			timeoutTimer = new Timer(20000);
			timeoutTimer.addEventListener(TimerEvent.TIMER,onTimesout)
			timeoutTimer.start();
			
			conn.connect();
			
			loginData = new LoginModel(conn.username, conn.password, conn.server, conn.resource)
	
			
		}
		
		private function checkKeepAlive(e:TimerEvent):void {
			if (conn.loggedIn)conn.sendKeepAlive()
		}
		
		private function onTimesout(e:TimerEvent):void {
			timeoutTimer.removeEventListener(TimerEvent.TIMER,onTimesout)
			loginErrorHandler("Connection timeout");
		}
		
		[MessageHandler (selector="onConnectionSucces")]
		public function onConnectionSucces(event:ConnectionEvent):void {

			
		}
		
		[MessageHandler (selector="onDisconnected")]
		public function onDisconnect(event:ConnectionEvent):void {
			conn.removeEventListener(IncomingDataEvent.INCOMING_DATA,onIncomingData);
			conn.removeEventListener(OutgoingDataEvent.OUTGOING_DATA,onOutgoingData);
			conn.removeEventListener(XIFFErrorEvent.XIFF_ERROR,xiffErrorHandler);
			keepAliveTimer.stop();
			if (!userDoLogout && logedIn){
				reconnectTimer = new Timer(SettingsManager.RECONNECT_TIME);
				reconnectTimer.addEventListener(TimerEvent.TIMER,onReconect);
				reconnectTimer.start();
			}
			connection.removeConnection()
			init();
			userDoLogout = false;	
			logedIn = false;
		}
		
		[MessageHandler (selector="onLoginSuccess")]
		public function onLoginHandler(event:ConnectionEvent):void {
			keepAliveTimer.start();
			timeoutTimer.stop();
			userDoLogout = false;
			logedIn = true
			if (reconnectTimer!=null && reconnectTimer.running)reconnectTimer.stop();
			rulesHolder.getInstance().addSubsystemToRule(Main.RULE.value,conn.domain,conn.domain);
		}
		
		private function onIncomingData(e:IncomingDataEvent):void {
			try {
				var fn:XMLNode = new XMLDocument(e.data.toString() ).firstChild;
				if (fn.attributes.type == IQ.TYPE_ERROR){
					if ( (fn.attributes.id as String).indexOf("add_user") == 0){
						if(SettingsManager.ALLERTS["notificationError"].popup == true){
							var title:String = "System Error";
							var body:String = "Sorry, you are not allowed to contact this user."
							UEM.newUEM("Errormessage",title,body,null,null,SettingsManager.ALLERTS["notificationError"].time)
						}
						if ( SettingsManager.ALLERTS["notificationError"].sound == true){
							dispatchSound()
						}
					}
				}
			}catch (error:Error){}
		
		}
		private function onOutgoingData(e:OutgoingDataEvent):void {
			/*try {
				trace ("\n>> out", e.data.toString() );
			}catch (error:Error){
			
			}*/
		}
		
		private function onReconect(event:TimerEvent):void {
			var ue:UserEvent = new UserEvent(UserEvent.USER_LOGIN);
			ue.loginData = loginData;
			dispatchEvent(ue);
		}

		private function xiffErrorHandler(error:XIFFErrorEvent):void {
		
			if (error.errorCode == 0 && error.errorCondition == "service-unavailable"){
				conn.disconnect();
				timeoutTimer.stop()
				lookupSRV();
				return
			}
		
			if ((error.errorCode == 401 || error.errorCode == 503) && conn.loggedIn == false){
				var msg:String;
				if (error.errorMessage == null || error.errorMessage.length == 0){
					msg = error.errorCondition;
				}else {
					msg = error.errorMessage;
				}
				loginErrorHandler(msg);
				timeoutTimer.stop()
				return
			}
			if (error.errorCode == 503)return;
			if(SettingsManager.ALLERTS["notificationError"].popup == true){
				var title:String = "System Error"+" "+error.errorCode;
				var body:String = error.errorMessage; 
			
				UEM.newUEM("Errormessage"+error.errorCode.toString(),title,body,null,null,SettingsManager.ALLERTS["notificationError"].time)
			}
			if ( SettingsManager.ALLERTS["notificationError"].sound == true){
				dispatchSound()
			}
		}
		public function dispatchSound():void {
			dispatchEvent(new SoundAlertEvent(SoundAlertEvent.ALERT_SOUND))
		}
		
		private function loginErrorHandler(msg:String):void {
			var evt:ConnectionEvent = new ConnectionEvent(ConnectionEvent.LOGIN_ERROR);
			evt.errorMessage = msg;
			dispatchEvent(evt);
		}	
	}
}
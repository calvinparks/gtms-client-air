/*
** LoginManager.as , package net.gltd.gtms.controller.app **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.1 
*	 Created: Jun 11, 2012 
*
*
*/ 
package net.gltd.gtms.controller.im
{
	import net.gltd.gtms.controller.app.ApplicationManager;
	import net.gltd.gtms.controller.xmpp.ConnectionManager;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.model.xmpp.LoginModel;
	
	import flash.data.EncryptedLocalStore;
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modules.Login_module;
	
	import mx.collections.ArrayCollection;
	
	
	[Event(name="onUserLogin",type="net.gltd.gtms.events.UserEvent")]
	[ManagedEvents("onUserLogin")]
	
	
	public class LoginManager extends EventDispatcher
	{

		public const	userName		:String	="User Name:", 
						password		:String	="Password:",
						server			:String	="Server Addres:",
						profile			:String	="Profile",
						loginButton		:String	="Login",
						remember		:String	="Remember Me",
						autoSing		:String	="Sign Me in automatically",
						autoOpen		:String	="Open at login";
		
		[Bindable]
		public var profiles:ArrayCollection = new ArrayCollection([
			"office","mobile"
		]);
		[Bindable]public	var _loginMessage	:String	 = "";
		
		[Bindable]public	var _user			:String	 = "";
		[Bindable]public	var _pass			:String	 = "";
		[Bindable]public	var _server			:String	 = "";
		[Bindable]public	var _profile		:String	 = profiles.source[0];
		[Bindable]public	var _autoSign		:Boolean = false;
		[Bindable]public	var _autoOpen		:Boolean = false;
		[Bindable]public	var _rememberMe		:Boolean = false;
		
		
		[Bindable]public	var _inProgress		:Boolean = false;
		
		
		private				var loginForm		:Login_module;	
		
		
		private				var autoLoginTO		:uint;
		
		
		[Bindable][Inject]
		public var connection:ConnectionManager;
		
		public function login():void {
			clearTimeout(autoLoginTO);
			if (_inProgress)return;
			if (_user.length == 0 || _pass.length == 0 || _server.length < 2){
				return;
			}
			_loginMessage = "";
			_inProgress = true;
			
			var loginEvent:UserEvent = new UserEvent(UserEvent.USER_LOGIN);
			loginEvent.loginData = new LoginModel(_user,_pass,_server,_profile)
			dispatchEvent(loginEvent);
		
			ApplicationManager._FIRST_RUN = false;
			if (_rememberMe)saveFields();
		}
	
		[MessageHandler (selector="onLoginError")]
		public function onLoginError(event:ConnectionEvent):void {
			_inProgress = false;
			_loginMessage = event.errorMessage;
		}
		[MessageHandler (selector="onDisconnected")]
		public function onDisconnected(event:ConnectionEvent):void {
			_inProgress = false;
		}
		
		private function saveFields():void {
			try {
				var userbytes:ByteArray = new ByteArray();
				userbytes.writeUTFBytes(_user);
				EncryptedLocalStore.setItem("username", userbytes);
				
				var passbytes:ByteArray = new ByteArray();
				passbytes.writeUTFBytes(_pass);
				EncryptedLocalStore.setItem("password", passbytes);
				
				var domainbytes:ByteArray = new ByteArray();
				domainbytes.writeUTFBytes(_server);
				EncryptedLocalStore.setItem("server", domainbytes);
				
				var profilebytes:ByteArray = new ByteArray();
				profilebytes.writeUTFBytes(_profile);
				EncryptedLocalStore.setItem("profile", profilebytes);
				
				var autobytes:ByteArray = new ByteArray();
				autobytes.writeBoolean(_autoSign);
				EncryptedLocalStore.setItem("autoSign", autobytes);
				
				var startbytes:ByteArray = new ByteArray();
				startbytes.writeBoolean(_autoOpen);
				EncryptedLocalStore.setItem("autoOpen", startbytes);
				
				var rememberbytes:ByteArray = new ByteArray();
				rememberbytes.writeBoolean(_rememberMe);
				EncryptedLocalStore.setItem("rememberMe", rememberbytes);
				
				NativeApplication.nativeApplication.startAtLogin = _autoOpen;
			}catch(error:Error){
				MLog.Log(error.getStackTrace());
			}
				
		 
		}
		[Observe]
		public function observe(view:Login_module):void {
			loginForm = view;
			if (_autoSign && ApplicationManager._FIRST_RUN) autoLoginTO = setTimeout(login,2000);
		}
		[Init]
		public function init():void {
			
		}
		public function LoginManager(target:IEventDispatcher=null)
		{
			
			var _tmp:ByteArray
			if (EncryptedLocalStore.getItem("username")) {
				_tmp = EncryptedLocalStore.getItem("username");
				_user = _tmp.readUTFBytes(_tmp.length);
			}
			if (EncryptedLocalStore.getItem("password")) {
				_tmp = EncryptedLocalStore.getItem("password");
				_pass = _tmp.readUTFBytes(_tmp.length);
			}
			if (EncryptedLocalStore.getItem("server")) {
				_tmp = EncryptedLocalStore.getItem("server");
				_server = _tmp.readUTFBytes(_tmp.length);
			}
			if (EncryptedLocalStore.getItem("profile")) {
				_tmp = EncryptedLocalStore.getItem("profile");
				_profile = _tmp.readUTFBytes(_tmp.length);
			}
			if (EncryptedLocalStore.getItem("autoSign")) {
				_tmp = EncryptedLocalStore.getItem("autoSign");
				_autoSign = _tmp.readBoolean();
			}
			if (EncryptedLocalStore.getItem("autoOpen")) {
				_tmp = EncryptedLocalStore.getItem("autoOpen");
				_autoOpen = _tmp.readBoolean();
			}
			if (EncryptedLocalStore.getItem("rememberMe")) {
				_tmp = EncryptedLocalStore.getItem("rememberMe");
				_rememberMe = _tmp.readBoolean();
			}
		}
	}
}
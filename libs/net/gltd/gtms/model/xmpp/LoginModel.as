/*
** LoginModel.as , package net.gltd.gtms.model.xmpp **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 14, 2012 
*
*
*/ 
package net.gltd.gtms.model.xmpp
{
	public class LoginModel
	{
		
		private var 	_username	:String,
						_pass		:String,
						_server		:String,
						_profile	:String;
		
		public function LoginModel(_username:String,_pass:String,_server:String,_profile:String)
		{
			this._username 	= _username;
			this._pass		= _pass;
			this._server	= _server;
			this._profile	= _profile;
		}
		public function get username():String {
			var tmp:String = _username;
			_username = null;
			return tmp;
		}
		public function get password():String {
			var tmp:String = _pass;
			_pass = null;
			return tmp;
		}
		public function get server():String {
			var tmp:String = _server;
			_server = null;
			return tmp;
		}
		public function get profile():String {
			var tmp:String = _profile;
			_profile = null;
			return tmp;
		}
	}
}
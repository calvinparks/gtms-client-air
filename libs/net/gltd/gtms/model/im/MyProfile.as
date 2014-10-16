package net.gltd.gtms.model.im
{
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.events.VCardEvent;
	import org.igniterealtime.xiff.vcard.VCard;

	public class MyProfile
	{
		
		private			var		_avatar			:AvatarModel = new AvatarModel(),
								_vcard			:VCard,
								_jid			:UnescapedJID,
								_bareJID		:String;
								
		public function MyProfile()
		{
		}
		public function kill():void {
			_vcard = null;
			avatar.kill()
		}
		
		
		public function set vcard(vc:VCard):void {
			_vcard = vc;
			_vcard.addEventListener(VCardEvent.LOADED,onLoaded)
		}
		
		[Bindable]
		public function get vcard():VCard {
			return _vcard;
		}
		
		public function set avatar(a:AvatarModel):void {
			_avatar = a;
		}
		
		[Bindable]
		public function get avatar():AvatarModel {
			return _avatar;
		}
		
		public function set jid(a:UnescapedJID):void {
			_jid = a;
			bareJID = _jid.bareJID
		}
		
		[Bindable]
		public function get jid():UnescapedJID {
			return _jid;
		}
		
		public function set bareJID(a:String):void {
			_bareJID = a;
		}
		
		[Bindable]
		public function get bareJID():String {
			return _bareJID;
		}
		
		private function onLoaded(event:VCardEvent):void {
			try {
				if (vcard.photo != null){
					_avatar.add(vcard.photo.bytes);
				}
			}catch (error:Error){
				
			}
		}
	}
	
}
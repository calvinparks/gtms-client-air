package net.gltd.gtms.utils
{
	
	import net.gltd.gtms.model.contact.BuddyModel;
	import net.gltd.gtms.model.contact.singl.buddiesHolder;
	
	import org.igniterealtime.xiff.vcard.VCard;

	public class FindNumber
	{
		public function FindNumber()
		{
			
		}
		
		public static function findRosterNumber(rJID:String):String {
			
			var nbd:BuddyModel = buddiesHolder.getInstance().getBuddy(rJID);
		
		
			var num:String;
			var numbs:Object;
			if (nbd.hasOwnProperty('phones')){
				numbs = nbd['phones'];
			}else {
				numbs = buildPhones(nbd)
			}
			if (numbs == null)return null
			var isOnline:Boolean = false;
			
			if (nbd.hasOwnProperty('roster')) {
				if (nbd['roster']!=null) isOnline = nbd['roster'].online;
			}
			
			
			if (isOnline){
				num = findNumber(numbs,"voic","work");
				if (!num) num = findNumber(numbs,"voic","");
			}else {
				num = findNumber(numbs,"mobile","work");
				if (!num) num = findNumber(numbs,"mobile","home");
			} 
			if (!num) num = findNumber(numbs,"","");
			return num
			
		}
		public static function buildPhones(bd:BuddyModel):Object {
			if (!bd.hasOwnProperty('vCard')) return null
			bd['phones'] = {};
			var tmp:String;
			if ( (bd['vCard'] as VCard).workTelephone != null ){
				tmp = (bd['vCard'] as VCard).workTelephone.cell;
				if (tmp != null && tmp.length > 0)bd['phones']["c"+tmp] = {phone:tmp ,label: "Work Mobile"}
				tmp = (bd['vCard'] as VCard).workTelephone.voice;
				if (tmp != null && tmp.length > 0)bd['phones']["c"+tmp] = {phone:tmp,label: "Work Voice"}
				tmp = (bd['vCard'] as VCard).workTelephone.msg;
				if (tmp != null && tmp.length > 0)bd['phones']["c"+tmp] = {phone:tmp,label: "Work Msg"}
				tmp = (bd['vCard'] as VCard).workTelephone.fax;
				if (tmp != null && tmp.length > 0)bd['phones']["c"+tmp] = {phone:tmp,label: "Work Fax"}
			}
			if ( (bd['vCard'] as VCard).homeTelephone != null ){
				
				tmp = (bd['vCard'] as VCard).homeTelephone.cell;
				if (tmp != null && tmp.length > 0)bd['phones']["c"+tmp] = {phone:tmp, label: "Home Mobile"}
				tmp = (bd['vCard'] as VCard).homeTelephone.voice;
				if (tmp != null && tmp.length > 0)bd['phones']["c"+tmp] = {phone:tmp, label: "Home Voice"}
				tmp = (bd['vCard'] as VCard).homeTelephone.msg;
				if (tmp != null && tmp.length > 0)bd['phones']["c"+tmp] = {phone:tmp, label: "Home Msg"}
				tmp = (bd['vCard'] as VCard).homeTelephone.fax;
				if (tmp != null && tmp.length > 0)bd['phones']["c"+tmp] = {phone:tmp, label: "Home Fax"}
			}
			return bd['phones'];
		}
		
		
		
		public static function findNumber(numbs:Object,key1:String, key2:String =""):String {
			var p:String;
			for (var i:String in numbs){
				if ((numbs[i].label.toLowerCase().indexOf(key1.toLowerCase()) > -1)&&(numbs[i].label.toLowerCase().indexOf(key2.toLowerCase()) > -1)){
					return numbs[i].phone; 
				}
			}
			return null;
			
		}
		
		
		public static function getNickname(number:String):Object {

			var l:uint = buddiesHolder.getInstance().length;
			
			if (number.indexOf("+") == 0){
				number = number.slice(3,number.length)
			}
			if (number.indexOf("00") == 0){
				number = number.slice(4,number.length)
			}
			if (number.indexOf("0") == 0){
				number = number.slice(1,number.length)
			}
			var who:String;
			var whoJID:String;
			var nbd:BuddyModel;
			var nbh:buddiesHolder = buddiesHolder.getInstance();
			for (var i:uint = 0;i<l;i++){
				nbd = nbh.getBuddy(i);
				var phones:Object
				if (!nbd.hasOwnProperty('phones')) {
					phones = buildPhones(nbd);
				}else {
					phones = nbd.phones;
				}
				if (phones == null) continue;
				
				for (var ind:String in phones){
					if (phones[ind] == undefined)continue;
					
					
					if (number.length < 8){
						if (number == phones[ind].phone){
							who = nbd.nickname;
							whoJID = nbd.id;
							return {nickname:who,bareJID:whoJID}
						}
					}else {	
						if (phones[ind].phone.indexOf(number) > -1){
							who = nbd.nickname;
							whoJID = nbd.id;
							return {nickname:who,bareJID:whoJID}
					}
						
				}

				}
			}
			return null
		}
	}
}
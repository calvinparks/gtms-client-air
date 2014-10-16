package net.gltd.gtms.utils
{
	public final class StringUtils {
		public static function generateRandomString(newLength:uint = 1, userAlphabet:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String{
			var alphabet:Array = userAlphabet.split("");
			var alphabetLength:int = alphabet.length;
			var randomLetters:String = "";
			for (var i:uint = 0; i < newLength; i++){
				randomLetters += alphabet[int(Math.floor(Math.random() * alphabetLength))];
			}
			return randomLetters;
		}
		public static function stripNonNumeric(a:String):String
		{
			var danum:String = "";
			for (var i:int=0; i < a.length ; i++) {
				var p:* = parseInt(a.charAt(i));
				if (!isNaN(p)) {
					danum = danum + a.charAt(i); 
				} 
			}
			return danum;
		}
		public static function stripNumeric(a:String):String 
		{
			var danum:String = "";
			for (var i:int=0; i < a.length ; i++) {
				var p:* = parseInt(a.charAt(i));
				if (isNaN(p)) {
					danum = danum + a.charAt(i); 
				} 
			}
			return danum;
		}	
		public static function removeChar(s:String,ch:String="."):String {
			if (s.indexOf(ch) == -1) return s;
			var a:Array =  s.split(ch);
			var ss:String = "";
			for (var i:uint = 0; i<a.length;i++){
				ss+=a[i];
			}
			return ss;
			
		}
	}
}
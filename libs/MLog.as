package 
{
	import mx.logging.Log;

	public class MLog 
	{
		public static function Log(msg:String,type:String="ERROR"):void {
			try {
				mx.logging.Log.getLogger(type).info("\n "+msg+ "\n");
			}catch (error:Error){
				
			}	
		}
	}
}
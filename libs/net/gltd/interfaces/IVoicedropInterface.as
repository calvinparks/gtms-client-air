package net.gltd.interfaces
{
	import flash.events.IEventDispatcher;

	public interface IVoicedropInterface extends IEventDispatcher
	{
		 function doVoiceDrop(callObject:Object,action:String):void 
		 function manageMessages():void 
		 function displayDropView():void	 
	}
}
package net.gltd.interfaces
{
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.events.MessageEvent;



	public interface IOpenlinkListner
	{
		 function processOpenlinkIQ(iq:IQ):void;
		 function processOpenlinkMessage(msg:Message):void;
		
	}
}
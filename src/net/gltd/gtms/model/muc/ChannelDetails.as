package net.gltd.gtms.model.muc
{
	
	import net.gltd.gtms.model.muc.xmlamapper.Fields;
	import net.gltd.gtms.model.muc.xmlamapper.Identity;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	
	[XmlMapping(elementName="query",ignoreUnmappedAttributes="true", ignoreUnmappedChildren="true")]
	public class ChannelDetails extends EventDispatcher
	{
	
		[ChoiceType("net.gltd.gtms.model.muc.xmlamapper.Identity")]
		public var identity:Identity;
		
		[ChoiceType("net.gltd.gtms.model.muc.xmlamapper.Feature")]
		public var feature:Array;
		
		[ChoiceType("net.gltd.gtms.model.muc.xmlamapper.Fields")]
		public var x:Fields;
		
		public function ChannelDetails(target:IEventDispatcher=null)
		{
			super(target);
		}
		
	
			
	}
}
package net.gltd.gtms.model.muc.xmlamapper
{
	[XmlMapping(elementName="x")]
	public class Fields
	{
		[ChoiceType("net.gltd.gtms.model.muc.xmlamapper.Field")]
		public var field:Array;
		
		[Attribute("type")]
		public var type:String;
		
		public function Fields()
		{
			
		}
		
		
	}
}
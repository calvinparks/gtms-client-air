package net.gltd.gtms.model.rules
{
	import net.gltd.gtms.model.rules.singl.rulesHolder;
	import net.gltd.gtms.utils.FilterArrayCollection;
	
	import mx.collections.ArrayCollection;

	public class RuleStystemModel
	{
		private 	var		_label			:String,
							_value			:String,
							_triggerEvents	:ArrayCollection,
							_subsystems		:FilterArrayCollection,
							_parameterType	:FilterArrayCollection = new FilterArrayCollection([
								{label:"Event Variable",value:"eventVariable",id:"eventVariable",fieldKind:"dropDown",dataProvider:new ArrayCollection()},
								//{label:"System Variable",value:"systemVariable", id:"systemVariable", fieldKind:"dropDown",dataProvider:new ArrayCollection()},
								{label:"Lookup",value:"lookup", id:"lookup",fieldKind:"dropDown",dataProvider:new ArrayCollection(),dataProviderFunction:rulesHolder.getInstance().initLookupFields},
								{label:"String",value:"string", id:"string",fieldKind:"input",dataProvider:new ArrayCollection()}]);
							
		public function RuleStystemModel(label:String,value:String)
		{
			this.label = label;
			this.value = value;
		}
		public function get id():String {
			return _value;
		}
		public function get label():String {
			return _label;
		}
		
		public function set label(s:String):void {
			_label = s;	
		}

		public function get value():String {
			return _value;
		}
		
		public function set value(s:String):void {
			_value = s;
		}
		[Bindable]
		public function get triggerEvent():ArrayCollection {
			return _triggerEvents;
		}
		
		public function set triggerEvent(s:ArrayCollection):void {
			if (s==null)_triggerEvents = new ArrayCollection();
			_triggerEvents = s;	
		}
		
		[Bindable]
		public function get subsystems():FilterArrayCollection {
			return _subsystems;
		}
		
		public function set subsystems(s:FilterArrayCollection):void {
			if (s==null)_subsystems = new FilterArrayCollection();
			_subsystems = s;	
		}
		
		[Bindable]
		public function get parameterType():FilterArrayCollection {
			return _parameterType;
		}
		
		public function set parameterType(s:FilterArrayCollection):void {
			if (s==null)_parameterType = new FilterArrayCollection();
			_parameterType = s;	
		}
		
		
		
		
		public function addSubsystem(s:RuleSubsystemModel):void {
			if (_subsystems==null)_subsystems=new FilterArrayCollection();
			_subsystems.addItem( s );
		}
		
		public function addTriggerEvent(e:RuleTriggerEvent):void {
			if (_triggerEvents==null)triggerEvent=new ArrayCollection();
			_triggerEvents.addItem( e );
		}
		
		
	}
}
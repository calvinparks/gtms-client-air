package net.gltd.gtms.model.app
{
	
	import flash.system.System;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.effects.Parallel;
	import mx.events.EffectEvent;
	import mx.events.ModuleEvent;
	import mx.modules.Module;
	
	import spark.components.Group;
	import spark.modules.ModuleLoader;

	public class AppModuleModel
	{
		
		
		private		var		_moduleName			:String,
							_moduleModuleURL	:String,
							
							easeInTime			:Number = .0,
							easeInDelay			:Number = .0,
							
							easeOutTime			:Number = .0,
							easeOutDelay		:Number = .0;
							
		private		var 	effect				:Parallel,
							removeEffect		:Parallel,
							toRemoveModule		:ModuleLoader;
							
							//_module				:ModuleLoader;
							
		public function AppModuleModel(_n:String,_url:String)
		{
			_moduleName = _n;
			_moduleModuleURL = _url;
		}
		public function getModule(ease:Parallel,toRemoveModule:ModuleLoader,removeEase:Parallel):ModuleLoader {
			effect = ease;
			this.toRemoveModule = toRemoveModule;
			this.removeEffect = removeEase;
			var md:ModuleLoader = createModule();
			effect.target = md;
			
			
			return md
		}
		public function unload(_target:ModuleLoader, ease:Parallel) : void {
		//	if (effect != null && effect.isPlaying)effect.stop();
			ease.addEventListener(EffectEvent.EFFECT_END,onEffectEnd,false,0,true);
			ease.addEventListener(EffectEvent.EFFECT_STOP,onEffectEnd,false,0,true);
			ease.play();
			//ease.addEventListener(EffectEvent.EFFECT_END,onEffectEnd)
		
		}
		private function onEffectstart(event:EffectEvent):void {
			
		}
		private function onEffectEnd(event:EffectEvent):void {
			event.currentTarget.removeEventListener(EffectEvent.EFFECT_END,onEffectEnd)
			event.currentTarget.removeEventListener(EffectEvent.EFFECT_STOP,onEffectEnd)
			removeModule(event.currentTarget.target);
			
		}
		public function get moduleName():String {
			return _moduleName;
		}
		private function createModule ():ModuleLoader {
			try {
				var _module:ModuleLoader	= new ModuleLoader();
				_module.percentWidth 		= 100;
				_module.percentHeight		= 100;
				_module.id 					= _moduleName;
				_module.url					= _moduleModuleURL;
				
				_module.addEventListener(ModuleEvent.READY,onModuleReady);
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
			return _module;
		}

		private function onModuleReady(event:ModuleEvent):void {
			try {
				effect.play();
				event.currentTarget.addEventListener(ModuleEvent.UNLOAD,onModulUnloaded);
				event.currentTarget.removeEventListener(ModuleEvent.READY,onModuleReady);
				if (toRemoveModule != null){
					unload(toRemoveModule,removeEffect);
				}
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
			//easeModule(event.currentTarget as ModuleLoader, easeInTime, {x:0,alpha:1, delay:easeInDelay, ease:Expo.easeInOut} )
		}
		private function onModulUnloaded(event:ModuleEvent):void {
			try {
				(event.currentTarget.parent as Group).removeElement(event.currentTarget as ModuleLoader);
				event.currentTarget.removeEventListener(ModuleEvent.UNLOAD,onModulUnloaded);
				toRemoveModule = null;
				
			}catch (err:Error){
				trace (err.getStackTrace());		
			}
		}
		private function removeModule(_target:ModuleLoader):void {
			trace ("---------unloading",_target.name, _target.id);
			trace (_target.hasEventListener(ModuleEvent.READY))
			trace (_target.hasEventListener(ModuleEvent.UNLOAD))
			_target.unloadModule();	
			
		}
		
	}
}
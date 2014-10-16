/**
   VERSION: 1.2
   DATE:3/27/2010
   ACTIONSCRIPT VERSION: 3.0
   @author Marco Di Giuseppe, marco [at] designmarco [dot] com
   @link http://designmarco.com
 */
package com.greensock.plugins
{
	import flash.text.TextField;
	import com.greensock.TweenLite;
	/**
	   DecoderTextPlugin tweens the characters of a TextField giving the appearance of text decoding.

	   @usage
	   import com.greensock.TweenLite;
	   import com.greensock.plugins.TweenPlugin;
	   import com.greensock.plugins.DecoderTextPlugin;

	   TweenPlugin.activate([DecoderTextPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.
	   TweenLite.to(textField, 0.5, {decoder:"Lorem Ipsum"});

	   Greensock Tweening Platform
	   @author Jack Doyle, jack@greensock.com
	   Copyright 2010, GreenSock. All rights reserved. This work is subject to the terms in http://www.greensock.com/terms_of_use.html
	   or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
	 */
	public class DecoderTextPlugin extends TweenPlugin
	{
		public static const API:Number = 1.0;
		protected var target:TextField;
		protected var tween:TweenLite;
		protected var prevTime:Number = 0;
		protected var oldText:String;
		protected var oldLength:int;
		protected var newText:String;
		protected var newLength:int;

		public function DecoderTextPlugin()
		{
			this.propName = "decoder";
			this.overwriteProps = [];
		}

		override public function onInitTween(target:Object, value:*, tween:TweenLite):Boolean
		{
			if (!(target is TextField)) return false;

			this.target = target as TextField;
			this.tween = tween;

			oldText = target.text;
			oldLength = oldText.length + 1;

			newText = String(value);
			newLength = newText.length + 1;

			return true;
		}

		override public function set changeFactor(n:Number):void
		{
			var counter:int, valueA:String, valueB:String;

			if (tween.cachedTime > prevTime)
			{
				counter = int(newLength * n - 1 + 0.5);
				valueA = newText.substr(0, counter);
				valueB = newText.substr(counter);
			}
			else
			{
				counter = int(oldLength * (1 - n) - 1 + 0.5);
				valueA = oldText.substr(0, counter);
				valueB = oldText.substr(counter);
			}

			var decoder:String = "";
			var i:int = valueB.length;
			while (i--)
			{
				decoder += String.fromCharCode(((Math.random() * 26) + 65) >> 0);
			}

			target.text = valueA + decoder;
			prevTime = tween.cachedTime;
		}
	}
}
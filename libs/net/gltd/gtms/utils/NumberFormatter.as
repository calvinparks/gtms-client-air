package net.gltd.gtms.utils
{	
		
		
		import flash.events.*;

        public dynamic class NumberFormatter extends EventDispatcher {
        
			
			 private static var instance : NumberFormatter;
			 private var InterNationalDialPrefix:String  = "00"
			 private var NationalDialPrefix:String  = "0"
			 private var CountryCode:String  = "44"
			 private var PBXAccessDigits:String  = ""
			 private var LocalAreaNumberLength:uint  = 10
			 private var PBXNumberLength:String  = "4"
			
			public function NumberFormatter()
		    {
			    if ( instance != null )
			    {
				   throw new Error("Private constructor. Use getIntance() instead.");
				   return;
			    }
				
		    }
			 public static function getInstance() : NumberFormatter
		    {
			   if ( instance == null )
			   {
				  instance = new NumberFormatter();
				  
			   }
			   return instance;
		    }
			
			
			
			public function stripSpaces(a:String):String  
	        {
	           var danum:String = "";
	           for (var i:int=0; i < a.length ; i++) {
	             if (a.charAt(i) != " ") {
		           danum = danum + a.charAt(i); 
		         }
	           }
	           ////trace("Stripped Number of spaces is "+danum);
	           return danum;
	      
	        }
	      private function stripNonNumeric(a:String):String
	      {
	         var danum:String = "";
	         for (var i:int=0; i < a.length ; i++) {
			   var p:* = parseInt(a.charAt(i));
	           if (!isNaN(p)) {
		         danum = danum + a.charAt(i); 
		       } 
	        }
	        ////trace("Stripped Number is "+danum);
	        return danum;
	      }

	    
	      private function checkLocalNumber (a:*):*
	      {
	         
	         //////trace("Local Area code is: "+ localAreaCode);
	         return a;
	      }
		  public function formatPhoneNumber(phoneNo:*):*
	      {
             if (phoneNo == null || phoneNo == undefined) return null;
             var pNo:* = this.stripSpaces(phoneNo);
             var formattedNo:*;
             var international:Boolean = false;
             var tempNo:*;
			 ////trace("formatTelephoneNo: " + phoneNo);
             if ("+" == pNo.substring(0, 1)) {
               international = true;
	            ////trace('international true');
	            tempNo = pNo;
            }
	        formattedNo = this.stripNonNumeric(pNo) as String;
       
	       if (international) {
              ////trace('number format 1: formatted num is ' +formattedNo+ ' country code is: '+CountryCode); 
              if (CountryCode == formattedNo.substring(0, CountryCode.length)) {
				////trace('number format 2');
                formattedNo = formattedNo.substring(CountryCode.length);
                 ////trace('number format 3');
                if (! (NationalDialPrefix == formattedNo.substring(0, NationalDialPrefix.length))) {
					////trace('number format 4');
                    formattedNo = NationalDialPrefix + formattedNo;
                }
				////trace('number format 5#');	
                formattedNo = PBXAccessDigits + formattedNo;

              } else {
	             var myopenbrack:String = "(";
		         var myclosebrack:String = ")";
	             var leadingbracPosition:int = tempNo.indexOf(myopenbrack);
		         var closingbracPosition:int = tempNo.indexOf(myclosebrack);
				////trace('number format 6');		
				formattedNo = "";
	             for (var i:int=0; i<tempNo.length ; i++) {
		            if (i > leadingbracPosition && i < closingbracPosition) {
		                continue;
		            }
		            formattedNo = formattedNo + tempNo.charAt(i); 
		        }
		        ////trace("Number formmatted is: "+ formattedNo);
		        formattedNo = this.stripNonNumeric(formattedNo);
				////trace('number format 7');
                formattedNo = PBXAccessDigits + InterNationalDialPrefix  + formattedNo;
            }

          } else { // not international, ignore local pbx extensions

             if (formattedNo.length > parseInt(PBXNumberLength)) {

                if (NationalDialPrefix == formattedNo.substring(0, NationalDialPrefix.length)) {
                    formattedNo = PBXAccessDigits + formattedNo; // my nation

                } else { // assume internal
/*
                    if (CountryCode == formattedNo.substring(0, CountryCode.length)) {
                        formattedNo = formattedNo.substring(CountryCode.length);

                        if (! NationalDialPrefix == formattedNo.substring(0, NationalDialPrefix.length)) {
                            formattedNo = NationalDialPrefix + formattedNo;
                        }

                        formattedNo = PBXAccessDigits + formattedNo;

                    } else {
                        formattedNo = PBXAccessDigits + InterNationalDialPrefix  + formattedNo;
                    }
*/
            }
         }

        }
        //////trace("Formatted Number is "+formattedNo);
        return formattedNo;
        
	  }
	  
	  public function setLocale(profileObj:*):void
      {
		 
			if (profileObj.nationaldialprefix) NationalDialPrefix = profileObj.nationaldialprefix ;
			if (profileObj.internationaldialprefix )InterNationalDialPrefix = profileObj.internationaldialprefix;
			if (profileObj.countrycode) CountryCode = profileObj.countrycode;
			if (profileObj.pbxaccessdigits) PBXAccessDigits = profileObj.pbxaccessdigits ;
			if (profileObj.pbxnumberlength) PBXNumberLength = profileObj.pbxnumberlength;
			
      }	  
   
	  

		
   }		

}		

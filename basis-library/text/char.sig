signature CHAR_GLOBAL =
   sig
      eqtype char

      val ord: char -> int 
      val chr: int -> char 
   end

signature CHAR =
   sig
      include CHAR_GLOBAL

      eqtype string

      val minChar: char 
      val maxChar: char 
      val maxOrd: int 
      val succ: char -> char 
      val pred: char -> char 
      val < : char * char -> bool 
      val <= : char * char -> bool 
      val > : char * char -> bool 
      val >= : char * char -> bool 
      val compare: char * char -> order 
      val contains: string -> char -> bool 
      val notContains: string -> char -> bool 
      val toLower: char -> char 
      val toUpper: char -> char 
      val isAscii: char -> bool 
      val isAlpha: char -> bool 
      val isAlphaNum: char -> bool 
      val isCntrl: char -> bool 
      val isDigit: char -> bool 
      val isGraph: char -> bool 
      val isHexDigit: char -> bool 
      val isLower: char -> bool 
      val isUpper: char -> bool 
      val isPrint: char -> bool 
      val isPunct: char -> bool 
      val isSpace: char -> bool 
      val fromString: string -> char option 
      val scan: (char, 'a) StringCvt.reader -> (char, 'a) StringCvt.reader
      val toString: char -> string 
      val fromCString: string -> char option
      val toCString: char -> string
   end

signature CHAR_EXTRA =
   sig
      include CHAR

      val formatSequences: (char, 'a) StringCvt.reader -> 'a -> 'a
      val scanC: (char, 'a) StringCvt.reader -> (char, 'a) StringCvt.reader
   end

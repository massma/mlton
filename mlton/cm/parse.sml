(* Based on the file entity/description.sml in the cm sources.
 * Heavily modified by sweeks@acm.org 2000-8-22.
 *)
(*
 * entity/description.sml: Entity description file parser.
 *
 *   Copyright (c) 1995 by AT&T Bell Laboratories
 *
 * author: Matthias Blume (blume@cs.princeton.edu)
 *)
structure Parse: PARSE =
struct

val fail = Process.fail

structure Lexer = CMLexer

datatype result =
   Alias of File.t
 | Bad of string
 | CanNotRead
 | Members of File.t list
   
(* The main read function for CM entities. *)
fun parse {cmfile: string} =
   if not (File.canRead cmfile)
      then CanNotRead
   else
      DynamicWind.withEscape
      (fn escape =>
       let
	  fun bad m = (escape (Bad m); raise Fail "impossible")
       in
	  File.withIn
	  (cmfile, fn ins =>
	   let
	      fun no _ = false
	      val lex =
		 Lexer.lexer {strdef = no,
			      sigdef = no,
			      fctdef = no,
			      fsigdef = no,
			      symval = fn _ => NONE}
		 (cmfile, ins)
	      val lookahead: Lexer.token list ref = ref []
	      fun normal () =
		 case !lookahead of
		    [] => lex Lexer.NORMAL
		  | h :: t => (lookahead := t; h)
	      fun member () =
		 case !lookahead of
		    [] => lex Lexer.MEMBERS
		  | h :: t => (lookahead := t; h)
	      fun unget t = lookahead := (t :: (!lookahead))
	      fun readExport () =
		 let
		    fun name () =
		       (case normal () of
			   Lexer.T_SYMBOL s => ()
			 | Lexer.T_STRING s => ()
			 | _ => bad "missing exported name"
			      ; SOME ())
		 in case normal () of
		    Lexer.T_KEYWORD Lexer.K_SIGNATURE => name ()
		  | Lexer.T_KEYWORD Lexer.K_STRUCTURE => name ()
		  | Lexer.T_KEYWORD Lexer.K_FUNCTOR => name ()
		  | Lexer.T_KEYWORD Lexer.K_FUNSIG => name ()
		  | x => (unget x; NONE)
		 end
	      fun readList readItem =
		 let
		    fun loop ac =
		       case readItem () of
			  NONE => rev ac
			| SOME i => loop (i :: ac)
		 in loop []
		 end
	      fun getFileName () =
		 case member () of
		    Lexer.T_SYMBOL name => SOME name
		  | Lexer.T_STRING name => SOME name
		  | t => (unget t; NONE)
	      fun readMember () =
		 case getFileName () of
		    NONE => NONE
		  | SOME f =>
		       (case member () of
			   Lexer.T_COLON =>
			      (case member () of
				  Lexer.T_SYMBOL class => ()
				| Lexer.T_STRING class => ()
				| _ => bad "missing class name")
			 | t => unget t
			      ; SOME f)
	      fun readMembers () =
		 case normal () of
		    Lexer.T_KEYWORD Lexer.K_IS =>
		       (if !lookahead <> [] then fail "Bug in parser" else ()
			   ; readList readMember)
		  | _ => bad "missing keyword 'is'"
	      fun parseAlias () =
		 case getFileName () of
		    NONE => bad "alias name missing"
		  | SOME f => let val _ = In.close ins
			      in Alias f
			      end
	      fun parseGroup () =
		 let
		    val _ = readList readExport
		    val members = readMembers ()
		    val _ = In.close ins
		 in Members members
		 end
	   in case normal () of
	      Lexer.T_KEYWORD Lexer.K_GROUP => parseGroup ()
	    | Lexer.T_KEYWORD Lexer.K_LIBRARY => parseGroup ()
	    | Lexer.T_KEYWORD Lexer.K_ALIAS => parseAlias ()
	    | _ => bad "expected 'group' or 'library'"
	   end)
       end)
 
end

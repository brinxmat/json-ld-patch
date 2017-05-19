grammar LDPatch;
/** based partially on https://github.com/antlr/grammars-v4/blob/master/json/JSON.g4 **/
@lexer::header {
    package no.deichman.ldpatchjson.parser;
}

@parser::header {
    package no.deichman.ldpatchjson.parser;
    import no.deichman.ldpatchjson.parser.Patch;
}

parseJSON     : patch EOF ;

patch         : statement | statementList ;
statementList : '[' statement ( SEP statement )* ']';
statement     : '{' declaration '}' ;

declaration : op_jobj SEP s_jobj SEP p_jobj SEP o_jobj
               | op_jobj SEP s_jobj SEP o_jobj SEP p_jobj  
               | op_jobj SEP p_jobj SEP s_jobj SEP o_jobj  
               | op_jobj SEP p_jobj SEP o_jobj SEP s_jobj
               | op_jobj SEP o_jobj SEP s_jobj SEP p_jobj  
               | op_jobj SEP o_jobj SEP p_jobj SEP s_jobj  
               | s_jobj SEP op_jobj SEP p_jobj SEP o_jobj  
               | s_jobj SEP op_jobj SEP o_jobj SEP p_jobj  
               | s_jobj SEP p_jobj SEP op_jobj SEP o_jobj  
               | s_jobj SEP p_jobj SEP o_jobj SEP op_jobj  
               | s_jobj SEP o_jobj SEP op_jobj SEP p_jobj  
               | s_jobj SEP o_jobj SEP p_jobj SEP op_jobj  
               | p_jobj SEP op_jobj SEP s_jobj SEP o_jobj  
               | p_jobj SEP op_jobj SEP o_jobj SEP s_jobj
               | p_jobj SEP s_jobj SEP op_jobj SEP o_jobj 
               | p_jobj SEP s_jobj SEP o_jobj SEP op_jobj 
               | p_jobj SEP o_jobj SEP op_jobj SEP s_jobj
               | p_jobj SEP o_jobj SEP s_jobj SEP op_jobj 
               | o_jobj SEP op_jobj SEP s_jobj SEP p_jobj 
               | o_jobj SEP op_jobj SEP p_jobj SEP s_jobj
               | o_jobj SEP s_jobj SEP op_jobj SEP p_jobj 
               | o_jobj SEP s_jobj SEP p_jobj SEP op_jobj
               | o_jobj SEP p_jobj SEP op_jobj SEP s_jobj
               | o_jobj SEP p_jobj SEP s_jobj SEP op_jobj
               ;

op_jobj : OP ':' OPERATION ;
s_jobj  : S ':' ( JSONURI | BLANKNODE ) ;
p_jobj  : P ':' JSONURI ;
o_jobj  : O ':' ( JSONURI
              | BLANKNODE
              | typedstring
              | langstring )
              ;

jsonuri  : JSONURI ;
typedstring : '{' VALUE ':' STRING SEP TYPE ':' JSONURI '}' ;
langstring : '{' VALUE ':' in1=STRING SEP LANG ':' in2=STRING '}' ;
string : STRING ;
number : NUMBER ;
plainliteral : ( string | number ) ;

VALUE : '"value"' ;
TYPE : '"datatype"' ;
LANG : '"lang"' ;
SEP  : ',' ;
OP   : '"op"' ;
S    : '"s"' ;
P    : '"p"' ;
O    : '"o"' ;

OPERATION : ( ADD | DEL ) ;
BLANKNODE : '"_:' UNQUOTED_STRING '"' ;
JSONURI  : '"' HTTP ( PN_CHARS | '.' | ':' | '/' | '\\' | '#' | '@' | '%' | '&' | UCHAR )+ '"' ;
STRING : '"' UNQUOTED_STRING '"' ;
NUMBER
    :   '-'? INT '.' [0-9]+ EXP?
    |   '-'? INT EXP            
    |   '-'? INT               
    ;

WS : [ \t\r\n]+ -> skip ;
fragment ADD : '"add"' ;
fragment DEL : '"del"' ;
fragment UNQUOTED_STRING : ( ESC | ~["\\] )* ;
fragment ESC :   '\\' ["\\/bfnrt] | UNICODE ;
fragment HTTP     : ('http' 's'? | 'HTTP' 'S'?) '://'  ;
fragment UCHAR    : UNICODE | '\\U' HEX HEX HEX HEX HEX HEX HEX HEX;
fragment PN_CHARS_BASE :   'A'..'Z'
        |   'a'..'z'
        |   '\u00C0'..'\u00D6'
        |   '\u00D8'..'\u00F6'
        |   '\u00F8'..'\u02FF'
        |   '\u0370'..'\u037D'
        |   '\u037F'..'\u1FFF'
        |   '\u200C'..'\u200D'
        |   '\u2070'..'\u218F'
        |   '\u2C00'..'\u2FEF'
        |   '\u3001'..'\uD7FF'
        |   '\uF900'..'\uFDCF'
        |   '\uFDF0'..'\uFFFD'
        ;
fragment PN_CHARS_U    : PN_CHARS_BASE | '_';
fragment PN_CHARS      : PN_CHARS_U | '-' | [0-9] | '\u00B7' | [\u0300-\u036F] | [\u203F-\u2040];
fragment HEX           : [0-9] | [A-F] | [a-f];
fragment UNICODE       : '\\u' HEX HEX HEX HEX ;
fragment INT :   '0' | [1-9] [0-9]* ;
fragment EXP :   [Ee] [+\-]? INT ;


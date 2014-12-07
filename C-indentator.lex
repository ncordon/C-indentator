%{
#include <iostream>
#include <stack>
using namespace std;

string tab = "    ";
int indentation_lv;
stack<int> pointers;
void indent(string text);
void aux(string name);
%}

openp                   \{
closep                  \}
fst_char                [^[:space:]]
ln_chars                [^\n{}]*
args                    [ \t]?\(.*\)[ \t]*
simple_if               if{ln_chars}
simple_else             else{ln_chars}
simple_for              for{ln_chars}
simple_wh               while{ln_chars}
simple_block            {simple_else}|{simple_if}|{simple_for}|{simple_wh}
codeln                  {fst_char}{ln_chars};
ln_comment              \/\/[^\n]*
block_start             {fst_char}{ln_chars}{openp}{ln_chars}
block_end               {closep};?
%START          LINE_INDENT      ADJUST_INDENT          ELSE
%%

{block_start}           { indent(yytext); indentation_lv++; }
{block_end}             { indentation_lv--; indent(yytext); }
{simple_else}
{simple_wh}
{simple_if}             { indent(yytext); pointers.push(indentation_lv);
                          indentation_lv++; BEGIN LINE_INDENT; BEGIN ELSE;}
{ln_comment}            { indent(yytext); }
<LINE_INDENT>{codeln}   { indent(yytext); indentation_lv--; BEGIN 0; }
{codeln}                { indent(yytext); }
\n                      { cout << endl; }

%%   

void aux(string name){
    cout << endl << name << " ";
    cout << "Se va a indentar a " << indentation_lv << " tabulaciones:" << endl;
}

void indent(string text){
    for(int i=0; i< indentation_lv; ++i){
        cout << tab;
    }
    cout << text;
}


int main (int argc, char *argv[]){   
    indentation_lv = 0;
    
    if (argc == 2){     
        yyin = fopen (argv[1], "rt");     
    
        if (yyin == NULL){       
            printf ("El fichero %s no se puede abrir\n", argv[1]);       
            exit (-1);     
        }
        yylex (); 
    }   
    else{
        cerr << "Uso del programa: " << argv[0] << " " << "Nombre de fichero" << endl;
        exit(-1);
    }
    
    return 0; 
}



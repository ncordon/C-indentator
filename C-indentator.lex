%{
#include <iostream>
#include <stack>
#include <vector>
using namespace std;

string tab = "    ";
stack<int> indentation_lv;
stack<int> if_indentation;
void indent(string text,int tope = indentation_lv.top());
void aux(string name);
%}

openp                   \{
closep                  \}
fst_char                [^[:space:]]
ln_chars                [^\n{}]*
args                    [ \t]?\(.*\)[ \t]*
simple_if               if{ln_chars}
simple_else             else{ln_chars}
simple_elif             else" "if{ln_chars}
simple_for              for{ln_chars}
simple_wh               while{ln_chars}
simple_block            {simple_else}|{simple_if}|{simple_for}|{simple_wh}
codeln                  {fst_char}{ln_chars};
ln_comment              \/\/[^\n]*
if                      {simple_if}{openp}{ln_chars}
else                    {simple_else}{openp}{ln_chars}
elif                    {simple_elif}{openp}{ln_chars}
block_start             {fst_char}{ln_chars}{openp}{ln_chars}
block_end               {closep}{ln_chars};?
%START          LINE_INDENT      ADJUST_INDENT          ELSE
%%

{if}                    { indent(yytext); 
                          if_indentation.push(indentation_lv.top());
                          indentation_lv.push(indentation_lv.top() + 1); }
{elif}                  { indent(yytext,if_indentation.top());
                          indentation_lv.push(if_indentation.top() + 1); }
{else}                  { indent(yytext,if_indentation.top()); 
                          if_indentation.pop();
                          indentation_lv.push(indentation_lv.top() + 1); }
{block_start}           { indent(yytext); indentation_lv.push(indentation_lv.top() + 1); }
{block_end}             { indentation_lv.pop(); indent(yytext); }
{ln_comment}            |
{codeln}                { indent(yytext); }
\n                      { cout << endl; }
.                       {}

%%   

void aux(string name){
    cout << name << " ";
    cout << "Se va a indentar a " << indentation_lv.top() << " tabulaciones:" << endl;
}

void indent(string text,int tope){
    for(int i=0; i< tope; ++i){
        cout << tab;
    }
    cout << text;
}


int main (int argc, char *argv[]){   
    indentation_lv.push(0);
    
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



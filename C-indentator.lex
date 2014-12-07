%{
#include <iostream>
#include <stack>
#include <vector>
using namespace std;

// Carácter de tabulación
string tab = "    ";

stack<int> indentation_lv;
stack<int> if_indentation;

bool one_line_block;

void indent(string text,int tope = indentation_lv.top());
void aux(string name);
%}

openp                   \{
closep                  \}
fst_char                [^[:space:]]
ln_chars                [^\n{}]*
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
vector_ln               {ln_chars}{openp}{ln_chars}{closep}{ln_chars}
%%

{vector_ln}             { indent(yytext); }
{simple_wh}             { indent(yytext); 
                          indentation_lv.push(indentation_lv.top() + 1);
                          one_line_block = true; }
{simple_if}             { if_indentation.push(indentation_lv.top());
                          indent(yytext); 
                          indentation_lv.push(if_indentation.top() + 1);
                          one_line_block = true; }
{simple_elif}           { indent(yytext,if_indentation.top());
                          indentation_lv.push(if_indentation.top() + 1);
                          one_line_block = true; }
{simple_else}           { indentation_lv.push(if_indentation.top() + 1);
                          indent(yytext,if_indentation.top()); 
                          if_indentation.pop();
                          one_line_block = true; }                          
{if}                    { if_indentation.push(indentation_lv.top());
                          indent(yytext); 
                          indentation_lv.push(if_indentation.top() + 1); }
{elif}                  { indent(yytext,if_indentation.top());
                          indentation_lv.push(if_indentation.top() + 1); }
{else}                  { indentation_lv.push(if_indentation.top() + 1); 
                          indent(yytext,if_indentation.top()); 
                          if_indentation.pop(); }
{block_start}           { indent(yytext); 
                          indentation_lv.push(indentation_lv.top() + 1); }
{block_end}             { indent(yytext,indentation_lv.top()-1); 
                          indentation_lv.pop();
                        }
{ln_comment}            |
{codeln}                { indent(yytext); }
\n                      { cout << endl; }
[[:graph:]]*            { indent(yytext); }
.                       {}

%%   

void aux(string name){
    cout << name << " ";
    cout << "Se va a indentar a " << indentation_lv.top() << " tabulaciones:" << endl;
}

void indent(string text,int tope){   
    if (one_line_block){
        one_line_block = false;
        indentation_lv.pop();
    }
    
    for(int i=0; i< tope; ++i){
        cout << tab;
    }
    cout << text;
}


int main (int argc, char *argv[]){   
    indentation_lv.push(0);
    one_line_block = false;
    
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



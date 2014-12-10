%{
#include <iostream>
#include <fstream>
#include <stack>
using namespace std;

// Carácter de tabulación
string tab = "    ";

// Clase wrapper de pila
class Stack{
private:
    stack<int> pila;
public:    
    int top(){
        if (!pila.empty())
            return pila.top();
        else
            return 0;
    }
    void pop(){
        if (!pila.empty())
            pila.pop();
    }
    void push(int n){
        pila.push(n);
    }
};
// Pila con el nivel de indentación en cada momento
Stack indentation_lv;
// El tope de esta pila indica el nivel de indentación que se aplicó al último if, o else if
Stack if_indentation;
// Pila que lleva una copia de seguridad del nivel de indentación antes de indentar un bloque
Stack backup_indentation;

// Indica si se está indentando un bloque(if,else,for,...) de una única linea
bool one_line_block;

/* 
Función de indentación
    Indenta la línea 'text' a 'nindent' sangrías
*/
void indent(string text,int nindent= indentation_lv.top());

/*
Permite buscar la primera ocurrencia de 'c' en text
*/
int look_for(string text, char c);
%}

openp                   \{
closep                  \}
fst_char                [^[:space:]{}]
ln_chars                [^\n{}]*
simple_if               if{ln_chars}
simple_else             else{ln_chars}
simple_elif             else" "if{ln_chars}
simple_for              for{ln_chars}
simple_wh               while{ln_chars}
simple_block            {simple_else}|{simple_if}|{simple_for}|{simple_wh}
codeln                  {fst_char}{ln_chars}
if                      {simple_if}{openp}{ln_chars}
else                    {simple_else}{openp}{ln_chars}
elif                    {simple_elif}{openp}{ln_chars}
block_start             {fst_char}{ln_chars}{openp}{ln_chars}
block_start_ml          {fst_char}{ln_chars}[\n]+{openp}{ln_chars}
block_end               {closep}{ln_chars};?
block_end_ln            {codeln}{closep}{ln_chars};?
block_ln                {fst_char}{ln_chars}{openp}{ln_chars}{closep}{ln_chars}
preproc_ln              \#[^\n]*
public                  public\:
private                 private\:
other_ln                ([[:graph:]][^\n]*)*
%%

{block_ln}              |
{simple_for};           |
{simple_wh};            { indent(yytext); }
{simple_for}            |
{simple_wh}             { indent(yytext); 
                          indentation_lv.push(indentation_lv.top() + 1);
                          one_line_block = true; }
                          
{simple_if};            { if_indentation.push(indentation_lv.top());
                          indent(yytext); }
                          
{simple_if}             { if_indentation.push(indentation_lv.top());
                          indent(yytext); 
                          indentation_lv.push(if_indentation.top() + 1);
                          one_line_block = true; }
                          
{simple_elif};          { indent(yytext,if_indentation.top()); }

{simple_elif}           { indent(yytext,if_indentation.top());
                          indentation_lv.push(if_indentation.top() + 1);
                          one_line_block = true; }
                          
{simple_else};          { indent(yytext,if_indentation.top()); 
                          if_indentation.pop(); }
                          
{simple_else}           { indentation_lv.push(if_indentation.top() + 1);
                          indent(yytext,if_indentation.top()); 
                          if_indentation.pop();
                          one_line_block = true; }
                          
{if}                    { if_indentation.push(indentation_lv.top());
                          indent(yytext); 
                          backup_indentation.push(indentation_lv.top());
                          indentation_lv.push(if_indentation.top() + 1); }
                          
{elif}                  { indent(yytext,if_indentation.top());
                          backup_indentation.push(indentation_lv.top());
                          indentation_lv.push(if_indentation.top() + 1); }
                          
{else}                  { indent(yytext,if_indentation.top()); 
                          backup_indentation.push(indentation_lv.top());
                          indentation_lv.push(if_indentation.top() + 1);
                          if_indentation.pop(); }

{block_start_ml}        { int i = look_for(yytext,'{');
                          indent(string(yytext,0,i-1));
                          indent(string(yytext,i-1,yyleng-i+1));
                          backup_indentation.push(indentation_lv.top());
                          indentation_lv.push(indentation_lv.top() + 1);
                        }
                            
{block_start}           { indent(yytext); 
                          backup_indentation.push(indentation_lv.top());
                          indentation_lv.push(indentation_lv.top() + 1); }
                          
{block_end}             { indent(yytext,indentation_lv.top()-1); 
                          indentation_lv.pop();
                          indentation_lv.pop();
                          indentation_lv.push(backup_indentation.top());
                          backup_indentation.pop();
                        }
                        
{block_end_ln}          { indent(yytext,indentation_lv.top()); 
                          indentation_lv.pop();
                          indentation_lv.pop();
                          indentation_lv.push(backup_indentation.top());
                          backup_indentation.pop();
                        }
{private}               |
{public}                { indent(yytext, indentation_lv.top()-1); }
{codeln};               |
{preproc_ln}            { indent(yytext); }
{other_ln}              { int i = look_for(yytext,'{');
                          int j = look_for(yytext,'}');
                          
                          /* Comprobamos si la cadena son varios } encadenados*/
                          if (i<yyleng || j<yyleng){
                              REJECT;
                          }
                          else{
                              indent(yytext);
                          }
                        }
\n                      { cout << endl; }
.                       {}

%%

void indent(string text,int nindent){   
    if (one_line_block){
        one_line_block = false;
        indentation_lv.pop();
    }
    
    for(int i=0; i<nindent; ++i){
        cout << tab;
    }
    cout << text;
}

int look_for(string text, char c){
    bool encontrado = false;
    int i;
    
    for(i=0; i<text.length() && !encontrado; ++i){
        if(yytext[i] == c)
            encontrado = true;
    }
    
    return i;
}
int main (int argc, char *argv[]){   
    indentation_lv.push(0);
    one_line_block = false;
    
    if (argc == 2){     
        yyin = fopen (argv[1], "rt");
        // Creamos el fichero de salida. ¡Estará indentado!
        // Redirigimos la salida estándar del programa al archivo creado
        string file = argv[1];
        file += "(1)";
        const char* out = file.c_str();
        freopen(out,"w",stdout);
        
        if (yyin == NULL){       
            cerr << "El fichero %s no se puede abrir\n", argv[1];       
            return -1;   
        }
        yylex (); 
    }   
    else{
        cerr << "Uso del programa: " << argv[0] << " " << "Nombre de fichero" << endl;
        return -1;
    }
    
    return 0; 
}
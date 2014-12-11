%{
#include "defs.cpp"
%}

openp                   \{
closep                  \}
fst_char                [^[:space:]{}]
ln_chars                [^{}\n]*
comma                   ;{ln_chars}
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
preproc_ln              \#.*
public                  public\:
private                 private\:
other_ln                ([[:graph:]][^\n]*)*

%START SWITCH
%%

{block_ln}              |
{simple_for}{comma}     |
{simple_wh}{comma}      { indent(yytext); }
{simple_for}            |
{simple_wh}             { int copia = indentation_lv.top();
                          indent(yytext); 
                          indentation_lv.push(copia + 1);
                          one_line_block = true; }
                          
{simple_if}{comma}      { if_indentation.push(indentation_lv.top());
                          indent(yytext); }
                          
{simple_if}             { if_indentation.push(indentation_lv.top());
                          indent(yytext); 
                          indentation_lv.push(if_indentation.top() + 1);
                          one_line_block = true;}
                          
{simple_elif}{comma}    { indent(yytext,if_indentation.top()); }

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
                          indentation_lv.push(indentation_lv.top() + 1);}
                            
{block_start}           { int copia = indentation_lv.top();
                          indent(yytext); 
                          backup_indentation.push(copia);
                          indentation_lv.push(copia + 1); }
                          
{block_end}             { indent(yytext,indentation_lv.top()-1); 
                          indentation_lv.pop();
                          indentation_lv.pop();
                          indentation_lv.push(backup_indentation.top());
                          if_indentation.adjust_ifs(backup_indentation.top() + 1);
                          backup_indentation.pop(); }

{block_end_ln}          { indent(yytext,indentation_lv.top()); 
                          indentation_lv.pop();
                          indentation_lv.pop();
                          indentation_lv.push(backup_indentation.top());
                          if_indentation.adjust_ifs(backup_indentation.top() + 1);
                          backup_indentation.pop();
                        }
{private}               |
{public}                { indent(yytext,indentation_lv.top()-1); }
{codeln}{comma}         |
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
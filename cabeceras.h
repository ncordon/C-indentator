#ifndef CABECERAS
#define CABECERAS

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
using namespace std;


// Clase wrapper de pila
class Stack{
protected:
    vector<int> pila;
public:    
    int top();
    void pop();
    void push(int n);
};

class Stack_if: public Stack{
public:
    void push(int n);
    void adjust_ifs(int n);
};

// Pila con el nivel de indentación en cada momento
Stack indentation_lv;
// El tope de esta pila indica el nivel de indentación que se aplicó al último if, o else if
Stack_if if_indentation;
// Pila que lleva una copia de seguridad del nivel de indentación antes de indentar un bloque
Stack backup_indentation;

/* 
Función de indentación
    Indenta la línea 'text' a 'nindent' sangrías
*/
void indent(string text,int nindent= indentation_lv.top());

/*
Permite buscar la primera ocurrencia de 'c' en text
*/
int look_for(string text, char c);

// Indica si se está indentando un bloque(if,else,for,...) de una única linea
bool one_line_block;

// Carácter de tabulación
string tab = "    ";


#endif
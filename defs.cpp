#include "cabeceras.h"

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
        if(text[i] == c)
            encontrado = true;
    }
    
    return i;
}
  
int Stack::top(){
    if (!pila.empty())
        return pila.back();
    else
        return 0;
}

void Stack::pop(){
    if (!pila.empty())
        pila.pop_back();
}

void Stack::push(int n){
    pila.push_back(n);
}


void Stack_if::push(int n){
    adjust_ifs(n);
    Stack::push(n);
}

void Stack_if::adjust_ifs(int n){
    vector<int>::iterator it;
    it=pila.begin();
    
    while(it!=pila.end()){
        if (*it >= n){
            it = pila.erase(it);       
        }
        else
            ++it;
    }
}
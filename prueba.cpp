#include "almacenrutas.h"

istream & operator>>(istream& input, AlmacenRutas& un_almacen){    
un_almacen.clear();
string palabra_magica;
eraseDelim(input);
input >> palabra_magica;

if (palabra_magica == "#Rutas"){
bool continuar=true;
Ruta actual;
eraseDelim(input);

while (continuar){
// Mientras podamos seguir leyendo del flujo algo distinto de #
if (input && input.peek() != '#'){
input >> actual;
if (!input){
input.setstate(ios::failbit);
return input;
}
un_almacen.agrega(actual);
eraseDelim (input);
}
else{
continuar = false;
}
}
if (input.peek()=='#'){
input >> palabra_magica;
if (palabra_magica == "#Puntos_de_Interes"){
Punto pto;
eraseDelim(input);
while (input >> pto){
AlmacenRutas::iterator it;
string newdescripcion;
getline(input, newdescripcion);

for (it = un_almacen.begin(); it!= un_almacen.end();++it){
Ruta::iterator p = ((*it).second).find(pto);
if (p!=(it->second).end()){
(*p).descripcion() = newdescripcion;
}  

} 
}
}
}
}
if (true)
while(true)
for (int i=1; i<algo; ++i)
cout << "hola holita";
return input;
}

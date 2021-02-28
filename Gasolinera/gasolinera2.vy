# @version ^0.2.8

#Variacion de gasolinera1 con mas uso de gas

#Seleccionar un valor predeterminado o llenar el deposito
#En el caso del valor predeterminado no se devuelve el importe,
#si es llenado se devuelve lo que no se haya echado

#Creamos una estructura para guardar los litros y el precio
struct Combustibles:
    litros: decimal
    precio_litro: decimal

#Creamos una estructura para almacenar distintos valores
struct Calles:
    uso: bool 
    cliente: address
    tope: decimal
    combustible: String[3]
    pagado: uint256
    selec: uint256

#Variables globales  
empresa: public(address)
maximo: public(decimal)

#Para cada tipo de gasolina almacena la estructura Combustibles
gasolinera: public(HashMap[String[3],Combustibles])

#para cada surtidor almacena la estructura Calles
surtidores: public(Calles[2])

#para cada seleccion almacena el precio de la seleccion
seleccion: public(decimal[7])

#Constructor del comtrato, pone precio de cada tipo de combustible
#los litros que hay de cada uno, el maximo de litros que puede haber
#y las distintas selecciones de precio
@external
def __init__(_precio95: decimal,_precio98: decimal,_precioN: decimal,_precioP: decimal,_maximo: decimal,
             _litros95: decimal,_litros98: decimal,_litrosN: decimal,_litrosP: decimal,
             _p1: decimal,_p2: decimal,_p3: decimal,_p4: decimal,_p5: decimal,_p6: decimal,_p7:decimal):
    assert _precio95 > 0.0
    assert _precio98 >  0.0
    assert _precioN >  0.0
    assert _precioP >  0.0
    assert _maximo >  0.0
    assert _maximo >= _litros95
    assert _maximo >= _litros98
    assert _maximo >= _litrosN
    assert _maximo >= _litrosP
    assert _p1 > 0.0
    assert _p2 > _p1
    assert _p3 > _p2
    assert _p4 > _p3
    assert _p5 > _p4
    assert _p6 > _p5
    assert _p7 > _p6
    self.empresa = msg.sender
    self.gasolinera["G95"] = Combustibles({litros: _litros95,precio_litro: _precio95})
    self.gasolinera["G98"] = Combustibles({litros: _litros98,precio_litro: _precio98})
    self.gasolinera["DiN"] = Combustibles({litros: _litrosN,precio_litro: _precioN})
    self.gasolinera["DiP"] = Combustibles({litros: _litrosP,precio_litro: _precioP})
    self.maximo = _maximo
    self.seleccion[0] = _p1
    self.seleccion[1] = _p2
    self.seleccion[2] = _p3
    self.seleccion[3] = _p4
    self.seleccion[4] = _p5
    self.seleccion[5] = _p6
    self.seleccion[6] = _p7

#Funcion externa que dado una String[3] te devuelve el precio del combustible
@view
@external
def precio(comb: String[3])-> decimal:
    assert (comb == "G95") or (comb == "G98") or (comb == "DiN") or (comb == "DiP"),"Bien escrito"
    return self.gasolinera[comb].precio_litro

#Funcion para almacenar el ether y los datos
#al estar el booleano uso en True, "libera"el surtidor para poder echar combustible
@payable
@external
def echargasolina(calle: uint256, comb: String[3],sel: uint256):
    assert (calle == 0 and not (self.surtidores[0].uso)) or (calle == 1 and not (self.surtidores[1].uso)),"No se estan usando"
    assert (comb == "G95") or (comb == "G98") or (comb == "DiN") or (comb == "DiP"),"Bien escrito"
    assert (sel < 7 and sel >= 0),"Seleccion valida"
    assert msg.value == convert(self.seleccion[sel], uint256),"Precio valido"
    assert self.gasolinera[comb].litros >= self.seleccion[sel] / self.gasolinera[comb].precio_litro,"Hay litros suficientes"
    
    self.surtidores[calle] = Calles({uso:True,cliente: msg.sender,tope: self.seleccion[sel]/ self.gasolinera[comb].precio_litro,combustible:comb,pagado:msg.value,selec:sel})

#Funcion para volver a poner el booleano use en False y asi no poder usarse hasta depositar ether
#En el caso de haber seleccionado la opcion 7 que es la de llenado, se devuelve el ether correspondiente a los litros no echados
#en cualquier otro caso el dinero va a la gasolinera    
@external
def parar(calle: uint256, litros: decimal,lleno: bool):
    assert calle == 0 or calle == 1,"Numero calle correcto"
    assert self.surtidores[calle].uso,"El surtidor se esta usando"
    assert (self.surtidores[calle].tope == litros or lleno),"Esta lleno o tope"
    self.surtidores[calle].uso = False
    self.gasolinera[self.surtidores[calle].combustible].litros -= litros
    if self.surtidores[calle].selec == 6:
        precio: int128 = ceil((self.gasolinera[self.surtidores[calle].combustible].precio_litro )*(self.surtidores[calle].tope - litros)) 
        valor : uint256 = convert(precio, uint256)
        send(self.surtidores[calle].cliente,valor)
        precio = ceil(litros*self.gasolinera[self.surtidores[calle].combustible].precio_litro) 
        valor  = convert(precio, uint256)
        send(self.empresa, valor)
        
    else:
        send(self.empresa,self.surtidores[calle].pagado)
    self.surtidores[calle] = empty(Calles)

#Funcion para llenar los depositos de combustible
@external
def surtir(cantidad:decimal,comb: String[3]):
    assert msg.sender == self.empresa,"Empresa"
    assert (comb == "G95") or (comb == "G98") or (comb == "DiN") or (comb == "DiP"),"Bien escrito"
    assert self.gasolinera[comb].litros + cantidad <= self.maximo,"Entra"
    self.gasolinera[comb].litros += cantidad

#Dado un String que es un tipo de combustible y el precio
#cambiamos el precio del combustible
@external
def cambiar_precio(comb: String[3],precio: decimal):
    assert msg.sender == self.empresa,"Empresa"
    assert (comb == "G95") or (comb == "G98") or (comb == "DiN") or (comb == "DiP"),"Bien escrito"
    assert self.gasolinera[comb].precio_litro != precio,"Distinto precio"
    assert precio > 0.0,"Positivo"
    self.gasolinera[comb].precio_litro = precio

#Funcion para cambiar la cantidad de litros de la seleccion
@external
def cambiar_seleccion(num: uint256, cantidad: decimal):
    assert self.empresa == msg.sender,"Empresa"
    assert num >= 0 and num <7,"En el rango"
    self.seleccion[num]=cantidad

#Seleccionar un valor predeterminado o llenar el deposito
#En el caso del valor predeterminado no se devuelve el importe,
#si es llenado se devuelve lo que no se haya echado

#Creamos una estructura para guardar los litros y el precio
struct Gasofalineria:
    litros: uint256
    precio_litro: uint256

#Creamos una estructura para almacenar distintos valores
struct surtidor:
    uso: bool 
    cliente: address
    tope: uint256
    combustible: String[3]
    pagado: uint256
    selec: uint256

#Variables globales  
empresa: public(address)
maximo: uint256

#Para cada tipo de gasolina almacena la estructura Gasofalineria
gasolinera: public(HashMap[String[3],Gasofalineria])

#para cada surtidor almacena la estructura surtidor
surtidores: public(HashMap[uint256,surtidor])

#para cada seleccion almacena el precio de la seleccion
seleccion: public(HashMap[uint256,uint256])

#Constructor del comtrato, pone precio de cada tipo de combustible
#los litros que hay de cada uno, el maximo de litros que puede haber
#y las distintas selecciones de precio
@external
def __init__(_precio95: uint256,_precio98: uint256,_precioN: uint256,_precioP: uint256,_maximo: uint256,
             _litros95: uint256,_litros98: uint256,_litrosN: uint256,_litrosP: uint256,
             _p1: uint256,_p2: uint256,_p3: uint256,_p4: uint256,_p5: uint256,_p6: uint256,_p7: uint256):
    assert _precio95 > 0
    assert _precio98 > 0
    assert _precioN > 0
    assert _precioP > 0
    assert _maximo > 0
    assert _maximo >= _litros95
    assert _maximo >= _litros98
    assert _maximo >= _litrosN
    assert _maximo >= _litrosP
    assert _p1 > 0
    assert _p2 > _p1
    assert _p3 > _p2
    assert _p4 > _p3
    assert _p5 > _p4
    assert _p6 > _p5
    assert _p7 > _p6
    self.empresa = msg.sender
    self.gasolinera["G95"] = Gasofalineria({litros: _litros95,precio_litro: _precio95})
    self.gasolinera["G98"] = Gasofalineria({litros: _litros98,precio_litro: _precio98})
    self.gasolinera["DiN"] = Gasofalineria({litros: _litrosN,precio_litro: _precioN})
    self.gasolinera["DiP"] = Gasofalineria({litros: _litrosP,precio_litro: _precioP})
    self.maximo = _maximo
    self.seleccion[1] = _p1
    self.seleccion[2] = _p2
    self.seleccion[3] = _p3
    self.seleccion[4] = _p4
    self.seleccion[5] = _p5
    self.seleccion[6] = _p6
    self.seleccion[7] = _p7

#Funcion externa que dado una String[3] te devuelve el precio del combustible
@view
@external
def precio(comb: String[3])-> uint256:
    return self.gasolinera[comb].precio_litro

#Funcion para almacenar el ether y los datos
#al estar el booleano uso en True, "libera"el surtidor para poder echar combustible
@payable
@external
def echargasolina(calle: uint256, comb: String[3],sel: uint256):
    assert (calle == 1 and not (self.surtidores[1].uso)) or (calle == 2 and not (self.surtidores[2].uso))
    assert (comb == "G95") or (comb == "G98") or (comb == "DiN") or (comb == "DiP")
    assert sel < 8
    assert sel > 0
    assert msg.value == self.seleccion[sel]* self.gasolinera[comb].precio_litro
    assert self.gasolinera[comb].litros >= self.gasolinera[comb].precio_litro * msg.value
    
    self.surtidores[calle] = surtidor({uso:True,cliente: msg.sender,tope: self.seleccion[sel],combustible:comb,pagado:msg.value,selec:sel})

#Funcion para volver a poner el booleano use en False y asi no poder usarse hasta depositar ether
#En el caso de haber seleccionado la opcion 7 que es la de llenado, se devuelve el ether correspondiente a los litros no echados
#en cualquier otro caso el dinero va a la gasolinera    
@external
def parar(calle: uint256, litros: uint256,lleno: bool):
    assert self.surtidores[calle].uso
    assert (self.surtidores[calle].tope == litros or lleno)
    self.surtidores[calle].uso = False
    self.gasolinera[self.surtidores[calle].combustible].litros -= litros
    if self.surtidores[calle].selec == 7:
        send(self.surtidores[calle].cliente,(self.gasolinera[self.surtidores[calle].combustible].precio_litro )*(self.surtidores[calle].tope - litros))
        send(self.empresa, litros*self.gasolinera[self.surtidores[calle].combustible].precio_litro)
        
    else:
        send(self.empresa,self.surtidores[calle].pagado)
    self.surtidores[calle] = empty(surtidor)

#Funcion para llenar los depositos de combustible
@external
def surtir(cantidad:uint256 ,comb: String[3]):
    assert msg.sender == self.empresa
    assert (comb == "G95") or (comb == "G98") or (comb == "DiN") or (comb == "DiP")
    assert self.gasolinera[comb].litros + cantidad <= self.maximo
    self.gasolinera[comb].litros += cantidad

#Dado un String que es un tipo de combustible y el precio
#cambiamos el precio del combustible
@external
def cambiar_precio(comb: String[3],precio: uint256):
    assert msg.sender == self.empresa
    assert self.gasolinera[comb].precio_litro != precio
    assert precio > 0
    assert (comb == "G95") or (comb == "G98") or (comb == "DiN") or (comb == "DiP")
    self.gasolinera[comb].precio_litro = precio

#Funcion para cambiar la cantidad de litros de la seleccion
@external
def cambiar_seleccion(num: uint256, cantidad: uint256):
    assert self.empresa == msg.sender
    self.seleccion[num]=cantidad

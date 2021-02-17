# @version ^0.2.8

interface Puntos:
    def acumularpuntos(puntos:uint256,cliente: address): nonpayable
    def usarpuntos(cliente:address)->uint256:nonpayable
    def usarlitros(cliente:address,puntos: uint256):nonpayable
    def nuevocliente(cliente:address): nonpayable
    def dejardesercliente(cliente:address):nonpayable

puntos_contract: Puntos

#Creamos una estructura para guardar los litros y el precio
struct Combustibles:
    litros: uint256
    precio_litro: uint256

#Creamos una estructura para almacenar distintos valores
struct Calles:
    uso: bool 
    cliente: address
    tope: uint256
    combustible: String[3]
    pagado: uint256
    selec: uint256
    usar_puntos: bool
    

#Variables globales  
empresa: public(address)
maximo: public(uint256)

#Para cada tipo de gasolina almacena la estructura Combustibles
gasolinera: public(HashMap[String[3],Combustibles])

#para cada surtidor almacena la estructura Calles
surtidores: public(HashMap[uint256,Calles])

#para cada seleccion almacena el precio de la seleccion
seleccion: public(HashMap[uint256,uint256])


#Constructor del comtrato, pone precio de cada tipo de combustible
#los litros que hay de cada uno, el maximo de litros que puede haber
#y las distintas selecciones de precio
@external
def __init__(_precio95: uint256,_precio98: uint256,_precioN: uint256,_precioP: uint256,_maximo: uint256,
             _litros95: uint256,_litros98: uint256,_litrosN: uint256,_litrosP: uint256,
             _p1: uint256,_p2: uint256,_p3: uint256,_p4: uint256,_p5: uint256,_p6: uint256,_p7: uint256,_puntos:address):
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
    self.gasolinera["G95"] = Combustibles({litros: _litros95,precio_litro: _precio95})
    self.gasolinera["G98"] = Combustibles({litros: _litros98,precio_litro: _precio98})
    self.gasolinera["DiN"] = Combustibles({litros: _litrosN,precio_litro: _precioN})
    self.gasolinera["DiP"] = Combustibles({litros: _litrosP,precio_litro: _precioP})
    self.maximo = _maximo
    self.seleccion[1] = _p1
    self.seleccion[2] = _p2
    self.seleccion[3] = _p3
    self.seleccion[4] = _p4
    self.seleccion[5] = _p5
    self.seleccion[6] = _p6
    self.seleccion[7] = _p7
    self.puntos_contract = Puntos(_puntos)

#Funcion externa que dado una String[3] te devuelve el precio del combustible
@view
@external
def precio(comb: String[3])-> uint256:
    return self.gasolinera[comb].precio_litro

#Funcion que comprueba que el String[3] esta bien escrito
@internal
def bienescrito(nombre: String[3])-> bool:
    return (nombre == "G95") or (nombre == "G98") or (nombre == "DiN") or (nombre == "DiP")


#Funcion para almacenar el ether y los datos
#al estar el booleano uso en True, "libera"el surtidor para poder echar combustible
#En el caso de haber puntos suficientes o que tengas litros gratis se usan estos y se devuelve el ether al cliente
@payable
@external
def echargasolina(calle: uint256, comb: String[3],sel: uint256, usar_puntos: bool):
    assert (calle == 1 and not (self.surtidores[1].uso)) or (calle == 2 and not (self.surtidores[2].uso)),"No se estan usando"
    assert self.bienescrito(comb),"Bien escrito"
    assert (sel < 8 and sel > 0),"Seleccion valida"
    assert msg.value == self.seleccion[sel],"Precio valido"
    assert self.gasolinera[comb].litros >= self.seleccion[sel] / self.gasolinera[comb].precio_litro,"Hay litros suficientes"
    litros: uint256 = 0
    if usar_puntos:
        litros = self.puntos_contract.usarpuntos(msg.sender)
        if litros != 0:
            
            self.surtidores[calle] = Calles({uso:True,cliente: msg.sender,
                                     tope: litros,
                                     combustible:comb,pagado:0,selec:sel,usar_puntos: True})
            send(msg.sender,msg.value)
        else:
            self.surtidores[calle] = Calles({uso:True,cliente: msg.sender,
                                     tope: self.seleccion[sel]/ self.gasolinera[comb].precio_litro,
                                     combustible:comb,pagado:msg.value,selec:sel,usar_puntos: False})
    else:
        
        self.surtidores[calle] = Calles({uso:True,cliente: msg.sender,
                                         tope: self.seleccion[sel]/ self.gasolinera[comb].precio_litro,
                                         combustible:comb,pagado:msg.value,selec:sel, usar_puntos: False})
    

#Funcion para volver a poner el booleano use en False y asi no poder usarse hasta depositar ether
#En el caso de haber seleccionado la opcion 7 que es la de llenado, se devuelve el ether correspondiente a los litros no echados
#en cualquier otro caso el dinero va a la gasolinera
@external
def parar(calle: uint256, _litros: uint256,lleno: bool):
    assert self.surtidores[calle].uso,"El surtidor se esta usando"
    assert (self.surtidores[calle].tope == _litros or lleno),"Esta lleno o tope"
    surti: Calles = self.surtidores[calle]
    surti.uso = False
    self.gasolinera[surti.combustible].litros -= _litros
    gastado: uint256 = surti.pagado
    if surti.usar_puntos:
        self.puntos_contract.usarlitros(surti.cliente, _litros)
    else:
        if surti.selec == 7:
            gastado = _litros*self.gasolinera[surti.combustible].precio_litro
            self.puntos_contract.acumularpuntos(gastado,surti.cliente)
            send(self.empresa, gastado)
        else:
            self.puntos_contract.acumularpuntos(self.surtidores[calle].pagado,surti.cliente)
            send(self.empresa,self.surtidores[calle].pagado)
            
    self.surtidores[calle] = empty(Calles)
    


#Funcion para llenar los depositos de combustible
@external
def surtir(cantidad:uint256 ,comb: String[3]):
    assert msg.sender == self.empresa,"Empresa"
    assert self.bienescrito(comb),"Bien escrito"
    assert self.gasolinera[comb].litros + cantidad <= self.maximo,"Entra"
    self.gasolinera[comb].litros += cantidad

#Dado un String que es un tipo de combustible y el precio
#cambiamos el precio del combustible
@external
def cambiar_precio(comb: String[3],precio: uint256):
    assert msg.sender == self.empresa,"Empresa"
    assert self.bienescrito(comb),"Bien escrito"
    assert self.gasolinera[comb].precio_litro != precio,"Distinto precio"
    assert precio > 0,"Positivo"
    self.gasolinera[comb].precio_litro = precio

#Funcion para cambiar la cantidad de litros de la seleccion
@external
def cambiar_seleccion(num: uint256, cantidad: uint256):
    assert self.empresa == msg.sender,"Empresa"
    assert num > 0,"Positiva"
    self.seleccion[num]=cantidad

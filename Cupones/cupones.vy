# @version ^0.2.8
#Acumular puntos y te hacen un descuento en la siguiente compra
#el descuento va en porcentajes

#Creamos un evento para que quede registrado el cupon
event Descuento:
    emisor: indexed(address)
    receptor: indexed(address)
    codigodescuento: String[10]

#Creamos un evento para que quede registrado la cantidad que se devuelve al cliente
event Devolver:
    emisor: indexed(address)
    beneficiario: indexed(address)
    valor:uint256

#Creamos una estructura para saber cuales son la cantidad de puntos y el cupon asociado
struct Premios:
    puntos: uint256
    descuento: uint256


#Variables de la empresa    
empresa: public(address)
premios: public(HashMap[uint256,Premios])
#Como Premios es publico hay que crear la variable cupones para almacenar nº del cupon
cupones: public(HashMap[uint256,String[10]])

#Variable para saber cual es la relacion entre lo gastado y los puntos equivalentes
apuntos: public(uint256)


puntos_acumulados: public(uint256)
#Variables para canjear un codigo
canjear: public(String[10])
#Direccion del cliente
cliente: address

#Esto no está pero puede estar bien
#Veces que ha visitado el comercio
uso: public(uint256)
rangos_clientes: public(HashMap[uint256, uint256])

#Lista para almacenar los cupones que tiene
list_cupones: public(HashMap[String[10],uint256])

devolver:public(uint256)

#Constructor del contrato que asocia los premios y los cupones
@external
def __init__(_p1:uint256, _d1:uint256,_p2:uint256, _d2:uint256,_p3:uint256, _d3:uint256,_c1:String[10],_c2:String[10],_c3:String[10],_apuntos: uint256):
    assert _p1 > 0
    assert _p1 < _p2 
    assert _p2 < _p3
    assert _d1 != _d2
    assert _d2 != _d3
    assert _d3 != _d1
    assert (_d1 > 0 and _d1 <= 100)
    assert (_d2 > 0 and _d2 <= 100)
    assert (_d3 > 0 and _d3 <= 100)
    self.empresa = msg.sender
    self.premios[1] = Premios({puntos: _p1,descuento: _d1})
    self.cupones[1] = _c1
    self.premios[2]= Premios({puntos: _p2,descuento: _d2})
    self.cupones[2]=_c2
    self.premios[3] = Premios({puntos: _p3,descuento: _d3})
    self.cupones[3]=_c3
    self.apuntos = _apuntos
    
#Funcion para ser nuevo cliente
@external
def nuevocliente():
    self.cliente = msg.sender
    self.puntos_acumulados = 0
    self.list_cupones[self.cupones[1]] = 0
    self.list_cupones[self.cupones[2]] = 0
    self.list_cupones[self.cupones[3]] = 0
    self.canjear = "No usar"

#Funcion interna para acumular puntos, solo la puede llamar la empresa, toma como argumentos la direccion del cliente y lo que se ha gastado

@internal
def _acumularpuntos(gastado: uint256):
    self. puntos_acumulados += gastado / self.apuntos

#Funcion que es llamada por el cliente para obtener un cupon con los puntos obtenidos
@external
def canjearpuntos():
    assert msg.sender == self.cliente,"Cliente"
    assert (self.puntos_acumulados >= self.premios[1].puntos or self.puntos_acumulados >= self.premios[2].puntos or self.puntos_acumulados >= self.premios[3].puntos),"Numero de descuento"
    n_descuento: uint256 = 0
    if self.puntos_acumulados >= self.premios[3].puntos:
        n_descuento = 3
    elif self.puntos_acumulados >= self.premios[2].puntos:
        n_descuento = 2
    elif self.puntos_acumulados >= self.premios[1].puntos:
        n_descuento = 1
   
    
    self.puntos_acumulados -= self.premios[n_descuento].puntos
    log Descuento(self.empresa,self.cliente,self.cupones[n_descuento])
    self.list_cupones[self.cupones[n_descuento]] +=1

#Funcion que solo puede usar el cliente para decir que quiere usar un cupon, como argumento toma el cupon que quiere usar
@external
def usar_cupones(cupon : String[10]):
    assert msg.sender == self.cliente,"Cliente"
    assert ((cupon == self.cupones[1]) or (cupon == self.cupones[2]) or (cupon == self.cupones[3])),"Cupon valido"
    assert self.list_cupones[cupon] >= 1,"Tiene el cupon"
    self.list_cupones[cupon] -= 1
    self.canjear = cupon
    
#Funcion que en la compra te canjea los cupones si tienes y acumula puntos.
@payable
@external
def compra():
    assert msg.sender == self.cliente,"Cliente"
    assert msg.value > 0,"Positivo"
    self.devolver = 0
    if self.canjear != "Nada":
        descuento: uint256 = 0
        if self.canjear == self.cupones[1]:
            descuento = self.premios[1].descuento
        elif self.canjear == self.cupones[2]:
            descuento = self.premios[2].descuento
        else:
            descuento = self.premios[3].descuento
        self.devolver = msg.value*(100-descuento)/100
    self._acumularpuntos(msg.value)
    send(self.cliente,self.devolver)
    log Devolver(self.empresa,self.cliente,self.devolver)


#Funcion que llama el cliente para dejar de serlo
@external
def dejardesercliente():
    assert msg.sender == self.cliente,"Cliente"
    selfdestruct(self.empresa)

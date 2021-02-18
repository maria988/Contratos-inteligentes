# @version ^0.2.8
#Variacion que acumula puntos y por x puntos y litros gratis

#Seleccionar un valor predeterminado o llenar el deposito
#En el caso del valor predeterminado no se devuelve el importe,
#si es llenado se devuelve lo que no se haya echado

    
struct Puntos_litros:
    cliente: bool
    puntos: uint256
    litros: uint256
    
#Variables globales  
empresa: public(address)

#Variables para determinar por la cantidad de puntos los litros que te dan
puntos: public(uint256)
litrosgratis: public(uint256)

#Variable para pasar del valor gastado a puntos
apuntos: public(uint256)

#Variable para asociar a acada cliente los puntos que lleva
list_clientes: HashMap[address,Puntos_litros]




@external
def __init__(_puntos:uint256,_lg:uint256,_apuntos: uint256 ):
    self.empresa = msg.sender
    self.puntos = _puntos
    self.litrosgratis = _lg
    self.apuntos = _apuntos


@external
def acumularpuntos(gastado: uint256, cliente: address):
    assert gastado > 0
    assert self.list_clientes[cliente].cliente
    self.list_clientes[cliente].puntos += gastado / self.apuntos


@external
def usarpuntos(cliente: address)-> uint256:
    assert self.list_clientes[cliente].cliente
    assert self.list_clientes[cliente].puntos >= self.puntos
    self.list_clientes[cliente].puntos -= self.puntos
    self.list_clientes[cliente].litros += self.litrosgratis
    return self.list_clientes[cliente].puntos

@external
def usarlitros(cliente:address, _litros: uint256):
    assert self.list_clientes[cliente].cliente
    assert self.list_clientes[cliente].litros >= _litros
    self.list_clientes[cliente].litros -= _litros
    
#Funcion para ser cliente
@external
def nuevocliente(nuevo_cliente:address):
    assert not self.list_clientes[nuevo_cliente].cliente
    self.list_clientes[nuevo_cliente].cliente= True
    self.list_clientes[nuevo_cliente].puntos = 0
    self.list_clientes[nuevo_cliente].litros = 0
    
#Funcion para dejar de ser cliente
@external
def dejardesercliente(cliente: address):
    assert self.list_clientes[cliente].cliente
    self.list_clientes[cliente] = empty(Puntos_litros)

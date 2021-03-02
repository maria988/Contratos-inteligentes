# @version ^0.2.8

#Contrato telefono saldo

#Variable del precio por unidad de tiempo
precioTiempo: public(uint256)

#Variable del precio del establecimiento de llamada
estabLlamada: public(uint256)

#Direccion de la compania
empresa: public(address)

#Numero de telefono 
telefono: public(String[9])

#Booleano para saber si se esta llamando o no
llamando: bool

#Precio de la llamada realizada
llamada: uint256

#Constructor del contrato, se almacenan los distintos precios y el numero de telefono
@external
def __init__(_precioTiempo: uint256,_estabLlamada: uint256, _telefono: String[9]):
    self.empresa = msg.sender
    self.precioTiempo = _precioTiempo
    self.estabLlamada = _estabLlamada
    self.telefono = _telefono

#Funcion interna que devuelve el saldo del telefono
@view
@internal
def _saldo()->uint256:
    return self.balance

#Funcion para consultar el saldo del telefono
@view
@external
def saldo(ntelefono: String[9]) ->uint256:
    assert self.telefono== ntelefono,"Telefono correcto"
    return self._saldo()

#Funcion para recargar el telefono
@payable    
@external
def recargar(ntelefono: String[9],empresa:address):
    assert self.empresa == empresa,"Empresa"
    assert self.telefono == ntelefono,"Telefono correcto"
    assert msg.value > 0,"Valor positivo"

#Funcion para llamar, se pasa el numero de telefono que se va a usar
@external
def llamar(ntelefono: String[9]):
    assert self.telefono == ntelefono,"Telefono correcto"
    assert self.balance > self.estabLlamada,"Suficiente"
    self.llamada = block.timestamp
    self.llamando = True
    send(self.empresa,self.estabLlamada)

#Funcion para colgar, se psas el numero de telefono que se va a usar
@external
def colgar(ntelefono:String[9]):
    assert self.telefono == ntelefono,"Telefono correcto"
    assert self.llamando,"Llamando"
    self.llamando = False
    cantidad : uint256 = (block.timestamp - self.llamada)*self.precioTiempo
    if self.balance < cantidad:
        cantidad = self.balance
    send(self.empresa,cantidad)
    
#Funcion para cortar la llamda en el caso de que se agote el saldo
@external
def cortar(ntelefono:String[9]):
    assert self.telefono == ntelefono,"Telefono correcto"
    assert self.empresa == msg.sender,"Empresa"
    assert self.llamando,"Llamando"
    assert self.balance <= (block.timestamp - self.llamada)*self.precioTiempo,"Superado"
    self.llamando = False
    send(self.empresa,self.balance)

# @version ^0.2.8

#Contrato telefono saldo

precioTiempo: public(uint256)
estabLlamada: public(uint256)
empresa: public(address)
telefono: public(String[9])
llamando: bool
llamada: uint256

@external
def __init__(_precioTiempo: uint256,_estabLlamada: uint256, _telefono: String[9]):
    self.empresa = msg.sender
    self.precioTiempo = _precioTiempo
    self.estabLlamada = _estabLlamada
    self.telefono = _telefono

@view
@internal
def _saldo()->uint256:
    return self.balance

@view
@external
def saldo(ntelefono: String[9]) ->uint256:
    assert self.telefono== ntelefono,"Telefono correcto"
    return self._saldo()

@payable    
@external
def recargar(ntelefono: String[9],empresa:address):
    assert self.empresa == empresa,"Empresa"
    assert self.telefono == ntelefono,"Telefono correcto"
    assert msg.value > 0,"Valor positivo"
    
@external
def llamar(ntelefono: String[9]):
    assert self.telefono == ntelefono,"Telefono correcto"
    assert self.balance > self.estabLlamada,"Suficiente"
    self.llamada = block.timestamp
    self.llamando = True
    send(self.empresa,self.estabLlamada)

@external
def colgar(ntelefono:String[9]):
    assert self.telefono == ntelefono,"Telefono correcto"
    assert self.llamando,"Llamando"
    self.llamando = False
    cantidad : uint256 = (block.timestamp - self.llamada)*self.precioTiempo
    if self.balance < cantidad:
        cantidad = self.balance
    send(self.empresa,cantidad)
    
@external
def cortar(ntelefono:String[9]):
    assert self.telefono == ntelefono,"Telefono correcto"
    assert self.empresa == msg.sender,"Empresa"
    assert self.llamando,"Llamando"
    assert self.balance <= (block.timestamp - self.llamada)*self.precioTiempo,"Superado"
    self.llamando = False
    send(self.empresa,self.balance)

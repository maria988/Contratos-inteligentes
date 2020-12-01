#bizum, pagar una cuenta en conjunto

event Transferencia:
    emisor: indexed(address)
    receptor: indexed(address)
    valor: uint256
    
cuenta: public(address)

@payable
@external
def __init__():
    assert msg.value > 0
    self.cuenta = msg.sender

@payable
@external
def pagarme(direccion: address):
    assert direccion == self.cuenta
    assert msg.sender != self.cuenta
    assert msg.value > 0
    send(self.cuenta,msg.value)
    log Transferencia(msg.sender,self.cuenta,msg.value)
    
@view
@external
def efectivo()->uint256:
    return self.balance

@payable
@external
def pagar(direccion: address, valor: uint256):
    assert msg.sender == self.cuenta
    assert msg.sender != direccion
    assert (valor <= self.balance) or (msg.value >= valor)
    send(direccion,valor)
    log Transferencia(self.cuenta, direccion,valor)
    
    
@payable
@external
def meterdinero():
    assert msg.value > 0

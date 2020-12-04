#Pagar o que te paguen. 

#Creamos un evento para registrar las transferencias realizadas
event Transferencia:
    emisor: indexed(address)
    receptor: indexed(address)
    valor: uint256
    
cuenta: public(address)

#Se construye el contrato y para ello se tiene que enviar ether para que se almacene
@payable
@external
def __init__():
    assert msg.value > 0
    self.cuenta = msg.sender
    
#Funcion externa para saber el ether que hay en la cuenta
@view
@external
def efectivo()->uint256:
    return self.balance

#Funcion para mandar ether o para que te manden ether
@payable
@external
def pagar(direccion: address, valor: uint256):
    assert msg.sender != direccion
    assert (valor <= self.balance) or (msg.value >= valor)
    send(direccion,valor)
    log Transferencia(msg.sender, direccion,valor)
    
#Funcion para añadir ether a la cuenta
@payable
@external
def meterdinero():
    assert msg.value > 0

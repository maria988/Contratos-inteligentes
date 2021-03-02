# @version ^0.2.8

#Pagar o que te paguen. El contrato funciona como una cuenta recibe dinero,
#pero se queda ahí y solo el titular puede enviar ether desde el contrato.

#Creamos un evento para registrar las transferencias realizadas
event Transferencia:
    emisor: indexed(address)
    receptor: indexed(address)
    valor: uint256

event Retirar:
    emisororden: indexed(address)
    valor: uint256
    
titular: public(address)

#Se construye el contrato y para ello se tiene que enviar ether para que se almacene
@payable
@external
def __init__():
    assert msg.value > 0
    self.titular = msg.sender
    
#Funcion externa para saber el ether que hay en la cuenta
@view
@external
def efectivo()->uint256:
    return self.balance

#Funcion para que meter ether en el contrato ( la cuenta)
#Se registra el movimiento con el evento
@payable
@external
def pagarme(direccion: address):
    assert direccion == self.titular,"Receptor titular"
    assert msg.sender != self.titular,"Emisor no titular"
    assert msg.value > 0,"Positivo"
    log Transferencia(msg.sender,self.titular,msg.value)

#Funcion para mandar ether
@payable
@external
def pagar(direccion: address, valor: uint256):
    assert msg.sender == self.titular,"Emisor titular"
    assert msg.sender != direccion,"Receptor no titular"
    assert (valor <= self.balance) or (msg.value >= valor),"Suficiente"
    send(direccion,valor)
    log Transferencia(self.titular, direccion,valor)
    
#Funcion para añadir ether al contrato
@payable
@external
def meterdinero():
    assert msg.value > 0,"Positivo"
    assert msg.sender == self.titular,"Titular"
    
#Funcion que el titular obtenga una cantidad de ether del contrato
@external
def sacardinero(cantidad: uint256):
    assert cantidad <= self.balance,"Suficiente"
    assert self.titular == msg.sender,"Titular"
    send(self.titular,cantidad)
    log Retirar(self.titular,cantidad)

#Funcion para destruir el contrato y enviar el ether del mismo al titular    
@external
def destruir():
    assert msg.sender == self.titular,"Titular"
    log Retirar(self.titular,self.balance)
    selfdestruct(self.titular)

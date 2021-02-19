# @version ^0.2.8

#Testamento

#Creamos un evento para registrar el cobro de la herencia
event Cobro:
    destinatario: indexed(address)
    valor: uint256


   
#Variables para almacenar la direccion  del cliente
cliente: public(address)

#Variable para saber el tiempo para poder aceptar la herencia
duracion : public(uint256)

#Para cada indice se le asigna una direccion
Herederos: HashMap[uint256, address]
#Para cada direccion se le asigna el valor de la herencia 
Herencia : HashMap[address, uint256]

#Variables para saber el lugar en el diccionario y para repartir la herencia
indice: uint256
inx: uint256

#Variable para almacenar el tope para firmar despues de fallecer
tiempo: uint256


#Boolenao para saber si ha fallecido el cliente
fallecido: bool


#Funcion para inicializar el contrato
@external 
def __init__(_duracion: uint256):
    assert _duracion > 0
    self.cliente = msg.sender
    self.duracion = _duracion


#Funcion para asignar a cada heredero su herencia
@payable
@external
def anadir_herederos(_heredero: address):
    assert msg.sender == self.cliente,"Cliente"
    self.Herederos[self.indice] = _heredero
    self.Herencia[_heredero] = msg.value
    self.indice += 1

#Funcion para cambiar la herencia asignada a un determinado heredero
@payable
@external
def cambiar_herencia(numero: uint256, _herencia: uint256):
    assert msg.sender == self.cliente,"Cliente"
    assert numero < self.indice,"Numero valido"
    assert msg.value + self.Herencia[self.Herederos[numero]]+self.balance >= _herencia,"Suficiente"
    self.Herencia[self.Herederos[numero]] = _herencia
   
#Funcion que es llamada cuando fallece el cliente
@external
def inicializar_herencia():
    assert self.Herencia[msg.sender] > 0,"Empresa"
    assert not self.fallecido,"No ha fallecido"
    self.tiempo = block.timestamp + self.duracion
    self.fallecido = True
 

#Funcion para cobrar la herencia
@external
def cobrar_herencia():
    assert self.fallecido,"Ha fallecido"
    assert block.timestamp > self.tiempo,"Tope pasado"
    indi: uint256 = self.inx
    for i in range(indi,indi+20):
        if i >= self.indice - 1:
            heredero : address = self.Herederos[i]
            log Cobro(heredero,self.Herencia[heredero])
            selfdestruct(heredero)
        else:
            heredero : address = self.Herederos[i]
            send(heredero,self.Herencia[heredero])
            log Cobro(heredero,self.Herencia[heredero])
    self.inx = indi +20
    
@view
@external
def saber_herencia()-> uint256:
    return self.Herencia[msg.sender]

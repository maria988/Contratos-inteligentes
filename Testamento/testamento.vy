# @version ^0.2.8

#Testamento

#Creamos un evento para registrar el cobro de la herencia
event Cobro:
    destinatario: indexed(address)
    valor: uint256

#Estructura para saber el valor de la herencia y si acepta o no la misma.
struct herencia:
    valor: uint256
    acepta : bool
   
#Variables para almacenar la direccion de la empresa, del cliente y del estado
empresa: public(address)
cliente: public(address)
estado : public(address)

#Variable para saber el precio del contrato y el tiempo para poder aceptar la herencia
precio: public(uint256)
duracion : public(uint256)

#Para cada indice se le asigna una direccion
Herederos: HashMap[uint256, address]
#Para cada direccion se le asigna el valor de la herencia y si la acepta o no
Herencia : HashMap[address, herencia]

#Variables para saber el lugar en el diccionario y para repartir la herencia
indice: uint256
inx: uint256

#Variable para almacenar el tope para firmar despues de fallecer
tiempo: uint256

#Booleano para saber si se ha pagado el precio del testamento
pagado: bool

#Boolenao para saber si ha fallecido el cliente
fallecido: bool

#Valor total de la herencia
total: uint256

#Funcion para inicializar el contrato
@external 
def __init__(_cliente:address,_precio: uint256,_duracion: uint256,_estado : address):
    assert _duracion > 0
    self.cliente = _cliente
    self.empresa = msg.sender
    self.precio = _precio
    self.duracion = _duracion
    self.estado = _estado

#Funcion para almacenar el precio del testamento y la cantidad a repartir
@payable
@external
def pagar(_total: uint256):
    assert msg.sender == self.cliente,"Cliente"
    assert self.precio + _total == msg.value,"Precio exacto"
    self.pagado = True
    self.total = _total

#Funcion para asignar a cada heredero su herencia
@external
def anadir_herederos(_heredero: address,_herencia: uint256):
    assert self.pagado,"Pagado"
    assert msg.sender == self.cliente,"Cliente"
    assert self.total >= _herencia,"Suficiente"
    self.Herederos[self.indice] = _heredero
    self.Herencia[_heredero].valor = _herencia
    self.indice += 1
    self.total -= _herencia

#Funcion para cambiar la herencia asignada a un determinado heredero
@external
def cambiar_herencia(numero: uint256,_herencia: uint256):
    assert self.pagado,"Pagado"
    assert msg.sender == self.cliente,"Cliente"
    assert numero < self.indice,"Numero valido"
    assert self.total+self.Herencia[self.Herederos[numero]].valor >= _herencia,"Suficiente"
    self.total = self.total +self.Herencia[self.Herederos[numero]].valor - _herencia
    self.Herencia[self.Herederos[numero]].valor = _herencia
   
#Funcion que es llamada cuando fallece el cliente
@external
def inicializar_herencia():
    assert self.empresa == msg.sender,"Empresa"
    assert not self.fallecido,"No ha fallecido"
    self.tiempo = block.timestamp + self.duracion
    self.fallecido = True

#Funcion para aceptar la herencia   
@external
def firmar_herencia():
    assert self.fallecido,"Ha fallecido"
    assert self.Herencia[msg.sender].valor != 0,"Valor positivo"
    assert block.timestamp <= self.tiempo,"Dentro de tiempo"
    self.Herencia[msg.sender].acepta = True    

#Funcion para cobrar la herencia
@external
def cobrar_herencia():
    assert self.fallecido,"Ha fallecido"
    assert block.timestamp > self.tiempo,"Tope pasado"
    indi: uint256 = self.inx
    for i in range(indi,indi+20):
        if i >= self.indice:
            send(self.empresa,self.precio)
            log Cobro(self.empresa,self.precio)
            log Cobro(self.estado,self.balance)
            selfdestruct(self.estado)
        else:
            heredero : address = self.Herederos[i]
            if self.Herencia[heredero].acepta:
                send(heredero,self.Herencia[heredero].valor)
                log Cobro(heredero,self.Herencia[heredero].valor)
    self.inx = indi +20
    
@view
@external
def saber_herencia(_heredero: address)-> uint256:
    return self.Herencia[_heredero].value

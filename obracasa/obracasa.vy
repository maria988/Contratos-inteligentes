#Se contrata a unos albaÃ±iles y dan un presupuesto y tiempo para 
#construir/restaurar una casa, en el caso de que se pasen del limite
#se ira quitando mensualmente el alquiler de la vivienda provisional

event Pago:
    emisor: indexed(address)
    receptor: indexed(address)
    valor: uint256

presupuesto: public(uint256)
tiempo_obra: public(uint256)
alquiler: public(uint256)
constructora : public(address)
cliente: public(address)
terminada: bool
empezar: bool
inicio: uint256
mes: uint256

#Constructor del contrato se establece el cliente, la duracion media de cada mes,elpresupuesto
#el tiempo estimado y cuando empiezan
@external
def __init__(_presupuesto: uint256,_tiempo_obra : uint256,_inicio:uint256,_cliente: address,_mes: uint256):
    assert _tiempo_obra > 0
    assert _presupuesto > 0
    self.presupuesto = _presupuesto
    self.tiempo_obra = _tiempo_obra
    self.inicio = _inicio
    self.constructora = msg.sender
    self.cliente = _cliente
    self.mes = _mes

#Funcion para dar el visto bueno al contrato, almacenar el ether correspondiente y almacenar cuanto vale el alquiler
@payable
@external
def pagarobra(_alquiler: uint256):
    assert msg.sender == self.cliente
    assert msg.value == self.presupuesto
    assert block.timestamp < self.inicio
    self.empezar = True
    self.alquiler = _alquiler

#Funcion que puede ser llamada por el constructor o por el cliente
#para pagar al cliente el alquiler en caso de que la obra dure mas de lo esperado
@external
def cobraralquiler():
    assert (msg.sender == self.cliente) or (msg.sender == self.constructora)
    assert not self.terminada
    assert block.timestamp > self.tiempo_obra
    assert self.balance > self.alquiler
    send(self.cliente,self.alquiler)
    log Pago(self.constructora, self.cliente,self.alquiler)
    self.tiempo_obra += self.mes

#Funcion para que el constructor introdzaca ether, este es el caso en el que se ha gastado
#el ether de la reforma en el alquiler
@payable
@external
def pagoalquiler():
    assert msg.value == self.alquiler
    assert not self.terminada
    assert self.balance < self.alquiler
    assert msg.sender == self.constructora

#Funcion llamada por la constructora para establecer que se ha terminado la obra
@external
def finobra():
    assert msg.sender == self.constructora
    assert self.empezar
    self.terminada = True

#Funcion para destruir el contrato, como que la obra esta terminada
#Se destruye el contrato y se le envia el ether restante al constructor
@external 
def findelcontrato():
    assert msg.sender == self.cliente
    assert self.terminada
    log Pago(self.cliente,self.constructora, self.balance)
    selfdestruct(self.constructora)

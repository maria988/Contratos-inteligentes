# @version ^0.2.8
#Fondo de inversion
#Evento para que quede registrado que se quiere recuperar lo invertido y la cantidad que es
event Recuperar:
    banco: indexed(address)
    cliente: indexed(address)
    cantidad: uint256

#Variables del contrato
#Direccion del banco    
banco: public(address)
#Duracion del contrato
duracion: public(uint256)
#Duracion de cada periodo
duracionPeriodo: public(uint256)
#Porcentaje que renta el capital
rentabilidad: public(uint256)
#Porcentaje que se queda el banco si se saca antes de que termine el contrato
penalizacion: public(uint256)
#Direccion del cliente
cliente: public(address)
#Cantidad que se va a meter en el fondo de inversion
cantidad: public(uint256)

#Fin del periodo actual
Periodo : uint256
#Capital que se tiene en el fondo
capital: public(uint256)
#Booleano para saber que se ha firmado el contrato
firma:bool
#Booleano para saber que se quiere recuperar el ether
recuperar: bool
#Cantidad a recuperar
crecuperar: uint256

#Constructor del contrato
@external
def __init__(_cliente: address,_duracion: uint256,_duracionPeriodo: uint256, _rentabilidad: uint256,_penalizacion: uint256,_cantidad: uint256):
    assert _duracion > _duracionPeriodo
    assert _rentabilidad > 0 and _rentabilidad < 100
    assert _penalizacion > 0 and _penalizacion < 100
    assert _duracionPeriodo > 0
    self.banco = msg.sender
    self.duracion = _duracion
    self.duracionPeriodo = _duracionPeriodo
    self.rentabilidad = _rentabilidad
    self.penalizacion = _penalizacion
    self.cliente = _cliente
    self.cantidad = _cantidad
   
#Funcion para firmar el contrato
@payable
@external
def firmar():
    assert not self.firma,"No firmado"
    assert msg.value == self.cantidad,"Cantidad exacta"
    assert msg.sender == self.cliente,"Cliente"
    self.firma = True
    self.duracion += block.timestamp 
    self.Periodo = block.timestamp + self.duracionPeriodo
    send(self.banco,msg.value)

#Funcion para cambiar de periodo y pagar la rentabilidad del capital al cliente
@payable    
@external
def cambiarPeriodo(_capital: uint256):
    assert msg.sender == self.banco,"Banco"
    assert msg.value == (_capital*self.rentabilidad)/100,"Cantidad exacta"
    assert block.timestamp > self.Periodo,"Periodo cumplido"
    self.Periodo += self.duracionPeriodo
    self.capital = _capital
    send(self.cliente,msg.value)

#Funcion para consultar el capital actual
@view
@external
def consultar()->uint256:
    assert msg.sender == self.cliente,"Cliente"
    return self.capital

#Funcion para cambiar el capital actual, solo puede acceder el banco
@external
def capital_actual(_capital : uint256):
    assert msg.sender == self.banco,"Banco"
    self.capital = _capital

#Funcion que te muestra la cantidad que recuperarias si sacases el ether en este momento
@view
@external
def recuperaria()->uint256:
    assert msg.sender == self.cliente,"Cliente"
    value: uint256 = self.capital
    if block.timestamp < self.duracion:
        value = (self.capital * (100 - self.penalizacion))/100
    return value

#Funcion para pedir sacar el ether del fondo de inversion        
@external
def sacar():
    assert msg.sender == self.cliente,"Cliente"
    if block.timestamp > self.duracion:
        log Recuperar(self.banco, msg.sender, self.capital)
        self.crecuperar = self.capital
    else:
        log Recuperar(self.banco, msg.sender, self.capital * (100 - self.penalizacion)/100)
        self.crecuperar = (self.capital * (100 - self.penalizacion))/100
    self.recuperar = True

#Funcion que envia el capital cuando lo solicita el cliente,destruye el contrato
@payable
@external
def devolver():
    assert self.recuperar,"Recuperar"
    assert msg.sender == self.banco,"Banco"
    assert msg.value == self.crecuperar,"Cantidad exacta"
    send(self.cliente,self.crecuperar)
    selfdestruct(self.banco)

#Alquiler de una bicicleta/vehículo por tiempo
# @version ^0.2.8

#Precio por unidad de tiempo
precio_udt: public(uint256)
#Direccion de la empresa
empresa: public(address)
#Tiempo maximo de uso por el ether introducido
tiempo_uso: public(uint256)
#Booleano que dice si el vehiculo está activo o no
usado: public(bool)
#Direccion del usuario
persona: public(address)
#Precio por empezar a usar el vehiculo
precio_inicio: public(uint256)

#Creador del contrato, que comprueba que el recio de uso sea mayor que 0.
@external
def __init__(_precio_udt: uint256, _precio_inicio: uint256):
    assert _precio_udt > 0
    self.precio_udt = _precio_udt
    self.empresa =msg.sender
    self.precio_inicio = _precio_inicio

#Funcion para alquilar el vehículo. Se puede alquilar el vehículo si no está en uso
# y si el ether enviado es mayor que el preio inicial del vehiculo.
@payable
@external
def alquilar():
    assert msg.value > self.precio_inicio, "Suficiente"
    assert not self.usado
    self.tiempo_uso = block.timestamp + (msg.value/self.precio_udt)
    self.usado = True
    self.persona = msg.sender

#Funcion a la que solo puede acceder la empresa cuando el vehiculo se esta usando
#y se esta usando por mas tiempo de lo que puede
#En este caso el vehiculo para( pasa a False el bool de uso) y se envia el ether e al empresa
@external
def fin_viaje():
    assert self.usado,"En uso"
    assert self.empresa == msg.sender,"Empresa"
    assert block.timestamp > self.tiempo_uso
    self.usado = False
    send(self.empresa,self.balance)

#Funcion externa a la que solo puede accder el ususario en caso de que el vehiculo este en uso
#y quiera pararlo. Se le devuelve el ether que no haya usado
@external
def dejar():
    assert self.usado,"En uso"
    assert msg.sender == self.persona,"Persona"
    assert block.timestamp <= self.tiempo_uso
    self.usado = False
    send(self.persona, (self.tiempo_uso - block.timestamp)*self.precio_udt)
    send(self.empresa,self.balance)

# @version ^0.2.8
#Creamos un evento par registrar el pago del transporte
event Pagar:
    emisor: indexed(address)
    receptor:indexed(address)
    valor: uint256

#Alquiler de transporte
empresa : public(address)
transporte: public(address)
t_estimado: public(uint256)
penalizacion_sueldo: public(uint256)
sueldo: public(uint256)

#Variable para inicializar solo una vez del envio
iniciado: bool
#Variable para almacenar el tiempo limite desde que se inicia el envio
tiempo: uint256
#Funcion constructora del contrato
@payable
@external
def __init__(_transporte: address, _tiempo_estimado: uint256,_pens: uint256):
    assert msg.value >= _pens
    self.empresa = msg.sender
    self.transporte = _transporte
    self.t_estimado = _tiempo_estimado
    self.penalizacion_sueldo = _pens
    self.sueldo = msg.value

#Funcion inicializadora del contrato
@external
def inicio():
    assert self.transporte == msg.sender,"Transporte"
    assert not self.iniciado,"No iniciado"
    self.iniciado = True
    self.tiempo = block.timestamp + self.t_estimado

#Funcion para que cobre el transportista en el caso de llegue a tiempo el sueldo total, en otro caso se le quitara la penalizacion
@external
def fin():
    assert self.iniciado,"Iniciado"
    assert msg.sender == self.empresa,"Empresa"
    valor: uint256 = 0
    if block.timestamp <= self.tiempo:
        send(self.transporte,self.sueldo)
        valor = self.sueldo
    else:
        send(self.transporte,self.sueldo - self.penalizacion_sueldo)
        valor = self.sueldo-self.penalizacion_sueldo
    log Pagar(self.empresa,self.transporte,valor)
    selfdestruct(self.empresa)

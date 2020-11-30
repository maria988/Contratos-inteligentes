#Alquiler de una casa con un evento
event Transaccion:
    receptor: indexed(address)
    emisor: indexed(address)
    valor: uint256
    
event Clave:
    receptor: indexed(address)
    emisor: indexed(address)
    clave_:uint256
        
    
arrendador: public(address)
arrendatario: public(address)
mensualidad: public(uint256)
tiempo: public(uint256)
tiempo_contrato: public(uint256)
alquilada: public(bool)
indice: uint256
fianza: uint256
llave: uint256
tiempo_mensual:public(uint256)

@payable
@external
def __init__( _mensualidad: uint256, _tiempo: uint256, _tiempo_contrato: uint256,_clave: uint256):
    self.fianza = msg.value
    self.arrendador = msg.sender
    self.mensualidad = _mensualidad
    self.tiempo = _tiempo
    self.tiempo_contrato = _tiempo_contrato
    self.llave = _clave

@payable    
@external
def alquilar(cantidad: uint256):
    assert not self.alquilada
    assert msg.value == self.fianza + self.mensualidad
    assert msg.value >= cantidad*(self.mensualidad+self.fianza)
    self.arrendatario = msg.sender
    self.alquilada = True
    self.tiempo_mensual = block.timestamp + self.tiempo
    send(self.arrendador,self.mensualidad)
    log Transaccion(self.arrendador,self.arrendatario,self.mensualidad)
    log Clave(self.arrendatario,self.arrendador,self.llave)
    self.llave = 0
    
@external
def darllave(clave: uint256):
    assert msg.sender == self.arrendador
    assert block.timestamp < self.tiempo_mensual
    self.llave = clave

@external
def cambio():
    assert block.timestamp > self.tiempo_mensual
    if block.timestamp > self.tiempo_contrato:
        send(self.arrendatario,self.fianza)
        selfdestruct(self.arrendador)
    else:
        if self.llave != 0:
            if self.balance == 2*self.fianza + self.mensualidad:
                log Transaccion(self.arrendador,self.arrendatario,self.mensualidad)
                send(self.arrendador,self.mensualidad)
                log Clave(self.arrendatario,self.arrendador,self.llave)
                self.tiempo_mensual = block.timestamp + self.tiempo
                self.llave = 0
            else:
                selfdestruct(self.arrendador)
        else:
            selfdestruct(self.arrendatario)

@payable
@external
def pagar():
    assert msg.sender == self.arrendatario
    assert block.timestamp < self.tiempo_mensual
    assert msg.value > 0
    assert msg.value == self.mensualidad

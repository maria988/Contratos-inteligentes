# @version ^0.2.8

#Contrato para alquilar una casa/piso

#Creamos un evento para que queden registradas las transacciones mensuales.
event Transaccion:
    receptor: indexed(address)
    emisor: indexed(address)
    valor: uint256

#Variables inicializadas por el arrendador
#Direcciond del arrendador,la fianza y mensualidad del inmueble.
#Periodo de tiempo entre una paga y otra, tiempo que dura el contrato y el tope de tiempo para pagar
             
arrendador: public(address)
fianza: public(uint256)
mensualidad: public(uint256)
tiempo: public(uint256)
tiempo_contrato: public(uint256)
tiempo_mensual:public(uint256)

#Booleano que muestra si está alquilada, la direccion del arrendatario y si se ha pagado el mes
alquilada: public(bool)
arrendatario: public(address)
pagada: public(bool)
#Constructor del contrato en el que el arrendador da la fianza del inmueble,
#y en el caso de que eche al arrendatario sin haber terminado el contrato
#, le daría la fianza( por las molestias) (Se puede quitar en cualquier momento)

@payable
@external
def __init__( _mensualidad: uint256, _tiempo: uint256, _tiempo_contrato: uint256):
    assert msg.value > 0
    assert _mensualidad > 0
    assert _tiempo > 0
    assert _tiempo_contrato >= _tiempo
    self.fianza = msg.value
    self.arrendador = msg.sender
    self.mensualidad = _mensualidad
    self.tiempo = _tiempo
    self.tiempo_contrato = _tiempo_contrato

#Funcion para alquilar la casa en caso de que no esté alquilada
@payable    
@external
def alquilar():
    assert not self.alquilada,"No esta alquilada"
    assert msg.value == self.fianza + self.mensualidad,"Valor exacto"
    self.arrendatario = msg.sender
    self.alquilada = True
    self.tiempo_mensual = block.timestamp + self.tiempo
    self.tiempo_contrato += block.timestamp
    self.alquilada = True
    #Se envia la mensualidad al arrendador y la fianza se queda en el deposito hasta que se termine el contrato
    send(self.arrendador,self.mensualidad)
    log Transaccion(self.arrendador,self.arrendatario,self.mensualidad)
    
#Funcion para hacer el cambio de ether por que la puerta se abra,
# se ha de realizar despues de que se termine el tiempo mensual
@external
def cambio():
    assert self.alquilada,"Alquilada"
    assert block.timestamp > self.tiempo_mensual,"Plazo cumplido"
    assert msg.sender == self.arrendador or msg.sender == self.arrendatario,"Arrendador o arrendatario"
    #Si el tiempo actual es mayor que el tiempo de contrato se devuelve la fianza y se destruye el contrato.
    if block.timestamp >= self.tiempo_contrato:
        send(self.arrendatario,self.fianza)
        selfdestruct(self.arrendador)
    else:
        #Si el arrendatario ha pagado el mes
        if self.pagada:
            log Transaccion(self.arrendador,self.arrendatario,self.mensualidad)
            send(self.arrendador,self.mensualidad)
            self.tiempo_mensual += self.tiempo
            self.pagada = False
               
        else:
            self.alquilada=False
        
#Funcion para que el arrendatario deposite el ether para pagar la mensualidad
@payable
@external
def pagar():
    assert self.alquilada,"Alquilada"
    assert msg.sender == self.arrendatario,"Arrendatario"
    assert block.timestamp <= self.tiempo_mensual,"Dentro del plazo"
    assert msg.value == self.mensualidad,"Mensualidad"
    self.pagada = True

#Funcion que solo se puede ejecutar cuando el arrendador la pida y destruye el contrato
@external
def eliminarcontrato():
    assert msg.sender == self.arrendador,"Arrendador"
    assert block.timestamp < self.tiempo_contrato,"Dentro del tiempo del contrato"
    if self.alquilada :
        selfdestruct(self.arrendatario)
    else:
        selfdestruct(self.arrendador)

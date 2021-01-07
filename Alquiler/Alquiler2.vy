# @version ^0.2.8
#Contrato para alquilar una casa/piso

#Creamos un evento para que queden registradas las transacciones mensuales.
event Transaccion:
    receptor: indexed(address)
    emisor: indexed(address)
    valor: uint256
    
#Creamos un evento para que el arrendatario pueda ver la clave 
event Clave:
    receptor: indexed(address)
    emisor: indexed(address)
    clave_:uint256
        
#Variables inicializadas por el arrendador
#Direcciond del arrendador,la fianza y mensualidad del inmueble.
#Periodo de tiempo entre una paga y otra, tiempo que dura el contrato y el tope de tiempo para pagar    
arrendador: public(address)
fianza: public(uint256)
mensualidad: public(uint256)
tiempo: public(uint256)
tiempo_contrato: public(uint256)
tiempo_mensual:public(uint256)

#Booleano que muestra si está alquilada, la direccion del arrendatario y un booleano para saber si se ha pagado el mes
arrendatario: public(address)
alquilada: public(bool)
pagada: bool
#Clave que proporciona el arrendador cada mes para que la puerta se abra
llave: uint256

#Constructor del contrato en el que el arrendador da la fianza del inmueble,
#y en el caso de que eche al arrendatario sin haber terminado el contrato
#, le daría la fianza( por las molestias) (Se puede quitar en cualquier momento)
@payable
@external
def __init__( _mensualidad: uint256, _tiempo: uint256, _tiempo_contrato: uint256,_llave: uint256):
    assert msg.value > 0
    assert _mensualidad > 0
    assert _tiempo > 0
    assert _tiempo_contrato >= _tiempo
    self.fianza = msg.value
    self.arrendador = msg.sender
    self.mensualidad = _mensualidad
    self.tiempo = _tiempo
    self.llave = _llave
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
    self.pagada = True
    send(self.arrendador,self.mensualidad)
    log Transaccion(self.arrendador,self.arrendatario,self.mensualidad)
    log Clave(self.arrendatario,self.arrendador,self.llave)
    #La llave es 0 hasta que el arrendador la cambie
    self.llave = 0

#Funcion que usa el arrendador para guardar la llave del mes siguiente
#para darsela al arrendatario en el caso de que pague
@external
def darllave(clave: uint256):
    assert self.alquilada,"Alquilada"
    assert msg.sender == self.arrendador,"Arrendador"
    assert block.timestamp < self.tiempo_mensual,"Dentro de plazo"
    self.llave = clave

#Funcion para hacer el cambio de ether por la llave,
# se ha de realizar despues de que se termine el tiempo mensual
@external
def cambio():
    assert self.alquilada,"Alquilada"
    assert block.timestamp > self.tiempo_mensual,"Plazo cumplido"
    assert msg.sender == self.arrendador or msg.sender == self.arrendatario,"Arrendador o arrendatario"
    if block.timestamp > self.tiempo_contrato:
        send(self.arrendatario,self.fianza)
        selfdestruct(self.arrendador)
    else:
       
        if self.llave != 0:
            #Si se ha pagado el alquiler y se ha guardado la llave, se registran ambos eventos
            if self.pagada:
                log Transaccion(self.arrendador,self.arrendatario,self.mensualidad)
                send(self.arrendador,self.mensualidad)
                log Clave(self.arrendatario,self.arrendador,self.llave)
                self.tiempo_mensual = block.timestamp + self.tiempo
                self.llave = 0
                self.pagada = False
            #Si el arrendadatario no paga se destruye el contrato y el ether va al arrendador
            else:
                selfdestruct(self.arrendador)
        #Si el arrendador no da la llave se destruye el contrato y el ether va al arrendatario
        else:
            selfdestruct(self.arrendatario)
            
#Funcion para que el arrendatario pague el mes siguiente
@payable
@external
def pagar():
    assert self.alquilada,"Alquilada"
    assert msg.sender == self.arrendatario,"Arrendatario"
    assert block.timestamp < self.tiempo_mensual,"Dentro del plazo"
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

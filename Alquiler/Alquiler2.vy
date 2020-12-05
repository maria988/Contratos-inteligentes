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
def __init__( _mensualidad: uint256, _tiempo: uint256, _tiempo_contrato: uint256,_clave: uint256):
    assert msg.value > 0
    assert _mensualidad > 0
    assert _tiempo > 0
    assert _tiempo_contrato >= _tiempo
    self.fianza = msg.value
    self.arrendador = msg.sender
    self.mensualidad = _mensualidad
    self.tiempo = _tiempo
    self.tiempo_contrato = _tiempo_contrato
    self.llave = _clave

#Funcion para alquilar la casa en caso de que no esté alquilada
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
    #La llave es 0 hasta que el arrendador la cambie
    self.llave = 0

#Funcion que usa el arrendador para guardar la llave del mes siguiente
#para darsela al arrendatario en el caso de que pague
@external
def darllave(clave: uint256):
    assert msg.sender == self.arrendador
    assert block.timestamp < self.tiempo_mensual
    self.llave = clave

#Funcion para hacer el cambio de ether por la llave,
# se ha de realizar despues de que se termine el tiempo mensual
@external
def cambio():
    assert block.timestamp > self.tiempo_mensual
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
    assert msg.sender == self.arrendatario
    assert block.timestamp < self.tiempo_mensual
    assert msg.value > 0
    assert msg.value == self.mensualidad
    self.pagada = True
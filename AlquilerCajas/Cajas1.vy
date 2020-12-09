#Alquiler de cajas fuertes/trasteros
#Creamos un evento para que quede registrada la transaccion mensual
event Transaccion:
    receptor: indexed(address)
    emisor: indexed(address)
    valor: uint256
    
#Creamos un evento para que quede registrada la clave para poder abrir la caja    
event Clave:
    receptor: indexed(address)
    emisor: indexed(address)
    clave_:uint256

#Creamos la estructura Caja para elemento a alquilar     
struct Caja:
    propietario: address
    tdisfrute: uint256
    ttope: uint256
    pagada: bool
    llave: uint256
    dejar: bool
    

#Direccion de la empresa    
tienda: public(address)
#Cantidad de cajas que hay libres
cajas : public(uint256)
#precio mensual de cada caja
mensualidad: public(uint256)
#Tope de tiempo para usarla
tiempo_disfrute:public(uint256)
#Diccionario que a cada caja le asigna todas las variables de la estructura Caja
clientes: public(HashMap[uint256, Caja])
indice: uint256
fianza: uint256
tiempo_pagar : uint256
#Cajas que hay totales
cajas_totales: uint256
indice_libres: uint256
cajaslibres: HashMap[uint256,uint256]

#Funcion par ainicializar el contrato
#Comprueba que haya cajas,que el valor de las mismas sea mayor que 0,
#el tiemo de disfrute y el de pagar sea mayor que 0.
@external
def __init__(_cajas: uint256, _mensualidad: uint256, _tiempo_disfrute: uint256,_tiempo_pagar: uint256,_fianza: uint256):
    self.tienda = msg.sender
    self.cajas = _cajas
    self.cajas_totales = _cajas
    self.mensualidad = _mensualidad
    self.tiempo_disfrute = _tiempo_disfrute
    self.tiempo_pagar = _tiempo_pagar
    self.fianza = _fianza


#Funcion para alquilar una caja
@payable    
@external
def alquilar():
    #Se revierte si todas las cajas estan ocupadas
    assert self.cajas > 0
    #El ether mandado debe de ser igual que el valor de la mensualidad y la fianza
    assert msg.value == self.mensualidad + self.fianza
    #Inicialmente se reparten las cajas segun se vayan pidiendo
    #cuando superan el numero de cajas totales pasa al siguiente apartado
    if self.indice <= self.cajas_totales:
        self.clientes[self.indice]=Caja({propietario: msg.sender,
                                         tdisfrute: block.timestamp + self.tiempo_disfrute, 
                                         ttope: block.timestamp + self.tiempo_disfrute + self.tiempo_pagar,
                                         pagada: True,llave:0, dejar: False})
        self.indice += 1
    #Si hay cajas y el indice es mayor que las cajas totales
    #Hay cajas sueltas disponibles
    else:
        index: uint256 = self.cajaslibres [self.indice_libres - 1]
        self.clientes[index]=Caja({propietario: msg.sender,tdisfrute: block.timestamp + self.tiempo_disfrute, 
                                   ttope: block.timestamp + self.tiempo_disfrute + self.tiempo_pagar,
                                   pagada: True,llave:0,  dejar: False})
        self.indice_libres -= 1
    self.cajas -= 1
    
#Funcion para almacenar la llave de la caja, se dara la llave
#al propietario si ha pagado el mes    
@external
def asignarllave(clave: uint256, ncaja: uint256):
    assert msg.sender == self.tienda
    assert ncaja < self.indice
    assert clave != 0
    caja_: Caja = self.clientes[ncaja]
    caja_.llave = clave

#Funcion interna para saber si una persona no ha pagado y esta usando la caja
#Si es moroso, se vacia la caja y queda libre    
@internal
def _moroso(ncaja:uint256):
    caja_: Caja = self.clientes[ncaja]
    assert not caja_.pagada
    assert (caja_.ttope < block.timestamp) or (caja_.dejar)
    caja_=empty(Caja)
    self.cajas += 1
    self.cajaslibres[self.indice_libres] = ncaja
    self.indice_libres += 1

#Funcion que dada el numero de la caja devuelve un booleano
#para saber si esta pagada o no
@view
@external
def tqpagar(ncaja: uint256)-> bool:
    return self.clientes[ncaja].pagada

#Funcion que dado un numero de caja devuelve el tiempo que le queda del uso de la caja
#si no ha pagado mas
@view
@external
def tiempoqueda(ncaja: uint256) -> uint256:
    assert ncaja < self.indice
    assert not self.clientes[ncaja].pagada
    return self.clientes[ncaja].tdisfrute - block.timestamp

#Funcion interna que dado un numero de caja devulve el tiempo que le queda para poder pagar
@view
@external
def tiempoquedapagar(ncaja: uint256) -> uint256:
    assert self.clientes[ncaja].tdisfrute > block.timestamp
    return self.clientes[ncaja].tdisfrute - block.timestamp

#Funcion que dado el numero de una caja hace el cambio 
#entre la cuota y la llave
@external
def cambio(ncaja:uint256):
    #Se comprueba que es un numero de caja valido
    assert ncaja < self.cajas_totales
    caja_: Caja = self.clientes[ncaja]
    #Se comprueba que el tiempo de uso es menor que el tiempo actual
    assert caja_.tdisfrute < block.timestamp
    #Si se ha pasado el tiempo de disfrute
    if caja_.ttope < block.timestamp:
        #Si se ha pagado el mes pero no hay clave
        if caja_.pagada:
            send(caja_.propietario,self.fianza + self.mensualidad)
        #Si se ha dado la llave pero no se ha pagado se llama a la funcion _moroso
        else:
            self._moroso(ncaja)
    #Si todavia esta dentro del tiempo de cambio
    else:
        #Si el cliente quiere dejar la caja
        if caja_.dejar:
            send(self.tienda,self.mensualidad)
            send(caja_.propietario,self.fianza)
            log Transaccion(self.tienda,caja_.propietario,self.mensualidad)
            caja_.pagada = False
            self._moroso(ncaja)
        #Si no se ha dado la llave
        elif caja_.llave == 0:
            send(caja_.propietario,self.fianza+self.mensualidad)
            log Transaccion(self.tienda,caja_.propietario,self.mensualidad)
            caja_.pagada = False
            caja_.dejar = True
            self._moroso(ncaja)
        #Si esta pagada y hay llave
        else:
            caja_.pagada = False
            caja_.tdisfrute += self.tiempo_disfrute
            caja_.ttope = caja_.tdisfrute + self.tiempo_pagar
            send(self.tienda,self.mensualidad)
            log Transaccion(self.tienda,caja_.propietario,self.mensualidad)
            log Clave(caja_.propietario,self.tienda,caja_.llave)
            caja_.llave = 0
      
#Funcion para que el cliente pague la mensualidad de la caja
@payable
@external
def pagos(ncaja: uint256):
    caja_: Caja = self.clientes[ncaja]
    assert not caja_.pagada
    assert msg.value == self.mensualidad
    assert caja_.propietario == msg.sender
    assert block.timestamp <= caja_.tdisfrute
    caja_.pagada = True


#Funcion que dado un numero de caja, el cliente pueda dejarla para el mes siguiente
@external
def dejarcaja(ncaja: uint256):
    assert self.clientes[ncaja].tdisfrute >= block.timestamp
    self.clientes[ncaja].dejar = True

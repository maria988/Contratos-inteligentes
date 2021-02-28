# @version ^0.2.8
#Alquiler de cajas fuertes/trasteros
#Variación de cajas1 que tiene un gasto de gas mayor que este

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
    primera: bool
    
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
fianza: public(uint256)
tiempo_pagar : public(uint256)
#Cajas que hay totales
cajas_totales: uint256
indice_libres: uint256
cajaslibres: HashMap[uint256,uint256]

#Diccionario que a cada numero de caja se le asigna un bool para saber si se esta usando o no
uso: public(HashMap[uint256, bool])

#Funcion par ainicializar el contrato
#Comprueba que haya cajas,que el valor de las mismas sea mayor que 0,
#el tiemo de disfrute y el de pagar sea mayor que 0.
@external
def __init__(_cajas: uint256, _mensualidad: uint256, _tiempo_disfrute: uint256,_tiempo_pagar: uint256,_fianza: uint256):
    assert _cajas > 0
    assert _mensualidad > 0
    assert _tiempo_disfrute > 0
    assert _tiempo_pagar> 0
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
    assert self.cajas > 0,"Suficientes cajas"
    #El ether mandado debe de ser igual que el valor de la mensualidad y la fianza
    assert msg.value == self.mensualidad + self.fianza,"Valor exacto"
    #Inicialmente se reparten las cajas segun se vayan pidiendo
    #cuando superan el numero de cajas totales pasa al siguiente apartado
    if self.indice <= self.cajas_totales:
        self.clientes[self.indice]=Caja({propietario: msg.sender,
                                         tdisfrute: block.timestamp + self.tiempo_disfrute, 
                                         ttope: block.timestamp + self.tiempo_disfrute + self.tiempo_pagar,
                                         pagada: True,llave:1, dejar: False,primera:True})
        self.uso[self.indice] = True
        self.indice += 1
    #Si hay cajas y el indice es mayor que las cajas totales
    #Hay cajas sueltas disponibles
    else:
        index: uint256 = self.cajaslibres [self.indice_libres - 1]
        self.clientes[index]=Caja({propietario: msg.sender,tdisfrute: block.timestamp + self.tiempo_disfrute, 
                                   ttope: block.timestamp + self.tiempo_disfrute + self.tiempo_pagar,
                                   pagada: True,llave:1, dejar: False,primera:True})
        self.uso[index] = True
        self.indice_libres -= 1
    self.cajas -= 1
    
#Funcion para almacenar la llave de la caja, se dara la llave
#al propietario si ha pagado el mes
@external
def asignarllave(clave: uint256, ncaja: uint256):
    assert self.uso[ncaja],"Caja asignada"
    assert block.timestamp <= self.clientes[ncaja].tdisfrute,"Dentro de tiempo"
    assert msg.sender == self.tienda,"Tienda"
    assert clave > 1,"Clave valida"
    self.clientes[ncaja].llave = clave

#Funcion interna para saber si una persona no ha pagado y esta usando la caja
#Si es moroso, se vacia la caja y queda libre
@internal
def _moroso(ncaja:uint256):
    self.uso[ncaja]=False
    self.clientes[ncaja]=empty(Caja)
    self.cajas += 1
    self.cajaslibres[self.indice_libres] = ncaja
    self.indice_libres += 1
    
#Funcion interna que dada el numero de la caja devuelve un booleano
#para saber si esta pagada o no
@view
@internal
def _tqpagar(ncaja: uint256) -> bool:
    return not self.clientes[ncaja].pagada

#Funcion externa que llama a la anterior
@view
@external
def tqpagar(ncaja: uint256)-> bool:
    assert self.uso[ncaja],"Caja asignada"
    assert (msg.sender == self.tienda or self.clientes[ncaja].propietario == msg.sender),"Propietario o tienda"
    return self._tqpagar(ncaja)

#Funcion interna que dado un numero de caja devuelve el tiempo que le queda del uso de la caja
#si no ha pagado mas
@view
@internal
def _tiempoqueda(ncaja: uint256)-> uint256:
    return self.clientes[ncaja].tdisfrute - block.timestamp

#Funcion externa que llama a la anterior
@view
@external
def tiempoqueda(ncaja: uint256) -> uint256:
    assert self.uso[ncaja],"Caja asignada"
    assert (self.clientes[ncaja].propietario == msg.sender or self.tienda == msg.sender),"Propietario o tienda"
    assert block.timestamp <= self.clientes[ncaja].tdisfrute,"Dentro de tiempo"
    return self._tiempoqueda(ncaja)

#Funcion que dado el numero de una caja hace el cambio 
#entre la cuota y la llave
@external
def cambio(ncaja:uint256):
    #Se comprueba que es un numero de caja valido
    assert self.uso[ncaja],"Caja asignada"
    #Se comprueba que quien llama a la funcion es el propietario o la tienda
    assert (self.clientes[ncaja].propietario == msg.sender or self.tienda == msg.sender),"Propietario o tienda"
    #Se comprueba que el tiempo de uso es menor que el tiempo actual
    assert ((self.clientes[ncaja].tdisfrute < block.timestamp) or (self.clientes[ncaja].primera) or (self.clientes[ncaja].dejar)),"Posibilidades de llamada"
    #Si se ha pasado el tiempo tope de pago
    if self.clientes[ncaja].ttope < block.timestamp:
        #Si se ha pagado el mes pero no hay clave
        if self.clientes[ncaja].pagada:
            send(self.clientes[ncaja].propietario,self.fianza + self.mensualidad)
        #Si se ha dado la llave pero no se ha pagado se llama a la funcion _moroso
        else:
            self._moroso(ncaja)
    #Si todavia esta dentro del tiempo de cambio
    else:
        #Si el cliente quiere dejar la caja
        if self.clientes[ncaja].dejar:
            send(self.tienda,self.mensualidad)
            send(self.clientes[ncaja].propietario,self.fianza)
            log Transaccion(self.tienda,self.clientes[ncaja].propietario,self.mensualidad)
            self.clientes[ncaja].pagada = False
            self._moroso(ncaja)
        #Si no se ha dado la llave
        elif self.clientes[ncaja].llave == 0:
            send(self.clientes[ncaja].propietario,self.fianza+self.mensualidad)
            log Transaccion(self.tienda,self.clientes[ncaja].propietario,self.mensualidad)
            self.clientes[ncaja].pagada = False
            self.clientes[ncaja].dejar = True
            self._moroso(ncaja)
        #Si esta pagada y hay llave
        else:
            self.clientes[ncaja].pagada = False
            send(self.tienda,self.mensualidad)
            log Transaccion(self.tienda,self.clientes[ncaja].propietario,self.mensualidad)
            log Clave(self.clientes[ncaja].propietario,self.tienda,self.clientes[ncaja].llave)
            self.clientes[ncaja].llave = 0
            if self.clientes[ncaja].primera:
                self.clientes[ncaja].primera = False
            else:
                self.clientes[ncaja].tdisfrute += self.tiempo_disfrute
                self.clientes[ncaja].ttope = self.clientes[ncaja].tdisfrute + self.tiempo_pagar
                
     


#Funcion para que el cliente pague la mensualidad de la caja
@payable
@external
def pagar(ncaja: uint256):
    assert self.uso[ncaja],"Caja asignada"
    assert self.clientes[ncaja].propietario == msg.sender,"Propietario"
    assert not self.clientes[ncaja].pagada,"No pagada"
    assert msg.value == self.mensualidad,"Valor exacto"
    assert block.timestamp <= self.clientes[ncaja].tdisfrute,"Dentro de tiempo"
    self.clientes[ncaja].pagada = True


#Funcion que dado un numero de caja, el cliente pueda dejarla para el mes siguiente
@external
def dejarcaja(ncaja: uint256):
    assert self.uso[ncaja],"Caja asignada"
    assert msg.sender == self.clientes[ncaja].propietario,"Propietario"
    assert block.timestamp <= self.clientes[ncaja].tdisfrute,"Dentro de tiempo"
    self.clientes[ncaja].dejar = True

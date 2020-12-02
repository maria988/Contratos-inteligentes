#Alquiler de cajas fuertes
event Transaccion:
    receptor: indexed(address)
    emisor: indexed(address)
    valor: uint256
    
event Clave:
    receptor: indexed(address)
    emisor: indexed(address)
    clave_:uint256
    
struct Caja:
    propietario: address
    tdisfrute: uint256
    ttope: uint256
    n_caja: uint256
    pagada: bool
    llave: uint256
    cambio: bool
    dejar: bool
    
    
tienda: public(address)
cajas : public(uint256)
mensualidad: public(uint256)
tiempo_disfrute:public(uint256)
clientes: public(HashMap[uint256, Caja])
indice: uint256
fianza: uint256
tiempo_pagar : uint256
cajas_totales: uint256
indice_libres: uint256
cajaslibres: HashMap[uint256,uint256]


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



@payable    
@external
def alquilar():
    assert self.cajas > 0
    assert msg.value == self.mensualidad + self.fianza
    assert self.indice_libres > 1
    if self.indice <= self.cajas_totales:
        self.clientes[self.indice]=Caja({propietario: msg.sender,
                                         tdisfrute: block.timestamp + self.tiempo_disfrute, 
                                         ttope: block.timestamp + self.tiempo_disfrute + self.tiempo_pagar,
                                         n_caja: self.indice, pagada: True,llave:0, cambio: False, dejar: False})
        self.indice += 1
    else:
        index: uint256 = self.cajaslibres [self.indice_libres - 1]
        self.clientes[index]=Caja({propietario: msg.sender,tdisfrute: block.timestamp + self.tiempo_disfrute, 
                                   ttope: block.timestamp + self.tiempo_disfrute + self.tiempo_pagar,
                                   n_caja: index, pagada: True,llave:0, cambio: False, dejar: False})
        self.indice_libres -= 1
    self.cajas -= 1
    
    
@external
def asignarllave(clave: uint256, ncaja: uint256):
    assert msg.sender == self.tienda
    assert ncaja < self.indice
    assert clave != 0
    self.clientes[ncaja].llave = clave
    self.clientes[ncaja].cambio = False
    
@internal
def _moroso(ncaja:uint256):
    assert not self.clientes[ncaja].pagada
    assert (self.clientes[ncaja].ttope < block.timestamp) or (self.clientes[ncaja].dejar)
    self.clientes[ncaja]=empty(Caja)
    self.cajas += 1
    self.cajaslibres[self.indice_libres] = ncaja
    self.indice_libres += 1
    
        

@view
@internal
def _tqpagar(ncaja: uint256) -> bool:
    return self.clientes[ncaja].pagada

@view
@external
def tqpagar(ncaja: uint256)-> bool:
    return self._tqpagar(ncaja)


@view
@internal
def _tiempoqueda(ncaja: uint256)-> uint256:
    assert ncaja < self.indice
    assert not self._tqpagar(ncaja)
    return self.clientes[ncaja].tdisfrute - block.timestamp

@view
@external
def tiempoqueda(ncaja: uint256) -> uint256:
    return self._tiempoqueda(ncaja)

@view
@internal
def _tiempoquedapagar(ncaja: uint256)-> uint256:
    assert self.clientes[ncaja].ttope > block.timestamp
    return self.clientes[ncaja].ttope - block.timestamp

@view
@external
def tiempoquedapagar(ncaja: uint256) -> uint256:
    return self._tiempoquedapagar(ncaja)

@external
def cambio(ncaja:uint256):
    assert ncaja < self.indice
    assert not self.clientes[ncaja].cambio
    assert self.clientes[ncaja].tdisfrute < block.timestamp
    #Si se ha pasado el tiempo de disfrute
    if self.clientes[ncaja].ttope < block.timestamp:
        #Si se ha pagado el mes pero no hay clave
        if self.clientes[ncaja].pagada:
            send(self.clientes[ncaja].propietario,self.fianza + self.mensualidad)
        else:
            self._moroso(ncaja)
    else:
        assert self.clientes[ncaja].pagada
        assert self.clientes[ncaja].llave != 0
        if self.clientes[ncaja].dejar:
            send(self.tienda,self.mensualidad)
            send(self.clientes[ncaja].propietario,self.fianza)
            log Transaccion(self.tienda,self.clientes[ncaja].propietario,self.mensualidad)
            self.clientes[ncaja].pagada = False
            self._moroso(ncaja)
        else:
            self.clientes[ncaja].cambio = True
            self.clientes[ncaja].pagada = False
            self.clientes[ncaja].tdisfrute += self.tiempo_disfrute
            self.clientes[ncaja].ttope = self.clientes[ncaja].tdisfrute + self.tiempo_pagar
            send(self.tienda,self.mensualidad)
            log Transaccion(self.tienda,self.clientes[ncaja].propietario,self.mensualidad)
            log Clave(self.clientes[ncaja].propietario,self.tienda,self.clientes[ncaja].llave)
            self.clientes[ncaja].llave = 0
      

@payable
@external
def pagos(ncaja: uint256):
    assert not self.clientes[ncaja].pagada
    assert msg.value == self.mensualidad
    assert self.clientes[ncaja].propietario == msg.sender
    assert block.timestamp <= self.clientes[ncaja].tdisfrute
    self.clientes[ncaja].pagada = True
    self.clientes[ncaja].cambio = False



@external
def dejarcaja(ncaja: uint256):
    assert self.clientes[ncaja].tdisfrute >= block.timestamp
    self.clientes[ncaja].dejar = True

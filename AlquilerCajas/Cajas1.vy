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

@external
def __init__(_cajas: uint256, _mensualidad: uint256, _tiempo_disfrute: uint256,_tiempo_pagar: uint256,_fianza: uint256):
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
    assert self.indice_libres > 0
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
    caja_: Caja = self.clientes[ncaja]
    caja_.llave = clave
    caja_.cambio = False
    
@internal
def _moroso(ncaja:uint256):
    caja_: Caja = self.clientes[ncaja]
    assert not caja_.pagada
    assert (caja_.ttope < block.timestamp) or (caja_.dejar)
    caja_=empty(Caja)
    self.cajas += 1
    self.cajaslibres[self.indice_libres] = ncaja
    self.indice_libres += 1


@view
@external
def tqpagar(ncaja: uint256)-> bool:
    return self.clientes[ncaja].pagada


@view
@external
def tiempoqueda(ncaja: uint256) -> uint256:
    assert ncaja < self.indice
    assert not self.clientes[ncaja].pagada
    return self.clientes[ncaja].tdisfrute - block.timestamp


@view
@external
def tiempoquedapagar(ncaja: uint256) -> uint256:
    assert self.clientes[ncaja].ttope > block.timestamp
    return self.clientes[ncaja].ttope - block.timestamp

@external
def cambio(ncaja:uint256):
    caja_: Caja = self.clientes[ncaja]
    assert ncaja < self.indice
    assert not caja_.cambio
    assert caja_.tdisfrute < block.timestamp
    #Si se ha pasado el tiempo de disfrute
    if caja_.ttope < block.timestamp:
        #Si se ha pagado el mes pero no hay clave
        if caja_.pagada:
            send(caja_.propietario,self.fianza + self.mensualidad)
        else:
            self._moroso(ncaja)
    else:
        assert caja_.pagada
        assert caja_.llave != 0
        if caja_.dejar:
            send(self.tienda,self.mensualidad)
            send(caja_.propietario,self.fianza)
            log Transaccion(self.tienda,caja_.propietario,self.mensualidad)
            caja_.pagada = False
            self._moroso(ncaja)
        else:
            caja_.cambio = True
            caja_.pagada = False
            caja_.tdisfrute += self.tiempo_disfrute
            caja_.ttope = caja_.tdisfrute + self.tiempo_pagar
            send(self.tienda,self.mensualidad)
            log Transaccion(self.tienda,caja_.propietario,self.mensualidad)
            log Clave(caja_.propietario,self.tienda,caja_.llave)
            caja_.llave = 0
      

@payable
@external
def pagos(ncaja: uint256):
    caja_: Caja = self.clientes[ncaja]
    assert not caja_.pagada
    assert msg.value == self.mensualidad
    assert caja_.propietario == msg.sender
    assert block.timestamp <= caja_.tdisfrute
    caja_.pagada = True
    caja_.cambio = False



@external
def dejarcaja(ncaja: uint256):
    assert self.clientes[ncaja].tdisfrute >= block.timestamp
    self.clientes[ncaja].dejar = True

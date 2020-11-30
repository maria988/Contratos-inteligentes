#devolucion de importe si no sale a tiempo

event Devolucion:
    emisor: indexed(address)
    receptor: indexed(address)
    value: uint256
    
event Compra:
    comprador:indexed(address)
    vendedor: indexed(address)
    valor: uint256


empresa: public(address)
precio: public(uint256)
porc_a_devolver: public(decimal)
tiempo_salida: public(uint256)
tiempo_pasado: public(uint256)
salido: public(bool)
asientos: uint256
clientes: public(HashMap[uint256,address])
indice: uint256
indice2: uint256
dinero: uint256
terminado: bool

@external
def __init__(_asientos: uint256,_precio: uint256,_porc_a_devolver: decimal,_tiempo_salida: uint256):
    assert _asientos > 0
    assert _precio > 0
    assert _porc_a_devolver > 0.0
    assert _porc_a_devolver <= 100.0
    self.asientos = _asientos
    self.empresa = msg.sender
    self.precio = _precio
    self.porc_a_devolver =_porc_a_devolver
    self.tiempo_salida = _tiempo_salida
    
@payable
@external
def comprar(cantidad:uint256):
    assert cantidad > 0
    assert cantidad <4
    assert cantidad <= self.asientos
    assert msg.value >= cantidad*self.precio
    self.clientes[self.indice]=msg.sender
    if cantidad > 1:
        self.clientes[self.indice+1]=msg.sender
        if cantidad > 2:
           self.clientes[self.indice+2]=msg.sender
    self.indice += cantidad
    log Compra(msg.sender,self.empresa,msg.value)
    self.asientos -= cantidad



@external
def asalido():
    assert not self.salido
    assert msg.sender == self.empresa
    self.salido = True
    if self.tiempo_salida > block.timestamp:
        cambio: decimal = convert(block.timestamp - self.tiempo_salida ,decimal)
        self.dinero = convert((cambio * self.porc_a_devolver)/100.0,uint256)
    
        
@external
def devolucionalosclientes():
    assert self.salido
    assert not (self.tiempo_salida > block.timestamp)
    index: uint256 = self.indice2
    for i in range(index,index+20):
        if i > self.indice:
            index = self.indice
            self.terminado = True
            return
        log Devolucion(self.empresa,self.clientes[i],self.dinero)
        send(self.clientes[i],self.dinero)
        
    self.indice2= index + 20
    
@external
def cobroempresa():
    assert self.terminado
    selfdestruct(self.empresa)

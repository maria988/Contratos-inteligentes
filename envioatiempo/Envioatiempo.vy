#devolucion de importe si no llega a tiempo

event Devolucion:
    emisor: indexed(address)
    receptor: indexed(address)
    value: uint256

event Compra:
    comprador:indexed(address)
    vendedor: indexed(address)
    valor: uint256

empresa: public(address)
comprador: public(address)
precio: public(uint256)
porc_a_devolver: public(decimal)
tiempo_envio: public(uint256)
tiempo_restante: public(uint256)
recibido: public(bool)

@external
def __init__(_precio: uint256,_porc_a_devolver: decimal,_tiempo_envio: uint256):
    assert _precio > 0
    assert _porc_a_devolver > 0.0
    assert _porc_a_devolver <= 100.0
    self.empresa = msg.sender
    self.precio = _precio
    self.porc_a_devolver =_porc_a_devolver
    self.tiempo_envio = _tiempo_envio
    
@payable
@external
def comprar():
    assert msg.value > 0
    assert msg.value >= self.precio
    self.comprador = msg.sender
    log Compra(msg.sender,self.empresa,self.precio)
    if msg.value > self.precio:
        send(msg.sender,msg.value-self.precio)
    self.tiempo_restante = block.timestamp + self.tiempo_envio

@external
def frecibido():
    assert not self.recibido
    assert msg.sender == self.comprador
    d_devolver: uint256 = 0
    self.recibido = True
    if self.tiempo_restante < block.timestamp:
        cambio: decimal = convert(self.precio,decimal)
        d_devolver = convert((cambio * self.porc_a_devolver)/100.0,uint256)
         
    log Devolucion(self.empresa,msg.sender,d_devolver)
    send(msg.sender,d_devolver)
    selfdestruct(self.empresa)
    
    
    

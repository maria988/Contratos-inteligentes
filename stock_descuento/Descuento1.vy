#Hay un stock de producto que se rebaja durante una determinada hora
#y durante un determinado periodo de tiempo

#valor inicial del producto
value:public(uint256)
#valor del producto con descuento
discount:public(uint256)
#vendedor
seller:public(address)
#empiezo y duracion de la oferta
start:public(uint256)
end :public(uint256)
#Stock para vender
stock:public(uint256)

@external
def __init__(_stock: uint256,price: uint256 ,_star: uint256 ,_end: uint256 ,_discount: uint256):
    assert _stock > 0
    assert price > 0
    assert _discount > 0
    self.seller = msg.sender
    self.stock = _stock
    self.value = price
    self.discount = _discount
    self.start = block.timestamp + _star
    self.end = self.start + _end

@internal
def _started()->bool:
    return block.timestamp < self.end and block.timestamp > self.start    

@external
@payable
def sell():
    assert self.stock > 0
    precio: uint256 = self.value
    if self._started():
        precio = self.discount
      
    assert msg.value >= precio
    cantidad: uint256 = msg.value / precio
    assert self.stock > cantidad
    self.stock -= cantidad
    send(self.seller,cantidad*precio)


        
@view
@external
def cash() -> uint256:
    return self.balance



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
#lista con en la que a cada direccion le asignan una cantidad de stock
listsold: HashMap[address, uint256]


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
    

@external
@payable
def sell():
    assert self.stock > 0
    precio: uint256 = self.value
    if block.timestamp < self.end and block.timestamp > self.start:
        precio = self.discount
      
    assert msg.value >= precio
    cantidad: uint256 = msg.value / precio
    assert self.stock > cantidad
    self.listsold[msg.sender]= cantidad
    self.stock -= cantidad
    send(self.seller,cantidad*precio)
    if cantidad*precio < msg.value:
        send(msg.sender,msg.value-(cantidad*precio))

        
@view
@external
def cash() -> uint256:
    return self.balance

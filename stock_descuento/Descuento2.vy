"""
Hay un stock de producto que se rebaja durante un determinado 
periodo de tiempo.
1. El vendedor inicializa el contrato con los valores iniciales
2. El comprador compra producto.

Ligera variación con respecto a Descuento1.
En este caso en vez de comprobar en la función de compra si es el tiempo con 
descuento, se ha creado una funcion interna.

"""

#Precio inicial del producto
precio: public(uint256)
#Precio del producto descontado
pdescuento:public(uint256)
#Direccion del vendedor
vendedor: public(address)
#Inicio y fin de la oferta
inicio: public(uint256)
fin :public(uint256)
#Stock para vender
stock:public(uint256)

#Constructor del contrato
@external
def __init__(_stock: uint256,_precio: uint256 ,_inicio: uint256 ,_duracion: uint256 ,_pdescuento: uint256):
    assert _stock > 0
    assert _precio > 0
    assert _pdescuento > 0
    self.vendedor = msg.sender
    self.stock = _stock
    self.precio = _precio
    self.pdescuento = _pdescuento
    self.inicio = block.timestamp + _inicio
    self.fin = self.inicio + _duracion

#Funcion interna que devuelve un booleano. Este es cierto si esta en el tiempo 
#de descuento y falso en el caso contrario.
@internal
def _tiempodescuento()-> bool:
    return block.timestamp < self.fin and block.timestamp > self.inicio    

#Función para comprar los articulos del vendedor
@external
@payable
def comprar():
    #Comprobamos que no se haya terminado el producto, en tal caso saldria de la funcion.
    assert self.stock > 0
    #Asignamos el precio que tiene en este momento el articulo, el inicial o, si esta en el tiempo de descuento, el precio rebajado.
    precio: uint256 = self.precio
    if self._tiempodescuento():
        precio = self.pdescuento
    #Si el valor del mensaje no es mayor que el precio se revierte la transaccion.
    assert msg.value >= precio
    cantidad: uint256 = msg.value / precio
    #Si la cantidad pedida por el cliente es mayor que el stock que hay se revierte la transaccion
    assert self.stock > cantidad
    self.stock -= cantidad
    #Se envia al vendedor el dinero total del pedido
    send(self.vendedor, cantidad * precio)


#Funcion que destruye el contrato cuando el vendedor lo pide.
#Comprueba de que quien invoca la función sea el vendedor.
@external
def terminar():
    assert msg.sender == self.vendedor
    selfdestruct(self.vendedor)
    



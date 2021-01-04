# @version ^0.2.8
#Devolucion de parte del ether si el producto no llega a tiempo
#Variacion: En vez de pagar en la construccion del contrato el vendedor, recibe el total menos el descuento
#y el descuento le recibe, si llega a tiempo, cuando el vendedor recibe el articulo.
#Creamos el evento Devolucion para que quede registrado el ether que se devolvio
event Devolucion:
    emisor: indexed(address)
    receptor: indexed(address)
    devolver: uint256
    
#Creamos el evento Compra para que quede registrado el ether que se pagó
event Compra:
    comprador:indexed(address)
    vendedor: indexed(address)
    valor: uint256

#Variables que inicializa la empresa/vendedor
#Direccion de la empresa/vendedor
empresa: public(address)
#precio del producto
precio: public(uint256)
#Ether que se ofrece a pagar la empresa si no llega en la fecha indicada
devolver: public(uint256)
#Tiempo máximo que da la empresa para recibir el paquete
tiempo_envio: public(uint256)

#Tiempo que queda para recibir el paquete
tiempo_recibir: public(uint256)

#Variables que modifica e inicializa el comprador
comprador: public(address)

#Booleano para saber si se ha comprado el prodcto
comprado: public(bool)

#Constructor del contrato
@external
def __init__(_precio: uint256,_devolver: uint256,_tiempo_envio: uint256):
    #No se crea el contrato si el precio es 0, y si el ether a devover no es mayor que 0
    assert _precio > 0
    assert _devolver > 0
    self.empresa = msg.sender
    self.precio = _precio
    self.devolver =_devolver
    self.tiempo_envio = _tiempo_envio

#Funcion para comprar el producto   
@payable
@external
def comprar():
    assert not self.comprado,"No se ha comprado"
    #No se compra si el valor del mensaje es distinto del precio
    assert msg.value == self.precio,"Precio exacto"
    self.comprador = msg.sender
    #Queda registrada la compra aunque no se le envie 100% del ether al vendedor
    log Compra(msg.sender,self.empresa,self.precio)
    send(self.empresa, self.precio - self.devolver)
    self.comprado = True
    self.tiempo_recibir = block.timestamp + self.tiempo_envio

#Funcion que utiliza el comprador cuando ha recibido el producto
#Hace que el ether restante vaya el vendedor, si ha llegado a tiempo
#o regrese al comprador
@external
def frecibido():
    #Solo el comprador la puede usar
    assert msg.sender == self.comprador,"Comprador"
    #Comprueba si ha llegado a tiempo
    #Si no ha llegado se registra la devolucion de la parte correspondiente al comprador
    #y se destruye el contrato enviando el ether que habia al comprador
    persona: address= self.empresa
    if self.tiempo_recibir < block.timestamp:
        log Devolucion(self.empresa,self.comprador,self.devolver)
        persona = self.comprador
    #En caso contrario, se registra la devolucion con 0 y se destruye el contrato
    #enviando el ether a la empresa
    else:
        log Devolucion(self.empresa,self.comprador,0)
      
    selfdestruct(persona)
    
    
    

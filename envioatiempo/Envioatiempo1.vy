#Devolucion de parte del ether si el producto no llega a tiempo
#Variacion: el vendedor recibe el 100% del precio, 
#pero paga previamente el ether que se devolvería

#Creamos el evento Devolucion para que quede registrado el ether que se devolvio
event Devolucion:
    emisor: indexed(address)
    receptor: indexed(address)
    dinero: uint256
    
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
#Tiempo máximo de envio que da la empresa para recibir el paquete
tiempo_envio: public(uint256)

#Tiempo maximo para recibir el paquete
tiempo_recibir: public(uint256)

#Variables que modifica e inicializa el comprador
recibido: public(bool)
comprador: public(address)

#Constructor del contrato
#La empresa paga el ether que va a devolver
@payable
@external
def __init__(_precio: uint256,_tiempo_envio: uint256):
    #No se crea el contrato si el precio es 0, y si el ether enviado no es mayor que 0
    assert _precio > 0
    assert msg.value > 0
    self.empresa = msg.sender
    self.precio = _precio
    self.devolver = msg.value
    self.tiempo_envio = _tiempo_envio

#Funcion para comprar el producto   
@payable
@external
def comprar():
    #No se compra si el valor del mensaje es distinto del precio
    assert msg.value == self.precio
    self.comprador = msg.sender
    #Queda registrada la compra 
    log Compra(msg.sender,self.empresa,self.precio)
    send(self.empresa, self.precio)
    self.tiempo_recibir = block.timestamp + self.tiempo_envio

#Funcion que utiliza el comprador cuando ha recibido el producto
#Hace que el ether restante vaya al vendedor, si ha llegado a tiempo
#o regrese al comprador
@external
def frecibido():
    #Si se ha recibido no se puede volver a llamar
    assert not self.recibido
    #Solo el comprador la puede usar
    assert msg.sender == self.comprador
    self.recibido = True
    #Comprueba si ha llegado a tiempo
    #Si no ha llegado se registra la devolucion de la parte correspondiente al comprador
    #y se destruye el contrato enviando el ehter que habia al comprador
    persona: address= self.empresa
    if self.tiempo_recibir < block.timestamp:
        log Devolucion(self.empresa,self.comprador,self.devolver)
        persona = self.comprador
    #En caso contrario, se registra la devolucion con 0 y se destruye el contrato
    #enviando el ether a la empresa
    else:
        log Devolucion(self.empresa,self.comprador,0)
      
    selfdestruct(persona)

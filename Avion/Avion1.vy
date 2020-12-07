#Contrato para devolver parte del dinero del billete del aviÃ³n si este no sale a tiempo

#Creamos un evento para que quede registrado la devolucion del importe
event Devolucion:
    emisor: indexed(address)
    receptor: indexed(address)
    value: uint256

#Creamos un evento para que quede registrado la compra del billete    
event Compra:
    comprador:indexed(address)
    vendedor: indexed(address)
    valor: uint256

#Variables que se inicializan al crear el contrato
#Direccion de la aerolinea
aerolinea: public(address)
#Precio por billete
precio: public(uint256)
#Porcentaje a devolver por la aerolinea
porc_a_devolver: public(decimal)
#Tiempo previsto de salida del avion
tiempo_salida: public(uint256)
#Tiempo real de salida del avion
tiempo_reals: public(uint256)
#Asientos del avion
asientos: public(uint256)


salido: public(bool)
#Lista con los clientes
clientes: public(HashMap[uint256,address])
indice: uint256
indice2: uint256
#Ether a devolver
dinero: uint256
#booleano para saber si se le ha devuelto a todos los clientes el porcentaje.
terminado: bool

#Constructor del contrato
@external
def __init__(_asientos: uint256,_precio: uint256,_porc_a_devolver: decimal,_tiempo_salida: uint256):
    #El contrato se crea si hay asientos, si el precio del billete es mayor que 0
    #y si el porcentaje esta entre 0 y 100
    assert _asientos > 0
    assert _precio > 0
    assert _porc_a_devolver > 0.0
    assert _porc_a_devolver <= 100.0
    self.asientos = _asientos
    self.aerolinea = msg.sender
    self.precio = _precio
    self.porc_a_devolver =_porc_a_devolver
    self.tiempo_salida = _tiempo_salida

#Funcion del contrato para comprar billetes, como mucho se puden comprar 3 a la vez
#Se accede a esta funcion y no se revierte si la cantidad solicitada esta entre 0 y
#4, si hay asientos para la cantidad solicitada y si el ether enviado es mayor o 
#igual que el valor de los billete 
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
    log Compra(msg.sender,self.aerolinea,msg.value)
    self.asientos -= cantidad


#Funcion que se realiza si la direccion que la llama es la de la aerolinea
#y si el viaje aun no ha salido
@external
def asalido():
    assert not self.salido
    assert msg.sender == self.aerolinea
    self.salido = True
    self.tiempo_reals = block.timestamp
    if self.tiempo_salida > block.timestamp:
        cambio: decimal = convert(self.tiempo_reals - self.tiempo_salida ,decimal)
        self.dinero = convert((cambio * self.porc_a_devolver)/100.0,uint256)
    
#Funcion para devolver el dinero a los clientes si el viaje ha salido y no a tiempo             
@external
def devolucionalosclientes():
    assert self.salido
    if (self.tiempo_salida <= self.tiempo_reals):
        self.terminado = True
    else:
        
        index: uint256 = self.indice2
        for i in range(index,index+20):
            if i > self.indice:
                index = self.indice
                self.terminado = True
                return
            log Devolucion(self.aerolinea,self.clientes[i],self.dinero)
            send(self.clientes[i],self.dinero)
            
        self.indice2= index + 20
#Solo se puede acceder a esta funcion si el viaje ha salido a tiempo o se le ha devuelto el porcentaje a cada cliente    
@external
def cobroempresa():
    assert self.terminado
    selfdestruct(self.aerolinea)

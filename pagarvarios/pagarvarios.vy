#Pagar una cuenta entre varias personas

#Variable spara saber la direccion de la empresa y el precio del producto/cuenta
empresa: public(address)
precio:uint256
#Booleano para saber si se ha pagado en su totalidad el producto/cuenta
pagado: bool
#Un diccionario en el que se asigna lo que ha pagado cada persona
yapagado: public(HashMap[address,uint256])

#Constructor del contrato, en el que se establecen la direccion de la empresa y el precio a pagar
@external
def __init__(_precio: uint256):
    self.empresa = msg.sender
    self.precio = _precio

#Funcion para pagar entre varios una cuenta, despues de pagarla se da el servicio
@payable
@external
def pagar(empresa: address):
    assert self.empresa == empresa
    if self.yapagado[msg.sender] == 1:
        self.yapagado[msg.sender] = msg.value
    else:
        self.yapagado[msg.sender] += msg.value
        
    self.precio -= msg.value
    if self.precio == 0:
        self.pagado= True

#Se ha recibido o se ha realizado el servicio requerido       
@external
def producto():
    assert self.pagado
    assert self.yapagado[msg.sender] != 1
    selfdestruct(self.empresa)

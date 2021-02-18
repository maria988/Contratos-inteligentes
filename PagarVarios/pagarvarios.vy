# @version ^0.2.8
#Pagar una cuenta entre varias personas

#Variable spara saber la direccion de la empresa y el precio del producto/cuenta
#No se devuelve el importe

empresa: public(address)
precio: public(uint256)
#Booleano para saber si se ha pagado en su totalidad el producto/cuenta
pagado: public(bool)
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
    assert self.empresa == empresa,"Empresa"
    assert msg.sender != self.empresa,"Cliente"
    if msg.value < self.precio:
        self.yapagado[msg.sender] += msg.value
        self.precio -= msg.value
    else:
        self.yapagado[msg.sender] += self.precio
        if msg.value > self.precio:
            send(msg.sender, msg.value - self.precio)
        self.precio = 0
        self.pagado= True

#Se ha recibido o se ha realizado el servicio requerido       
@external
def producto():
    assert self.pagado,"Pagado"
    assert self.yapagado[msg.sender] != 0,"Ha pagado"
    selfdestruct(self.empresa)

#Autoservicio :D
# @version ^0.2.8
#Estructura para guardar el nombre,los ingredientes y el precio del plato
struct Comida:
    nombre : String[10]
    descripcion : String[30]
    precio: uint256


    
#Variable para almacenar la direccion de la empresa
empresa: public(address)
#Diccionario para asignar a cada numero un plato
carta : public(HashMap[uint256,Comida])
#variables para añadir un nuevo plato o quitarle
indice : uint256
indice_libre:HashMap[uint256,uint256]
indicelibre : uint256
indiceborrar: uint256
#Variable para almacenar la comanda de lo pedido
comanda:HashMap[String[10],uint256]
#Tiempo para pagar
tiempo_pago: public(uint256)
#Limite de tiempo para pagar
tiempo_tope: uint256
#Variable para acumular el valor de los platos pedidos
preciototal: uint256
#Direccion del cliente
cliente:public(address)
#Booleano para saber si seha pagado la cuenta o no
pagado : bool

#Constructora del contrato, se inicia con un plato
@external
def __init__(plato: String[10],ingredientes:String[30],_precio:uint256,tiempopago: uint256):
    self.empresa = msg.sender
    self.tiempo_pago = tiempopago
    self.carta[self.indice]=Comida({nombre:plato,descripcion:ingredientes,precio:_precio})
    self.indice += 1
    self.indicelibre = 0
    self.preciototal = 0

#Funcion para añadir un nuevo plato, toma de argumentos el nombre, la descripcion y el precio
@external
def anadir_plato(plato: String[10],ingredientes:String[30],_precio:uint256):
    assert msg.sender == self.empresa,"Empresa"
    if self.indicelibre > 0:
        self.carta[self.indice_libre[self.indicelibre]] = Comida({nombre:plato,descripcion:ingredientes,precio:_precio})
        self.indicelibre -= 1
    else:
        self.carta[self.indice]=Comida({nombre:plato,descripcion:ingredientes,precio:_precio})
        self.indice += 1

#Funcion para quitar un plato, toma como argumento el numeor asociado al plato
@external
def quitar_plato(numero: uint256):
    assert numero < self.indice,"Numero correcto"
    assert msg.sender == self.empresa,"Empresa"
    self.carta[numero] = empty(Comida)
    self.indice_libre[self.indicelibre] = numero
    self.indicelibre += 1
    
#Funcion para pedir, se va almacenando el pedido
@external
def pedir(numero: uint256, terminado: bool):
    plato:String[10] = self.carta[numero].nombre
    self.comanda[plato] += 1
    self.preciototal += self.carta[numero].precio
    if terminado:
        self.cliente = msg.sender
        self.tiempo_tope = block.timestamp + self.tiempo_pago
        
#Funcion para pagar la cuenta, si se supera el tiempo de espera se borra la comanda    
@payable
@external
def pagarcuenta():
    assert self.cliente == msg.sender,"Cliente"
    assert msg.value == self.preciototal,"Precio"
    if block.timestamp < self.tiempo_tope:
        send(self.empresa,msg.value)
        self.pagado = True
    else:
        tope:uint256 = self.indiceborrar
        for i in range(tope,tope+20):
            if i > self.indice:
                return
            else:
                self.comanda[self.carta[i].nombre] = 0   
        self.indiceborrar = tope +20
            
#Funcion para quitar la comanda en el caso de que no pague el cliente
@external
def quitarcomanda():
    assert self.empresa == msg.sender,"Empresa"
    assert not self.pagado,"Sin pagar"
    assert block.timestamp > self.tiempo_tope
    tope:uint256 = self.indiceborrar
    for i in range(tope,tope+20):
        if i > self.indice:
            return
        else:
            self.comanda[self.carta[i].nombre] = 0   
    self.indiceborrar = tope +20
    
#Funcion para consultar el nombre del plato, la descripcion y el precio del mismo
@view
@external
def consultar(numero: uint256)->Comida:
    assert numero < self.indice
    comida:Comida = Comida({nombre:self.carta[numero].nombre,descripcion:self.carta[numero].descripcion,precio:self.carta[numero].precio})
    return comida

#Funcion para consultar el precio de cada plato
@view
@external
def consultarprecio()->uint256:
    assert self.cliente == msg.sender
    return self.preciototal

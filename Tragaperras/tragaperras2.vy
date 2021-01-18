# @version ^0.2.8
#Las maquinas tragaperras reparten el beneficio x -y
#x para los dueños de la maquina e y para el dueño del local

#Creamos un evento para que quede registrado si gana o no y lo que se gana
event Partida:
    jugador:indexed(address)
    texto:String[13]
    premio:uint256    

#Los beneficiarios
socio: public(address)
empresa: public(address)

#El porcentaje de premio que hay, varia
premio: public(uint256)


#precio de cada jugada
precio : public(uint256)

#Porcentaje de beneficios que se lleva el dueño de la maquina, el del local y porcentaje que se queda en la maquina
benef_maquina : public(uint256)
benef_local : public(uint256)
porc_maq: public(uint256)

cliente: address
jugando: public(bool)
acumulado: uint256
#Construccion del contrato
@payable
@external
def __init__(_socio: address,_premio: uint256, _precio: uint256, _benmaq: uint256,_benloc : uint256,_porc_maq: uint256):
    assert _benmaq + _benloc + _porc_maq == 100
    assert _benmaq > 0 and _benloc > 0 and _porc_maq > 0
    assert (_premio > 0) and (_premio < 100)
    assert _precio > 0
    assert msg.value > 0
    self.socio = _socio
    self.empresa = msg.sender
    self.premio = _premio
    self.precio = _precio
    self.benef_maquina = _benmaq
    self.benef_local = _benloc
    self.porc_maq = _porc_maq
    self.acumulado = msg.value

#Funcion para "jugar" se almacena la moneda y
#si se ha tenido suerte devuelve un porcentaje de lo que tiene
#en el caso contrario se va acumulando el ether
@payable
@external
def echarmoneda():
    assert msg.value == self.precio,"Precio exacto"
    assert not self.jugando,"No jugando"
    self.cliente = msg.sender
    self.jugando = True   
    self.acumulado += msg.value

#Funcion que es llamada por la empresa para saber si se ha ganado o no
@external
def ganado(ha_ganado : bool):
    assert self.empresa == msg.sender,"Empresa"
    assert  self.jugando,"Jugando"
    if ha_ganado:
        cantidad : uint256 = self.premio * self.acumulado/100
        log Partida(self.cliente,"Ha ganado",cantidad)
        send(self.cliente,cantidad)
        self.acumulado -= cantidad
    else:
        log Partida(self.cliente,"Sigue jugando",0)
    self.jugando = False

#Funcion para repartir el ether recaudado
#Se reparte segun los porcentajes iniciales
@external
def sacardinero():
    assert msg.sender == self.empresa,"Empresa"
    send(self.socio,self.balance*self.benef_local/100)
    send(self.empresa,self.balance*self.benef_maquina/100)

#Funcion para cambiar los porcentajes de los premios 
@external
def cambiarpremio(_premio: uint256):
    assert msg.sender == self.empresa,"Empresa"
    assert _premio != self.premio,"Distinto premio"
    self.premio = _premio

#Funcion que devuelve el premio que se puede conseguir si se juega  
@view
@external
def funpremio()-> uint256:
    return self.premio*self.balance/100

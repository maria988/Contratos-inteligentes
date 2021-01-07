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
premio1: public(uint256)
premio2: public(uint256)
#variable que indice cuando sale el premio
n_veces: public(uint256)
#variables para cambiar el numero de juego
variacion1 :public(uint256)
variacion2 : public(uint256)
#precio de cada jugada
precio : public(uint256)

#Contrador para saber las jugadas hechas
ind_v: uint256

#Porcentaje de beneficios que se lleva el dueño de la maquina, el del local y porcentaje que se queda en la maquina
benef_maquina : public(uint256)
benef_local : public(uint256)
porc_maq: public(uint256)

#Construccion del contrato
@external
def __init__(_socio: address,_p1: uint256,_p2: uint256, _n_veces: uint256,_v1 :uint256,_v2: uint256,_precio: uint256, _benmaq: uint256,_benloc : uint256,_porc_maq: uint256):
    assert _benmaq + _benloc + _porc_maq == 100
    assert _benmaq > 0 and _benloc > 0 and _porc_maq > 0
    assert (_p1 > 0) and (_p1 < 100)
    assert (_p2 > 0) and (_p2 < 100)
    assert _v1 > 0
    assert _v2 > 0
    assert _precio > 0
    assert _n_veces > 0
    self.socio = _socio
    self.empresa = msg.sender
    self.premio1 = _p1
    self.premio2 = _p2
    self.n_veces = _n_veces
    self.variacion1 = _v1
    self.variacion2 = _v2
    self.precio = _precio
    self.benef_maquina = _benmaq
    self.benef_local = _benloc
    self.porc_maq = _porc_maq

#Funcion para "jugar" se almacena la moneda y
#si se ha tenido suerte devuelve un porcentaje de lo que tiene
#en el caso contrario se va acumulando el ether
@payable
@external
def echarmoneda():
    assert msg.value == self.precio,"Precio exacto"
    self.ind_v+= 1
    if self.ind_v == self.n_veces:
        log Partida(msg.sender,"Ha ganado",self.premio1*self.balance/100)
        send(msg.sender,self.premio1*self.balance/100)
        self.n_veces = self.variacion1
        self.ind_v= 0
        i: uint256 = self.variacion1
        self.variacion1 = self.variacion2
        self.variacion2 = i
        i = self.premio1
        self.premio1 = self.premio2
        self.premio2 = i
    else:
        log Partida(msg.sender,"Sigue jugando",0)

#Funcion para repartir el ether recaudado
#Se reparte segun los porcentajes iniciales
@external
def sacardinero():
    assert msg.sender == self.empresa,"Empresa"
    send(self.socio,self.balance*self.benef_local/100)
    send(self.empresa,self.balance*self.benef_maquina/100)

#Funcion para cambiar los porcentajes de los premios 
@external
def cambiarpremio(_p1: uint256, _p2:uint256):
    assert msg.sender == self.empresa,"Empresa"
    assert _p1 != self.premio1 and _p2 != self.premio2,"Distintos premios"
    self.premio1 = _p1
    self.premio2 = _p2

#Funcion para cambiar las variaciones del numero en el que sale el premio    
@external
def cambiarvariaciones(_v1: uint256,_v2: uint256):
    assert msg.sender == self.empresa,"Empresa"
    assert _v1 != self.variacion1 and _v2 != self.variacion2,"Distintas variaciones"
    self.variacion1 = _v1
    self.variacion2 = _v2

#Funcion que devuelve el premio que se puede conseguir si se juega  
@view
@external
def premio()-> uint256:
    return self.premio1*self.balance/100

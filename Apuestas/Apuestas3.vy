#Apostar en un partido mas completo que #1 y #2
#Creamos una estructura para almacenar las apuestas en un diccionario
struct Juego:
    apostador: address
    equipo1: uint256
    equipo2: uint256
    apuesta: uint256
 
#Variables definidas inicialmente
casa:public(address)
inicial:uint256
empieza:public(uint256)
termina: public(uint256)

#Variable para almacenar los puntos de cada equipo
pequipo1: uint256
pequipo2: uint256

#Variables para los indices del diccionario y el diccionario
indice : uint256
apostadores: HashMap[uint256, Juego]
sigindice : uint256

#Variables para saber si la casa ha mandado el ether necesario y si se le ha devuelto el dinero a todos
invertido: bool
todos: bool



#Constructor del contrato, primero comprueba que el tiempo_inicio es mayor que 0
#y que el ether enviado por la casa de apuestas se mayor que cero.
@payable
@external    
def __init__( tiempo_inicio: uint256,duracion: uint256):
    assert tiempo_inicio > 0
    assert duracion > 0 
    self.inicial = msg.value
    self.casa = msg.sender
    self.empieza = block.timestamp + tiempo_inicio
    self.termina = self.empieza + duracion
 
#Funcion externa para que cada jugador apueste.
#Como entrada la funcion recibe dos argumentos, que son los puntos de cada equipo.           
@external
@payable
def apostar(eq1: uint256,eq2: uint256):
    assert not block.timestamp >self.empieza
    assert msg.sender != self.casa
    assert msg.value > 0 
    nfi: uint256 = self.indice
    self.apostadores[nfi] = Juego({apostador: msg.sender,equipo1: eq1, equipo2:eq2,apuesta:msg.value})
    self.indice = nfi + 1

#Funcion a la que solo puede acceder la casa para saber el ether que tiene que introducir
@view
@external
def necesario()-> uint256:
    assert msg.sender == self.casa
    return (self.balance - self.inicial) / 2

#Funcion para que la casa de apuestas introducza la mitad de ether del ether recibido.
#Se puede acceder a el cuando el partido haya empezado puesto que ya no se puede apostar.
@payable
@external
def mitad():
    assert block.timestamp > self.empieza
    assert self.casa == msg.sender
    assert msg.value + self.inicial  >= (self.balance - self.inicial - msg.value) / 2
    self.invertido = True
    

#Funcion dar a los apostantes el ether ganado
@external
def devolver():
    assert block.timestamp > self.termina
    assert self.casa == msg.sender
    assert self.invertido
    nive:uint256 = self.sigindice
    for i in range (nive,nive+30):
        if i > self.indice:
            nive = self.indice
            self.todos = True
            return
        else:
            if (self.apostadores[i].equipo1 == self.pequipo1) and (self.apostadores[i].equipo2 == self.pequipo2):
                send(self.apostadores[i].apostador,self.apostadores[i].apuesta + (self.apostadores[i].apuesta/2) )
                
            self.apostadores[i]= empty(Juego)
    self.sigindice = nive + 30

#Funcion para asignar a las variables globales la puntuacion de cada equipo
@external
def ganadores(_eq1: uint256, _eq2: uint256):
    assert msg.sender == self.casa
    assert block.timestamp > self.termina
    assert _eq1 >= 0 and _eq2 >= 0
    self.pequipo1 = _eq1
    self.pequipo2 = _eq2
    
#Funcion externa que devulve un booleano para saber si ha terminado el partido
@view
@external
def terminado()-> bool:
    return block.timestamp > self.termina

#Funcion externa que devulve un booleano para saber si ha empezado el partido
@view
@external
def empezado() -> bool:
    return block.timestamp >self.empieza

#Funcion externa que devuelve un uint256, que es el ether ganado
@view
@external
def ganar(apos:Juego)-> uint256:
    assert block.timestamp > self.termina
    if (apos.equipo1 == self.pequipo1) and (apos.equipo2 == self.pequipo2):
        return apos.apuesta + (apos.apuesta/2) 
    else:
        return 0

#Funcion externa que devuelve un booleano para saber si se ha acertado con la jugada o no
@view
@external
def ganado(apos: Juego)-> bool:
    return (apos.equipo1 == self.pequipo1) and (apos.equipo2 == self.pequipo2)

#Cuando se devuelva todo el dinero, se destruye el contrato y el dinero que hubiese va a la casa    
@external
def finalizacion():
    assert self.todos
    selfdestruct(self.casa)

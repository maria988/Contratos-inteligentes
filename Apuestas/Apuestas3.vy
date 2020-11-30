#Apostar en un partido de futbol con cambios
struct Bet:
    apostador: address
    equipo1: uint256
    equipo2: uint256
    apuesta: uint256
    
casa:public(address)

cequipo1: uint256
cequipo2: uint256
hstart:public(uint256)
hend: public(uint256)
ni : uint256
apostadores: HashMap[uint256, Bet]
niv : uint256
invertido: bool
todos: bool
inicial:uint256
invertido_total: uint256
@payable
@external    
def __init__( tiempo_inicio: uint256,duracion: uint256):
    assert tiempo_inicio > 0
    assert duracion > 0 
    self.inicial = msg.value
    self.casa = msg.sender
    self.hstart = block.timestamp + tiempo_inicio
    self.hend = self.hstart + duracion
 
   
@external
@payable
def bet(eq1: uint256,eq2: uint256):
    assert not block.timestamp >self.hstart
    assert msg.sender != self.casa
    assert msg.value > 0 
    nfi: uint256 = self.ni
    self.apostadores[nfi] = Bet({apostador: msg.sender,equipo1: eq1, equipo2:eq2,apuesta:msg.value})
    self.ni = nfi + 1

@payable
@external
def mitad():
    assert block.timestamp >self.hstart
    assert self.casa == msg.sender
    self.invertido_total = msg.value + self.inicial
    assert self.invertido_total  >= (self.balance - self.inicial - msg.value) / 2
    self.invertido = True
    


@external
def devolver():
    assert block.timestamp > self.hend
    assert self.casa == msg.sender
    assert self.invertido
    nive:uint256 = self.niv
    for i in range (nive,nive+30):
        if i > self.ni:
            nive = self.ni
            self.todos = True
            return
        else:
            if (self.apostadores[i].equipo1 == self.cequipo1) and (self.apostadores[i].equipo2 == self.cequipo2):
                send(self.apostadores[i].apostador,self.apostadores[i].apuesta + (self.apostadores[i].apuesta/2) )
                
            self.apostadores[i]= empty(Bet)
    self.niv = nive + 30

@external
def ganadores(_eq1: uint256, _eq2: uint256):
    assert msg.sender == self.casa
    assert block.timestamp > self.hend
    assert _eq1 >= 0 and _eq2 >= 0
    self.cequipo1 = _eq1
    self.cequipo2 = _eq2
    
@view
@external
def terminado()-> bool:
    return block.timestamp > self.hend

@view
@external
def empezado() -> bool:
    return block.timestamp >self.hstart

@view
@external
def ganar(apos:Bet)-> uint256:
    assert block.timestamp > self.hend
    if (apos.equipo1 == self.cequipo1) and (apos.equipo2 == self.cequipo2):
        return apos.apuesta + (apos.apuesta/2) 
    else:
        return 0

@view
@external
def ganado(apos: Bet)-> bool:
    return (apos.equipo1 == self.cequipo1) and (apos.equipo2 == self.cequipo2)

@external
def finalizacion():
    assert self.todos
    selfdestruct(self.casa)
